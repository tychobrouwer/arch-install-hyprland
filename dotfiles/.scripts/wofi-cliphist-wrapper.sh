#!/bin/bash

if [[ ! $(pgrep -f "/bin/bash $HOME/.scripts/wofi-cliphist.sh") ]]; then
  /bin/bash $HOME/.scripts/wofi-cliphist.sh
else
  pgrep -f "/bin/bash $HOME/.scripts/wofi-cliphist.sh" | xargs kill
fi
