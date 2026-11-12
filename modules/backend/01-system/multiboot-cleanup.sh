helper_dir="${OJUNY_HELPER_DIR:?}"
entry_file="${OJUNY_ENTRY_FILE:?}"
boot_mount="${OJUNY_BOOT_MOUNT:-}"
sbctl_conf="${OJUNY_SBCTL_CONF:-/var/lib/ojuny/sbctl.conf}"

remove_database_entry() {
    local file="$1"
    command -v sbctl >/dev/null 2>&1 || return 0
    if [ -f "$sbctl_conf" ]; then
        sbctl --config "$sbctl_conf" --disable-landlock remove-file "$file" >/dev/null 2>&1 || true
    else
        sbctl --disable-landlock remove-file "$file" >/dev/null 2>&1 || true
    fi
}

remove_database_entry "$helper_dir/refind_x64.efi"

if [ -d "$helper_dir" ]; then
    rm -rf "$helper_dir"
fi
if [ -f "$entry_file" ]; then
    rm -f "$entry_file"
fi
if [ -n "$boot_mount" ] && [ -d "$boot_mount/EFI/ojuny" ]; then
    rmdir "$boot_mount/EFI/ojuny" 2>/dev/null || true
fi
