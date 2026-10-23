#!/usr/bin/env bash
# Install Desktop → CLI auth bridge scripts + optional launchd watcher (macOS).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${HOME}/.local/bin"
LAUNCH_AGENTS="${HOME}/Library/LaunchAgents"
LABEL="com.icatw.cursor-agent-desktop-sync"
PLIST="${LAUNCH_AGENTS}/${LABEL}.plist"
CACHE="${HOME}/.cache/cursor-agent-desktop-sync"

WITH_LAUNCHD=1
SKIP_WRAPPER=0

usage() {
  cat <<'EOF'
Usage: install/install-macos.sh [--no-launchd] [--skip-wrapper]

  --no-launchd     Install scripts only; do not load launchd WatchPaths job
  --skip-wrapper   Do not retarget ~/.local/bin/agent and cursor-agent

Requires: Cursor Desktop, Cursor CLI (agent), python3, sqlite3.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-launchd) WITH_LAUNCHD=0; shift ;;
    --skip-wrapper) SKIP_WRAPPER=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

mkdir -p "${BIN}" "${CACHE}"
chmod 700 "${CACHE}"

install -m 0755 "${ROOT}/scripts/cursor-agent-sync-auth" "${BIN}/"
install -m 0755 "${ROOT}/scripts/agent-desktop-auth-wrapper" "${BIN}/"
install -m 0755 "${ROOT}/scripts/agent-desktop-reenter" "${BIN}/"
install -m 0755 "${ROOT}/scripts/cursor-agent-desktop-sync-watch" "${BIN}/"

if [[ "${SKIP_WRAPPER}" -eq 0 ]]; then
  # Preserve real binary symlink if present and not already our wrapper.
  if [[ -L "${BIN}/agent" ]]; then
    target="$(readlink "${BIN}/agent")"
    if [[ "${target}" != *agent-desktop-auth-wrapper* ]]; then
      ln -sfn "${target}" "${BIN}/agent.real"
    fi
  elif [[ -x "${BIN}/agent" ]] && ! grep -q 'agent-desktop-auth-wrapper\|Desktop sync' "${BIN}/agent" 2>/dev/null; then
    mv "${BIN}/agent" "${BIN}/agent.real.bak"
  fi
  ln -sfn "${BIN}/agent-desktop-auth-wrapper" "${BIN}/agent"
  ln -sfn "${BIN}/agent-desktop-auth-wrapper" "${BIN}/cursor-agent"
  echo "install: agent / cursor-agent → agent-desktop-auth-wrapper"
fi

if [[ "${WITH_LAUNCHD}" -eq 1 ]]; then
  mkdir -p "${LAUNCH_AGENTS}"
  sed "s|__HOME__|${HOME}|g" \
    "${ROOT}/launchd/com.icatw.cursor-agent-desktop-sync.plist.template" \
    >"${PLIST}"
  launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "${PLIST}"
  launchctl enable "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  launchctl kickstart -k "gui/$(id -u)/${LABEL}" 2>/dev/null || true
  echo "install: launchd ${LABEL} loaded"
fi

echo "install: running one sync…"
"${BIN}/cursor-agent-sync-auth" || echo "install: sync failed (is Desktop logged in?)" >&2

echo
echo "Next:"
echo "  1. agent status"
echo "  2. Start Magpie (port 3425); enable opencode-cursor-auth"
echo "  3. Merge templates/codex/config.magpie.snippet.toml into ~/.codex/config.toml"
echo "  4. See docs/setup-new-machine.md"
