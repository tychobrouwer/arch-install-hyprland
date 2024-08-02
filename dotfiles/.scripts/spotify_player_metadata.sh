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

  echo "{\"text\": \"$result\", \"class\": \"spotify-text\"}"

  sleep 1
done
