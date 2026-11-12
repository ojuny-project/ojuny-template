#!/usr/bin/env python3
"""Reject sbctl verify calls that use the exit status as the signature result."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERIFY = re.compile(r"\bsbctl(?:_cmd)?\b[^\n|&;]*\bverify\b")


def main() -> int:
    failed = []
    for path in sorted((ROOT / "modules/backend").rglob("*.sh")):
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if not VERIFY.search(line):
                continue
            if "--json" in line:
                continue
            failed.append("{}:{}: {}".format(path.relative_to(ROOT), number, line.strip()))
    for entry in failed:
        print(entry)
    if failed:
        print("sbctl verify must use --json and parse is_signed")
        return 1
    print("sbctl verify gate: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
