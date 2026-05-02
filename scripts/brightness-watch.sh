#!/usr/bin/env bash
# Prevent multiple instances
pgrep -f "brightness-watch.sh" | grep -v $$ > /dev/null && exit 0

WAYBAR_DIR="$HOME/.config/mango/waybar"
STATE="$WAYBAR_DIR/.theme"
STYLE="$WAYBAR_DIR/style.css"
CONFIG="$WAYBAR_DIR/config.jsonc"

while true; do
    sleep 2

    b=$(cat /sys/class/backlight/*/brightness 2>/dev/null | head -1)
    m=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -1)
    [ -z "$b" ] || [ -z "$m" ] || [ "$m" -eq 0 ] && continue

    percent=$(( b * 100 / m ))
    current=$(cat "$STATE" 2>/dev/null || echo "night")

    if [ "$percent" -gt 60 ] && [ "$current" != "day" ]; then
        echo "day" > "$STATE"
        sed -i 's|colors-night\.css|colors-day.css|' "$STYLE"
        pkill waybar
        sleep 0.3
        waybar -c "$CONFIG" -s "$STYLE" >/dev/null 2>&1 &
    elif [ "$percent" -le 60 ] && [ "$current" != "night" ]; then
        echo "night" > "$STATE"
        sed -i 's|colors-day\.css|colors-night.css|' "$STYLE"
        pkill waybar
        sleep 0.3
        waybar -c "$CONFIG" -s "$STYLE" >/dev/null 2>&1 &
    fi
done
