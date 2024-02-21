#!/bin/bash

cd $HOME/git/arch-install-hyprland
stow --adopt -t $HOME/.config/ config
git restore .
