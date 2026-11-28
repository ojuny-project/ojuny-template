#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/run"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

cat >"$work/bin/mmsg" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
printf '%s\n' "\$*" >>"\$MMSG_LOG"
case "\$1 \$2" in
  "get keymode")
    printf '{"keymode":"%s"}\n' "\${MMSG_KEYMODE:-default}"
    ;;
  "get focusing-client")
    if [ "\${MMSG_NO_CLIENT:-0}" = "1" ]; then
      printf '{"error":"no focused client"}\n'
      exit 1
    fi
    printf '%s\n' "\${MMSG_FOCUS:-}"
    ;;
  "get all-monitors")
    printf '%s\n' "\$MMSG_MONITORS"
    ;;
  "get cursorpos")
    printf '%s\n' "\${MMSG_CURSOR:-}"
    ;;
  "dispatch "*) ;;
  *)
    printf 'unexpected mmsg call: %s\n' "\$*" >&2
    exit 1
    ;;
esac
STUB

cat >"$work/bin/ydotool" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
printf '%s\n' "\$*" >>"\$YDOTOOL_LOG"
STUB

cat >"$work/bin/udisksctl" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
if [ "\$1" = "status" ]; then
  exit 0
fi
printf '%s\n' "\$*" >>"\$UDISKS_LOG"
STUB

cat >"$work/bin/lsblk" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
printf '%s\n' "\$LSBLK_JSON"
STUB

cat >"$work/bin/findmnt" <<STUB
#!${BASH:-/usr/bin/env bash}
set -euo pipefail
case "\$*" in
  *"-S /dev/sdd1"*) printf 'rw,uid=%s\n' "$(id -u)" ;;
  *"-S /dev/sdf1"*) printf 'rw,uid=9999\n' ;;
  *) exit 1 ;;
esac
STUB

chmod +x "$work/bin/mmsg" "$work/bin/ydotool" "$work/bin/udisksctl" "$work/bin/lsblk" "$work/bin/findmnt"
export PATH="$work/bin:$PATH"
export XDG_RUNTIME_DIR="$work/run"
export MMSG_LOG="$work/mmsg.log"
export YDOTOOL_LOG="$work/ydotool.log"
export UDISKS_LOG="$work/udisks.log"

focus_tiling='{"is_fullscreen":false,"is_floating":false}'
focus_floating='{"is_fullscreen":false,"is_floating":true}'
focus_fullscreen='{"is_fullscreen":true,"is_floating":false}'

run_middle() {
  local focus="$1"
  local floating="$2"
  local tiling="$3"
  : >"$MMSG_LOG"
  : >"$YDOTOOL_LOG"
  MMSG_FOCUS="$focus" bash "$here"/ojuny-middle-click.sh "$floating" "$tiling"
}

run_middle "$focus_tiling" maximize zoom || fail "the tiling middle click failed"
grep -qx 'dispatch zoom' "$MMSG_LOG" || fail "a tiled window was not zoomed"
grep -qx 'dispatch setkeymode,middle-click-passthrough' "$MMSG_LOG" ||
  fail "the middle click did not enter the pass-through mode"
grep -qx 'dispatch setkeymode,default' "$MMSG_LOG" ||
  fail "the middle click did not restore the previous key mode"
grep -qx 'click 0xC2' "$YDOTOOL_LOG" || fail "the middle click was not re-emitted"

run_middle "$focus_floating" maximize zoom || fail "the floating middle click failed"
grep -qx 'dispatch togglemaximizescreen,0' "$MMSG_LOG" ||
  fail "a floating window was not maximized"
grep -qx 'click 0xC2' "$YDOTOOL_LOG" || fail "the floating middle click was not re-emitted"

run_middle "$focus_fullscreen" maximize zoom || fail "the fullscreen middle click failed"
if grep -qx 'dispatch zoom' "$MMSG_LOG" || grep -qx 'dispatch togglemaximizescreen,0' "$MMSG_LOG"; then
  fail "a fullscreen window received a layout action"
fi
grep -qx 'click 0xC2' "$YDOTOOL_LOG" || fail "a fullscreen window did not receive the middle click"

run_middle "$focus_tiling" none none || fail "the disabled policy middle click failed"
if grep -qx 'dispatch zoom' "$MMSG_LOG" || grep -qx 'dispatch togglemaximizescreen,0' "$MMSG_LOG"; then
  fail "a disabled policy still applied a layout action"
fi
grep -qx 'click 0xC2' "$YDOTOOL_LOG" || fail "a disabled policy did not re-emit the click"

