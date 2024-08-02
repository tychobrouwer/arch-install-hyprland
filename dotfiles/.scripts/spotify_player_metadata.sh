#!/bin/bash

while true; do
  player=$(playerctl --list-all | grep spotify | head -n 1)
  status=$(playerctl --player=$player status)
  result=$(playerctl --player=$player metadata --format "{{ title }} - {{ artist }}")

  if [ "$status" == "Playing" ]; then
    result=" $result"
  else
    result=" $result"
  fi

  # Escape problematic characters
  result=$(echo $result | sed 's/"/\\"/g')
  result=$(echo $result | sed "s/'/\\\'/g")
  result=$(echo $result | sed 's/&/\\&/g')

  echo "{\"text\": \"$result\", \"class\": \"spotify-text\"}"
  sleep 0.5
done
