#!/usr/bin/env bash
set -euo pipefail

watch_dir="$1"
autoconnect="$2"
autoconnect_profile="$3"
state_dir="/var/lib/ojuny/wireguard-imported"

install -d -m 0700 "$state_dir"

shopt -s nullglob
for file in "$watch_dir"/*.conf; do
  name="$(basename "$file" .conf)"
  checksum="$(sha256sum "$file" | cut -d' ' -f1)"
  previous="$(cat "$state_dir/$name" 2>/dev/null || true)"

  if [ "$checksum" = "$previous" ]; then
    continue
  fi

  if nmcli -t -f NAME connection show | grep -Fxq "$name"; then
    nmcli connection delete "$name" >/dev/null
  fi

  before="$(nmcli -t -f UUID,TYPE connection show | awk -F: '$2 == "wireguard" { print $1 }' | sort)"
  nmcli connection import type wireguard file "$file" >/dev/null
  after="$(nmcli -t -f UUID,TYPE connection show | awk -F: '$2 == "wireguard" { print $1 }' | sort)"
  imported="$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | head -n 1)"

  if [ -n "$imported" ]; then
    nmcli connection modify "$imported" connection.id "$name"
  fi

  printf '%s\n' "$checksum" >"$state_dir/$name"
done

for marker in "$state_dir"/*; do
  name="$(basename "$marker")"
  if [ ! -f "$watch_dir/$name.conf" ]; then
    if nmcli -t -f NAME connection show | grep -Fxq "$name"; then
      nmcli connection delete "$name" >/dev/null
    fi
    rm -f "$marker"
  fi
done

managed=()
for marker in "$state_dir"/*; do
  managed+=("$(basename "$marker")")
done

target="$autoconnect_profile"
if [ "$autoconnect" = "1" ] && [ -z "$target" ] && [ "${#managed[@]}" -gt 0 ]; then
  target="${managed[0]}"
fi

if [ "$autoconnect" = "1" ] && [ -n "$target" ]; then
  while IFS=: read -r name type; do
    if [ "$type" != "wireguard" ] && [ "$type" != "vpn" ]; then
      continue
    fi
    if [ "$name" = "$target" ]; then
      nmcli connection modify "$name" connection.autoconnect yes
      nmcli connection modify "$name" connection.autoconnect-priority 100
    else
      nmcli connection modify "$name" connection.autoconnect no
      nmcli connection modify "$name" connection.autoconnect-priority 0
    fi
  done < <(nmcli -t -f NAME,TYPE connection show)
else
  for name in "${managed[@]}"; do
    nmcli connection modify "$name" connection.autoconnect no
    nmcli connection modify "$name" connection.autoconnect-priority 0
  done
fi
