#!/usr/bin/env python3
"""Fail when a shell wrapper calls python3 without adding pkgs.python3."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FLAKE = ROOT / "flake.nix"
WRAPPER = "pkgs.writeShellApplication"
READ_FILE = re.compile(r"builtins\.readFile\s+\./scripts/([A-Za-z0-9_.-]+)")
PYTHON = re.compile(r"(?<![\w.-])python3(?![\w.-])")


def skip_string(text, index):
    if text.startswith("''", index):
        index += 2
        while index < len(text):
            if text.startswith("''", index):
                if index + 2 < len(text) and text[index + 2] in "'$\\":
                    index += 3
                    continue
                return index + 2
            index += 1
        return len(text)
    index += 1
    while index < len(text):
        if text[index] == "\\":
            index += 2
            continue
        if text[index] == '"':
            return index + 1
        index += 1
    return len(text)


def skip_comment(text, index):
    if text[index] == "#":
        end = text.find("\n", index)
        return len(text) if end == -1 else end + 1
    if text.startswith("/*", index):
        end = text.find("*/", index + 2)
        return len(text) if end == -1 else end + 2
    return index


def matching_brace(text, opening):
    depth = 0
    index = opening
    while index < len(text):
        if text.startswith("''", index) or text[index] == '"':
            index = skip_string(text, index)
            continue
        if text[index] == "#" or text.startswith("/*", index):
            index = skip_comment(text, index)
            continue
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return -1


def wrapper_blocks(text):
    blocks = []
    index = 0
    while True:
        index = text.find(WRAPPER, index)
        if index == -1:
            return blocks
        brace = index + len(WRAPPER)
        while brace < len(text) and text[brace].isspace():
            brace += 1
        if brace < len(text) and text[brace] == "{":
            end = matching_brace(text, brace)
            if end != -1:
                blocks.append((index, end + 1))
        index += len(WRAPPER)


def without_nested(text, start, end, blocks):
    chars = list(text[start:end])
    for nested_start, nested_end in blocks:
        if start < nested_start and nested_end <= end:
            for index in range(nested_start - start, nested_end - start):
                chars[index] = " "
    return "".join(chars)


def main():
    text = FLAKE.read_text(encoding="utf-8")
    blocks = wrapper_blocks(text)
    failures = []
    for start, end in blocks:
        direct = without_nested(text, start, end, blocks)
        has_python = "pkgs.python3" in direct
        for match in READ_FILE.finditer(direct):
            script = ROOT / "scripts" / match.group(1)
            if script.suffix != ".sh":
                continue
            if PYTHON.search(script.read_text(encoding="utf-8")) and not has_python:
                failures.append(
                    f"{script.relative_to(ROOT)} uses python3; add pkgs.python3 to "
                    f"its writeShellApplication runtimeInputs"
                )
    if failures:
        print("Shell wrappers are missing python3 runtime inputs.", file=sys.stderr)
        for failure in sorted(set(failures)):
            print(failure, file=sys.stderr)
        return 1
    print("runtime-deps gate: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
