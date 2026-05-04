#!/bin/bash

# Hyprlock Installation Script
# Installerer og konfigurerer hyprlock med Archruud bakgrunn

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Hyprlock Setup ===${NC}"
echo ""

HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installer hyprlock
if ! command -v hyprlock &> /dev/null; then
    echo -e "${YELLOW}Hyprlock er ikke installert. Installerer...${NC}"
    if command -v yay &> /dev/null; then
        yay -S --noconfirm hyprlock
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm hyprlock
    else
        echo -e "${RED}Installer hyprlock manuelt: yay -S hyprlock${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Hyprlock er allerede installert${NC}"
fi

# Opprett directories
mkdir -p "$HOME/.config/hypr"
mkdir -p "$WALLPAPER_DIR"

# Velg wallpaper
echo -e "${CYAN}Hvilken oppløsning bruker du?${NC}"
echo "  1) 1920x1200 (anbefalt for laptop)"
echo "  2) 2560x1600 (for større skjermer)"
echo ""
read -p "Velg (1 eller 2): " resolution_choice

case $resolution_choice in
    1)
        WALLPAPER_FILE="ARCHRUUD_1920x1200.png"
        ;;
    2)
        WALLPAPER_FILE="ARCHRUUD_2560x1600.png"
        ;;
    *)
        echo -e "${YELLOW}Ugyldig valg. Bruker 1920x1200${NC}"
        WALLPAPER_FILE="ARCHRUUD_1920x1200.png"
        ;;
esac

# Kopier wallpaper hvis den finnes i script directory
if [ -f "$SCRIPT_DIR/wallpapers/$WALLPAPER_FILE" ]; then
    echo -e "${GREEN}Kopierer wallpaper...${NC}"
    cp "$SCRIPT_DIR/wallpapers/$WALLPAPER_FILE" "$WALLPAPER_DIR/"
fi

# Sjekk at wallpaper finnes
if [ ! -f "$WALLPAPER_DIR/$WALLPAPER_FILE" ]; then
    echo -e "${YELLOW}Advarsel: Wallpaper finnes ikke i $WALLPAPER_DIR${NC}"
    echo -e "${YELLOW}Hyprlock vil bruke fallback bakgrunn${NC}"
fi

# Lag hyprlock config
echo -e "${GREEN}Oppretter hyprlock konfigurasjon...${NC}"
cat > "$HYPRLOCK_CONFIG" << EOF
# Hyprlock Configuration - Archruud

# General
general {
    grace = 5
    hide_cursor = true
    no_fade_in = false
    no_fade_out = false
}

# Background
background {
    monitor =
    path = $WALLPAPER_DIR/$WALLPAPER_FILE
    color = rgba(25, 20, 20, 1.0)
    blur_passes = 3
    blur_size = 7
    brightness = 0.5
    contrast = 0.8
}

# Input field
input-field {
    monitor =
    size = 300, 50
    outline_thickness = 2
    dots_size = 0.25
    dots_spacing = 0.3
    dots_center = true
    outer_color = rgb(b8e6fd)
    inner_color = rgb(1e1e2e)
    font_color = rgb(cdd6f4)
    fade_on_empty = false
    placeholder_text = <span foreground="##cdd6f4">Skriv passord...</span>
    hide_input = false
    position = 0, -120
    halign = center
    valign = center
}

# Time
label {
    monitor =
    text = cmd[update:1000] echo "\$(date +'%H:%M')"
    color = rgba(255, 255, 255, 1.0)
    font_size = 120
    font_family = JetBrains Mono Bold
    position = 0, 200
    halign = center
    valign = center
}

# Date
label {
    monitor =
    text = cmd[update:1000] echo "\$(date +'%A, %d %B %Y')"
    color = rgba(255, 255, 255, 0.8)
    font_size = 24
    font_family = JetBrains Mono
    position = 0, 80
    halign = center
    valign = center
}

# User
label {
    monitor =
    text = \$USER
    color = rgba(184, 230, 253, 1.0)
    font_size = 18
    font_family = JetBrains Mono
    position = 0, -180
    halign = center
    valign = center
}
EOF

echo -e "${GREEN}✓ Hyprlock config opprettet${NC}"

echo ""
echo -e "${GREEN}=== Hyprlock setup fullført! ===${NC}"
echo ""
echo -e "${YELLOW}Test hyprlock:${NC}"
echo "  hyprlock           # Lås skjerm nå"
echo ""
echo -e "${YELLOW}Keybindings:${NC}"
echo "  Legg til i hyprland.conf:"
echo "  bind = SUPER, L, exec, hyprlock"
echo ""
echo -e "${YELLOW}Config fil:${NC}"
echo "  $HYPRLOCK_CONFIG"
echo ""
echo -e "${YELLOW}Wallpaper:${NC}"
echo "  $WALLPAPER_DIR/$WALLPAPER_FILE"
echo ""
echo -e "${CYAN}Tips: Hyprlock brukes automatisk av hypridle${NC}"
