#!/bin/bash

# Store PIDs for cleanup
XEPHYR_PID=""
OPENBOX_PID=""
MATLAB_PID=""

monitor_resolution() {
    local last_size=""
    while true; do
        sleep 1
        # Monitor the display from inside Xephyr itself
        local current_size=$(DISPLAY=:1 xdpyinfo 2>/dev/null | grep "dimensions:" | awk '{print $2}')
        
        if [ -n "$current_size" ] && [ "$current_size" != "$last_size" ]; then
            echo "Display size changed to $current_size - refreshing"
            
            # Run xrandr to refresh display mapping
            DISPLAY=:1 xrandr >/dev/null 2>&1
            
            last_size="$current_size"
        fi
    done
}

cleanup() {
    echo "Shutting down gracefully..."
    
    for pid in "$MATLAB_PID" "$OPENBOX_PID" "$XEPHYR_PID"; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null
            sleep 0.5
            kill -KILL "$pid" 2>/dev/null || true
        fi
    done
    
    echo "Shutdown complete."
    exit 0
}

trap cleanup INT TERM EXIT

# Get current monitor resolution
RESOLUTION=$(xrandr --current | grep '*' | head -1 | awk '{print $1}')
if [ -z "$RESOLUTION" ]; then
    RESOLUTION="1920x1080"
fi

echo "Using resolution: $RESOLUTION"

# Start Xephyr with your monitor's resolution
echo "Starting Xephyr..."
Xephyr :1 -screen "$RESOLUTION" -resizeable 2>/dev/null &
XEPHYR_PID=$!
sleep 0.5

# Start openbox
echo "Starting openbox..."
DISPLAY=:1 openbox &
OPENBOX_PID=$!
sleep 0.5

echo "Starting window size monitor..."
monitor_resolution &
MONITOR_PID=$!

# Start MATLAB
echo "Starting MATLAB..."
DISPLAY=:1 JAVA_AWT_WM_NONEPARENTING=1 AWT_TOOLKIT=MToolkit /usr/local/bin/matlab -desktop &
MATLAB_PID=$!

echo "MATLAB running with resolution $RESOLUTION"
echo "Maximize will work correctly at this size."
echo "Press Ctrl+C to stop."

wait $MATLAB_PID
echo "MATLAB exited normally."
