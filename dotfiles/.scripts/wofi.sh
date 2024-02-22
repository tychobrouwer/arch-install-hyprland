#!/bin/bash

if [[ ! $(pidof wofi) ]]; then
  wofi --show drun --prompt 'Search...' --conf $HOME/.config/wofi/config --style $HOME/.config/wofi/style.css
else
  killall wofi
fi
