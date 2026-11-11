# 12 - Flake module contract

Ojuny tools find files by the flake module they declare, not by a directory
under the template. A fork may keep `modules/07-system/`, flatten everything
into `modules/`, or use its own nested layout.

## Modules

| Generated content | Module name | Fallback when no module exists |
| --- | --- | --- |
| System settings | `flake.modules.nixos.system-configuration` | `modules/00-configuration.nix` |
| User account | `flake.modules.nixos.users` | `modules/00-user.nix` |
| Host imports | `flake.modules.nixos.host-imports` | `modules/00-imports.nix` |
| Hardware | `flake.modules.nixos.system-hardware` | `modules/00-hardware.nix` |
| Bootloader | `flake.modules.nixos.system-bootloader` | same hardware file |
| Hardware quirks | `flake.modules.nixos.system-hardware-quirks` | `modules/backend/00-hardware-quirks.nix` |
| Host | `flake.nixosConfigurations.<host>` | `modules/00-host.nix` |
| Facter report | no module | `modules/facter.json` |
| Multiboot switch | `ojuny.multiboot.enable` | no fallback; the feature stays off |

When a module exists, the tool rewrites that file and keeps its name and
location. When it does not exist, the tool writes the fallback under
`modules/`.

The facter report is found anywhere in the flake. If none exists,
`modules/facter.json` is used.

The imports module may live anywhere. The tool adds
`self.modules.nixos.<name>` to its first `imports = [ ... ];` list. The
fallback imports file defines `flake.modules.nixos.host-imports`.

## Selection

If more than one file declares the same module, an interactive caller is
asked to choose. Installer and unattended callers are non-interactive and
select the first sorted path. `prepare-repo` has `--select` for an explicit
choice.

## Flake location

`ojuny.repoPath` is the single source of truth for the installed flake
location. It defaults to `repos/nix-flake` under the primary user's home. The
system projects it to `/etc/ojuny/flake-path`; tools that need the installed
flake read that file. Do not hardcode another location.

## Constraints

- Follow `docs/05-settings-gui-limitations.md`: annotated options stay in a
  plain attribute set or directly inside `lib.mkIf`. Do not nest options in a
  list, `map`, `forEach`, `lib.mkMerge` or `lib.optionalAttrs`.
- Do not change `nix-settings-gui/src/scan.rs` to descend into lists or apply
  nodes. Change the module shape instead.
- A generated module must still be collected by the fork's flake and imported
  by the host imports module. The fallback files are collected by the template's
  `import-tree ./modules`; a fork with another collection mechanism must keep
  the same module names.
