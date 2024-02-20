#!/bin/bash

if [[ ! $(pidof waybar) ]]; then
  waybar -c $HOME/.config/waybar/waybar.json -s $HOME/.config/waybar/waybar.css
fi
