#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

# Install packages
read -p "Install essential pacakges? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/essential.txt
fi

# Install NVIDIA drivers
read -p "Install NVIDIA packages? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/nvidia.txt

  paru -S --needed --noconfirm nvidia-vaapi-driver-git

  sudo sed -i 's/MODULES=(btrfs/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm btrfs/g' /etc/mkinitcpio.conf

  if ! grep -q "nvidia-drm.modeset=1" /boot/loader/entries/*linux-zen.conf; then
    sudo sed -i '/^options/s/$/ nvidia-drm.modeset=1/' /boot/loader/entries/*linux-zen.conf
  fi
fi

# Install applications
read -p "Install applications? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < settings/applications.txt
fi

# Rate pacman mirrors
read -p "Rate pacman mirrors? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if [[ ! -f /etc/pacman.d/mirrorlist.backup ]]; then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  fi

  sudo bash -c "curl -s 'https://archlinux.org/mirrorlist/?country=NL&country=GB&country=DE&protocol=https&use_mirror_status=on' | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist"
fi

# Install paru
read -p "Install paru? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru || exit
    makepkg -si

    cd "$SCRIPT_DIR"
    rm -rf /tmp/paru
  fi
fi

# Install AUR packages
if command -v paru &> /dev/null; then
  read -p "Install AUR packages? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    paru -S --needed --noconfirm --skipreview - < settings/aur.txt
  fi

  # Install spotify-player with custom arguments
  cd /tmp || exit

  paru -G spotify-player
  sed -i '/cargo build/s/$/ --features notify,daemon/' /tmp/spotify-player/PKGBUILD

  cd /tmp/spotify-player || exit
  paru -Bi --needed --noconfirm --skipreview .

  cd "$SCRIPT_DIR"
  rm -rf /tmp/spotify-player

  read -p "Log Spotify player in? [Y/n] " yn
  if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
    spotify_player authenticate
  fi
fi

# Fix thunar icon
if [ -f "/usr/share/applications/thunar.desktop" ]; then
  sudo sed -i 's/org.xfce.thunar/Thunar/' /usr/share/applications/thunar.desktop
  sudo sed -i 's/org.xfce.thunar/Thunar/' /usr/share/applications/thunar-bulk-rename.desktop
  sudo sed -i 's/org.xfce.thunar/Thunar/' /usr/share/applications/thunar-settings.desktop
fi

# Configure dotfiles
read -p "Configure dotfiles? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
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
fi

# Add user to input group
if grep -q "input" /etc/group; then
  sudo usermod -aG input "$USER"
fi

# Set up git
if command -v git &> /dev/null; then
  git config --global user.name "$(awk 'NR==1' 'settings/git.txt')"
  git config --global user.email "$(awk 'NR==2' 'settings/git.txt')"
  git config --global init.defaultBranch main
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

# Configure zsh
if command -v zsh &> /dev/null; then
  # Check if oh-my-zsh is installed
  if [[ ! -d "$SCRIPT_DIR/../oh-my-zsh" ]]; then
    # Clone oh-my-zsh repository and install
    ZSH="$SCRIPT_DIR/../oh-my-zsh" sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc --skip-chsh
  else
    # Update oh-my-zsh
    omz update
  fi

  # Set zsh as default shell
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

# Generate SSH key
if command -v ssh &> /dev/null; then
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -a 100 -C "$USER@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
  fi

  # Start and enable ssh deamon
  sudo systemctl start sshd.service
  sudo systemctl enable sshd.service
fi

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

  # Fix systemd messages in tuigreet  <-- Not working
  if ! grep -q "multi-user.target" /usr/lib/systemd/system/greetd.service; then
    sudo sed -i '/\[Unit\]/a After=multi-user.target' /usr/lib/systemd/system/greetd.service
  fi

  # Enable colors in hooks
  if grep -q "systemd" /etc/mkinitcpio.conf; then
    if ! grep -q "sd-colors" /etc/mkinitcpio.conf; then
      sudo sed -i 's/systemd/systemd sd-colors/' /etc/mkinitcpio.conf
    fi
  else
    if ! grep -q "colors" /etc/mkinitcpio.conf; then
      sudo sed -i 's/udev/udev colors/' /etc/mkinitcpio.conf
    fi
  fi

  # Set vt colors
  sudo sed -ni -e '/COLOR_0=/!p' -e '$a\COLOR_0=151623' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_1=/!p' -e '$a\COLOR_1=ff5555' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_2=/!p' -e '$a\COLOR_2=50fa7b' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_3=/!p' -e '$a\COLOR_3=f1fa8c' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_4=/!p' -e '$a\COLOR_4=bd93f9' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_5=/!p' -e '$a\COLOR_5=ff79c6' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_6=/!p' -e '$a\COLOR_6=8be9fd' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_7=/!p' -e '$a\COLOR_7=cdd6f4' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_8=/!p' -e '$a\COLOR_8=313244' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_9=/!p' -e '$a\COLOR_9=ff6e67' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_10=/!p' -e '$a\COLOR_10=5af78e' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_11=/!p' -e '$a\COLOR_11=f4f99d' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_12=/!p' -e '$a\COLOR_12=caa9fa' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_13=/!p' -e '$a\COLOR_13=ff92d0' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_14=/!p' -e '$a\COLOR_14=9aedfe' /etc/vconsole.conf
  sudo sed -ni -e '/COLOR_15=/!p' -e '$a\COLOR_15=e6e6e6' /etc/vconsole.conf

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

# # Create wireguard configuration files
# read -p "Create wireguard configuration files? [Y/n] " yn
# if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
#   mkdir -p "/etc/wireguard"

#   read -p "Wireguard endpoint: " wg_endpoint
#   read -p "Wireguard public key: " wg_public_key

#   i=0
#   for wg_file_line in $(cat settings/wireguard_files.txt); do
#     if [ ! -f "$wg_file_line" ]; then
#       i=$((i+1))
#       continue
#     fi

#     if grep -q "Endpoint" "$wg_file_line"; then
#       wg_file_line=Endpoint=$wg_endpoint:51820
#     elif grep -q "PublicKey" "$wg_file_line"; then
#       wg_file_line=PublicKey=$wg_public_key
#     elif grep -q "PrivateKey" "$wg_file_line"; then
#       read -p "Wireguard private key for config $i: " wg_private_key

#       wg_file_line=PrivateKey=$wg_private_key
#     fi

#     sudo bash -c "echo '$wg_file_line' >> '/etc/wireguard/wg$i.conf'"
#   done
# fi

# # Create samba service files
# read -p "Create samba service files? [Y/n] " yn
# if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  
# fi

# Enable ltp and configure
read -p "Enable and configure ltp? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm ltp

  sudo systemctl enable ltp.service
  sudo systemctl start ltp.service
  sudo systemctl mask systemd-rfkill.service
  sudo systemctl mask systemd-rfkill.socket
fi

# Hide applications in menu
read -p "Set NoDisplay desktop files? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  mkdir -p "$HOME/.local/share/applications"

  for desktop_file in $(cat settings/nodisplay_desktop_files.txt); do
    [ ! -f "$desktop_file" ] && continue

    application=$(basename "$desktop_file")
    local_desktop_file="$HOME/.local/share/applications/$application"

    sudo cp "$desktop_file" "$local_desktop_file"
    sudo chown "$USER:$USER" "$local_desktop_file"
    sed -ni -e '/NoDisplay/!p' -e '$a\NoDisplay=true' "$local_desktop_file"
  done
fi

# Apply ozone wayland modifications
read -p "Apply ozone wayland modifications? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  mkdir -p "$HOME/.local/share/applications"

  for desktop_file in $(cat settings/ozone_desktop_files.txt); do
    [ ! -f "$desktop_file" ] && continue

    application=$(basename "$desktop_file")
    local_desktop_file="$HOME/.local/share/applications/$application"

    sudo cp "$desktop_file" "$local_desktop_file"
    sudo chown "$USER:$USER" "$local_desktop_file"
    if ! grep -q "--enable-features=UseOzonePlatform --ozone-platform=wayland" "$local_desktop_file"; then
      sed -i '/^Exec=/s/$/ --enable-features=UseOzonePlatform --ozone-platform=wayland/g' "$local_desktop_file"
    fi
  done
fi

# Disable startup services
read -p "Set Hidden xdg autostart? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  mkdir -p "$HOME/.config/autostart"

  for desktop_file in $(cat settings/hidden_xdg_files.txt); do
    [ ! -f "$desktop_file" ] && continue

    application=$(basename "$desktop_file")
    local_desktop_file="$HOME/.config/autostart/$application"

    sudo cp "$desktop_file" "$local_desktop_file"
    sudo chown "$USER:$USER" "$local_desktop_file"
    sed -ni -e '/Hidden/!p' -e '$a\Hidden=true' "$local_desktop_file"
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

# Set up NordVPN if installed
if command -v nordvpn &> /dev/null; then
  sudo usermod -aG nordvpn "$USER"
fi

# Set up sudo to ask for root password instead of user password
read -p "Use root password for sudo? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  if ! sudo grep -q "^Defaults rootpw$" /etc/sudoers; then
    sudo bash -c "echo 'Defaults rootpw' >> /etc/sudoers"
  fi
fi

# Clone repositories from configuration file
read -p "Clone repositories from configuration file? [Y/n] " yn
if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  # Print ssh pub key
  if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    echo "Add you ssh public key to GitHub:"
    cat "$HOME/.ssh/id_ed25519.pub"
  fi

  # Wait for enter
  read -p "Press enter to continue"

  while IFS="," read -r repository directory; do
    if [[ -z "$repository" ]]; then
      continue
    fi

    cd ..

    mkdir -p "$directory"
    cd "$directory" || exit

    if [[ -d ".git" ]]; then
      git pull origin main || continue
    else
      git clone "$repository"
    fi
  done < settings/repositories.csv

  cd "$SCRIPT_DIR"
fi
