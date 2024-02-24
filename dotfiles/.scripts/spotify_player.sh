#!/bin/bash

if [[ ! $(pidof spotify_player) ]]; then
  spotify_player -d --config-folder $HOME/.config/spotify_player
fi
