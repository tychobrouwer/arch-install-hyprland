#!/bin/bash

# Install packages

read -p "Install pacakges? (Y/n) " yn

if [[ $yn == "Y" || $yn == "y" || $yn == "" ]]; then
  sudo pacman -S --needed --noconfirm - < packages.txt
fi
