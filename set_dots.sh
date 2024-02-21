#!/bin/bash

# Create links do dotfiles
cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
stow --adopt -t "$HOME" .

# Copy files to /etc
cp -r $HOME/git/arch-install-hyprland/etc/* /etc

# Reset to master branch 
git reset --hard
git pull
cd "$HOME/git/arch-install-hyprland"
