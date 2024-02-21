#!/bin/bash

cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
stow --adopt -t "$HOME" .
git reset --hard
git pull
cd "$HOME"
