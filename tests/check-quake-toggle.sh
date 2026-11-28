#!/usr/bin/env bash
set -euo pipefail

toggle="$1"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

export STATE="$work/state"
mkdir -p "$STATE"
printf '0\n' >"$STATE/visible"
printf 'HDMI-A-1\n' >"$STATE/monitor"

cat >"$work/bin/mmsg" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
printf '%s\n' "\$*" >>"\$MMSG_LOG"
case "\$*" in
  "get focusing-client")
    printf '{"monitor":"eDP-1"}\n'
    ;;
  "get all-clients")
    if [ "\$(cat "\$STATE/visible")" = "1" ]; then
      printf '[{"appid":"org.ojuny.quake","monitor":"%s","is_visible":true,"is_focused":true,"width":1344,"height":572,"x":0,"y":0}]\n' "\$(cat "\$STATE/monitor")"
    else
      printf '[]\n'
    fi
    ;;
  "get monitor eDP-1")
    printf '{"name":"eDP-1","x":0,"y":0,"width":1920,"height":1080}\n'
    ;;
  "get monitor HDMI-A-1")
    printf '{"name":"HDMI-A-1","x":1920,"y":0,"width":1920,"height":1080}\n'
    ;;
  "dispatch toggle_named_scratchpad,org.ojuny.quake,none,ghostty --class=org.ojuny.quake")
    printf '1\n' >"\$STATE/visible"
    ;;
  "dispatch tagmon,eDP-1")
    printf 'eDP-1\n' >"\$STATE/monitor"
    ;;
  "dispatch movewin,"*)
    ;;
  *)
    printf 'unexpected mmsg call: %s\n' "\$*" >&2
    exit 1
    ;;
esac
STUB
chmod +x "$work/bin/mmsg"
export PATH="$work/bin:$PATH"
export MMSG_LOG="$work/mmsg.log"

bash "$toggle" org.ojuny.quake none "ghostty --class=org.ojuny.quake" ||
  fail "the quake toggle failed"
grep -qx 'dispatch toggle_named_scratchpad,org.ojuny.quake,none,ghostty --class=org.ojuny.quake' "$MMSG_LOG" ||
  fail "the quake scratchpad was not toggled"
grep -qx 'dispatch tagmon,eDP-1' "$MMSG_LOG" ||
  fail "the quake window was not moved to the focused monitor"
grep -qx 'dispatch movewin,288,0' "$MMSG_LOG" ||
  fail "the quake window was not positioned at the top of the focused monitor"

printf 'ok: the quake terminal moves to the focused monitor and is positioned\n'
