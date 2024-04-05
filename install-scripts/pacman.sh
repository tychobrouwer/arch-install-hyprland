#!/bin/bash

sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 20' /etc/pacman.conf
sudo sed -i '/MAKEFLAGS=/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf

# Backup mirrorlist
if [[ ! -f /etc/pacman.d/mirrorlist.backup ]]; then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
fi

# Rank mirrors (rankmirrors required)
sudo bash -c "curl -s 'https://archlinux.org/mirrorlist/?country=NL&country=GB&country=DE&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist"

