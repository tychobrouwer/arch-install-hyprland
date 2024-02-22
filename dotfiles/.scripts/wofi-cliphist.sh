if [[ ! $(pidof wofi) ]]; then
  cliphist list | wofi --dmenu | cliphist decode | wl-copy
else
  killall wofi
fi
