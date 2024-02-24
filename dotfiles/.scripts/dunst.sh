#!/bin/bash

CONFIG_FILES="$HOME/.config/dunst/dunstrc"

trap "killall dunst" EXIT

if [[ ! $(pidof dunst) ]]; then
  while true; do
    dunst --config $HOME/.config/dunst/dunstrc &

    if [[ ! $(pidof dunst) ]]; then
      notify-send -u critical -a "Dunst" "Failed to start Dunst"

      exit 1
    fi

    inotifywait -e create,modify $CONFIG_FILES
    killall dunst
  done
fi
