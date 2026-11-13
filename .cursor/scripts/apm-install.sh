#!/usr/bin/env bash
# Install the pinned APM CLI if needed, then materialize Cursor skills from apm.yml.
# Generated trees (.agents, apm_modules, .cursor agents/commands) stay untracked.
# apm.lock.yaml is tracked and selects the CLI version. Safe to re-run.
set -euo pipefail

log() {
  printf '%s\n' "$*"
}

install_apm_cli() {
  local launcher="${HOME}/.local/bin/apm"
  local version
  version="$(awk '/^apm_version:/ { print $2; exit }' apm.lock.yaml)"
  if [[ -z "${version}" ]]; then
    log "apm.lock.yaml has no apm_version"
    exit 1
  fi
  export PATH="/usr/local/bin:${HOME}/.local/bin:${PATH}"
  local escaped="${version//./\\.}"
  # sha256 of the install.sh published with the locked apm_version tag.
  # aka.ms/apm-unix tracks main and drifts; pin the matching release tag instead.
  # Re-pin this when intentionally changing apm_version / installers.
  local installer_url="https://raw.githubusercontent.com/microsoft/apm/v${version}/install.sh"
  local installer_sha256="0e813353630c02a9eb961fbad82cf916967e855aa84a533940975c5d699c9caa"
  if ! apm --version 2>/dev/null | grep -Eq "(^|[^0-9.])${escaped}([^0-9.]|$)"; then
    local installer
    installer="$(mktemp)"
    curl -fsSL "${installer_url}" -o "${installer}"
    if [[ "$(sha256sum "${installer}" | awk '{ print $1 }')" != "${installer_sha256}" ]]; then
      rm -f "${installer}"
      log "apm installer checksum mismatch"
      exit 1
    fi
    APM_NO_MODIFY_PATH=1 VERSION="v${version}" sh "${installer}"
    rm -f "${installer}"
  fi
  if [[ -x "${launcher}" && ! -e /usr/local/bin/apm ]]; then
    if [[ -w /usr/local/bin ]]; then
      ln -sfn "${launcher}" /usr/local/bin/apm
    else
      sudo ln -sfn "${launcher}" /usr/local/bin/apm
    fi
  fi
  # Login shells on this image do not load ~/.local/bin.
  export PATH="/usr/local/bin:${HOME}/.local/bin:${PATH}"
  if ! command -v apm >/dev/null 2>&1; then
    log "apm is not on PATH after install"
    exit 1
  fi
  if ! apm --version 2>/dev/null | grep -Eq "(^|[^0-9.])${escaped}([^0-9.]|$)"; then
    log "apm version does not match ${version}"
    exit 1
  fi
}

# Cloud Agent git config rewrites GitHub URLs to credentialed https:// URLs.
# APM refuses those url.*.insteadOf rules. This copy is process-local.
sanitize_git_config() {
  local src="${GIT_CONFIG_GLOBAL:-${HOME}/.gitconfig}"
  local dst
  dst="$(mktemp)"
  python3 - "${src}" "${dst}" <<'PY'
import sys
from pathlib import Path

src, dst = sys.argv[1], sys.argv[2]
text = Path(src).read_text() if Path(src).is_file() else ""
lines = text.splitlines(keepends=True)
out = []
i = 0
while i < len(lines):
    line = lines[i]
    if line.startswith("[url "):
        header = line
        i += 1
        body = []
        while i < len(lines) and not lines[i].startswith("["):
            body.append(lines[i])
            i += 1
        # Drop replacements that embed credentials (userinfo@host).
        if "://" in header and "@" in header.split("://", 1)[-1]:
            continue
        out.append(header)
        out.extend(body)
        continue
    out.append(line)
    i += 1
Path(dst).write_text("".join(out))
PY
  export GIT_CONFIG_GLOBAL="${dst}"
  unset GIT_CONFIG_COUNT || true
}

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${root}"

if [[ ! -f apm.yml ]]; then
  log "apm.yml is absent; skipping apm install"
  exit 0
fi

install_apm_cli

sanitize_git_config
apm install --target cursor --https

# Cloud Agents load ~/.cursor/skills at chat start. Repository copies stay gitignored.
python3 "${root}/.cursor/scripts/publish-cursor-skills.py" "${root}"
