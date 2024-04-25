#!/bin/bash

rootfilesystem=$(df -T | grep /$ | awk '{print $2}')
if [[ $rootfilesystem == "btrfs" ]]; then
    sudo sed -i 's/fsck//' /etc/mkinitcpio.conf

    sudo systemctl mask systemd-fsck-root.service
fi
