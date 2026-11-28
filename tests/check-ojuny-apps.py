#!/usr/bin/env python3
"""Check the Ojuny-owned application and desktop page shapes."""

import argparse
import pathlib
import sys


def require(text, needle, path, errors):
    if needle not in text:
        errors.append(f"{path}: missing {needle}")


def forbid(text, needle, path, errors):
    if needle in text:
        errors.append(f"{path}: must not contain {needle}")


def check(root):
    root = pathlib.Path(root)
    errors = []
    office = (root / "modules/05-applications/03-office.nix").read_text()
    vesktop = (root / "modules/05-applications/04-vesktop.nix").read_text()
    steam = (root / "modules/05-applications/05-steam.nix").read_text()
    screenshot = (root / "modules/05-applications/07-screenshot.nix").read_text()
    qr = (root / "scripts/ojuny-capture-qr").read_text()
    accessibility = (root / "modules/07-system/08-accessibility.nix").read_text()
    accessibility_backend = (root / "modules/backend/01-system/08-accessibility-backend.nix").read_text()
    fastfetch = (root / "modules/backend/02-core/08-terminal-backend.nix").read_text()
    raven = (root / "modules/backend/05-applications/08-appimage-raven-backend.nix").read_text()
    mangosettings = (root / "modules/03-desktop/02-mangosettings.nix").read_text()

    forbid(office, "craftAll", "03-office.nix", errors)
    require(office, "figcraft.enable = false", "03-office.nix", errors)
    require(office, "craft-anything.enable = false", "03-office.nix", errors)
    require(office, 'itemType = "string"', "03-office.nix", errors)
    require(office, "apps.figcraft.enable", "03-office.nix", errors)
    require(office, "apps.craft-anything.enable", "03-office.nix", errors)

    require(vesktop, "autostart", "04-vesktop.nix", errors)
    require(vesktop, "vesktop --start-minimized", "04-vesktop.nix", errors)
    require(steam, "autostart", "05-steam.nix", errors)
    require(steam, "steam -silent", "05-steam.nix", errors)

    require(screenshot, '"SUPER"', "07-screenshot.nix", errors)
    require(screenshot, '"ALT"', "07-screenshot.nix", errors)
    require(screenshot, "Super+Alt+Q", "07-screenshot.nix", errors)
    forbid(qr, "--sensitive", "ojuny-capture-qr", errors)
    require(qr, "wl-copy", "ojuny-capture-qr", errors)

    require(accessibility, "ydotool click 0xC0", "08-accessibility.nix", errors)
    require(accessibility, "ydotool click 0xC1", "08-accessibility.nix", errors)
    require(accessibility, "ydotool click 0xC2", "08-accessibility.nix", errors)
    forbid(accessibility, "ydotool click 0x00", "08-accessibility.nix", errors)

    for label in ("Shell", "Terminal", "Terminal Font", "Disk", "Board"):
        marker = f'key = "'
        found = False
        for line in fastfetch.splitlines():
            if marker in line and label in line and "key =" in line:
                value = line.split('"')[1]
                found = any(ord(char) > 127 for char in value)
                break
        if not found:
            errors.append(f"08-terminal-backend.nix: {label} key has no icon glyph")
    require(fastfetch, "├󰓡 Swap", "08-terminal-backend.nix", errors)
    require(fastfetch, "Local Repo", "08-terminal-backend.nix", errors)
    require(fastfetch, "Remote Repo", "08-terminal-backend.nix", errors)
    require(fastfetch, "Ojuny Base", "08-terminal-backend.nix", errors)
    require(fastfetch, 'text = "git -C', "08-terminal-backend.nix", errors)
    forbid(fastfetch, 'command = "git -C', "08-terminal-backend.nix", errors)
    require(fastfetch, "cudaSupport = true", "08-terminal-backend.nix", errors)
    require(fastfetch, 'show_gpu_info = "On"', "08-terminal-backend.nix", errors)
    require(fastfetch, 'if [ "$EUID" -eq 0 ]', "08-terminal-backend.nix", errors)
    require(fastfetch, 'exec ${pkgs.coreutils}/bin/rm "$@"', "08-terminal-backend.nix", errors)
    require(fastfetch, 'rm = "${rmShim}/bin/rm";', "08-terminal-backend.nix", errors)
    forbid(fastfetch, 'rm = "rmtrash";', "08-terminal-backend.nix", errors)

    require(mangosettings, 'itemType = "string"', "02-mangosettings.nix", errors)
    browser = (root / "modules/backend/02-core/06-browser-backend.nix").read_text()
    require(browser, "seed-firefox-extension-storage", "06-browser-backend.nix", errors)
    require(browser, "seed-extension-storage", "06-browser-backend.nix", errors)
    firefox_storage = (root / "scripts/seed-firefox-extension-storage.sh").read_text()
    require(
        firefox_storage,
        "browser-extension-data/sponsorBlocker@ajay.app",
        "seed-firefox-extension-storage.sh",
        errors,
    )
    require(
        firefox_storage,
        '"alreadyInstalled":true',
        "seed-firefox-extension-storage.sh",
        errors,
    )
    chromium_storage = (root / "scripts/seed-extension-storage.cc").read_text()
    require(chromium_storage, '"alreadyInstalled"', "seed-extension-storage.cc", errors)
    require(chromium_storage, '"userID"', "seed-extension-storage.cc", errors)
    accessibility = (root / "modules/07-system/08-accessibility.nix").read_text()
    tray = (root / "scripts/ojuny-osk-tray.py").read_text()
    require(accessibility, "services.ojuny-wvkbd", "08-accessibility.nix", errors)
    require(accessibility, "colors = self.colors config.lib.stylix.colors", "08-accessibility.nix", errors)
    development = (root / "modules/patches/patch-development.nix").read_text()
    require(development, '"directory":"${flakeRoot}"', "patch-development.nix", errors)
    require(accessibility, "ojuny-osk-toggle", "08-accessibility.nix", errors)
    require(tray, "input-keyboard-symbolic", "ojuny-osk-tray.py", errors)
    require(accessibility, "ojuny.accessibility.onScreenKeyboard.enable = true;", "08-accessibility.nix", errors)
    require(
        accessibility_backend,
        'default = true;\n            description = "Install and run the themed wvkbd on-screen keyboard.";',
        "08-accessibility-backend.nix",
        errors,
    )
    require(raven, "--execution=native --exit-code-fd=3", "08-appimage-raven-backend.nix", errors)
    require(raven, "Guest exit code:", "08-appimage-raven-backend.nix", errors)
    if "dms ipc call virtualKeyboard toggle" in accessibility:
        errors.append("08-accessibility.nix: the DMS virtual keyboard bind is still present")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    args = parser.parse_args()
    errors = check(args.root)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
