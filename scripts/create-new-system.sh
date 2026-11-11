#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${OJUNY_ROOT:-$PWD}"
HELPER="$REPO_ROOT/scripts/flake_structure.py"

state_version="26.11"
for arg in "$@"; do
  case "$arg" in
  --force) ;;
  --state-version=*) state_version="${arg#*=}" ;;
  *)
    echo "create-new-system: unknown argument: $arg" >&2
    exit 2
    ;;
  esac
done

read -rp "Hostname [ojuny]: " hostname
hostname="${hostname:-ojuny}"

clone_path="${OJUNY_CLONE_PATH:-repos/nix-flake}"

python3 "$HELPER" --root "$REPO_ROOT" --non-interactive ensure-configuration \
  --hostname "$hostname" \
  --state-version "$state_version" \
  --repo-path "$clone_path" >/dev/null

python3 "$HELPER" --root "$REPO_ROOT" --non-interactive host \
  --hostname "$hostname" \
  --clone-path "$clone_path" >/dev/null

echo "create-new-system: wired nixosConfigurations.$hostname"
