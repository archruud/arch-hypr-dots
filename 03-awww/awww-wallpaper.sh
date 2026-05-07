#!/bin/bash

# AWWW Wallpaper Setter - Archruud
# Plassering: ~/.config/hypr/scripts/awww-wallpaper.sh
#
# BYTT OPPLØSNING: Endre WALLPAPER_FILE nedenfor
#   1920x1200 = laptop / mindre skjerm
#   2560x1600 = større skjerm
#
# MANUELL BRUK:
#   awww img ~/.config/hypr/wallpapers/ARCHRUUD_1920x1200.png --transition-type fade
#   awww img ~/.config/hypr/wallpapers/ARCHRUUD_2560x1600.png --transition-type grow

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# ─── ENDRE HER FOR Å BYTTE OPPLØSNING ───────────────────────────────────────
WALLPAPER_FILE="ARCHRUUD_1920x1200.png"
# WALLPAPER_FILE="ARCHRUUD_2560x1600.png"
# ─────────────────────────────────────────────────────────────────────────────

WALLPAPER_PATH="$WALLPAPER_DIR/$WALLPAPER_FILE"

# Start awww-daemon hvis den ikke kjører
if ! pgrep -x awww-daemon > /dev/null; then
    awww-daemon &
fi

# Vent til socket er klar (maks 10 sekunder) - unngår race condition
SOCKET_FILE="${XDG_RUNTIME_DIR}/awww-${WAYLAND_DISPLAY}.socket"
TIMEOUT=10
COUNT=0
until [ -S "$SOCKET_FILE" ] || [ $COUNT -ge $TIMEOUT ]; do
    sleep 0.5
    COUNT=$((COUNT + 1))
done

# Sjekk at wallpaper-filen finnes
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Feil: Fant ikke $WALLPAPER_PATH" >&2
    exit 1
fi

# Sett wallpaper
awww img "$WALLPAPER_PATH" \
    --transition-type fade \
    --transition-duration 2 \
    --transition-fps 60
