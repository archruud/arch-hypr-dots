#!/bin/bash

# ============================================================
# hdrop-init.sh
# Starter hdrop etter at Hyprland er ferdig initialisert
#
# Problem: exec-once starter hdrop for tidlig — window rules
# er ikke lastet ennå, så kitty havner tilfeldig på skjermen.
#
# Løsning: vent til Hyprland socket er klar + litt ekstra tid,
# så starter hdrop. Vinduet pre-spawnes på riktig plass.
# ============================================================

HDROP_CMD="hdrop -b -f -h 35 -w 75 -p top -g 57 kitty --class kitty_top --override window_padding_width=0"

# Vent til Hyprland socket eksisterer
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"
TIMEOUT=15
COUNT=0

until [ -S "$SOCKET" ] || [ $COUNT -ge $TIMEOUT ]; do
    sleep 0.5
    COUNT=$((COUNT + 1))
done

# Litt ekstra tid for at window rules skal lastes inn
sleep 1.5

# Start hdrop — kitty spawnes nå på riktig plass
$HDROP_CMD
