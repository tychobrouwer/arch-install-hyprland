#!/bin/bash

if [[ ! $(pidof wofi) ]]; then
  wofi --show drun --prompt 'Search...' --conf ~/.config/wofi/config --style ~/.config/wofi/style.css
else
  pkill wofi
fi
