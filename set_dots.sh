#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create directories needed for dotfiles
tree -dfi --noreport $SCRIPT_DIR/dotfiles | xargs -I {} mkdir -p "{}"
cd "$SCRIPT_DIR/dotfiles" || exit
# Create links to dotfiles
stow --adopt -t "$HOME" .

# Copy files to /etc
sudo cp -r $SCRIPT_DIR/etc/* /etc

# Reset to master branch
git reset --hard
git pull
cd "$SCRIPT_DIR"

sudo fc-cache -f
