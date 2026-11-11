#!/usr/bin/env zsh

function plz() {
    if [ -z "$1" ]; then
        sudo $(fc -ln 1 | tail -1)
    else
        sudo "$@"
    fi
}

export IMAGEPROGRAM='satty --filename'

alias -s json=$EDITOR
alias -s yaml=$EDITOR
alias -s md=$EDITOR
alias -s toml=$EDITOR
alias -s conf=$EDITOR
alias -s yml=$EDITOR
alias -s txt=$EDITOR
alias -s css=$EDITOR
alias -s html=$EDITOR
alias -s png=$IMAGEPROGRAM
alias -s jpg=$IMAGEPROGRAM
alias -s jpeg=$IMAGEPROGRAM
alias -s webp=$IMAGEPROGRAM
alias -s nix=$EDITOR
