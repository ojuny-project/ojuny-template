#!/usr/bin/env bash
set -euo pipefail

mode="${1:-focused}"
monitors="$(mmsg get all-monitors)" || exit 1

focused_monitor() {
  mmsg get focusing-client 2>/dev/null |
    jq -r '.monitor // empty' 2>/dev/null |
    head -n 1 || true
}

cursor_monitor() {
  mmsg get cursorpos 2>/dev/null |
    jq -r '.monitor // empty' 2>/dev/null |
    head -n 1 || true
}

toggle_sleep() {
  mmsg dispatch "sleep_toggle_monitor,$1" >/dev/null
}

case "$mode" in
focused)
  name="$(focused_monitor)"
  [ -n "$name" ] || name="$(cursor_monitor)"
  [ -n "$name" ] || name="$(printf '%s' "$monitors" | jq -r '.monitors[] | select(.active == true) | .name' | head -n 1)"
  [ -n "$name" ] || exit 1
  toggle_sleep "$name"
  ;;
all)
  names="$(printf '%s' "$monitors" | jq -r '.monitors[].name')"
  [ -n "$names" ] || exit 1
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    toggle_sleep "$name"
  done <<<"$names"
  ;;
*)
  printf 'usage: %s [focused|all]\n' "$0" >&2
  exit 2
  ;;
esac
