#!/bin/bash

player=$(playerctl --list-all | grep spotify | head -n 1)
result=$(playerctl --player=$player metadata --format "{{ title }} - {{ artist }}")
status=$(playerctl --player=$player status)

if [ "$status" = "Playing" ]; then
  result=" $result"
else
  result=" $result"
fi

echo "{\"text\": \"${result}\", \"class\": \"spotify-text\"}"
