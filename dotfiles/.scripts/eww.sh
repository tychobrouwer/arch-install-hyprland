#!/bin/sh

CONFIG_FILES="$HOME/.config/eww/eww.scss $HOME/.config/eww/eww.yuck"

pidof eww || while true; do
  eww open bar --config $HOME/.config/eww &

  pidof eww || (notify-send -u critical -a "Eww" "Failed to start Eww" && exit 1)

  inotifywait -e create,modify $CONFIG_FILES

  killall eww
done

