#!/bin/sh

if command -v wpctl &>/dev/null; then
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
        echo 0
        exit
    else
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'
    fi
elif command -v pamixer &>/dev/null; then
    if [ true == $(pamixer --get-mute) ]; then
        echo 0
        exit
    else
        pamixer --get-volume
    fi
else
    amixer -D pulse sget Master | awk -F '[^0-9]+' '/Left:/{print $3}'
fi
