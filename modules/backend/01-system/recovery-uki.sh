recovery_dir="${OJUNY_RECOVERY_DIR:?}"
recovery_file="${OJUNY_RECOVERY_FILE:?}"
manifest="${OJUNY_MANIFEST:?}"
pki_bundle="${OJUNY_PKI_BUNDLE:-}"
ukify="${OJUNY_UKIFY:?}"
sbctl_conf="$(dirname "$manifest")/sbctl.conf"

sbctl_cmd() {
    if [ -f "$sbctl_conf" ]; then
        sbctl --config "$sbctl_conf" "$@"
    else
        sbctl "$@"
    fi
}

efi_is_signed() {
    sbctl_cmd --json verify "$1" 2>/dev/null |
        jq -e 'type == "array" and length == 1 and .[0].is_signed == 1' >/dev/null
}

install -d "$recovery_dir" "$(dirname "$manifest")"

toplevel="${OJUNY_TOPLEVEL:-$(readlink -f /run/current-system)}"
boot_json="$toplevel/boot.json"
if [ ! -f "$boot_json" ]; then
    boot_json="/nix/var/nix/profiles/system/boot.json"
fi
if [ ! -f "$boot_json" ]; then
    echo "ojuny-recovery: no bootspec document found" >&2
    exit 1
fi

build_id="ukify-v1"
marker="$recovery_dir/.ojuny-recovery-version"
marker_value="$build_id:$toplevel"
if [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$marker_value" ] || [ ! -f "$recovery_file" ]; then
    kernel="$(jq -r '."org.nixos.bootspec.v1".kernel // empty' "$boot_json")"
    initrd="$(jq -r '."org.nixos.bootspec.v1".initrd // empty' "$boot_json")"
    init="$(jq -r '."org.nixos.bootspec.v1".init // empty' "$boot_json")"
    params="$(jq -r '(."org.nixos.bootspec.v1".kernelParams // []) | join(" ")' "$boot_json")"
    if [ -z "$kernel" ] || [ -z "$init" ]; then
        echo "ojuny-recovery: bootspec document is missing kernel or init" >&2
        exit 1
    fi
    cmdline="init=$init${params:+ $params}"

    ukify_args=(
        build
        --linux "$kernel"
        --cmdline "$cmdline"
        --os-release /etc/os-release
        --output "$recovery_file.tmp"
    )
    if [ -n "$initrd" ]; then
        ukify_args+=(--initrd "$initrd")
    fi

    "$ukify" "${ukify_args[@]}"
    install -m 0644 "$recovery_file.tmp" "$recovery_file"
    rm -f "$recovery_file.tmp"
    printf '%s\n' "$marker_value" >"$marker"
fi

signed="not-required"
if [ -d "$pki_bundle/keys" ]; then
    install -d "$(dirname "$sbctl_conf")"
    {
        printf 'keydir: %s/keys\n' "$pki_bundle"
        printf 'guid: %s/GUID\n' "$pki_bundle"
        printf 'files_db: %s/files.json\n' "$pki_bundle"
        printf 'bundles_db: %s/bundles.json\n' "$pki_bundle"
    } >"$sbctl_conf.tmp"
    mv "$sbctl_conf.tmp" "$sbctl_conf"

    key_marker="$recovery_dir/.ojuny-recovery-key"
    key_id="$(sha256sum "$pki_bundle/keys/db/db.pem" 2>/dev/null | cut -d" " -f1 || true)"
    if ! efi_is_signed "$recovery_file"; then
        sbctl_cmd sign -s "$recovery_file" || true
    fi
    if efi_is_signed "$recovery_file"; then
        signed="signed"
        if [ -n "$key_id" ]; then
            printf '%s\n' "$key_id" >"$key_marker"
        fi
    else
        echo "ojuny-recovery: $recovery_file is not signed" >&2
        signed="unsigned"
    fi
fi

jq -n \
    --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg toplevel "$toplevel" \
    --arg uki "$recovery_file" \
    --arg signed "$signed" \
    '{schema:1,generated_at:$generated_at,enabled:true,toplevel:$toplevel,uki:$uki,signed:$signed}' \
    >"$manifest.tmp"
mv "$manifest.tmp" "$manifest"

sync
