#!/bin/bash

player=$(playerctl --list-all | grep spotify | head -n 1)

while true; do
  status=$(playerctl --player=$player status)
  result=$(playerctl --player=$player metadata --format "{{ title }} - {{ artist }}")

  if [ "$status" == "Playing" ]; then
    result=" $result"
  else
    result=" $result"
  fi

  echo "{\"text\": \"$result\", \"class\": \"spotify-text\"}"

done
