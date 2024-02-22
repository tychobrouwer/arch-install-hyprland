#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/config.json $HOME/.config/waybar/style.css"

if [[ ! $(pidof waybar) ]]; then
  while true; do
    inotifywait -e create,modify $CONFIG_FILES
    killall waybar
    waybar -c $HOME/.config/waybar/config -s $HOME/.config/waybar/style.css &
  done
fi
