#!/usr/bin/env python3
"""Reject fixed template paths in scripts that must use module detection."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FORBIDDEN = ("modules/07-system", "modules/01-users", "12-multiboot.nix")
ALLOW_LINE = "00-ssh-test.nix"
TARGETS = sorted(
    list((ROOT / "scripts").glob("*.py"))
    + list((ROOT / "scripts").glob("*.sh"))
)

failures = []
for path in TARGETS:
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if ALLOW_LINE in line:
            continue
        for value in FORBIDDEN:
            if value in line:
                failures.append(f"{path.relative_to(ROOT)}:{number}: {value}")

if failures:
    print("Fixed template paths are not allowed. Use docs/12-flake-module-contract.md.", file=sys.stderr)
    for failure in failures:
        print(failure, file=sys.stderr)
    sys.exit(1)

print("fixed-path gate: ok")