: >"$MMSG_LOG"
: >"$YDOTOOL_LOG"
MMSG_NO_CLIENT=1 MMSG_FOCUS='' bash "$here"/ojuny-middle-click.sh maximize zoom ||
  fail "the no-client middle click failed"
if [ -s "$YDOTOOL_LOG" ]; then
  fail "a middle click with no focused window was re-emitted"
fi

export MMSG_MONITORS='{"monitors":[{"name":"eDP-1","active":true},{"name":"HDMI-A-1","active":false}]}'
export MMSG_FOCUS=''
export MMSG_CURSOR=''
: >"$MMSG_LOG"
bash "$here"/ojuny-display-toggle.sh focused || fail "the focused display toggle failed"
grep -qx 'dispatch sleep_toggle_monitor,eDP-1' "$MMSG_LOG" ||
  fail "the focused monitor was not slept"
if grep -q 'dispatch toggle_monitor' "$MMSG_LOG"; then
  fail "the display toggle used toggle_monitor"
fi
if grep -qx 'dispatch reload_config' "$MMSG_LOG"; then
  fail "the display toggle reloaded the layout"
fi
if grep -q 'wlr-randr' "$MMSG_LOG"; then
  fail "the display toggle tried to restore positions"
fi

export MMSG_CURSOR='{"monitor":"HDMI-A-1"}'
: >"$MMSG_LOG"
bash "$here"/ojuny-display-toggle.sh focused || fail "the cursor display toggle failed"
grep -qx 'dispatch sleep_toggle_monitor,HDMI-A-1' "$MMSG_LOG" ||
  fail "the monitor under the cursor was not slept"

export MMSG_MONITORS='{"monitors":[{"name":"eDP-1","active":true},{"name":"HDMI-A-1","active":true}]}'
export MMSG_FOCUS=''
export MMSG_CURSOR=''
: >"$MMSG_LOG"
bash "$here"/ojuny-display-toggle.sh all || fail "the all-displays toggle failed"
grep -qx 'dispatch sleep_toggle_monitor,eDP-1' "$MMSG_LOG" ||
  fail "all-displays skipped eDP-1"
grep -qx 'dispatch sleep_toggle_monitor,HDMI-A-1' "$MMSG_LOG" ||
  fail "all-displays skipped HDMI-A-1"
if grep -qx 'dispatch reload_config' "$MMSG_LOG"; then
  fail "the all-displays toggle reloaded the layout"
fi

home="$work/home"
theme_source="$work/theme"
mkdir -p "$home" "$theme_source"
printf '{"name":"Adwaita"}\n' >"$theme_source/skin.json"
printf ':root { --adw-window-bg: #2d353b; }\n' >"$work/stylix.css"
HOME="$home" bash "$here"/ojuny-steam-theme.sh "$theme_source" Adwaita "$work/stylix.css" ||
  fail "the Steam theme install failed"
[ -L "$home/.local/share/Steam/millennium/themes/Adwaita" ] || fail "the Steam theme was not linked"
[ "$(readlink "$home/.local/share/Steam/millennium/themes/Adwaita")" = "$theme_source" ] ||
  fail "the Steam theme link points at the wrong path"
jq -e '.themes.activeTheme == "Adwaita"' "$home/.config/millennium/config.json" ||
  fail "the Steam theme was not selected"
grep -q -- '--adw-window-bg: #2d353b' "$home/.config/millennium/quick.css" ||
  fail "the Stylix CSS was not installed"

printf '{"name":"millennium"}\n' >"$home/.config/millennium/config.json"
HOME="$home" bash "$here"/ojuny-steam-theme.sh "$theme_source" Adwaita ||
  fail "the Steam theme install without a themes key failed"
jq -e '.themes.activeTheme == "Adwaita"' "$home/.config/millennium/config.json" ||
  fail "the Steam theme was not selected without a themes key"

printf '{"themes":{"activeTheme":"default"}}\n' >"$home/.config/millennium/config.json"
HOME="$home" bash "$here"/ojuny-steam-theme.sh "$theme_source" Adwaita ||
  fail "the Steam theme install with the default value failed"
jq -e '.themes.activeTheme == "Adwaita"' "$home/.config/millennium/config.json" ||
  fail "the Steam theme did not replace the default value"

printf '{"themes":{"activeTheme":"Other"}}\n' >"$home/.config/millennium/config.json"
HOME="$home" bash "$here"/ojuny-steam-theme.sh "$theme_source" Adwaita ||
  fail "the second Steam theme install failed"
jq -e '.themes.activeTheme == "Other"' "$home/.config/millennium/config.json" ||
  fail "the Steam theme install overwrote an existing choice"

printf 'ok: middle click, display toggle and Steam theme scripts\n'
