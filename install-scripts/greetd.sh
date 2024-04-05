#!/bin/bash

# Check if greetd is installed
if ! command -v greetd &> /dev/null; then
    exit "greetd is not installed"
fi

# Start and enable greetd
sudo systemctl enable greetd.service

sudo bash -c "cat <<EOF > /usr/share/wayland-sessions/hyprland.desktop
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiled Wayland compositor
Exec=Hyprland
Type=Application
EOF"

# Fix systemd messages in tuigreet
if ! grep -q "multi-user.target" /usr/lib/systemd/system/greetd.service; then
    sudo sed -i '/\[Unit\]/a After=multi-user.target' /usr/lib/systemd/system/greetd.service
fi

# Enable colors in hooks (mkinitcpio-colors)
if ! grep -q "colors" /etc/mkinitcpio.conf; then
    if [ -d "/boot/loader" ]; then
        sudo sed -i 's/systemd/systemd sd-colors/' /etc/mkinitcpio.conf
    else
        sudo sed -i 's/udev/udev colors/' /etc/mkinitcpio.conf
    fi
fi

# Set vt colors
sudo sed -ni -e '/COLOR_0=/!p'  -e '$a\COLOR_0=151623'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_1=/!p'  -e '$a\COLOR_1=ff5555'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_2=/!p'  -e '$a\COLOR_2=50fa7b'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_3=/!p'  -e '$a\COLOR_3=f1fa8c'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_4=/!p'  -e '$a\COLOR_4=bd93f9'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_5=/!p'  -e '$a\COLOR_5=ff79c6'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_6=/!p'  -e '$a\COLOR_6=8be9fd'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_7=/!p'  -e '$a\COLOR_7=cdd6f4'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_8=/!p'  -e '$a\COLOR_8=313244'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_9=/!p'  -e '$a\COLOR_9=ff6e67'  /etc/vconsole.conf
sudo sed -ni -e '/COLOR_10=/!p' -e '$a\COLOR_10=5af78e' /etc/vconsole.conf
sudo sed -ni -e '/COLOR_11=/!p' -e '$a\COLOR_11=f4f99d' /etc/vconsole.conf
sudo sed -ni -e '/COLOR_12=/!p' -e '$a\COLOR_12=caa9fa' /etc/vconsole.conf
sudo sed -ni -e '/COLOR_13=/!p' -e '$a\COLOR_13=ff92d0' /etc/vconsole.conf
sudo sed -ni -e '/COLOR_14=/!p' -e '$a\COLOR_14=9aedfe' /etc/vconsole.conf
sudo sed -ni -e '/COLOR_15=/!p' -e '$a\COLOR_15=e6e6e6' /etc/vconsole.conf

# Rebuild initramfs
sudo mkinitcpio -P
