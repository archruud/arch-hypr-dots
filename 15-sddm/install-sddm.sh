#!/bin/bash

# SDDM Theme Installation Script v2 - Forbedret
# Finner automatisk theme files der scriptet ligger

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== SDDM Theme Installation - Archruud ===${NC}"

# Sjekk root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Dette scriptet må kjøres som root (sudo)${NC}"
    exit 1
fi

# Finn hvor scriptet ligger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SOURCE="$SCRIPT_DIR/sddm-archruud"
THEME_TARGET="/usr/share/sddm/themes/archruud"
SDDM_CONF="/etc/sddm.conf.d/theme.conf"

echo -e "${CYAN}Script directory: $SCRIPT_DIR${NC}"

# Sjekk om SDDM er installert
if ! command -v sddm &> /dev/null; then
    echo -e "${YELLOW}SDDM er ikke installert. Installerer...${NC}"
    pacman -S --noconfirm sddm
fi

# Sjekk om theme source finnes
if [ ! -d "$THEME_SOURCE" ]; then
    echo -e "${RED}Feil: Kan ikke finne SDDM theme i $THEME_SOURCE${NC}"
    echo -e "${YELLOW}Pass på at 'sddm-archruud' mappen ligger ved siden av dette scriptet${NC}"
    exit 1
fi

echo -e "${CYAN}Hvilken oppløsning bruker du?${NC}"
echo "  1) 1920x1200 (anbefalt for laptop)"
echo "  2) 2560x1600 (for større skjermer)"
echo ""
read -p "Velg (1 eller 2): " resolution_choice

case $resolution_choice in
    1)
        BG_FILE="ARCHRUUD_1920x1200.png"
        WIDTH="1920"
        HEIGHT="1200"
        ;;
    2)
        BG_FILE="ARCHRUUD_2560x1600.png"
        WIDTH="2560"
        HEIGHT="1600"
        ;;
    *)
        echo -e "${YELLOW}Ugyldig valg. Bruker 1920x1200${NC}"
        BG_FILE="ARCHRUUD_1920x1200.png"
        WIDTH="1920"
        HEIGHT="1200"
        ;;
esac

# Kopier theme
echo -e "${GREEN}Kopierer theme til $THEME_TARGET...${NC}"
rm -rf "$THEME_TARGET"
mkdir -p "$THEME_TARGET"
cp -r "$THEME_SOURCE"/* "$THEME_TARGET/"

# Oppdater theme.conf
echo -e "${GREEN}Konfigurerer for $BG_FILE...${NC}"
sed -i "s|^Background=.*|Background=\"Backgrounds/$BG_FILE\"|" "$THEME_TARGET/theme.conf"
sed -i "s|^ScreenWidth=.*|ScreenWidth=\"$WIDTH\"|" "$THEME_TARGET/theme.conf"
sed -i "s|^ScreenHeight=.*|ScreenHeight=\"$HEIGHT\"|" "$THEME_TARGET/theme.conf"

# Sett permissions
chown -R root:root "$THEME_TARGET"
chmod -R 755 "$THEME_TARGET"

# Aktiver theme
echo -e "${GREEN}Aktiverer theme...${NC}"
mkdir -p /etc/sddm.conf.d

cat > "$SDDM_CONF" << 'EOF'
[Theme]
Current=archruud
CursorTheme=Adwaita

[General]
DisplayServer=wayland
GreeterEnvironment="QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
EOF

# Enable service
echo -e "${GREEN}Aktiverer SDDM service...${NC}"
systemctl enable sddm

echo ""
echo -e "${GREEN}=== Installasjon fullført! ===${NC}"
echo ""
echo -e "${YELLOW}SDDM theme er nå installert i:${NC}"
echo "  $THEME_TARGET"
echo ""
echo -e "${YELLOW}Bruker:${NC}"
echo "  Bakgrunn: $BG_FILE"
echo "  Oppløsning: ${WIDTH}x${HEIGHT}"
echo ""
echo -e "${YELLOW}For å se theme:${NC}"
echo "  Restart systemet: sudo reboot"
echo ""
echo -e "${CYAN}ADVARSEL: sudo systemctl restart sddm logger deg ut umiddelbart!${NC}"
