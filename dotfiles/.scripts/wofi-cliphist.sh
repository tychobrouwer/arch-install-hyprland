#!/bin/bash

out=$(cliphist list | wofi --dmenu --prompt 'Search clipboard...') && echo "$out" | cliphist decode | wl-copy
