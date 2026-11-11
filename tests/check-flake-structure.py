#!/usr/bin/env python3
"""Exercise the flake module contract used by install and generation tools."""

import sys
import tempfile
import textwrap
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import flake_structure


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(textwrap.dedent(text).lstrip(), encoding="utf-8")


def canonical():
    root = Path(tempfile.mkdtemp(prefix="ojuny-contract-"))
    write(root / "modules/07-system/00-imports.nix", """
        { self, ... }: { flake.modules.nixos.host-imports = { imports = [ ]; }; }
    """)
    write(root / "modules/07-system/01-configuration.nix", """
        { ... }: { flake.modules.nixos.system-configuration = { ... }: { config = { networking.hostName = "old"; system.stateVersion = "25.11"; }; }; }
    """)
    write(root / "modules/07-system/00-hardware.nix", """
        { ... }: { flake.modules.nixos.system-hardware = { ... }: { }; }
    """)
    write(root / "modules/01-users/01-user.nix", """
        { ... }: { flake.modules.nixos.users = { ... }: { }; }
    """)
    write(root / "modules/07-system/00-host.nix", """
        { self, inputs, ... }: { flake.nixosConfigurations.alpha = inputs.nixpkgs.lib.nixosSystem { modules = [ self.modules.nixos.host-imports ]; }; }
    """)
    return root


def main():
    root = canonical()
    assert flake_structure.find_modules(root, "users") == [
        root / "modules/01-users/01-user.nix"
    ]
    assert flake_structure.find_host(root, "alpha") == [
        root / "modules/07-system/00-host.nix"
    ]

    flake_structure.ensure_configuration(
        root,
        {
            "hostname": "alpha",
            "state_version": "26.11",
            "timezone": "Europe/Amsterdam",
        },
        interactive=False,
    )
    configuration = (root / "modules/07-system/01-configuration.nix").read_text()
    assert 'networking.hostName = "alpha";' in configuration
    assert 'system.stateVersion = "26.11";' in configuration

    flake_structure.ensure_facter(root, "{}\n", interactive=False)
    assert (root / "modules/facter.json").is_file()

    flake_structure.ensure_host(
        root,
        "beta",
        "/home/user/repos/nix-flake",
        interactive=False,
    )
    assert flake_structure.find_host(root, "beta") == [root / "modules/00-host.nix"]

    flake_structure.ensure_multiboot(root, interactive=False) is False

    write(root / "modules/07-system/00-secureboot.nix", """
        { ... }: { config = { ojuny.multiboot.enable = false; }; }
    """)
    assert flake_structure.ensure_multiboot(root, interactive=False) is True
    assert "ojuny.multiboot.enable = true;" in (
        root / "modules/07-system/00-secureboot.nix"
    ).read_text()

    flat = Path(tempfile.mkdtemp(prefix="ojuny-contract-flat-"))
    assert flake_structure.find_modules(flat, "users") == []
    flake_structure.ensure_users(flat, "{ ... }: { }\n", interactive=False)
    assert (flat / "modules/00-user.nix").is_file()

    flake_structure.ensure_imports(
        flat, ["users", "system-hardware"], interactive=False
    )
    imports = (flat / "modules/00-imports.nix").read_text()
    assert "self.modules.nixos.users" in imports
    assert "self.modules.nixos.system-hardware" in imports

    print("flake structure contract: ok")


if __name__ == "__main__":
    main()
