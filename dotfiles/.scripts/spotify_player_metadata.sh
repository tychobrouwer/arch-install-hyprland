#!/bin/bash

player=$(playerctl --list-all | grep spotify | head -n 1)
format="{{ title }} - {{ artist }}"

result=$(playerctl --player=$player metadata --format $format)

echo "{text: '${result}', class: 'spotify-text'}"
