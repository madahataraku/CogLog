#!/usr/bin/env python3
"""Shared SSCMA Swift-YOLO helpers for Core ML / TFLite float32 export."""

from __future__ import annotations

import sys
import types
from pathlib import Path


def ensure_yolov5_csp_deepen_factor(sscma_root: Path) -> None:
    """Patch YOLOv5CSPDarknet to apply deepen_factor in make_round."""
    path = sscma_root / "sscma" / "models" / "backbones" / "csp_darknet.py"
    if not path.is_file():
        raise FileNotFoundError(f"Missing backbone file: {path}")
    text = path.read_text(encoding="utf-8")
    good = "num_blocks = make_round(num_blocks, self.deepen_factor)"
    bad = "num_blocks = make_round(num_blocks)"
    if good in text:
        return
    if bad not in text:
        raise RuntimeError(
            f"{path} has neither the known-good nor known-bad make_round "
            "call; check deepen_factor wiring manually."
        )
    path.write_text(text.replace(bad, good, 1), encoding="utf-8")
    print(f"Patched {path} to apply deepen_factor in make_round")


def stub_sscma_optional_deps() -> None:
    for name in ("pyarrow", "lance", "lancedb"):
        if name not in sys.modules:
            sys.modules[name] = types.ModuleType(name)


def build_nhwc_seven_seg(sscma_root: Path, weights: Path):
    """Return (wrapped_module, probed_output_tensor) for NHWC 192 contract."""
    import torch
    import torch.nn as nn
    from mmengine.config import Config
    from mmengine.registry import MODELS, init_default_scope

    ensure_yolov5_csp_deepen_factor(sscma_root)
    stub_sscma_optional_deps()
    sys.path.insert(0, str(sscma_root.resolve()))

    # Imported for side-effect registration.
    from sscma.datasets.data_preprocessor import DetDataPreprocessor  # noqa: F401
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

    config_file = (
        sscma_root / "configs" / "swift_yolo" / "swift_yolo_tiny_1xb16_300e_coco.py"
    )
    if not config_file.is_file():
        raise FileNotFoundError(f"Swift-YOLO config not found: {config_file}")

    try:
        ckpt = torch.load(weights, map_location="cpu", weights_only=False)
    except TypeError:
        ckpt = torch.load(weights, map_location="cpu")
    if not isinstance(ckpt, dict) or "state_dict" not in ckpt:
        raise ValueError("Unsupported checkpoint: expected dict with 'state_dict'")

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
        raise RuntimeError(
            "state_dict mismatch "
            f"(missing={len(missing)}, unexpected={len(unexpected)}). "
            "YOLOv5CSPDarknet must use "
            "`make_round(num_blocks, self.deepen_factor)`."
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
        raise RuntimeError(f"Unexpected output shape: {tuple(probed.shape)}")
    return wrapped, probed, dummy
