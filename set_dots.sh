#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create links do dotfiles
tree -dfi --noreport $SCRIPT_DIR/dotfiles | xargs -I {} mkdir -p "$HOME/{}"
cd "$SCRIPT_DIR/dotfiles" || exit
stow --adopt -t "$HOME" .

# Copy files to /etc
sudo cp -r $SCRIPT_DIR/etc/* /etc

# Reset to master branch 
git reset --hard
git pull
cd "$SCRIPT_DIR"

sudo fc-cache -f
