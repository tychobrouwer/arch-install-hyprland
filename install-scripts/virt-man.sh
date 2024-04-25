#!/bin/bash

# Check if current bootloader is grub
if [ ! -d "/boot/loader" ]; then
  exit "systemd-boot is not the current bootloader"
fi

sudo pacman -Syu --needed --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs swtpm acpi_call-dkms


if ! grep -q "intel_iommu=on,igfx_off" /boot/loader/entries/*linux-zen.conf; then
  sudo sed -i '/^options/s/$/ intel_iommu=on,igfx_off/' /boot/loader/entries/*linux-zen.conf
fi

if ! grep -q "iommu=pt" /boot/loader/entries/*linux-zen.conf; then
  sudo sed -i '/^options/s/$/ iommu=pt/' /boot/loader/entries/*linux-zen.conf
fi

if ! grep -q "kvm.ignore_msrs=1" /boot/loader/entries/*linux-zen.conf; then
  sudo sed -i '/^options/s/$/ kvm.ignore_msrs=1/' /boot/loader/entries/*linux-zen.conf
fi

