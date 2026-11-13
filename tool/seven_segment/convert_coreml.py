#!/usr/bin/env python3
"""Convert SSCMA Digital Meter Electricity .pth to Core ML mlpackage.

Requires macOS: coremltools mlprogram save needs native BlobWriter.
See convert_coreml.md for the full procedure and Linux limitation.
"""

from __future__ import annotations

import argparse
import hashlib
import platform
import sys
from pathlib import Path


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
    args = parser.parse_args()

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
    except ImportError as exc:
        return _die(f"Missing dependency: {exc}", code=2)

    weights = args.weights
    if not weights.is_file():
        return _die(f"Weights not found: {weights}")

    if args.sscma_root is not None:
        root = args.sscma_root.resolve()
        if not root.is_dir():
            return _die(f"--sscma-root not a directory: {root}")
        sys.path.insert(0, str(root))

    try:
        from mmengine.config import Config
        from mmengine.registry import MODELS, init_default_scope

        from sscma.datasets import DetDataPreprocessor  # noqa: F401
        from sscma.models import (  # noqa: F401
            CrossEntropyLoss,
            DetHead,
            YOLOAnchorGenerator,
            YOLODetector,
            YOLOV5Head,
            YOLOv5CSPDarknet,
            YOLOv5IoULoss,
            YOLOv5PAFPN,
        )
    except ImportError as exc:
        return _die(
            f"SSCMA / mmengine import failed: {exc}. "
            "Clone Seeed-Studio/ModelAssistant and pass --sscma-root. "
            "Ensure deepen_factor is applied in YOLOv5CSPDarknet "
            "(make_round(num_blocks, self.deepen_factor)).",
            code=2,
        )

    sscma_root = args.sscma_root
    if sscma_root is None:
        return _die(
            "--sscma-root is required so the Swift-YOLO config can be loaded.",
            code=2,
        )
    config_file = (
        sscma_root / "configs" / "swift_yolo" / "swift_yolo_tiny_1xb16_300e_coco.py"
    )
    if not config_file.is_file():
        return _die(f"Swift-YOLO config not found: {config_file}")

    print(f"Loading {weights} ...")
    try:
        ckpt = torch.load(weights, map_location="cpu", weights_only=False)
    except TypeError:
        ckpt = torch.load(weights, map_location="cpu")
    if not isinstance(ckpt, dict) or "state_dict" not in ckpt:
        return _die("Unsupported checkpoint: expected dict with 'state_dict'")

    # mmengine 0.8.2 の Config.fromfile は modified_constant を受け取らない。
    cfg = Config.fromfile(str(config_file))
    cfg.num_classes = 10
    cfg.height = 192
    cfg.width = 192
    bbox_head = getattr(cfg.model, "bbox_head", None)
    if bbox_head is not None:
        if hasattr(bbox_head, "num_classes"):
            bbox_head.num_classes = 10
        head_module = getattr(bbox_head, "head_module", None)
        if head_module is not None and hasattr(head_module, "num_classes"):
            head_module.num_classes = 10
    cfg.model.backbone.deepen_factor = 0.33
    cfg.model.neck.deepen_factor = 0.33
    init_default_scope("sscma")
    detector = MODELS.build(cfg.model)
    missing, unexpected = detector.load_state_dict(ckpt["state_dict"], strict=False)
    if missing or unexpected:
        return _die(
            "state_dict mismatch "
            f"(missing={len(missing)}, unexpected={len(unexpected)}). "
            "Check deepen_factor wiring in ModelAssistant."
        )
    detector.eval()

    class NhwcSevenSeg(nn.Module):
        """NHWC [1,192,192,3] → [1,2268,15] with scores in 0–1 (÷100)."""

        def __init__(self, det: nn.Module) -> None:
            super().__init__()
            self.backbone = det.backbone
            self.neck = det.neck
            self.head = det.bbox_head.head_module

        def forward(self, x_nhwc: torch.Tensor) -> torch.Tensor:
            x = x_nhwc.permute(0, 3, 1, 2).contiguous()
            feats = self.backbone(x)
            if self.neck is not None:
                feats = self.neck(feats)
            out = self.head._forward(feats)
            return torch.cat([out[..., :4], out[..., 4:] / 100.0], dim=-1)

    wrapped = NhwcSevenSeg(detector).eval()
    dummy = torch.rand(1, 192, 192, 3)
    with torch.no_grad():
        probed = wrapped(dummy)
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
