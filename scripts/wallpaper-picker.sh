#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Pictures/Wallpaper"
THUMB_DIR="$HOME/.cache/mango/wallpaper-thumbs"
STATE="$HOME/.config/mango/wallpaper/.current"

mkdir -p "$THUMB_DIR"

# Generate missing thumbnails
for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp,PNG,JPG,JPEG}; do
    [ -f "$img" ] || continue
    thumb="$THUMB_DIR/$(basename "$img").jpg"
    [ -f "$thumb" ] && continue
    magick "$img" -resize 460x259^ -gravity center -extent 460x259 -quality 85 "$thumb" 2>/dev/null
done

# Pipe entries directly to rofi (null bytes cannot live in bash variables)
selected=$(
    for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp,PNG,JPG,JPEG}; do
        [ -f "$img" ] || continue
        name="${img%.*}"
        name="${name##*/}"
        thumb="$THUMB_DIR/$(basename "$img").jpg"
        [ -f "$thumb" ] || continue
        printf '%s\0icon\x1f%s\n' "$name" "$thumb"
    done | rofi \
        -dmenu \
        -p "󰸉" \
        -show-icons \
        -theme "$HOME/.config/mango/rofi/wallpaper.rasi"
)

[ -z "$selected" ] && exit 0

# Find and apply the selected wallpaper
for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp,PNG,JPG,JPEG}; do
    [ -f "$img" ] || continue
    name="${img%.*}"
    name="${name##*/}"
    if [ "$name" = "$selected" ]; then
        echo "$img" > "$STATE"
        pkill swaybg
        swaybg -i "$img" &
        break
    fi
done
