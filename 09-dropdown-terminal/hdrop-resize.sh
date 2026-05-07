#!/bin/bash

# ============================================================
# hdrop-resize.sh
# Resizer hdrop dropdown terminal med toppen låst til skjermtoppen
#
# Problem: resizeactive resizer fra CENTER → toppen forsvinner opp
# Løsning: resizeactive + moveactive for å kompensere
#
# Bruk: hdrop-resize.sh <retning>
#   Retninger: up | down | left | right
#
# Keybinds i hyprland.conf:
#   binde = $mainMod ALT, up,    exec, ~/.config/hypr/scripts/hdrop-resize.sh up
#   binde = $mainMod ALT, down,  exec, ~/.config/hypr/scripts/hdrop-resize.sh down
#   binde = $mainMod ALT, left,  exec, ~/.config/hypr/scripts/hdrop-resize.sh left
#   binde = $mainMod ALT, right, exec, ~/.config/hypr/scripts/hdrop-resize.sh right
# ============================================================

STEP=40       # Antall piksler per tastetrykk
DIRECTION=$1

case $DIRECTION in
    down)
        # Høyere: bunnen flyttes ned — toppen holdes i ro
        # resizeactive legger til STEP/2 opp og STEP/2 ned (senter-basert)
        # moveactive kompenserer ved å flytte vinduet STEP/2 ned igjen
        hyprctl dispatch resizeactive 0 $STEP
        hyprctl dispatch moveactive 0 $((STEP / 2))
        ;;
    up)
        # Lavere: bunnen flyttes opp — toppen holdes i ro
        hyprctl dispatch resizeactive 0 -$STEP
        hyprctl dispatch moveactive 0 -$((STEP / 2))
        ;;
    left)
        # Smalere: begge sider går innover fra senter — dette er riktig!
        hyprctl dispatch resizeactive -$STEP 0
        ;;
    right)
        # Bredere: begge sider går utover fra senter — dette er riktig!
        hyprctl dispatch resizeactive $STEP 0
        ;;
    *)
        echo "Bruk: hdrop-resize.sh <up|down|left|right>"
        exit 1
        ;;
esac
