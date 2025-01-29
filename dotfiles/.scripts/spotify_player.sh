#!/bin/bash

first=true

while true; do
  ping -c1 www.google.com &>/dev/null && break
  sleep 1
done

#while ! ip route | grep -oP 'default via .+ dev'; do
#  echo "interface not up, will try again in 1 second";
#  sleep 1;
#done

while true; do
  if [[ ! $(pidof spotify_player) ]]; then
    spotify_player -d --config-folder $HOME/.config/spotify_player

    if [[ $(pidof spotify_player) ]]; then
      break
    fi

    if $first; then
      notify-send -u critical -a "Spotify Player" "Failed to start Spotify Player"

      first=false
    fi

    sleep 5
  else
    break
  fi
done
