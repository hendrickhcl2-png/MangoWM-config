#!/usr/bin/env bash
WAYBAR_DIR="$HOME/.config/mango/waybar"
STATE="$WAYBAR_DIR/.theme"
STYLE="$WAYBAR_DIR/style.css"
CONFIG="$WAYBAR_DIR/config.jsonc"

# Let brightness change settle before reading
sleep 0.15

b=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -1)
m=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -1)

[ -z "$b" ] || [ -z "$m" ] || [ "$m" -eq 0 ] && exit 0

percent=$(( b * 100 / m ))
current=$(cat "$STATE" 2>/dev/null || echo "night")

if [ "$percent" -gt 75 ] && [ "$current" != "day" ]; then
    echo "day" > "$STATE"
    sed -i 's|colors-night\.css|colors-day.css|' "$STYLE"
    setsid bash -c "pkill waybar; sleep 0.3; waybar -c $CONFIG -s $STYLE >/dev/null 2>&1 &" &
elif [ "$percent" -le 75 ] && [ "$current" != "night" ]; then
    echo "night" > "$STATE"
    sed -i 's|colors-day\.css|colors-night.css|' "$STYLE"
    setsid bash -c "pkill waybar; sleep 0.3; waybar -c $CONFIG -s $STYLE >/dev/null 2>&1 &" &
fi
