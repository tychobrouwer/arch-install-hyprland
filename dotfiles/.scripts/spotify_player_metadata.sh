#!/bin/bash

player=$(playerctl --list-all | grep spotify | head -n 1)
result=$(playerctl --player=$player metadata --format "{{ emoji(status) }} {{ title }} - {{ artist }}")

echo "{\"text\": \"${result}\", \"class\": \"spotify-text\"}"
