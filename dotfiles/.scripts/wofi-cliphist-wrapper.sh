#!/bin/bash

if [[ ! $(pgrep -f "/bin/bash $HOME/.scripts/wofi-cliphist.sh") ]]; then
  /bin/bash $HOME/.scripts/wofi-cliphist.sh
else
  killall wofi

  cliphist list | cliphist decode | wl-copy
fi
