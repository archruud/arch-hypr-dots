#!/bin/bash

# ============================================================
# dropterminal-resize.sh
# Resizer JaKooLit Dropterminal - relativ posisjonering
#
# Bruker RELATIV movewindowpixel — unngår koordinatproblemer
# med pinnede vinduer (absolutte koordinater kan inkludere
# virtuelle workspace-offsets og gi feil posisjon).
#
# Vertikalt:   toppen holdes låst — kun bunnen beveger seg
# Horisontalt: senter holdes — begge sider beveger seg (riktig!)
# ============================================================

STEP=40
HALF=$((STEP / 2))
DIRECTION=$1
ADDR_FILE="/tmp/dropdown_terminal_addr"

if [ ! -f "$ADDR_FILE" ] || [ ! -s "$ADDR_FILE" ]; then exit 1; fi
ADDR=$(cut -d' ' -f1 "$ADDR_FILE")
if [ -z "$ADDR" ]; then exit 1; fi

# Hent kun størrelse (ikke posisjon — unngår workspace-offset problemet)
WIN_SIZE=$(hyprctl clients -j | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['address'] == '$ADDR':
        print(c['size'][0], c['size'][1])
        break
" 2>/dev/null)

if [ -z "$WIN_SIZE" ]; then exit 1; fi

W=$(echo "$WIN_SIZE" | awk '{print $1}')
H=$(echo "$WIN_SIZE" | awk '{print $2}')

case $DIRECTION in
    down)
        # Høyere: resize fra senter (topp går opp HALF), korriger med relativ move ned HALF
        NEW_H=$((H + STEP))
        hyprctl dispatch resizewindowpixel "exact $W $NEW_H,address:$ADDR"
        sleep 0.05
        hyprctl dispatch movewindowpixel "0 $HALF,address:$ADDR"
        ;;
    up)
        # Lavere: resize fra senter (topp går ned HALF), korriger med relativ move opp HALF
        NEW_H=$((H - STEP))
        [ $NEW_H -lt 80 ] && NEW_H=80
        hyprctl dispatch resizewindowpixel "exact $W $NEW_H,address:$ADDR"
        sleep 0.05
        hyprctl dispatch movewindowpixel "0 -$HALF,address:$ADDR"
        ;;
    right)
        # Bredere: center-resize er riktig adferd — ingen korreksjon
        NEW_W=$((W + STEP))
        hyprctl dispatch resizewindowpixel "exact $NEW_W $H,address:$ADDR"
        ;;
    left)
        # Smalere: center-resize er riktig adferd — ingen korreksjon
        NEW_W=$((W - STEP))
        [ $NEW_W -lt 200 ] && NEW_W=200
        hyprctl dispatch resizewindowpixel "exact $NEW_W $H,address:$ADDR"
        ;;
    *)
        echo "Bruk: dropterminal-resize.sh <up|down|left|right>"
        exit 1
        ;;
esac
