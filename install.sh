#!/bin/bash

cd ~/git/arch-install-hyprland
stow --adopt -t $HOME/.config/ config
git restore .

# Install liboft, otf-font-awesome, ttf-roboto-mono-nerd, foot, stow, hyprpaper
