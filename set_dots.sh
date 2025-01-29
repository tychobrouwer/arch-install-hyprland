#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Create directories needed for dotfiles
cd "$SCRIPT_DIR/dotfiles" || exit
find . -type d -exec mkdir -p $HOME/{} \;
# Create links to dotfiles
stow --adopt --restow -t "$HOME" .

# Copy files to /etc
# sudo cp -r $SCRIPT_DIR/etc/* /etc

# Reset to master branch
# git reset --hard
# git pull
# cd "$SCRIPT_DIR"

# sudo fc-cache -f
