#!/usr/bin/env bash

clear

flakepath="$OJUNY_REPO_PATH"

sudo echo "rebuilding configuration $(hostname) using path $flakepath"
git -C $flakepath pull

if which nom 2>&1 > /dev/null; then
    sudo nixos-rebuild switch --flake $flakepath#$(hostname) |& nom
else
    sudo nixos-rebuild switch --flake $flakepath#$(hostname)
fi

if mmsg get cursorpos 2>&1 > /dev/null; then
    dms kill > /dev/null
    mmsg dispatch spawn_shell,dms run > /dev/null
fi
