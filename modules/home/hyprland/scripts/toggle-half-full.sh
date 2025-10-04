#!/usr/bin/env bash
# ~/.config/hypr/scripts/toggle-half-full.sh

MONITOR_WIDTH=$(hyprctl monitors | grep -oP '^\s+\d+x\d+' | head -1 | cut -d'x' -f1 | tr -d ' ')
MONITOR_HEIGHT=$(hyprctl monitors | grep -oP '^\s+\d+x\d+' | head -1 | cut -d'x' -f2)
HALF_WIDTH=$((MONITOR_WIDTH / 2))

# Get current active window width
CURRENT_WIDTH=$(hyprctl activewindow | grep -oP 'at: \d+,\d+' | grep -oP '\d+' | head -1)
WINDOW_WIDTH=$(hyprctl activewindow | grep -oP 'size: \d+,\d+' | grep -oP '\d+' | head -1)

# Toggle based on current size (with 50px tolerance for tiling gaps)
if [ "$WINDOW_WIDTH" -lt $((HALF_WIDTH + 50)) ]; then
    # Currently half or less, go full
    hyprctl dispatch resizewindowpixel exact ${MONITOR_WIDTH} ${MONITOR_HEIGHT}
else
    # Currently full, go half
    hyprctl dispatch resizewindowpixel exact ${HALF_WIDTH} ${MONITOR_HEIGHT}
fi
