#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/waybar.jsonc $HOME/.config/waybar/waybar.css"

if [[ ! $(pidof waybar) ]]; then
  while true; do
    waybar -c $HOME/.config/waybar/waybar.jsonc -s $HOME/.config/waybar/waybar.css &

    if [[ ! $(pidof waybar) ]]; then
      notify-send -u critical -a "Waybar" "Failed to start Waybar"

      exit 1
    fi

    inotifywait -e create,modify $CONFIG_FILES

    killall waybar
  done
fi
