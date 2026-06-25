#!/usr/bin/env bash
# Grok hook: play a sound when an agent turn finishes (Stop / StopFailure / SessionEnd).
set -u

SOUND_NAME="${GROK_NOTIFY_SOUND:-Glass}"
SHOW_BANNER="${GROK_NOTIFY_BANNER:-1}"
SPEAK="${GROK_NOTIFY_SPEAK:-0}"

SOUND_FILE="/System/Library/Sounds/${SOUND_NAME}.aiff"
if [[ ! -f "$SOUND_FILE" ]]; then
  SOUND_FILE="/System/Library/Sounds/Glass.aiff"
fi

EVENT="${GROK_HOOK_EVENT:-stop}"
PROJECT="${GROK_WORKSPACE_ROOT:-${CLAUDE_PROJECT_DIR:-Grok}}"
PROJECT_NAME="$(basename "$PROJECT" 2>/dev/null || echo Grok)"
# sanitize for AppleScript string
PROJECT_NAME="${PROJECT_NAME//\"/\'}"

play_sound() {
  if command -v afplay >/dev/null 2>&1; then
    afplay "$SOUND_FILE" &
    return 0
  fi
  if command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
    return 0
  fi
  printf '\a' >&2
}

notify_banner() {
  [[ "$SHOW_BANNER" == "1" ]] || return 0
  command -v osascript >/dev/null 2>&1 || return 0
  osascript -e "display notification \"Agent turn finished (${EVENT})\" with title \"Grok — ${PROJECT_NAME}\" sound name \"${SOUND_NAME}\"" 2>/dev/null || true
}

speak_done() {
  [[ "$SPEAK" == "1" ]] || return 0
  command -v say >/dev/null 2>&1 || return 0
  say "Grok done" 2>/dev/null &
}

play_sound
notify_banner
speak_done
wait 2>/dev/null || true
exit 0
