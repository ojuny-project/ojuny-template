boot_mount="${OJUNY_BOOT_MOUNT:?}"
linux_dir="$boot_mount/EFI/Linux"
nixos_dir="$boot_mount/EFI/nixos"
removed=0

for uki in "$linux_dir"/nixos-generation-*.efi; do
    [ -f "$uki" ] || continue
    rm -f "$uki"
    removed=$((removed + 1))
done
for stub in "$nixos_dir"/kernel-*.efi "$nixos_dir"/initrd-*.efi; do
    [ -f "$stub" ] || continue
    rm -f "$stub"
    removed=$((removed + 1))
done

if [ "$removed" -gt 0 ]; then
    echo "ojuny-lanzaboote-cleanup: removed $removed stale files" >&2
    sync
fi
