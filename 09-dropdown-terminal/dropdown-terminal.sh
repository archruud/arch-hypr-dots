#!/bin/bash

# ═════════════════════════════════════════════════════════════
# DROPDOWN TERMINAL FOR HYPRLAND
# Toggle script for kitty dropdown terminal
# ═════════════════════════════════════════════════════════════

# Sjekk om dropdown terminal allerede kjører
if hyprctl clients -j | jq -e '.[] | select(.class == "dropdown-terminal")' > /dev/null 2>&1; then
    # Hvis den kjører, toggle special workspace
    hyprctl dispatch togglespecialworkspace dropdown
else
    # Start ny dropdown terminal
    kitty --class=dropdown-terminal &
    
    # Vent litt til kitty starter
    sleep 0.3
    
    # Flytt til special workspace
    hyprctl dispatch movetoworkspace special:dropdown
    
    # Vis special workspace
    hyprctl dispatch togglespecialworkspace dropdown
fi
