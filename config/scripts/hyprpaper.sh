#!/bin/bash

if [[ ! $(pidof hyprpaper) ]]; then
  hyprpaper -c $HOME/.config/hypr/hyprpaper.conf
fi
