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
    """Replace optional heavy deps with stubs for export-only imports.

    ModelAssistant may import datasets → lancedb → pyarrow. A real pyarrow
    often conflicts with Colab/numpy, so we stub. The stub must expose
    ``__version__`` because some importers read it eagerly.
    """

    def _ensure(name: str) -> types.ModuleType:
        mod = sys.modules.get(name)
        if mod is None:
            mod = types.ModuleType(name)
            sys.modules[name] = mod
        if not hasattr(mod, "__version__"):
            mod.__version__ = "0.0.0"
        return mod

    for name in ("pyarrow", "lance", "lancedb"):
        _ensure(name)
    for name in (
        "pyarrow.lib",
        "pyarrow.compute",
        "pyarrow.dataset",
        "pyarrow.parquet",
        "lancedb",
    ):
        _ensure(name)


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


def _is_ignorable_unexpected_key(key: str) -> bool:
    """Only EMA-related leftovers are ignorable; backbone extras are not."""
    lower = key.lower()
    return (
        lower.startswith("ema_")
        or ".ema_" in lower
        or lower.startswith("ema.")
        or "/ema/" in lower
    )


def _build_detector(sscma_root: Path, weights: Path):
    import torch
    from mmengine.config import Config
    from mmengine.registry import MODELS, init_default_scope

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
    deepen_factor_mode: str = "off",
):
    """Return (wrapped_module, probed_output_tensor, dummy) for NHWC 192 contract.

    deepen_factor_mode must be ``on`` or ``off`` only. ``auto`` is handled by
    callers via a fresh subprocess per mode (registry/class cache cannot switch
    deepen_factor safely in one process).
    """
    import torch
    import torch.nn as nn

    if deepen_factor_mode not in {"on", "off"}:
        raise ValueError(
            f"deepen_factor_mode must be 'on' or 'off' (got {deepen_factor_mode!r}); "
            "CLI 'auto' must spawn a new process per mode"
        )

    stub_sscma_optional_deps()
    root = str(sscma_root.resolve())
    if root not in sys.path:
        sys.path.insert(0, root)

    if deepen_factor_mode == "on":
        ensure_yolov5_csp_deepen_factor(sscma_root)
    else:
        try:
            revert_yolov5_csp_deepen_factor(sscma_root)
        except RuntimeError:
            pass

    detector, missing, unexpected = _build_detector(sscma_root, weights)
    bad_unexpected = [k for k in unexpected if not _is_ignorable_unexpected_key(k)]
    if missing or bad_unexpected:
        preview_m = ", ".join(missing[:8])
        preview_u = ", ".join(bad_unexpected[:8])
        raise RuntimeError(
            f"state_dict mismatch mode={deepen_factor_mode} "
            f"missing={len(missing)} unexpected_non_ema={len(bad_unexpected)} "
            f"sample_missing=[{preview_m}] sample_unexpected=[{preview_u}]"
        )
    if unexpected:
        print(
            f"Ignoring {len(unexpected)} EMA unexpected keys "
            f"(mode={deepen_factor_mode})"
        )
    print(f"Loaded checkpoint with deepen_factor_mode={deepen_factor_mode}")

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
    if tuple(probed.shape) not in {(1, 2268, 15), (2268, 15)}:
        raise RuntimeError(f"Unexpected output shape: {tuple(probed.shape)}")
    print(f"Probe output shape: {tuple(probed.shape)}")
    return wrapped, probed, dummy
