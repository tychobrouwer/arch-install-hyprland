#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create links do dotfiles
cd "$SCRIPT_DIR/dotfiles" || exit
/bin/tree -dfia --noreport ./ | xargs -I {} mkdir -p "$HOME/{}"
stow --adopt -t "$HOME" .

# Copy files to /etc
sudo cp -r $SCRIPT_DIR/etc/* /etc

# Reset to master branch 
git reset --hard
git pull
cd "$SCRIPT_DIR"

# Update fonts
sudo fc-cache -f
