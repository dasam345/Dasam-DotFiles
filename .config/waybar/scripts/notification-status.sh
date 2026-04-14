#!/bin/bash
# Wrapper dla swaync-client – wymagany przez waybar custom/notification
# swaync-client -swb działa strumieniowo, waybar czyta kolejne linie

if ! command -v swaync-client >/dev/null 2>&1; then
    echo '{"text":"󰂜","tooltip":"SwayNC nie jest zainstalowany","class":"none"}'
    exit 0
fi

# Uruchom swaync-client w trybie watch – wysyła JSON przy każdej zmianie
exec swaync-client -swb
