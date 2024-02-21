#!/bin/bash

cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
stow --adopt -t "$HOME" .
git restore .
git pull
cd "$HOME"
