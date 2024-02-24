#!/bin/bash

CONFIG_FILES="$HOME/.config/waybar/waybar.json $HOME/.config/waybar/waybar.css"

trap "killall waybar" EXIT

if [[ ! $(pidof waybar) ]]; then
  while true; do
    waybar -c $HOME/.config/waybar/waybar.json -s $HOME/.config/waybar/waybar.css &

    if [[ ! $(pidof waybar) ]]; then
      notify-send -u critical -a "Waybar" "Failed to start Waybar"

      exit 1
    fi

    inotifywait -e create,modify $CONFIG_FILES
    killall waybar
  done
fi
