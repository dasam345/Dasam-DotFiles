#!/bin/bash

# ── CPU usage ──────────────────────────────────────────────
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)

# ── RAM usage (bash-only, no bc dependency) ─────────────────
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED_KB=$(( MEM_TOTAL - MEM_AVAIL ))
MEM_PCT=$(( MEM_USED_KB * 100 / MEM_TOTAL ))

# Format RAM used (MB or GB)
MEM_USED_MB=$(( MEM_USED_KB / 1024 ))
if [ "$MEM_USED_MB" -ge 1024 ]; then
    MEM_FMT="$(( MEM_USED_MB / 1024 )).$(( (MEM_USED_MB % 1024) * 10 / 1024 ))G"
else
    MEM_FMT="${MEM_USED_MB}M"
fi

# Format RAM total (GB)
MEM_TOTAL_GB=$(( MEM_TOTAL / 1024 / 1024 ))
MEM_TOTAL_REM=$(( (MEM_TOTAL / 1024 / 1024) * 10 + (MEM_TOTAL % (1024 * 1024)) * 10 / (1024 * 1024) ))
MEM_TOTAL_SHORT="${MEM_TOTAL_GB}.$(( (MEM_TOTAL % (1024 * 1024)) * 10 / (1024 * 1024) ))G"

# ── GPU usage ──────────────────────────────────────────────
GPU="?"
if command -v radeontop >/dev/null 2>&1; then
    GPU_VAL=$(radeontop -d - -l 1 2>/dev/null | grep -oP 'gpu\s+\K[0-9.]+' | head -1 | cut -d. -f1)
    [ -n "$GPU_VAL" ] && GPU="$GPU_VAL"
elif command -v intel_gpu_top >/dev/null 2>&1; then
    GPU_VAL=$(intel_gpu_top -L -s 1 2>/dev/null | grep -oP 'render\s+\K[0-9]+' | head -1)
    [ -n "$GPU_VAL" ] && GPU="$GPU_VAL"
fi

# ── JSON output ────────────────────────────────────────────
if [ "$CPU" -gt 80 ] || [ "$MEM_PCT" -gt 80 ] || { [ "$GPU" != "?" ] && [ "$GPU" -gt 80 ]; }; then
    CLASS="critical"
elif [ "$CPU" -gt 50 ] || [ "$MEM_PCT" -gt 50 ] || { [ "$GPU" != "?" ] && [ "$GPU" -gt 50 ]; }; then
    CLASS="warning"
else
    CLASS="normal"
fi

TOOLTIP="CPU: ${CPU}%  |  RAM: ${MEM_FMT} / ${MEM_TOTAL_SHORT} (${MEM_PCT}%)"
[ "$GPU" != "?" ] && TOOLTIP="${TOOLTIP}  |  GPU: ${GPU}%"

TEXT=" ${CPU}%"
[ "$GPU" != "?" ] && TEXT="${TEXT}   ${GPU}%"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS"
