#!/bin/bash

# 1. Środowisko - absolutnie kluczowe dla Hyprlanda
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:$HOME/.local/bin:$HOME/bin"
set +e 

# Ścieżki
WALL_DIR="$HOME/Wallpapers"
CACHE="$HOME/.cache/rofi-wallpapers"
CURRENT_WALL="$HOME/.cache/current_wallpaper"

mkdir -p "$CACHE"

# Rofi menu
choice=$(
    {
    for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
        [ -e "$img" ] || continue
        base="$(basename "$img")"
        echo -e "$base\x00icon\x1f$CACHE/$base.png"
    done
    for img in "$WALL_DIR"/*.gif; do
        [ -e "$img" ] || continue
        basename "$img"
    done
    } | rofi -dmenu -theme ~/.config/rofi/wallpaper.rasi -p "Wallpaper"
)

[ -z "$choice" ] && exit 0

IMG_PATH="$WALL_DIR/$choice"
IMG_NAME="${choice%.*}"

# =========================
# 1. Matugen - On załatwia Waybara
# =========================
# Twój config.toml ma 'post_hook' dla waybara, więc NIE DODAJEMY pkill w skrypcie.
matugen -c "$HOME/.config/matugen/config.toml" image "$IMG_PATH" -m dark --prefer=saturation -t scheme-tonal-spot
sync

# =========================
# 2. Zmiana tapety (swww)
# =========================
if command -v swww >/dev/null 2>&1; then
    pgrep -x swww-daemon >/dev/null 2>&1 || (swww-daemon & sleep 0.5)
    RANDOM_POS="$(awk 'BEGIN { srand(); printf "%.2f,%.2f", rand(), rand() }')"
    swww img "$IMG_PATH" --transition-type grow --transition-pos "$RANDOM_POS" --transition-duration 2.8 --transition-fps 60
fi

# =========================
# 3. Odświeżanie UI (Tylko to, czego nie ma w matugen)
# =========================

# Linkowanie tapety
[[ "$IMG_PATH" != *.gif ]] && ln -sf "$IMG_PATH" "$CURRENT_WALL"

# FIX DLA SWAYNC - Agresywne czyszczenie innych demonów i restart
# Zabijamy mako/dunst jeśli jakimś cudem wstały
pkill -9 mako