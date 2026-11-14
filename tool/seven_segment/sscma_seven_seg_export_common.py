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


def revert_yolov5_csp_deepen_factor(sscma_root: Path) -> None:
    """Undo ensure_yolov5_csp_deepen_factor (for weights trained without deepen)."""
    path = sscma_root / "sscma" / "models" / "backbones" / "csp_darknet.py"
    if not path.is_file():
        raise FileNotFoundError(f"Missing backbone file: {path}")
    text = path.read_text(encoding="utf-8")
    good = "num_blocks = make_round(num_blocks, self.deepen_factor)"
    bad = "num_blocks = make_round(num_blocks)"
    if bad in text and good not in text:
        return
    if good not in text:
        raise RuntimeError(f"{path} does not contain the patched make_round call")
    path.write_text(text.replace(good, bad, 1), encoding="utf-8")
    print(f"Reverted deepen_factor patch in {path}")


def stub_sscma_optional_deps() -> None:
    for name in ("pyarrow", "lance", "lancedb"):
        if name not in sys.modules:
            sys.modules[name] = types.ModuleType(name)


def _normalize_state_dict(state_dict: dict) -> dict:
    """Drop EMA / prefix noise common in mmengine training checkpoints."""
    out: dict = {}
    for key, value in state_dict.items():
        name = key
        if name.startswith("ema_"):
            continue
        if name.startswith("module."):
            name = name[len("module.") :]
        out[name] = value
    return out


def _build_detector(sscma_root: Path, weights: Path):
    import torch
    from mmengine.config import Config
    from mmengine.registry import MODELS, init_default_scope

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
    state = _normalize_state_dict(ckpt["state_dict"])
    missing, unexpected = detector.load_state_dict(state, strict=False)
    return detector, missing, unexpected


def build_nhwc_seven_seg(
    sscma_root: Path,
    weights: Path,
    *,
    deepen_factor_mode: str = "auto",
):
    """Return (wrapped_module, probed_output_tensor, dummy) for NHWC 192 contract.

    deepen_factor_mode:
      - ``auto``: try patched architecture first; on large missing, revert and retry
      - ``on``: always patch (Seeed zoo weights)
      - ``off``: never patch (Colab train before deepen patch)
    """
    import torch
    import torch.nn as nn

    stub_sscma_optional_deps()
    root = str(sscma_root.resolve())
    if root not in sys.path:
        sys.path.insert(0, root)

    if deepen_factor_mode not in {"auto", "on", "off"}:
        raise ValueError(f"Unknown deepen_factor_mode: {deepen_factor_mode}")

    attempts: list[str]
    if deepen_factor_mode == "auto":
        attempts = ["on", "off"]
    else:
        attempts = [deepen_factor_mode]

    last_error: Exception | None = None
    detector = None
    for mode in attempts:
        try:
            if mode == "on":
                ensure_yolov5_csp_deepen_factor(sscma_root)
            else:
                # Ensure unpatched source before import/build.
                try:
                    revert_yolov5_csp_deepen_factor(sscma_root)
                except RuntimeError:
                    pass
            # Force re-import of backbone if a previous attempt patched/reverted.
            for mod_name in list(sys.modules):
                if mod_name.startswith("sscma.models.backbones"):
                    del sys.modules[mod_name]
            detector, missing, unexpected = _build_detector(sscma_root, weights)
            # EMA / buffers may show as unexpected; only missing blocks the export.
            if missing:
                preview = ", ".join(missing[:8])
                raise RuntimeError(
                    f"state_dict missing={len(missing)} unexpected={len(unexpected)} "
                    f"(mode={mode}). sample missing: {preview}"
                )
            if unexpected:
                print(
                    f"Ignoring {len(unexpected)} unexpected keys "
                    f"(mode={mode}; often EMA/buffers)"
                )
            print(f"Loaded checkpoint with deepen_factor_mode={mode}")
            break
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            detector = None
            print(f"Load attempt mode={mode} failed: {exc}")
    if detector is None:
        raise RuntimeError(
            f"Failed to load weights under modes {attempts}: {last_error}"
        )

    detector.eval()

    class NhwcSevenSeg(nn.Module):
        """NHWC [1,192,192,3] → detections with scores in 0–1 (÷100)."""

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
    # Row count depends on anchors/strides at imgsz=192; require 15-wide contract.
    if probed.ndim != 3 or probed.shape[0] != 1 or probed.shape[-1] != 15:
        raise RuntimeError(f"Unexpected output shape: {tuple(probed.shape)}")
    print(f"Probe output shape: {tuple(probed.shape)}")
    return wrapped, probed, dummy
