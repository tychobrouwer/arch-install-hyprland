#!/bin/sh

CONFIG_FILES="$HOME/.config/eww/eww.scss $HOME/.config/eww/eww.yuck"

if [[ ! $(pidof eww) ]]; then
  while true; do
    eww open bar --config $HOME/.config/eww &

    if [[ ! $(pidof eww) ]]; then
      notify-send -u critical -a "Eww" "Failed to start Eww"

      exit 1
    fi

    inotifywait -e create,modify $CONFIG_FILES

    killall eww
  done
fi
