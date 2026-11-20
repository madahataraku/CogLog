#!/usr/bin/env bash
# Build a CogLog-oriented Gemma 4 E2B Core ML bundle:
#   google/gemma-4-E2B-it → stateless INT4 chunks + prefill_b128 + ctx=1024
#   + still-image vision only (no video / audio)
#
# Requires: macOS (Apple Silicon recommended), Python 3.10–3.12, Xcode CLT,
#           network access to GitHub + Hugging Face.
#
# Usage:
#   ./tool/gemma_coreml_build/build_stateless_int4_bundle.sh
#   COREML_LLM_DIR=~/src/CoreML-LLM OUT_DIR=/tmp/gemma4-e2b-bundle \
#     ./tool/gemma_coreml_build/build_stateless_int4_bundle.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

HF_REPO="${HF_REPO:-google/gemma-4-E2B-it}"
MODEL_KEY="${MODEL_KEY:-gemma4-e2b}"
CTX="${CTX:-1024}"
PREFILL_SIZE="${PREFILL_SIZE:-128}"
COREML_LLM_REF="${COREML_LLM_REF:-main}"
COREML_LLM_URL="${COREML_LLM_URL:-https://github.com/john-rocky/CoreML-LLM.git}"
WORK_ROOT="${WORK_ROOT:-${REPO_ROOT}/.cache/gemma_coreml_build}"
COREML_LLM_DIR="${COREML_LLM_DIR:-${WORK_ROOT}/CoreML-LLM}"
OUT_DIR="${OUT_DIR:-${WORK_ROOT}/output/${MODEL_KEY}-ctx${CTX}-prefill${PREFILL_SIZE}}"
HF_DIR="${HF_DIR:-${WORK_ROOT}/hf/${HF_REPO##*/}}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
SKIP_HF_DOWNLOAD="${SKIP_HF_DOWNLOAD:-0}"
SKIP_VISION="${SKIP_VISION:-0}"

log() { printf '[gemma-coreml-build] %s\n' "$*"; }
die() { printf '[gemma-coreml-build] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This build must run on macOS (coremltools compiles text-MIL .mlmodelc)."
fi

if ! command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
  die "Python not found (${PYTHON_BIN})."
fi

PY_MAJOR="$("${PYTHON_BIN}" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
case "${PY_MAJOR}" in
  3.10|3.11|3.12) ;;
  *)
    log "Warning: CoreML-LLM documents Python 3.10–3.12; found ${PY_MAJOR}."
    ;;
esac

mkdir -p "${WORK_ROOT}" "${OUT_DIR}"

if [[ ! -d "${COREML_LLM_DIR}/.git" ]]; then
  log "Cloning CoreML-LLM (${COREML_LLM_REF}) → ${COREML_LLM_DIR}"
  git clone --depth 1 --branch "${COREML_LLM_REF}" "${COREML_LLM_URL}" "${COREML_LLM_DIR}" \
    || git clone --depth 1 "${COREML_LLM_URL}" "${COREML_LLM_DIR}"
  if [[ "${COREML_LLM_REF}" != "main" ]]; then
    git -C "${COREML_LLM_DIR}" fetch --depth 1 origin "${COREML_LLM_REF}" || true
    git -C "${COREML_LLM_DIR}" checkout "${COREML_LLM_REF}" || true
  fi
else
  log "Reusing CoreML-LLM at ${COREML_LLM_DIR}"
fi

CONVERSION_DIR="${COREML_LLM_DIR}/conversion"
[[ -d "${CONVERSION_DIR}" ]] || die "Missing ${CONVERSION_DIR}"

VENV_DIR="${WORK_ROOT}/venv"
if [[ ! -d "${VENV_DIR}" ]]; then
  log "Creating venv at ${VENV_DIR}"
  "${PYTHON_BIN}" -m venv "${VENV_DIR}"
fi
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
pip install --upgrade pip wheel >/dev/null
log "Installing conversion requirements"
pip install -r "${CONVERSION_DIR}/requirements.txt"
pip install scikit-learn huggingface_hub

