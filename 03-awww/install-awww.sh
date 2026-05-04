#!/bin/bash

# AWWW Installation & Configuration Script
# Dette setter opp awww (wayland wallpaper daemon) for Hyprland
# Erstatter swww som ble arkivert og omdøpt til awww i oktober 2025
# Ny kilde: https://codeberg.org/LGFae/awww

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== AWWW Setup - Wayland Wallpaper Daemon ===${NC}"
echo -e "${CYAN}(Tidligere kjent som swww - omdøpt oktober 2025)${NC}"
echo ""

# Paths
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
AWWW_SCRIPT="$SCRIPTS_DIR/awww-wallpaper.sh"

# Finn hvor dette scriptet ligger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sjekk om awww er installert (prøv awww først, deretter swww som fallback)
if ! command -v awww &> /dev/null; then
    echo -e "${YELLOW}AWWW er ikke installert. Installerer...${NC}"
    if command -v yay &> /dev/null; then
        yay -S --needed --answerdiff=None --answerclean=None awww
    elif command -v paru &> /dev/null; then
        paru -S --needed --noconfirm awww
    else
        echo -e "${RED}Installer awww manuelt: yay -S awww${NC}"
        echo -e "${YELLOW}Kilde: https://codeberg.org/LGFae/awww${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ AWWW er allerede installert${NC}"
fi

# Opprett directories
mkdir -p "$HOME/.config/hypr"
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$SCRIPTS_DIR"

# --- Kopier BEGGE wallpaper-filer (uavhengig av valg) ---
echo -e "${GREEN}Kopierer wallpaper-filer...${NC}"

WALLPAPERS=("ARCHRUUD_1920x1200.png" "ARCHRUUD_2560x1600.png")

for WP in "${WALLPAPERS[@]}"; do
    if [ -f "$SCRIPT_DIR/wallpapers/$WP" ]; then
        cp "$SCRIPT_DIR/wallpapers/$WP" "$WALLPAPER_DIR/"
        echo -e "${GREEN}✓ Kopiert: $WP${NC}"
    elif [ -f "$WALLPAPER_DIR/$WP" ]; then
        echo -e "${CYAN}ℹ Finnes allerede: $WP${NC}"
    else
        echo -e "${YELLOW}⚠ Ikke funnet: $WP (legg den manuelt i $WALLPAPER_DIR)${NC}"
    fi
done

# --- Velg standard wallpaper ---
echo ""
echo -e "${CYAN}Hvilken oppløsning vil du bruke som standard?${NC}"
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

# --- Lag awww startup script ---
echo ""
echo -e "${GREEN}Lager awww startup script: $AWWW_SCRIPT${NC}"

cat > "$AWWW_SCRIPT" << EOF
#!/bin/bash

# AWWW Wallpaper Setter - Archruud
# Dette scriptet starter awww daemon og setter wallpaper
# Erstatter swww (omdøpt til awww, oktober 2025)

WALLPAPER_DIR="\$HOME/.config/hypr/wallpapers"
WALLPAPER_FILE="$WALLPAPER_FILE"

# Start awww daemon (hvis ikke allerede kjører)
if ! pgrep -x awww-daemon > /dev/null; then
    awww-daemon &
    sleep 1
fi

# Sett wallpaper med fade transition
awww img "\$WALLPAPER_DIR/\$WALLPAPER_FILE" \\
    --transition-type fade \\
    --transition-duration 2 \\
    --transition-fps 60

# Alternativt: random transition hver gang
# TRANSITIONS=("fade" "wipe" "grow" "wave" "center" "outer")
# RANDOM_TRANSITION=\${TRANSITIONS[\$RANDOM % \${#TRANSITIONS[@]}]}
# awww img "\$WALLPAPER_DIR/\$WALLPAPER_FILE" --transition-type \$RANDOM_TRANSITION
EOF

chmod +x "$AWWW_SCRIPT"
echo -e "${GREEN}✓ Startup script opprettet: $AWWW_SCRIPT${NC}"

