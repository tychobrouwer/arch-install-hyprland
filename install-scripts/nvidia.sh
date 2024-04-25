#!/bin/bash

# Get installed kernel versions
kernel_titles=$(bootctl list | grep "title: Arch Linux" | awk '{print $4}' | sed 's/\((\|)\)//g')
kernel_extensions=$(bootctl list | grep "linux: " | sed 's/.*linux: \/boot\/\/vmlinuz-linux//g')

# List optios for the user to select the kernel version
echo "Please select the NVIDIA driver version you want to install:"
i=1
for title in $kernel_titles; do
    echo "$i) $title"
    i=$((i+1))
done

option=1

# Read user input for the kernel version
read -p "Enter your choice: " choice
if [ $choice -gt 0 ] && [ $choice -lt $i ]; then
    option=$choice
else
    echo "Invalid choice. Using default option 1"
fi

# Get the kernel version and extension
kernel_title=$(sed -n "${option}p" <<< $kernel_titles)
kernel_extension=$(sed -n "${option}p" <<< $kernel_extensions)
echo
echo "Installing for $kernel_title"
echo

# Get nvidia package extension
nvidia_version_extension=$kernel_extension
if [[ $kernel_extension != "" || $kernel_extension != "lts" ]]; then
    nvidia_version_extension="-dkms"
fi

# Install nvidia drivers
sudo pacman -S nvidia$nvidia_version_extension linux$kernel_extension-headers nvidia-utils lib32-nvidia-utils nvidia-settings nvtop opencl-nvidia libva --needed --noconfirm

echo

if [ -f /boot/loader/loader.conf ]; then
    echo "Setting bootloader options (systemd-boot)"
    if ! grep -q "nvidia-drm.modeset=1" /boot/loader/entries/*linux$kernel_extension.conf; then
        # Update systemd-boot options
        sudo sed -i '/^options/s/$/ nvidia-drm.modeset=1/' /boot/loader/entries/*linux$kernel_extension.conf
    fi
elif [ -f /boot/grub/grub.cfg ]; then
    echo "Setting bootloader options (grub)"
    if ! grep -q "nvidia-drm modeset=1" /etc/default/grub; then
        # Update GRUB options
        sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub
        # Grub update
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
else
    echo "Bootloader not detected"
fi
echo

if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
    # Update mkinitcpio.conf MODULES
    sudo sed -i '/^MODULES/s/$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf
fi

if grep -q "kms" /etc/mkinitcpio.conf; then
    # Remove kms from mkinitcpio.conf HOOKS
    sudo sed -i 's/kms //' /etc/mkinitcpio.conf
fi

# Show nvidia driver details
nvidia-smi
echo

