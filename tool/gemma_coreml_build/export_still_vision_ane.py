#!/usr/bin/env python3
"""Export still-image vision Core ML only (no video / audio / text decoder).

Wraps CoreML-LLM's conversion helpers so the full multimodal decoder rebuild
is skipped. Prefer ``vision.ane.mlpackage`` when the upstream API provides it.
"""

from __future__ import annotations

import argparse
import os
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--conversion-dir", required=True)
    parser.add_argument("--hf-dir", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--context-length", type=int, default=1024)
    args = parser.parse_args()

    conversion_dir = os.path.abspath(args.conversion_dir)
    if conversion_dir not in sys.path:
        sys.path.insert(0, conversion_dir)

    os.makedirs(args.output, exist_ok=True)

    import torch
    from transformers import Gemma4ForConditionalGeneration

    from models.gemma4_vision import (  # type: ignore
        convert_still_image_vision_ane_to_coreml,
        save_vision_weights,
    )

    print(f"Loading HF multimodal model from {args.hf_dir}")
    hf_model = Gemma4ForConditionalGeneration.from_pretrained(
        args.hf_dir,
        dtype=torch.float16,
        device_map="cpu",
    )
    hf_model.eval()

    print("Saving vision weight sidecars (debug / parity)")
    save_vision_weights(hf_model, args.output)

    print("Converting still-image vision tower (ANE build)")
    path = convert_still_image_vision_ane_to_coreml(hf_model, args.output)
    print(f"Wrote {path}")

    del hf_model
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
