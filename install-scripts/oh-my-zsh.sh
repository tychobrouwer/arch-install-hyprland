#!/bin/bash

dir="/home/$USER/.local/share/bin"

# Allow user to select the install directory
read -p "Install directory (default: $dir): " input_dir

# Set the install directory
if [ -n "$input_dir" ]; then
    dir="$input_dir"
fi

# Check if oh-my-zsh is installed
if ! command -v omz &> /dev/null; then
    # Clone oh-my-zsh repository and install
    ZSH="$dir/oh-my-zsh" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
else
    # Update oh-my-zsh
    omz update
fi

# Set zsh as default shell
sudo chsh -s "$(command -v zsh)" "$USER"
