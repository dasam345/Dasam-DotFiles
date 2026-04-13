#!/bin/bash

FILE="$HOME/Pictures/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" && notify-send "Screenshot saved & copied" "$FILE" -i "$FILE"
