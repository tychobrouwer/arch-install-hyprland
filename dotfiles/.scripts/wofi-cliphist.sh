#!/bin/bash

out=$(cliphist list | wofi --dmenu --prompt 'Search...') && echo "$out" | cliphist decode | wl-copy
