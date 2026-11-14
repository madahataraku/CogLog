#!/usr/bin/env python3
"""Export CogLog-contract TFLite FLOAT32 from an SSCMA Swift-YOLO .pth.

Uses the same NHWC + score÷100 wrapper as convert_coreml.py.
SSCMA ``tools/export.py`` only emits INT8; do not use it for the Android asset.
"""

from __future__ import annotations

import argparse
import hashlib
import shutil
import sys
import tempfile
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from sscma_seven_seg_export_common import build_nhwc_seven_seg  # noqa: E402


def _die(message: str, code: int = 1) -> int:
    print(message, file=sys.stderr)
    return code


def _export_via_onnx2tf(wrapped, dummy, out_tflite: Path) -> None:
    import numpy as np
    import tensorflow as tf
    import torch
    from onnx2tf import onnx2tf

    out_tflite.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        onnx_path = tmp_path / "seven_seg_192.onnx"
        torch.onnx.export(
            wrapped,
            dummy,
            str(onnx_path),
            input_names=["input"],
            output_names=["output"],
            opset_version=17,
            dynamo=False,
        )
        try:
            import onnx
            import onnxsim

            simplified, ok = onnxsim.simplify(onnx.load(str(onnx_path)))
            if ok:
                onnx.save(simplified, str(onnx_path))
        except Exception as exc:  # noqa: BLE001
            print(f"Warning: onnxsim skipped ({exc})")

        out_dir = tmp_path / "onnx2tf_out"
        out_dir.mkdir(parents=True, exist_ok=True)
        convert_kwargs = dict(
            output_folder_path=str(out_dir),
            batch_size=1,
            output_signaturedefs=True,
            verbosity="warn",
            output_integer_quantized_tflite=False,
        )
        # Keep ONNX NHWC input [1,192,192,3] (CogLog Dart contract).
        # Older onnx2tf may lack this kwarg — fail closed if unsupported.
        try:
            onnx2tf.convert(
                str(onnx_path),
                keep_shape_absolutely_input_names=["input"],
                **convert_kwargs,
            )
        except TypeError:
            onnx2tf.convert(str(onnx_path), **convert_kwargs)
        candidates = sorted(out_dir.glob("*float32*.tflite"))
        if not candidates:
            candidates = sorted(out_dir.glob("*.tflite"))
        if not candidates:
            raise RuntimeError(f"onnx2tf produced no .tflite under {out_dir}")
        # Prefer names that look float32; reject int8 artifacts if mixed.
        float_like = [p for p in candidates if "int8" not in p.name.lower()]
        chosen = float_like[0] if float_like else candidates[0]
        if "int8" in chosen.name.lower():
            raise RuntimeError(f"Only INT8 TFLite found: {chosen}")
        shutil.copy2(chosen, out_tflite)

    interpreter = tf.lite.Interpreter(model_path=str(out_tflite))
    interpreter.allocate_tensors()
    inp = interpreter.get_input_details()[0]
    out = interpreter.get_output_details()[0]
    if inp["dtype"] != np.float32 or out["dtype"] != np.float32:
        raise RuntimeError(
            f"Expected float32 TFLite, got input={inp['dtype']} output={out['dtype']}"
        )
    inp_shape = tuple(int(x) for x in inp["shape"])
    if inp_shape != (1, 192, 192, 3):
        raise RuntimeError(
            f"Unexpected TFLite input shape {inp_shape}; expected (1, 192, 192, 3). "
            "onnx2tf likely transposed NHWC→NCHW; upgrade onnx2tf or set "
            "keep_shape_absolutely_input_names."
        )
    print(f"input shape={list(inp['shape'])} dtype={inp['dtype']}")
    print(f"output shape={list(out['shape'])} dtype={out['dtype']}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--weights", type=Path, required=True)
    parser.add_argument("--sscma-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    if not args.weights.is_file():
        return _die(f"Weights not found: {args.weights}")
    if not args.sscma_root.is_dir():
        return _die(f"--sscma-root not a directory: {args.sscma_root}")

    try:
        wrapped, probed, dummy = build_nhwc_seven_seg(
            args.sscma_root.resolve(), args.weights.resolve()
        )
        print(f"Probe output shape: {tuple(probed.shape)}")
        _export_via_onnx2tf(wrapped, dummy, args.output.resolve())
    except (RuntimeError, FileNotFoundError, ValueError, ImportError) as exc:
        return _die(str(exc))

    data = args.output.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    print(f"Saved: {args.output}")
    print(f"Bytes: {len(data)}")
    print(f"SHA-256: {digest}")
    print("Update assets NOTICE.md Android section with bytes / sha256.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
