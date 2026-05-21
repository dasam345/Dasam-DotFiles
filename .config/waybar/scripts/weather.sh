#!/bin/bash

CACHE="$HOME/.cache/weather"
CACHE_MAX_AGE=1800

# Fetch weather with auto-location (via IP)
if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -lt $CACHE_MAX_AGE ]; then
    WEATHER=$(cat "$CACHE")
else
    WEATHER=$(curl -s "wttr.in/?format=%C+%t&m" 2>/dev/null | head -1)
    [ -n "$WEATHER" ] && echo "$WEATHER" > "$CACHE" || WEATHER=$(cat "$CACHE" 2>/dev/null)
fi

[ -z "$WEATHER" ] && printf '{"text":"☀️ ?","tooltip":"Weather unavailable","class":"normal"}\n' && exit 0

CONDITION=$(echo "$WEATHER" | awk '{print $1}')
TEMP=$(echo "$WEATHER" | awk '{$1=""; print $0}' | xargs)

case "$CONDITION" in
    *Clear*)                       ICON="☀️" ;;
    *Sunny*)                       ICON="☀️" ;;
    *Partly*cloud*)                ICON="⛅" ;;
    *Cloud*overcast*|*Overcast*)    ICON="☁️" ;;
    *Cloud*)                       ICON="☁️" ;;
    *Rain*|*Drizzle*|*Light*rain*) ICON="🌧️" ;;
    *Heavy*rain*|*Downpour*)       ICON="🌧️" ;;
    *Snow*)                        ICON="❄️" ;;
    *Thunder*|*Storm*)             ICON="⛈️" ;;
    *Fog*|*Mist*|*Haze*)           ICON="🌫️" ;;
    *)                             ICON="☀️" ;;
esac

TOOLTIP="$(curl -s "wttr.in/?format=%l:+%C,+%t,+%w&m" 2>/dev/null | head -1)"
[ -z "$TOOLTIP" ] && TOOLTIP="$CONDITION $TEMP"

printf '{"text":"%s %s","tooltip":"%s","class":"normal"}\n' "$ICON" "$TEMP" "$TOOLTIP"
