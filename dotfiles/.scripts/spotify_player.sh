#!/bin/bash

if [[ ! $(pidof spotify_player) ]]; then
  spotify_player -d --config-folder $HOME/.config/spotify_player

  if [[ ! $(pidof spotify_player) ]]; then
    notify-send -u critical -a "Spotify Player" "Failed to start Spotify Player"

    exit 1
  fi

  spotify_player playback pause
fi
