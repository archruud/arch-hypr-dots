#!/bin/bash

# dropterminal-init.sh
# Kjøres ved oppstart via exec-once
# Initialiserer JaKooLit dropdown terminal så den er klar ved første bruk
#
# Sekvens:
#   1. Vent til Hyprland er klar
#   2. Kjør 1: oppretter vindu i scratchpad (usynlig)
#   3. Kjør 2: viser vinduet
#   4. Kjør 3: skjuler vinduet igjen → klar til bruk!

SCRIPT="$HOME/.config/hypr/scripts/dropterminal.sh"

# Vent til Hyprland socket er klar
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"
COUNT=0
until [ -S "$SOCKET" ] || [ $COUNT -ge 20 ]; do
    sleep 0.5
    COUNT=$((COUNT + 1))
done

# Litt ekstra tid for at window rules lastes
sleep 0.1

bash "$SCRIPT" kitty   # 1: opprett i scratchpad
sleep 0.1
bash "$SCRIPT" kitty   # 2: vis
sleep 0.1
bash "$SCRIPT" kitty   # 3: skjul — klar!
