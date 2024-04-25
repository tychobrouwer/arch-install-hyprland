#!/bin/bash

dir="/home/$USER/.local/share/bin"

# Allow user to select the install directory
read -p "Install directory (default: $dir): " input_dir

# Set the install directory
if [ -n "$input_dir" ]; then
    dir="$input_dir"
fi

if [ ! -d "$dir/paru" ]; then
    # Create the directory
    mkdir -p "$dir/paru"

    # Clone the paru repository
    git clone https://aur.archlinux.org/paru.git "$dir/paru"
    cd "$dir/paru" || exit
else
    # Update the paru repository
    cd "$dir/paru" || exit
    git_update=$(git pull)

    # Exit if the repository is up to date and paru is installed
    if [ "$git_update" = "Already up to date." ] && ! command -v paru &> /dev/null; then
        exit
    fi
fi

# Build and install paru
makepkg -si
