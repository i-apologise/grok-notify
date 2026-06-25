#!/usr/bin/env bash
# Install Grok finish notifications into ~/.grok/hooks/
#
# Quick start:
#   ./install.sh --test
#
# Other:
#   ./install.sh              install only
#   ./install.sh --uninstall  remove
#   ./install.sh --help
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
HOOKS_DIR="${HOME}/.grok/hooks"
SCRIPTS_DIR="${HOOKS_DIR}/scripts"
HOOK_NAME="notify-on-stop.json"
SCRIPT_NAME="notify-done.sh"

usage() {
  cat <<'EOF'
Grok notify — sound/notification when an agent turn finishes

Usage:
  ./install.sh              Install hooks into ~/.grok/hooks/
  ./install.sh --test       Install and play 3 test sounds
  ./install.sh --uninstall  Remove installed files
  ./install.sh --help       Show this help

After install: restart Grok, then Ctrl+L → Hooks → confirm "notify-on-stop".

Optional env (set before starting Grok):
  GROK_NOTIFY_SOUND=Ping    # Glass, Ping, Hero, Purr, Sosumi, Basso, ...
  GROK_NOTIFY_BANNER=0      # 1=macOS banner (default), 0=sound only
  GROK_NOTIFY_SPEAK=1       # 1=speak "Grok done"
EOF
  exit "${1:-0}"
}

need_file() {
  if [[ ! -f "$1" ]]; then
    echo "error: missing $1" >&2
    echo "Run install.sh from inside the cloned repo (not a partial copy)." >&2
    exit 1
  fi
}

uninstall() {
  rm -f "${HOOKS_DIR}/${HOOK_NAME}"
  rm -f "${SCRIPTS_DIR}/${SCRIPT_NAME}"
  rmdir "${SCRIPTS_DIR}" 2>/dev/null || true
  echo "Removed hooks (if they existed)."
  echo "Restart Grok so hooks reload."
  exit 0
}

install_files() {
  need_file "${SCRIPT_DIR}/scripts/${SCRIPT_NAME}"
  need_file "${SCRIPT_DIR}/hooks/${HOOK_NAME}"

  if [[ ! -d "${HOME}/.grok" ]]; then
    echo "warning: ~/.grok not found. Install Grok first: https://x.ai/cli" >&2
  fi

  mkdir -p "$SCRIPTS_DIR"
  if command -v install >/dev/null 2>&1; then
    install -m 0755 "${SCRIPT_DIR}/scripts/${SCRIPT_NAME}" "${SCRIPTS_DIR}/${SCRIPT_NAME}"
    install -m 0644 "${SCRIPT_DIR}/hooks/${HOOK_NAME}" "${HOOKS_DIR}/${HOOK_NAME}"
  else
    cp "${SCRIPT_DIR}/scripts/${SCRIPT_NAME}" "${SCRIPTS_DIR}/${SCRIPT_NAME}"
    chmod 0755 "${SCRIPTS_DIR}/${SCRIPT_NAME}"
    cp "${SCRIPT_DIR}/hooks/${HOOK_NAME}" "${HOOKS_DIR}/${HOOK_NAME}"
    chmod 0644 "${HOOKS_DIR}/${HOOK_NAME}"
  fi

  echo "✓ Installed:"
  echo "    ${HOOKS_DIR}/${HOOK_NAME}"
  echo "    ${SCRIPTS_DIR}/${SCRIPT_NAME}"
}

test_sounds() {
  echo ""
  echo "Playing test sounds (Glass → Ping → Hero)..."
  "${SCRIPTS_DIR}/${SCRIPT_NAME}" || true
  sleep 0.45
  GROK_NOTIFY_SOUND=Ping "${SCRIPTS_DIR}/${SCRIPT_NAME}" || true
  sleep 0.45
  GROK_NOTIFY_SOUND=Hero "${SCRIPTS_DIR}/${SCRIPT_NAME}" || true
  echo "✓ Test finished. If silent: check volume, Focus, Do Not Disturb."
}

next_steps() {
  cat <<'EOF'

Next steps:
  1. Restart Grok (or start a new session)
  2. Press Ctrl+L → open Hooks tab → confirm "notify-on-stop" is listed
  3. Send a prompt; when the agent stops, you should hear a sound

Manual test anytime:
  ~/.grok/hooks/scripts/notify-done.sh
EOF
}

ACTION="install"
for arg in "$@"; do
  case "$arg" in
    -h|--help|help) usage 0 ;;
    --uninstall|-u|uninstall) ACTION="uninstall" ;;
    --test|-t|test) ACTION="test" ;;
    install) ACTION="install" ;;
    *)
      echo "unknown option: $arg" >&2
      usage 1
      ;;
  esac
done

case "$ACTION" in
  uninstall) uninstall ;;
  install)
    install_files
    next_steps
    ;;
  test)
    install_files
    test_sounds
    next_steps
    ;;
esac
