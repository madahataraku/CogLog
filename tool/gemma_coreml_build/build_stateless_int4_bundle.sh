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

# Resolve relative paths against the repo root without requiring them to exist.
abs_path() {
  local raw="$1"
  if [[ "${raw}" = /* ]]; then
    printf '%s\n' "${raw}"
    return
  fi
  local cleaned="${raw#./}"
  printf '%s/%s\n' "${REPO_ROOT}" "${cleaned}"
}

HF_REPO="${HF_REPO:-google/gemma-4-E2B-it}"
MODEL_KEY="${MODEL_KEY:-gemma4-e2b}"
CTX="${CTX:-1024}"
PREFILL_SIZE="${PREFILL_SIZE:-128}"
COREML_LLM_REF="${COREML_LLM_REF:-main}"
COREML_LLM_URL="${COREML_LLM_URL:-https://github.com/john-rocky/CoreML-LLM.git}"
WORK_ROOT="$(abs_path "${WORK_ROOT:-${REPO_ROOT}/.cache/gemma_coreml_build}")"
COREML_LLM_DIR="$(abs_path "${COREML_LLM_DIR:-${WORK_ROOT}/CoreML-LLM}")"
OUT_DIR="$(abs_path "${OUT_DIR:-${WORK_ROOT}/output/${MODEL_KEY}-ctx${CTX}-prefill${PREFILL_SIZE}}")"
HF_DIR="$(abs_path "${HF_DIR:-${WORK_ROOT}/hf/${HF_REPO##*/}}")"
HOST_PYTHON="${HOST_PYTHON:-${PYTHON_BIN:-python3}}"
SKIP_HF_DOWNLOAD="${SKIP_HF_DOWNLOAD:-0}"
SKIP_VISION="${SKIP_VISION:-0}"
# 1 = skip pip install -r requirements.txt (reuse an already-prepared venv / host deps)
SKIP_DEPS="${SKIP_DEPS:-0}"
# 1 = create venv with --system-site-packages so a host torch (e.g. conda) is visible
VENV_SYSTEM_SITE_PACKAGES="${VENV_SYSTEM_SITE_PACKAGES:-0}"

log() { printf '[gemma-coreml-build] %s\n' "$*"; }
die() { printf '[gemma-coreml-build] ERROR: %s\n' "$*" >&2; exit 1; }

# torch==2.11.0 (CoreML-LLM pin) ships macOS wheels for arm64 only — not x86_64.
require_torch_platform() {
  local arch
  arch="$(uname -m)"
  if [[ "${arch}" != "arm64" ]]; then
    die "torch==2.11.0 has no macOS ${arch} wheel on PyPI (arm64 / Apple Silicon only). Use an Apple Silicon Mac, or set SKIP_DEPS=1 with a venv that already has torch 2.11.0."
  fi
}

# Explain common pip failures for the pinned torch version.
install_conversion_requirements() {
  local reqs="$1"
  require_torch_platform
  log "Installing conversion requirements from ${reqs}"
  log "Note: pip installs into the build venv; a host/conda torch is ignored unless VENV_SYSTEM_SITE_PACKAGES=1 or SKIP_DEPS=1."
  if ! "${PYTHON_BIN}" -m pip install -r "${reqs}"; then
    die "pip install -r ${reqs} failed. Common causes: (1) not Apple Silicon arm64, (2) Python not 3.10–3.12 for this venv, (3) PIP_INDEX_URL / extra-index pointing only at a CUDA torch index. Fix: use arm64 Python 3.10–3.12 and default PyPI, or SKIP_DEPS=1 after preparing the venv, or VENV_SYSTEM_SITE_PACKAGES=1 with host torch 2.11.0."
  fi
}

ensure_coreml_llm_ref() {
  local dir="$1"
  local ref="$2"
  log "Checking out CoreML-LLM ref '${ref}' in ${dir}"
  git -C "${dir}" fetch --depth 1 origin "${ref}"
  # Prefer exact ref tip; fail hard if unavailable.
  if git -C "${dir}" rev-parse --verify --quiet "FETCH_HEAD" >/dev/null; then
    git -C "${dir}" checkout --force FETCH_HEAD
  else
    git -C "${dir}" checkout --force "${ref}"
  fi
  local head
  head="$(git -C "${dir}" rev-parse --short HEAD)"
  log "CoreML-LLM HEAD=${head} (requested ref=${ref})"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  die "This build must run on macOS (coremltools compiles text-MIL .mlmodelc)."
fi

if ! command -v "${HOST_PYTHON}" >/dev/null 2>&1; then
  die "Python not found (${HOST_PYTHON})."
fi

PY_MAJOR="$("${HOST_PYTHON}" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
case "${PY_MAJOR}" in
  3.10|3.11|3.12) ;;
  *)
    log "Warning: CoreML-LLM documents Python 3.10–3.12; found ${PY_MAJOR}."
    ;;
esac

mkdir -p "${WORK_ROOT}" "${OUT_DIR}" "${HF_DIR}"

if [[ ! -d "${COREML_LLM_DIR}/.git" ]]; then
  log "Cloning CoreML-LLM → ${COREML_LLM_DIR}"
  mkdir -p "$(dirname "${COREML_LLM_DIR}")"
  git clone "${COREML_LLM_URL}" "${COREML_LLM_DIR}"
else
  log "Reusing CoreML-LLM at ${COREML_LLM_DIR}"
