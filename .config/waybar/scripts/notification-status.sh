#!/bin/bash
set -euo pipefail

if ! command -v swaync-client >/dev/null 2>&1; then
    echo '{"text":"󰂜","tooltip":"SwayNC missing"}'
    exit 0
fi

output=$(swaync-client -swb 2>/dev/null || true)
if [[ -z "$output" ]]; then
    echo '{"text":"󰂜","tooltip":"No notifications"}'
    exit 0
fi

printf '%s' "$output"
