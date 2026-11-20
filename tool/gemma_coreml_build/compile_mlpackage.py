#!/usr/bin/env python3
"""Compile a Core ML .mlpackage into text-MIL .mlmodelc (macOS only).

Uses the same coremltools recipe as CoreML-LLM's build_gemma4_bundle.py.
Do not use ``xcrun coremlcompiler`` for iPhone bundles (Mac-specific MIL).
"""

from __future__ import annotations

import argparse
import os
import shutil


def compile_mlpackage(src: str, dst: str) -> None:
    import coremltools as ct

    model = ct.models.MLModel(src)
    compiled = model.get_compiled_model_path()
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(compiled, dst)
    del model


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", required=True, help="Path to *.mlpackage")
    parser.add_argument("--dst", required=True, help="Path to output *.mlmodelc")
    args = parser.parse_args()

    if not os.path.isdir(args.src):
        raise SystemExit(f"Missing mlpackage directory: {args.src}")

    os.makedirs(os.path.dirname(os.path.abspath(args.dst)) or ".", exist_ok=True)
    compile_mlpackage(args.src, args.dst)
    print(f"Compiled {args.src} → {args.dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