fi
ensure_coreml_llm_ref "${COREML_LLM_DIR}" "${COREML_LLM_REF}"

CONVERSION_DIR="${COREML_LLM_DIR}/conversion"
[[ -d "${CONVERSION_DIR}" ]] || die "Missing ${CONVERSION_DIR}"

VENV_DIR="${WORK_ROOT}/venv"
if [[ ! -d "${VENV_DIR}" ]]; then
  log "Creating venv at ${VENV_DIR}"
  VENV_ARGS=()
  if [[ "${VENV_SYSTEM_SITE_PACKAGES}" == "1" ]]; then
    VENV_ARGS+=(--system-site-packages)
    log "venv will use --system-site-packages (host torch visible)"
  fi
  "${HOST_PYTHON}" -m venv "${VENV_ARGS[@]}" "${VENV_DIR}"
fi
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
# Always use the venv interpreter after activation (ignore outer PYTHON_BIN).
PYTHON_BIN="${VENV_DIR}/bin/python"
[[ -x "${PYTHON_BIN}" ]] || die "venv python missing: ${PYTHON_BIN}"

VENV_PY_MAJOR="$("${PYTHON_BIN}" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
VENV_ARCH="$("${PYTHON_BIN}" -c 'import platform; print(platform.machine())')"
log "venv python=${VENV_PY_MAJOR} arch=${VENV_ARCH} (${PYTHON_BIN})"

"${PYTHON_BIN}" -m pip install --upgrade pip wheel >/dev/null
if [[ "${SKIP_DEPS}" == "1" ]]; then
  log "SKIP_DEPS=1 — not running pip install -r requirements.txt"
  if ! "${PYTHON_BIN}" -c 'import torch; assert torch.__version__.startswith("2.11."), torch.__version__'; then
    die "SKIP_DEPS=1 but venv cannot import torch 2.11.x. Install it into this venv or use VENV_SYSTEM_SITE_PACKAGES=1 with a host torch 2.11.0."
  fi
  "${PYTHON_BIN}" -c 'import torch; print("torch", torch.__version__)'
else
  install_conversion_requirements "${CONVERSION_DIR}/requirements.txt"
  "${PYTHON_BIN}" -m pip install scikit-learn huggingface_hub
fi

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
  "${PYTHON_BIN}" build_gemma4_bundle.py \
    --model "${MODEL_KEY}" \
    --ctx "${CTX}" \
    --hf-dir "${HF_DIR}" \
    --output "${BUNDLE_DIR}" \
    --prefill-sizes "${PREFILL_SIZE}"
)

VERIFY_ARGS=("${BUNDLE_DIR}")

if [[ "${SKIP_VISION}" != "1" ]]; then
  log "Exporting still-image vision only (no video / audio)"
  VISION_OUT="${OUT_DIR}/vision_export"
  mkdir -p "${VISION_OUT}"
  "${PYTHON_BIN}" "${SCRIPT_DIR}/export_still_vision_ane.py" \
    --conversion-dir "${CONVERSION_DIR}" \
    --hf-dir "${HF_DIR}" \
    --output "${VISION_OUT}" \
    --context-length "${CTX}"

  if [[ -d "${VISION_OUT}/vision.ane.mlpackage" ]]; then
    log "Compiling vision.ane.mlpackage → vision.ane.mlmodelc"
    "${PYTHON_BIN}" "${SCRIPT_DIR}/compile_mlpackage.py" \
      --src "${VISION_OUT}/vision.ane.mlpackage" \
      --dst "${BUNDLE_DIR}/vision.ane.mlmodelc"
  elif [[ -d "${VISION_OUT}/vision.mlpackage" ]]; then
    log "Compiling vision.mlpackage → vision.mlmodelc"
    "${PYTHON_BIN}" "${SCRIPT_DIR}/compile_mlpackage.py" \
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
  log "SKIP_VISION=1 — text/prefill bundle only; removing stale vision artifacts"
  rm -rf \
    "${BUNDLE_DIR}/vision.ane.mlpackage" \
    "${BUNDLE_DIR}/vision.ane.mlmodelc" \
    "${BUNDLE_DIR}/vision.mlpackage" \
    "${BUNDLE_DIR}/vision.mlmodelc"
  VERIFY_ARGS+=(--allow-missing-vision)
fi

# Guard: never ship video/audio artifacts in this recipe.
rm -rf \
  "${BUNDLE_DIR}/vision_video.mlpackage" \
  "${BUNDLE_DIR}/vision_video.mlmodelc" \
  "${BUNDLE_DIR}/audio.mlpackage" \
  "${BUNDLE_DIR}/audio.mlmodelc"

"${PYTHON_BIN}" "${SCRIPT_DIR}/write_build_info.py" \
  --bundle-dir "${BUNDLE_DIR}" \
  --hf-repo "${HF_REPO}" \
  --hf-dir "${HF_DIR}" \
  --coreml-llm-dir "${COREML_LLM_DIR}" \
  --ctx "${CTX}" \
  --prefill-size "${PREFILL_SIZE}" \
  --model-key "${MODEL_KEY}"

bash "${SCRIPT_DIR}/verify_bundle.sh" "${VERIFY_ARGS[@]}"

log "Done."
log "Bundle: ${BUNDLE_DIR}"
log "Next: see tool/gemma_coreml_build/README.md (sideload / HF upload)."