# --- Oppdater hyprland.conf ---
if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo -e "${RED}Feil: Kan ikke finne $HYPRLAND_CONFIG${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Rydder opp i hyprland.conf...${NC}"

# Fjern gamle swww/awww/hyprpaper exec-once linjer
sed -i '/exec-once.*swww-daemon/d' "$HYPRLAND_CONFIG"
sed -i '/exec-once.*awww-daemon/d' "$HYPRLAND_CONFIG"
sed -i '/exec-once.*swww-wallpaper/d' "$HYPRLAND_CONFIG"
sed -i '/exec-once.*awww-wallpaper/d' "$HYPRLAND_CONFIG"
sed -i '/exec-once.*hyprpaper/d' "$HYPRLAND_CONFIG"

echo -e "${GREEN}Legger til awww i hyprland.conf...${NC}"

# Legg til ny awww startup linje
if grep -q "### AUTOSTART ###" "$HYPRLAND_CONFIG"; then
    sed -i '/### AUTOSTART ###/a exec-once = ~/.config/hypr/scripts/awww-wallpaper.sh' "$HYPRLAND_CONFIG"
else
    # Legg til etter første exec-once linje, eller på toppen av filen
    if grep -q "^exec-once" "$HYPRLAND_CONFIG"; then
        sed -i '0,/^exec-once/s/^exec-once/exec-once = ~\/.config\/hypr\/scripts\/awww-wallpaper.sh\nexec-once/' "$HYPRLAND_CONFIG"
    else
        sed -i '1s/^/exec-once = ~\/.config\/hypr\/scripts\/awww-wallpaper.sh\n/' "$HYPRLAND_CONFIG"
    fi
fi

echo -e "${GREEN}✓ AWWW aktivert i hyprland.conf${NC}"

# --- Test awww nå ---
echo ""
echo -e "${CYAN}Starter awww nå...${NC}"
bash "$AWWW_SCRIPT"

sleep 2
if pgrep -x awww-daemon > /dev/null; then
    echo -e "${GREEN}✓ AWWW daemon kjører!${NC}"
    echo -e "${GREEN}✓ Wallpaper er satt til: $WALLPAPER_FILE${NC}"
else
    echo -e "${RED}✗ AWWW startet ikke. Prøv manuelt: awww-daemon &${NC}"
fi

echo ""
echo -e "${GREEN}=== Setup fullført! ===${NC}"
echo ""
echo -e "${YELLOW}Viktige filer:${NC}"
echo "  Startup script : $AWWW_SCRIPT"
echo "  Wallpapers     : $WALLPAPER_DIR/"
echo "    - ARCHRUUD_1920x1200.png"
echo "    - ARCHRUUD_2560x1600.png"
echo "  Aktiv wallpaper: $WALLPAPER_FILE"
echo ""
echo -e "${YELLOW}Endringer i hyprland.conf:${NC}"
echo "  Fjernet : exec-once = swww-daemon"
echo "  Fjernet : exec-once = swww-wallpaper.sh (gammel)"
echo "  Lagt til: exec-once = ~/.config/hypr/scripts/awww-wallpaper.sh"
echo ""
echo -e "${YELLOW}Kommandoer:${NC}"
echo "  Sett wallpaper : awww img /path/to/image.png"
echo "  Bytt med fade  : awww img /path/to/image.png --transition-type fade"
echo "  Bytt til 2560  : awww img $WALLPAPER_DIR/ARCHRUUD_2560x1600.png --transition-type fade"
echo "  Bytt til 1920  : awww img $WALLPAPER_DIR/ARCHRUUD_1920x1200.png --transition-type fade"
echo "  Stop daemon    : pkill awww-daemon"
echo "  Start daemon   : awww-daemon &"
echo ""
echo -e "${YELLOW}Transitions:${NC}"
echo "  fade, wipe, grow, wave, center, outer, any, random"
echo ""
echo -e "${CYAN}AWWW vil starte automatisk ved neste Hyprland oppstart!${NC}"
echo -e "${CYAN}NB: Mappe bør renames: 03-swww → 03-awww på GitHub${NC}"