if [[ "${SKIP_HF_DOWNLOAD}" != "1" ]]; then
  log "Downloading ${HF_REPO} → ${HF_DIR}"
  mkdir -p "${HF_DIR}"
  "${PYTHON_BIN}" - <<PY
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id="${HF_REPO}",
    local_dir="${HF_DIR}",
    allow_patterns=[
        "*.safetensors",
        "*.json",
        "tokenizer*",
        "*.txt",
        "*.model",
        "*.jinja",
    ],
)
print("HF download complete:", "${HF_DIR}")
PY
else
  [[ -d "${HF_DIR}" ]] || die "SKIP_HF_DOWNLOAD=1 but HF_DIR missing: ${HF_DIR}"
fi

BUNDLE_DIR="${OUT_DIR}/bundle"
mkdir -p "${BUNDLE_DIR}"

log "Building stateless INT4 decode+prefill bundle (ctx=${CTX}, prefill=${PREFILL_SIZE})"
(
  cd "${CONVERSION_DIR}"
  python build_gemma4_bundle.py \
    --model "${MODEL_KEY}" \
    --ctx "${CTX}" \
    --hf-dir "${HF_DIR}" \
    --output "${BUNDLE_DIR}" \
    --prefill-sizes "${PREFILL_SIZE}"
)

if [[ "${SKIP_VISION}" != "1" ]]; then
  log "Exporting still-image vision only (no video / audio)"
  VISION_OUT="${OUT_DIR}/vision_export"
  mkdir -p "${VISION_OUT}"
  python "${SCRIPT_DIR}/export_still_vision_ane.py" \
    --conversion-dir "${CONVERSION_DIR}" \
    --hf-dir "${HF_DIR}" \
    --output "${VISION_OUT}" \
    --context-length "${CTX}"

  if [[ -d "${VISION_OUT}/vision.ane.mlpackage" ]]; then
    log "Compiling vision.ane.mlpackage → vision.ane.mlmodelc"
    python "${SCRIPT_DIR}/compile_mlpackage.py" \
      --src "${VISION_OUT}/vision.ane.mlpackage" \
      --dst "${BUNDLE_DIR}/vision.ane.mlmodelc"
  elif [[ -d "${VISION_OUT}/vision.mlpackage" ]]; then
    log "Compiling vision.mlpackage → vision.mlmodelc"
    python "${SCRIPT_DIR}/compile_mlpackage.py" \
      --src "${VISION_OUT}/vision.mlpackage" \
      --dst "${BUNDLE_DIR}/vision.mlmodelc"
  else
    die "Vision export produced neither vision.ane.mlpackage nor vision.mlpackage"
  fi

  # Keep source mlpackage alongside for inspection / recompile.
  if [[ -d "${VISION_OUT}/vision.ane.mlpackage" ]]; then
    rm -rf "${BUNDLE_DIR}/vision.ane.mlpackage"
    cp -R "${VISION_OUT}/vision.ane.mlpackage" "${BUNDLE_DIR}/vision.ane.mlpackage"
  fi
  if [[ -d "${VISION_OUT}/vision.mlpackage" ]]; then
    rm -rf "${BUNDLE_DIR}/vision.mlpackage"
    cp -R "${VISION_OUT}/vision.mlpackage" "${BUNDLE_DIR}/vision.mlpackage"
  fi
else
  log "SKIP_VISION=1 — text/prefill bundle only"
fi

# Guard: never ship video/audio artifacts in this recipe.
rm -rf \
  "${BUNDLE_DIR}/vision_video.mlpackage" \
  "${BUNDLE_DIR}/vision_video.mlmodelc" \
  "${BUNDLE_DIR}/audio.mlpackage" \
  "${BUNDLE_DIR}/audio.mlmodelc"

python "${SCRIPT_DIR}/write_build_info.py" \
  --bundle-dir "${BUNDLE_DIR}" \
  --hf-repo "${HF_REPO}" \
  --hf-dir "${HF_DIR}" \
  --coreml-llm-dir "${COREML_LLM_DIR}" \
  --ctx "${CTX}" \
  --prefill-size "${PREFILL_SIZE}" \
  --model-key "${MODEL_KEY}"

bash "${SCRIPT_DIR}/verify_bundle.sh" "${BUNDLE_DIR}"

log "Done."
log "Bundle: ${BUNDLE_DIR}"
log "Next: see tool/gemma_coreml_build/README.md (sideload / HF upload)."
