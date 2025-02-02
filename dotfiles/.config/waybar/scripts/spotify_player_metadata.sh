#!/bin/sh
player=$(playerctl --list-all | grep spotify | head -n 1)

while read -r line; do 
  echo "{\"text\": \"$line\", \"class\": \"spotify-text\"}" | sed -e 's/Playing//' -e 's/Paused//'
done < <(playerctl --player=spotify_player --follow metadata --format "{{ status }} {{ markup_escape(title) }} - {{ artist }}" )
