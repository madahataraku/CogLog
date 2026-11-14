#!/usr/bin/env python3
"""Convert SSCMA Digital Meter Electricity .pth to Core ML mlpackage.

Requires macOS: coremltools mlprogram save needs native BlobWriter.
See convert_coreml.md for the full procedure and Linux limitation.
"""

from __future__ import annotations

import argparse
import hashlib
import platform
import subprocess
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from sscma_seven_seg_export_common import build_nhwc_seven_seg  # noqa: E402


def _die(message: str, code: int = 1) -> int:
    print(message, file=sys.stderr)
    return code


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Convert Digital Meter Electricity .pth to "
            "DigitalMeterElectricity192.mlpackage (macOS required)."
        )
    )
    parser.add_argument("--weights", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--sscma-root",
        type=Path,
        default=None,
        help="Path to Seeed-Studio/ModelAssistant checkout (adds to sys.path).",
    )
    parser.add_argument(
        "--deepen-factor-mode",
        choices=("auto", "on", "off"),
        default="auto",
        help=(
            "auto: try zoo patch then unpatched; "
            "on: Seeed zoo weights; "
            "off: Colab train without deepen patch (this CogLog Colab run)"
        ),
    )
    args = parser.parse_args()

    if args.deepen_factor_mode == "auto":
        script = Path(__file__).resolve()
        last_code = 1
        for mode in ("off", "on"):
            cmd = [
                sys.executable,
                "-u",
                str(script),
                "--weights",
                str(args.weights),
                "--output",
                str(args.output),
                "--sscma-root",
                str(args.sscma_root),
                "--deepen-factor-mode",
                mode,
            ]
            print(f"auto: trying deepen_factor_mode={mode} in subprocess", flush=True)
            last_code = subprocess.call(cmd)
            if last_code == 0:
                return 0
        return last_code

    if platform.system() != "Darwin":
        return _die(
            "Core ML mlpackage save requires macOS (coremltools BlobWriter). "
            "This host is "
            f"{platform.system()}. Follow tool/seven_segment/convert_coreml.md "
            "on a Mac; do not invent a placeholder mlpackage on Linux.",
            code=3,
        )

    try:
        import coremltools as ct
        import torch
        import torch.nn as nn
        # SSCMA mask 構造が roi_align を import する前に、torchvision を完了させる。
        # 不完全／版不一致だと circular import（extension 欠落）になる。
        import torchvision
        from torchvision.ops import roi_align as _roi_align  # noqa: F401
    except ImportError as exc:
        return _die(
            f"Missing dependency: {exc}. "
            "Use Python 3.10 venv and "
            "`pip install --force-reinstall 'torch==2.2.0' "
            "'torchvision==0.17.0' 'numpy<2,>=1.26'`.",
            code=2,
        )
    except AttributeError as exc:
        return _die(
            f"Broken torchvision install ({exc}). "
            "`pip uninstall -y torch torchvision` then "
            "`pip install 'torch==2.2.0' 'torchvision==0.17.0'`. "
            "Confirm: "
            "`python -c \"from torchvision.ops import roi_align; print('ok')\"`.",
            code=2,
        )

    try:
        from coremltools.libmilstoragepython import (  # noqa: F401
            _BlobStorageWriter as _MilBlobWriter,
        )
    except ImportError as exc:
        return _die(
            "coremltools native BlobWriter is missing "
            f"({exc}). On macOS use Python 3.10 venv and "
            "`pip install --only-binary=:all: 'coremltools==7.2' "
            "'torch==2.2.0'`. See tool/seven_segment/convert_coreml.md.",
            code=2,
        )
    if _MilBlobWriter is None:
        return _die(
            "coremltools BlobWriter failed to load. "
            "Reinstall macOS binary wheel of coremltools 7.2 "
            "(Python 3.10). See tool/seven_segment/convert_coreml.md.",
            code=2,
        )

    weights = args.weights
    if not weights.is_file():
        return _die(f"Weights not found: {weights}")

    sscma_root = args.sscma_root
    if sscma_root is None:
        return _die(
            "--sscma-root is required so the Swift-YOLO config can be loaded.",
            code=2,
        )
    if not sscma_root.is_dir():
        return _die(f"--sscma-root not a directory: {sscma_root}")

    print(f"Loading {weights} (deepen_factor_mode={args.deepen_factor_mode}) ...")
    try:
        wrapped, probed, dummy = build_nhwc_seven_seg(
            sscma_root.resolve(),
            weights.resolve(),
            deepen_factor_mode=args.deepen_factor_mode,
        )
    except Exception as exc:  # noqa: BLE001
        return _die(
            f"SSCMA load failed: {exc}. "
            "Clone Seeed-Studio/ModelAssistant and pass --sscma-root. "
            "Also `pip install 'torch==2.2.0' 'torchvision==0.17.0' "
            "'torchaudio==2.2.0' 'numpy<2' pycocotools mmengine six "
            "tqdm albumentations scikit-learn timm`. "
            "Do not `pip install pyarrow` (conflicts with numpy<2). "
            "For Colab-trained weights use --deepen-factor-mode off.",
            code=2,
        )
    if tuple(probed.shape) not in {(1, 2268, 15), (2268, 15)}:
        return _die(f"Unexpected output shape: {tuple(probed.shape)}")

    print("Tracing ...")
    traced = torch.jit.trace(wrapped, dummy)

    input_name = "input"
    output_name = "output"
    print("Converting with coremltools ...")
    try:
        mlmodel = ct.convert(
            traced,
            inputs=[ct.TensorType(name=input_name, shape=dummy.shape)],
            outputs=[ct.TensorType(name=output_name)],
            minimum_deployment_target=ct.target.iOS16,
            convert_to="mlprogram",
        )
    except Exception as exc:  # noqa: BLE001 — surface converter errors
        return _die(f"Conversion failed: {exc}")

    out = args.output
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        if out.is_dir():
            import shutil

            shutil.rmtree(out)
        else:
            out.unlink()
    try:
        mlmodel.save(str(out))
    except Exception as exc:  # noqa: BLE001
        return _die(
            f"mlpackage save failed: {exc}. "
            "On non-macOS this is expected (BlobWriter). "
            "Run on macOS per convert_coreml.md."
        )

    digest = hashlib.sha256()
    total = 0
    for child in sorted(out.rglob("*")):
        if child.is_file():
            data = child.read_bytes()
            digest.update(data)
            total += len(data)

    # Confirm names from the saved model when available.
    try:
        spec = mlmodel.get_spec()
        input_names = [i.name for i in spec.description.input]
        output_names = [o.name for o in spec.description.output]
        if input_names:
            input_name = input_names[0]
        if output_names:
            output_name = output_names[0]
    except Exception:  # noqa: BLE001
        pass

    print(f"Saved: {out}")
    print(f"Input name: {input_name}")
    print(f"Output name: {output_name}")
    print(f"Output shape (probe): {tuple(probed.shape)}")
    print(f"Bytes (tree): {total}")
    print(f"SHA-256 (tree aggregate): {digest.hexdigest()}")
    print(
        "Update SevenSegmentCoreMlRunner.swift and NOTICE.md iOS section "
        "with the names / bytes / sha256 above."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
