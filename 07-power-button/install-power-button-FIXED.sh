#!/bin/bash

# Power Button Configuration Script
# Konfigurerer power button til å åpne wlogout i stedet for shutdown

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Power Button Configuration ===${NC}"
echo ""

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
LOGIND_CONF="/etc/systemd/logind.conf"

# Sjekk om wlogout er installert
if ! command -v wlogout &> /dev/null; then
    echo -e "${YELLOW}wlogout er ikke installert${NC}"
    echo -e "${YELLOW}Power button vil ikke fungere uten wlogout${NC}"
    echo -e "${YELLOW}Installer wlogout først: ./07-wlogout/install-wlogout.sh${NC}"
    exit 1
fi

# Konfigurer systemd logind til å IGNORERE power button
echo -e "${CYAN}Konfigurerer systemd logind...${NC}"

if [ ! -f "$LOGIND_CONF.backup" ]; then
    echo -e "${GREEN}Lager backup av logind.conf...${NC}"
    sudo cp "$LOGIND_CONF" "$LOGIND_CONF.backup"
fi

# Oppdater logind.conf - IGNORE power button (ikke logout!)
sudo bash -c "cat > $LOGIND_CONF << 'EOF'
# Logind Configuration - Power Button Handling
# Modified by power-button script

[Login]
HandlePowerKey=ignore
HandleSuspendKey=suspend
HandleHibernateKey=hibernate
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
EOF"

echo -e "${GREEN}✓ logind.conf oppdatert (power button ignoreres)${NC}"

# VIKTIG: Ikke restart systemd-logind nå - det logger ut alle brukere!
echo -e "${YELLOW}OBS: systemd-logind restarter IKKE nå (ville logget deg ut!)${NC}"
echo -e "${YELLOW}Endringene trer i kraft etter neste reboot eller logout${NC}"

# Legg til keybinding i hyprland.conf
echo -e "${GREEN}Legger til power button handling i hyprland.conf...${NC}"

# Fjern gamle power button bindings
sed -i '/XF86PowerOff/d' "$HYPRLAND_CONFIG"

# Legg til ny binding
if grep -q "### KEYBINDINGS ###" "$HYPRLAND_CONFIG"; then
    sed -i '/### KEYBINDINGS ###/a \
# Power button handling\
bind = , XF86PowerOff, exec, wlogout -b 5 -c 0 -r 0 -m 0' "$HYPRLAND_CONFIG"
else
    cat >> "$HYPRLAND_CONFIG" << 'EOF'

# Power button handling (added by power-button script)
bind = , XF86PowerOff, exec, wlogout -b 5 -c 0 -r 0 -m 0
EOF
fi

echo -e "${GREEN}✓ Power button binding lagt til${NC}"

echo ""
echo -e "${GREEN}=== Power Button setup fullført! ===${NC}"
echo ""
echo -e "${YELLOW}VIKTIG: Power button konfigurasjon trer i kraft etter reboot/logout${NC}"
echo ""
echo -e "${YELLOW}Hva skjer når du restarter:${NC}"
echo "  Power button → Åpner wlogout menu"
echo "  Du kan velge: Lock, Logout, Shutdown, Reboot, Suspend, Hibernate"
echo ""
echo -e "${YELLOW}Alternative keybindings:${NC}"
echo "  SUPER + X  → Åpne wlogout (satt av wlogout script)"
echo ""
echo -e "${YELLOW}For å reversere:${NC}"
echo "  sudo cp $LOGIND_CONF.backup $LOGIND_CONF"
echo "  sudo systemctl restart systemd-logind"
echo ""
echo -e "${GREEN}Du kan trygt fortsette med installasjon av andre moduler!${NC}"
