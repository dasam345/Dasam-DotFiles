#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" && notify-send "Screenshot saved & copied" "$FILE" -i "$FILE"
