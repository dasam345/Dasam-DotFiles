#!/bin/bash

CONF="$HOME/.config/hypr/bindings.conf"

# ── Build rofi menu from bindings ────────────────────────────
MENU=""
CATEGORY=""

while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]] && continue

    # Category headers
    if [[ "$line" =~ ^#[[:space:]]*--[[:space:]](.*) ]]; then
        CATEGORY="${BASH_REMATCH[1]}"
        continue
    fi

    # Parse keybinds
    if [[ "$line" =~ ^bind[[:space:]]*=[[:space:]]*(.*) ]]; then
        parts="${BASH_REMATCH[1]}"
        # Replace $mainMod with SUPER
        parts="${parts//\$mainMod/SUPER}"
        # Split on comma, trim spaces
        key=$(echo "$parts" | cut -d',' -f1-2 | tr ',' '+' | xargs)
        action=$(echo "$parts" | cut -d',' -f3- | xargs)
        MENU+="${CATEGORY:+[$CATEGORY] }$key → $action"$'\n'
    fi

    if [[ "$line" =~ ^bindm[[:space:]]*=[[:space:]]*(.*) ]]; then
        parts="${BASH_REMATCH[1]}"
        parts="${parts//\$mainMod/SUPER}"
        key=$(echo "$parts" | cut -d',' -f1-2 | tr ',' '+' | xargs)
        action=$(echo "$parts" | cut -d',' -f3- | xargs)
        MENU+="${CATEGORY:+[$CATEGORY] }Mouse: $key → $action"$'\n'
    fi
done < <(grep -v '^\s*$' "$CONF")

# ── Show in rofi ─────────────────────────────────────────────
echo "$MENU" | rofi -dmenu -i -p "Keybinds (SUPER+H to close)" \
    -theme-str 'window {width: 600px;} listview {lines: 20;}'
