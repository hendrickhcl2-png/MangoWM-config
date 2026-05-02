#!/usr/bin/env bash
STATE="$HOME/.config/mango/waybar/.theme"
STYLE="$HOME/.config/mango/waybar/style.css"
CONFIG="$HOME/.config/mango/waybar/config.jsonc"

current=$(cat "$STATE" 2>/dev/null || echo "night")

if [ "$current" = "night" ]; then
    echo "day" > "$STATE"
    sed -i 's|colors-night\.css|colors-day.css|' "$STYLE"
else
    echo "night" > "$STATE"
    sed -i 's|colors-day\.css|colors-night.css|' "$STYLE"
fi

# Run in a new session so it survives waybar being killed
setsid bash -c "pkill waybar; sleep 0.3; waybar -c $CONFIG -s $STYLE >/dev/null 2>&1 &" &
