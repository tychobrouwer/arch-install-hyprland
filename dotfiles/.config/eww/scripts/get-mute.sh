#!/bin/sh

if command -v wpctl &>/dev/null; then
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
        echo "true"
    else
        echo ""
    fi
elif command -v pamixer &>/dev/null; then
    if [ true == $(pamixer --get-mute) ]; then
        echo "true"
    else
        echo ""
    fi
else
    echo ""
fi
