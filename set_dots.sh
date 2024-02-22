#!/bin/bash

# Create links do dotfiles
tree -dfi --noreport $HOME/git/arch-install-hyprland/dotfiles | xargs -I {} mkdir -p "$HOME/{}"
cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
stow --adopt -t "$HOME" .

# Copy files to /etc
sudo cp -r $HOME/git/arch-install-hyprland/etc/* /etc

# Reset to master branch 
git reset --hard
git pull
cd "$HOME/git/arch-install-hyprland"

sudo fc-cache -f
