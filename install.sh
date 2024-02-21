#!/bin/bash

# Set pacman options
sudo sed -i '/ParallelDownloads/c\ParallelDownloads = 20' /etc/pacman.conf

# Set makepkg options
sudo sed -i '/MAKEFLAGS=/c\MAKEFLAGS="-j$(nproc)"' /etc/makepkg.conf

if pacman -Qs grub > /dev/null; then
  # Grub not supported
  read -p "Grub not supported, continue?" Yn
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

  # Enable IOMMU if not already enabled
  read -p "Enable IOMMU? [Y/n] " Yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    if ! grep -q "intel_iommu=on" /boot/loader/entries/*linux-zen.conf; then
      sudo sed '/^options/s/$/ intel_iommu=on/' /boot/loader/entries/*linux-zen.conf
    fi

    if ! grep -q "iommu=pt" /boot/loader/entries/*linux-zen.conf; then
      sudo sed '/^options/s/$/ iommu=pt/' /boot/loader/entries/*linux-zen.conf
    fi
  fi

  read -p "Disable mitigations? [Y/n] " Yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    # Disable mitigations if not already disabled
    if ! grep -q "mitigations=off" /boot/loader/entries/*linux-zen.conf; then
      sudo sed '/^options/s/$/ mitigations=off/' /boot/loader/entries/*linux-zen.conf
    fi
  fi

  read -p "Enable tsc clock? [Y/n] " Yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    # Set tsc to reliable if not already set
    if ! grep -q "tsc=reliable" /boot/loader/entries/*linux-zen.conf; then
      sudo sed '/^options/s/$/ tsc=reliable/' /boot/loader/entries/*linux-zen.conf
    fi

    # Set clocksource to tsc if not already set
    if ! grep -q "clocksource=tsc" /boot/loader/entries/*linux-zen.conf; then
      sudo sed '/^options/s/$/ clocksource=tsc/' /boot/loader/entries/*linux-zen.conf
    fi
  fi
fi

# Set systemd timeouts to 10s
sudo sed -i '/DefaultTimeoutStopSec/c\DefaultTimeoutStopSec=10s' /etc/systemd/system.conf
sudo sed -i '/DefaultDeviceTimeoutSec/c\DefaultDeviceTimeoutSec=10s' /etc/systemd/system.conf

# Set systemd journald limits
sudo sed -i '/SystemMaxUse/c\SystemMaxUse=1G' /etc/systemd/journald.conf

# Configure dotfiles
read -p "Configure dotfiles? [Y/n] " Yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  cd "$HOME/git/arch-install-hyprland/dotfiles" || exit
  stow --adopt -t "$HOME" .
  git reset --hard
  git pull
  cd "$HOME"
fi

# Install packages
read -p "Install essential pacakges? [Y/n] " Yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < deps/packages.txt
fi

# Install NVIDIA drivers
read -p "Install NVIDIA packages? [Y/n] " Yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < deps/nvidia.txt
fi

# Install applications
read -p "Install applications? [Y/n] " Yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < deps/applications.txt
fi

# Enable Docker if installed
if pacman -Qs docker > /dev/null; then
  sudo systemctl start docker.service
  sudo systemctl enable docker.service
  sudo groupadd docker
  sudo usermod -aG docker "$USER"
fi

# Install paru
read -p "Install paru? [Y/n] " Yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! command -v paru &> /dev/null then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru || exit
    makepkg -si

    cd "$HOME"
    rm -rf /tmp/paru
  fi
fi

if command -v paru &> /dev/null then
  # Install AUR packages
  read -p "Install AUR packages? [Y/n] " Yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    paru -S --needed --noconfirm --skipreview - < deps/aur.txt
  fi
fi

# Configure zsh
if command -v zsh &> /dev/null then
  ZSH="$HOME/git/oh-my-zsh" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Set zsh as default shell
  chsh -s "$(command -v zsh)"
fi

# Generate SSH key
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -a 100 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
fi

# Start and enable ssh deamon
sudo systemctl start sshd.service
sudo systemctl enable sshd.service
