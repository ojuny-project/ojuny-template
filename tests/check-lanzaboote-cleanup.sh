#!/usr/bin/env bash
# Exercise modules/backend/01-system/lanzaboote-cleanup.sh on a fake ESP.
set -uo pipefail

SCRIPT="${SCRIPT:-$(dirname "$0")/../modules/backend/01-system/lanzaboote-cleanup.sh}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

ESP="$WORK/esp"
mkdir -p "$ESP/EFI/Linux" "$ESP/EFI/nixos"

touch \
    "$ESP/EFI/Linux/nixos-generation-1.efi" \
    "$ESP/EFI/Linux/nixos-generation-2.efi" \
    "$ESP/EFI/nixos/kernel-abc123.efi" \
    "$ESP/EFI/nixos/initrd-abc123.efi" \
    "$ESP/EFI/nixos/nixos-generation-1-linux-6.12-bzImage.efi" \
    "$ESP/EFI/nixos/nixos-generation-1-initrd-linux-6.12.efi"

OJUNY_BOOT_MOUNT="$ESP" bash "$SCRIPT"
OJUNY_BOOT_MOUNT="$ESP" bash "$SCRIPT"

FAILED=0

expect_absent() {
    [ ! -e "$ESP/EFI/$1" ] || {
        printf 'FAIL: %s survived\n' "$1" >&2
        FAILED=$((FAILED + 1))
    }
}

expect_present() {
    [ -e "$ESP/EFI/$1" ] || {
        printf 'FAIL: %s was removed\n' "$1" >&2
        FAILED=$((FAILED + 1))
    }
}

expect_absent "Linux/nixos-generation-1.efi"
expect_absent "Linux/nixos-generation-2.efi"
expect_absent "nixos/kernel-abc123.efi"
expect_absent "nixos/initrd-abc123.efi"
expect_present "nixos/nixos-generation-1-linux-6.12-bzImage.efi"
expect_present "nixos/nixos-generation-1-initrd-linux-6.12.efi"

if [ "$FAILED" -eq 0 ]; then
    printf 'lanzaboote cleanup passed\n'
else
    exit 1
fi
