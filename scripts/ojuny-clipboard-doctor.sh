#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n== %s ==\n' "$*"
}

section "session"
printf 'XDG_SESSION_TYPE=%s\nWAYLAND_DISPLAY=%s\nDISPLAY=%s\n' \
  "${XDG_SESSION_TYPE:-}" "${WAYLAND_DISPLAY:-}" "${DISPLAY:-}"

section "clipboard processes"
pgrep -a -f 'wl-clip-persist|cliphist|wl-paste' || true

section "wayland clipboard types"
if command -v wl-paste >/dev/null 2>&1; then
  wl-paste --list-types 2>&1 || true
else
  printf 'wl-paste not found\n'
fi

section "wayland clipboard preview"
if command -v wl-paste >/dev/null 2>&1; then
  timeout 2 wl-paste --no-newline 2>/dev/null | head -c 200 || true
  printf '\n'
fi

section "wayland clipboard types by target"
if command -v wl-paste >/dev/null 2>&1; then
  for type in text/plain 'text/plain;charset=utf-8' 'text/plain;charset=UTF-8' UTF8_STRING; do
    printf '%s: ' "$type"
    timeout 2 wl-paste -t "$type" --no-newline 2>/dev/null | head -c 80 || true
    printf '\n'
  done
fi

section "x11 clipboard preview"
if command -v xclip >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  timeout 2 xclip -selection clipboard -o 2>/dev/null | head -c 200 || true
  printf '\n'
else
  printf 'xclip or DISPLAY unavailable\n'
fi

section "cliphist"
if command -v cliphist >/dev/null 2>&1; then
  cliphist list 2>/dev/null | head -n 10 || true
else
  printf 'cliphist not found\n'
fi

section "clients"
for name in codium vscodium ghostty; do
  pgrep -a -x "$name" || true
done

section "client protocols"
if command -v mmsg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  mmsg get all-clients 2>/dev/null |
    jq -r '.[] | select(.appid | test("codium|vscodium|ghostty")) | "\(.pid) \(.appid) xwayland=\(.is_xwayland) monitor=\(.monitor)"' ||
    true
fi
for pid in $(pgrep -f 'codium|vscodium|ghostty' || true); do
  if [ ! -r "/proc/$pid/environ" ]; then
    printf '%s unknown\n' "$pid"
    continue
  fi
  wayland="$(tr '\0' '\n' <"/proc/$pid/environ" | grep -c '^WAYLAND_DISPLAY=' || true)"
  x11="$(tr '\0' '\n' <"/proc/$pid/environ" | grep -c '^DISPLAY=' || true)"
  if [ "$wayland" -gt 0 ] && [ "$x11" -gt 0 ]; then
    printf '%s wayland+x11\n' "$pid"
  elif [ "$wayland" -gt 0 ]; then
    printf '%s wayland\n' "$pid"
  elif [ "$x11" -gt 0 ]; then
    printf '%s x11\n' "$pid"
  else
    printf '%s unknown\n' "$pid"
  fi
done

section "capture order"
printf 'Run this twice: once with VSCodium open first, once with the terminal open first.\n'
printf 'After each copy, record this output and the direction that failed.\n'
printf 'Also run: WAYLAND_DEBUG=1 codium >/tmp/codium-wayland.log 2>&1\n'
printf 'And: WAYLAND_DEBUG=1 ghostty >/tmp/ghostty-wayland.log 2>&1\n'
