#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

nix flake check --no-build
nix build .#nixosConfigurations.fixture.config.system.build.toplevel --no-link
nix build .#prepare-repo .#regenerate-hardware --no-link
nix build .#ojuny-cli .#ojuny-patches-cli --no-link

printf 'template baseline ok: %s\n' "$(git rev-parse --short HEAD)"
