#!/bin/bash

# Create links do dotfiles
cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
stow --adopt -t "$HOME" .

# Create links to etc files
cd "$HOME/git/arch-install-hyprland/etc" || exit
sudo stow --adopt -t /etc .

# Reset to master branch 
git reset --hard
git pull
cd "$HOME/git/arch-install-hyprland"
