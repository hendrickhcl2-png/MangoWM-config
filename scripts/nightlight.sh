#!/usr/bin/env bash
STATE="$HOME/.config/mango/waybar/.nightlight"

get_temp() {
    cat "$STATE" 2>/dev/null || echo "3500"
}

restart_wlsunset() {
    local temp="$1"
    pkill wlsunset 2>/dev/null
    sleep 0.1
    wlsunset -T "$(( temp + 1 ))" -t "$temp" >/dev/null 2>&1 &
}

case "$1" in
    toggle)
        if pgrep -x wlsunset > /dev/null; then
            pkill wlsunset
        else
            restart_wlsunset "$(get_temp)"
        fi
        ;;
    warmer)
        temp=$(( $(get_temp) - 200 ))
        [ "$temp" -lt 1000 ] && temp=1000
        echo "$temp" > "$STATE"
        pgrep -x wlsunset > /dev/null && restart_wlsunset "$temp"
        ;;
    cooler)
        temp=$(( $(get_temp) + 200 ))
        [ "$temp" -gt 6500 ] && temp=6500
        echo "$temp" > "$STATE"
        pgrep -x wlsunset > /dev/null && restart_wlsunset "$temp"
        ;;
    status)
        if pgrep -x wlsunset > /dev/null; then
            echo "󰛨 $(get_temp)K"
        else
            echo "󰛩"
        fi
        ;;
esac
