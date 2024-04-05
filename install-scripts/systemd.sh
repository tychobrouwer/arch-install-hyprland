#!/bin/bash

# Check if current bootloader is grub
if [ ! -d "/boot/loader" ]; then
  exit "systemd-boot is not the current bootloader"
fi

# Create systemd-boot pacman hook
sudo mkdir -p /etc/pacman.d/hooks
sudo bash -c "cat <<EOF > /etc/pacman.d/hooks/95-systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF"

# Change mkinitcpio to systemd-boot hooks
sudo sed -i 's/base udev/systemd/'  /etc/mkinitcpio.conf
sudo sed -i 's/keymap/sd-vconsole/' /etc/mkinitcpio.conf

# sudo mkinitcpio -P

# Fix long timeout times
sudo sed -i '/DefaultTimeoutStopSec/c\DefaultTimeoutStopSec=10s'     /etc/systemd/system.conf
sudo sed -i '/DefaultDeviceTimeoutSec/c\DefaultDeviceTimeoutSec=10s' /etc/systemd/system.conf

# Set max journal size
sudo sed -i '/SystemMaxUse/c\SystemMaxUse=1G'                        /etc/systemd/journald.conf
