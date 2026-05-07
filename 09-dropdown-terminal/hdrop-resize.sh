#!/bin/bash

# ============================================================
# hdrop-resize.sh v2
# Resizer hdrop dropdown terminal med eksakt posisjonering
#
# Problem v1: resizeactive + moveactive er upålitelig
# Løsning v2: henter eksakt posisjon/størrelse via hyprctl,
#             beregner ny verdi, setter eksakt med class-match
#
# Vertikalt:  toppen holdes låst — kun bunnen beveger seg
# Horisontalt: senter holdes — begge sider beveger seg (riktig!)
# ============================================================

STEP=40
DIRECTION=$1
CLASS="kitty_top"

# ── Hent eksakt posisjon og størrelse ────────────────────────────────────────
WIN_INFO=$(hyprctl clients -j | python3 -c "
import json, sys
clients = json.load(sys.stdin)
for c in clients:
    if c['class'] == '$CLASS':
        print(c['at'][0], c['at'][1], c['size'][0], c['size'][1])
        break
" 2>/dev/null)

if [ -z "$WIN_INFO" ]; then
    WIN_INFO=$(hyprctl clients -j | jq -r \
        ".[] | select(.class == \"$CLASS\") | \"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])\"" \
        2>/dev/null | head -1)
fi

if [ -z "$WIN_INFO" ]; then exit 1; fi

X=$(echo "$WIN_INFO" | awk '{print $1}')
Y=$(echo "$WIN_INFO" | awk '{print $2}')
W=$(echo "$WIN_INFO" | awk '{print $3}')
H=$(echo "$WIN_INFO" | awk '{print $4}')

case $DIRECTION in
    down)
        NEW_H=$((H + STEP))
        hyprctl dispatch resizewindowpixel "exact $W $NEW_H,class:^($CLASS)$"
        hyprctl dispatch movewindowpixel   "exact $X $Y,class:^($CLASS)$"
        ;;
    up)
        NEW_H=$((H - STEP))
        [ $NEW_H -lt 80 ] && NEW_H=80
        hyprctl dispatch resizewindowpixel "exact $W $NEW_H,class:^($CLASS)$"
        hyprctl dispatch movewindowpixel   "exact $X $Y,class:^($CLASS)$"
        ;;
    right)
        NEW_W=$((W + STEP))
        NEW_X=$((X - STEP / 2))
        hyprctl dispatch resizewindowpixel "exact $NEW_W $H,class:^($CLASS)$"
        hyprctl dispatch movewindowpixel   "exact $NEW_X $Y,class:^($CLASS)$"
        ;;
    left)
        NEW_W=$((W - STEP))
        [ $NEW_W -lt 200 ] && NEW_W=200
        NEW_X=$((X + STEP / 2))
        hyprctl dispatch resizewindowpixel "exact $NEW_W $H,class:^($CLASS)$"
        hyprctl dispatch movewindowpixel   "exact $NEW_X $Y,class:^($CLASS)$"
        ;;
    *)
        echo "Bruk: hdrop-resize.sh <up|down|left|right>"
        exit 1
        ;;
esac
