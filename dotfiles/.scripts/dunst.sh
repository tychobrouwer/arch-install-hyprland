#!/bin/sh

CONFIG_FILES="$HOME/.config/dunst/dunstrc"

trap "killall dunst" EXIT

pidof dunst || while true; do
  dunst --config $HOME/.config/dunst/dunstrc &

  pidof dunst || (notify-send -u critical -a "Dunst" "Failed to start Dunst" && exit 1)

  inotifywait -e create,modify $CONFIG_FILES
  killall dunst
done

