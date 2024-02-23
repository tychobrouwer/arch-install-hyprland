#!/bin/bash

CONFIG_FILES="$HOME/.config/dunst/dunstrc"

trap "killall dunst" EXIT

if [[ ! $(pidof dunst) ]]; then
  while true; do
    dunst --config $HOME/.config/dunst/dunstrc &
    inotifywait -e create,modify $CONFIG_FILES
    killall dunst
  done
fi
