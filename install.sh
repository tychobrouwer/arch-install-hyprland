#!/bin/bash

# Set pacman options
sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 20' /etc/pacman.conf

# Set makepkg options
sudo sed -i '/MAKEFLAGS=/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf

if pacman -Qs grub > /dev/null; then
  # Grub not supported
  read -p "Grub not supported, continue?" yn
  if [[ $yn == "N" || $yn == "n" ]]; then
    exit 1
  fi
else
  # Set pacman hook for systemd-boot
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

  # Systemd hook instead of base
  sudo sed -i 's/base udev/systemd/' /etc/mkinitcpio.conf

  # Disable fsck if root filesystem is btrfs
  rootfilesystem=$(df -T | grep /$ | awk '{print $2}')
  if [[ $rootfilesystem == "btrfs" ]]; then
    sudo sed -i 's/fsck//' /etc/mkinitcpio.conf

    sudo systemctl mask systemd-fsck-root.service
  fi
  sudo sed -i 's/ )/)/' /etc/mkinitcpio.conf

  # Enable IOMMU if not already enabled
  read -p "Enable IOMMU? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    if ! grep -q "intel_iommu=on" /boot/loader/entries/*linux-zen.conf; then
      sudo sed -i '/^options/s/$/ intel_iommu=on/' /boot/loader/entries/*linux-zen.conf
    fi

    if ! grep -q "iommu=pt" /boot/loader/entries/*linux-zen.conf; then
      sudo sed -i '/^options/s/$/ iommu=pt/' /boot/loader/entries/*linux-zen.conf
    fi
  fi

  read -p "Disable mitigations? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    # Disable mitigations if not already disabled
    if ! grep -q "mitigations=off" /boot/loader/entries/*linux-zen.conf; then
      sudo sed -i '/^options/s/$/ mitigations=off/' /boot/loader/entries/*linux-zen.conf
    fi
  fi

  read -p "Enable tsc clock? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    # Set tsc to reliable if not already set
    if ! grep -q "tsc=reliable" /boot/loader/entries/*linux-zen.conf; then
      sudo sed -i '/^options/s/$/ tsc=reliable/' /boot/loader/entries/*linux-zen.conf
    fi

    # Set clocksource to tsc if not already set
    if ! grep -q "clocksource=tsc" /boot/loader/entries/*linux-zen.conf; then
      sudo sed -i '/^options/s/$/ clocksource=tsc/' /boot/loader/entries/*linux-zen.conf
    fi
  fi
fi

# Set systemd timeouts to 10s
sudo sed -i '/DefaultTimeoutStopSec/c\DefaultTimeoutStopSec=10s' /etc/systemd/system.conf
sudo sed -i '/DefaultDeviceTimeoutSec/c\DefaultDeviceTimeoutSec=10s' /etc/systemd/system.conf

# Set systemd journald limits
sudo sed -i '/SystemMaxUse/c\SystemMaxUse=1G' /etc/systemd/journald.conf

# Configure dotfiles
read -p "Configure dotfiles? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  # Create links do dotfiles
  tree -dfi --noreport $HOME/git/arch-install-hyprland/dotfiles | xargs -I {} mkdir -p "$HOME/{}"
  cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
  stow --adopt -t "$HOME" .

  # Copy files to /etc
  sudo cp -r $HOME/git/arch-install-hyprland/etc/* /etc

  # Reset to master branch 
  git reset --hard
  git pull
  cd "$HOME/git/arch-install-hyprland"

  # Update fonts
  sudo fc-cache -f
fi

# Install packages
read -p "Install essential pacakges? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/essential.txt
fi

# Install NVIDIA drivers
read -p "Install NVIDIA packages? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/nvidia.txt
fi

# Install applications
read -p "Install applications? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/applications.txt
fi

# Rate pacman mirrors
read -p "Rate pacman mirrors? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! -f /etc/pacman.d/mirrorlist.backup; then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  fi

  sudo bash -c "curl -s 'https://archlinux.org/mirrorlist/?country=NL&country=GB&country=DE&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist"
fi

if command -v git &> /dev/null; then
  git config --global user.name $(awk 'NR==1' "settings/git.txt")
  git config --global user.email $(awk 'NR==2' "settings/git.txt")
fi

# Enable Docker if installed
read -p "Enable Docker? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! pacman -Qs docker > /dev/null; then
    # Install Docker
    sudo pacman -S --needed --noconfirm docker
  fi
  
  sudo systemctl start docker.service
  sudo systemctl enable docker.service

  if ! grep -q "docker" /etc/group; then
    sudo groupadd docker
  fi
  sudo usermod -aG docker "$USER"
fi

# Install paru
read -p "Install paru? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru || exit
    makepkg -si

    cd "$HOME"
    rm -rf /tmp/paru
  fi
fi

# Install AUR packages
if command -v paru &> /dev/null; then
  read -p "Install AUR packages? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    paru -S --needed --noconfirm --skipreview - < settings/aur.txt
  fi
fi

# Configure zsh
if command -v zsh &> /dev/null; then
  # Remove oh-my-zsh repository if exists
  if [[ -d "$HOME/git/oh-my-zsh" ]]; then
    rm -rf "$HOME/git/oh-my-zsh"
  fi

  # Clone oh-my-zsh repository and install
  ZSH="$HOME/git/oh-my-zsh" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh

  # Set zsh as default shell
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

# Generate SSH key
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -a 100 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
fi

# Start and enable ssh deamon
sudo systemctl start sshd.service
sudo systemctl enable sshd.service

# Enable greetd and tuigreet
read -p "Enable greetd with tuigreet? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
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
  if ! grep -q "multi-user.target" /etc/systemd/system/greetd.service; then
    sudo sed -i '/^After=/ {s/$/ multi-user.target/; :a;n;ba' /etc/systemd/system/greetd.service
  fi

  # Enable colors in hooks
  if grep -q "systemd" /etc/tuigreet.conf; then
    if ! grep -q "sd-colors" /etc/tuigreet.conf; then
      sudo sed -ri 's/HOOKS=\((.*)\)/HOOKS=(\1 sd-colors)/' /etc/tuigreet.conf
    fi
  else
    if ! grep -q "colors" /etc/tuigreet.conf; then
      sudo sed -ri 's/HOOKS=\((.*)\)/HOOKS=(\1 colors)/' /etc/tuigreet.conf
    fi
  fi

  # Set vt colors
  sudo sed -ni -e '/COLOR_0/!p' -e '/COLOR_0/a\COLOR_0=191724' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_1/!p' -e '/COLOR_1/a\COLOR_1=dc322f' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_2/!p' -e '/COLOR_2/a\COLOR_2=859900' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_3/!p' -e '/COLOR_3/a\COLOR_3=b58900' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_4/!p' -e '/COLOR_4/a\COLOR_4=268bd2' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_5/!p' -e '/COLOR_5/a\COLOR_5=d33682' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_6/!p' -e '/COLOR_6/a\COLOR_6=2aa198' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_7/!p' -e '/COLOR_7/a\COLOR_7=dddddd' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_8/!p' -e '/COLOR_8/a\COLOR_8=002b36' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_9/!p' -e '/COLOR_9/a\COLOR_9=cb4b16' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_10/!p' -e '/COLOR_10/a\COLOR_10=586e75' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_11/!p' -e '/COLOR_11/a\COLOR_11=657b83' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_12/!p' -e '/COLOR_12/a\COLOR_12=839496' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_13/!p' -e '/COLOR_13/a\COLOR_13=6c71c4' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_14/!p' -e '/COLOR_14/a\COLOR_14=dddddd' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_15/!p' -e '/COLOR_15/a\COLOR_15=dddddd' /etc/vconsole.conf

  # Rebuild initramfs
  sudo mkinitcpio -P
fi

read -p "Enable iwd with NetworkManager? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  # NetworkManager configuration
  sudo systemctl enable NetworkManager.service
  sudo systemctl start NetworkManager.service
  sudo systemctl stop wpa_supplicant
  sudo systemctl disable wpa_supplicant
  sudo systemctl mask wpa_supplicant
  sudo systemctl start iwd
  sudo systemctl enable iwd
fi

# Hide applications in menu
read -p "set NoDisplay desktop files? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  mkdir -p "$HOME/.local/share/applications"

  for desktop_file in $(cat settings/nodisplay_desktop_files.txt); do
    [ ! -f "$desktop_file" ] && continue

    application=$(basename "$desktop_file")
    local_desktop_file="$HOME/.local/share/applications/$application"

    sudo cp "desktop_file" "$local_desktop_file"
    sudo chown "$USER:$USER" "$local_desktop_file"
    sed -ni -e '/NoDisplay/!p' -e '/NoDisplay/a\NoDisplay=true' "$local_desktop_file"
  done
fi

# Disable startup services
read -p "set Hidden xdg autostart? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  mkdir -p "$HOME/.config/autostart"

  for desktop_file in $(cat settings/hidden_xdg_files.txt); do
    [ ! -f "$desktop_file" ] && continue

    application=$(basename "$desktop_file")
    local_desktop_file="$HOME/.config/autostart/$application"

    sudo cp "desktop_file" "$local_desktop_file"
    sudo chown "$USER:$USER" "$local_desktop_file"
    sed -ni -e '/Hidden/!p' -e '/Hidden/a\Hidden=true' "$local_desktop_file"
  done
fi

# Set up firewall
read -p "Set up firewall? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! pacman -Qs firewalld > /dev/null; then
    sudo pacman -S --needed --noconfirm firewalld
  fi

  sudo systemctl start firewalld
  sudo systemctl enable firewalld

  sudo firewall-cmd --permanent --add-service=ssh
  sudo firewall-cmd --permanent --add-service=dhcpv6-client
  sudo firewall-cmd --reload
fi
