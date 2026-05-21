#!/bin/bash

# ── Check NetworkManager ────────────────────────────────────
if ! command -v nmcli &>/dev/null; then
    notify-send "WiFi" "NetworkManager (nmcli) not found"
    exit 1
fi

# ── Ensure Wi-Fi is enabled ─────────────────────────────────
if ! nmcli radio wifi | grep -q enabled; then
    nmcli radio wifi on
    sleep 1
fi

# ── Rescan and list networks ────────────────────────────────
nmcli dev wifi rescan &>/dev/null

LIST=$(nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list | head -30 | awk -F: '{
    ssid=$1
    signal=$2
    sec=$3
    if (length(ssid)==0) next
    bars=""
    if (signal+0 >= 80) bars="████"
    else if (signal+0 >= 60) bars="███"
    else if (signal+0 >= 40) bars="██"
    else if (signal+0 >= 20) bars="█"
    else bars=" "
    if (sec == "" || sec == "--") sec=" "
    printf "%-25s %s %s\n", ssid, bars, sec
}')

[ -z "$LIST" ] && notify-send "WiFi" "No networks found" && exit 0

# ── Rofi menu ───────────────────────────────────────────────
CHOICE=$(echo "$LIST" | rofi -dmenu -i -p "WiFi" -theme-str 'window {width: 450px;} listview {lines: 12;}')

[ -z "$CHOICE" ] && exit 0

# Extract SSID (first field, trim)
SSID=$(echo "$CHOICE" | awk '{$1=$1; print $1}')

# Check if already connected
if nmcli -t -f GENERAL.STATE con show "$SSID" 2>/dev/null | grep -q activated; then
    notify-send "WiFi" "Already connected to $SSID"
    exit 0
fi

# Try to connect
if nmcli con show "$SSID" &>/dev/null; then
    nmcli con up "$SSID" 2>/dev/null && \
        notify-send "WiFi" "Connected to $SSID" || \
        notify-send -u critical "WiFi" "Failed to connect to $SSID"
else
    HAS_SEC=$(echo "$CHOICE" | grep -oE 'WPA|WEP|802.1X')
    if [ -n "$HAS_SEC" ]; then
        PASSWORD=$(rofi -dmenu -password -p "Password for $SSID" -theme-str 'window {width: 350px;}')
        [ -z "$PASSWORD" ] && exit 0
        nmcli dev wifi connect "$SSID" password "$PASSWORD" 2>/dev/null && \
            notify-send "WiFi" "Connected to $SSID" || \
            notify-send -u critical "WiFi" "Wrong password or connection failed"
    else
        nmcli dev wifi connect "$SSID" 2>/dev/null && \
            notify-send "WiFi" "Connected to $SSID" || \
            notify-send -u critical "WiFi" "Connection failed"
    fi
fi
