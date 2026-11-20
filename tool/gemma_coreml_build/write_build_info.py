#!/usr/bin/env python3
"""Write BUILD_INFO.json next to a finished Core ML bundle."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from datetime import datetime, timezone


def _git_rev(path: str) -> str:
    try:
        return (
            subprocess.check_output(
                ["git", "-C", path, "rev-parse", "HEAD"],
                stderr=subprocess.DEVNULL,
            )
            .decode()
            .strip()
        )
    except Exception:
        return ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle-dir", required=True)
    parser.add_argument("--hf-repo", required=True)
    parser.add_argument("--hf-dir", required=True)
    parser.add_argument("--coreml-llm-dir", required=True)
    parser.add_argument("--ctx", type=int, required=True)
    parser.add_argument("--prefill-size", type=int, required=True)
    parser.add_argument("--model-key", required=True)
    args = parser.parse_args()

    info = {
        "recipe": "stateless-int4-chunks + prefill_bN + still-vision",
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
        "hf_repo": args.hf_repo,
        "hf_dir": os.path.abspath(args.hf_dir),
        "model_key": args.model_key,
        "context_length": args.ctx,
        "prefill_size": args.prefill_size,
        "quantize": "int4-palettize (CoreML-LLM default)",
        "kv_cache": "stateless explicit I/O (not MLState)",
        "vision": "still-image only (vision.ane.*; no video/audio)",
        "coreml_llm_git_rev": _git_rev(args.coreml_llm_dir),
        "excluded": ["vision_video", "audio", "MLState"],
    }
    out = os.path.join(args.bundle_dir, "BUILD_INFO.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(info, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
