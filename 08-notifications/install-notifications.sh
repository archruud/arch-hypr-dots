#!/bin/bash

# Notifications Installation Script
# Installerer og konfigurerer mako notification daemon

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Notifications Setup (Mako) ===${NC}"
echo ""

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
MAKO_CONFIG="$HOME/.config/mako/config"

# Installer mako
if ! command -v mako &> /dev/null; then
    echo -e "${YELLOW}Mako er ikke installert. Installerer...${NC}"
    sudo pacman -S --noconfirm mako
else
    echo -e "${GREEN}✓ Mako er allerede installert${NC}"
fi

# Opprett config directory
mkdir -p "$HOME/.config/mako"

# Lag mako config med Archruud farger
echo -e "${GREEN}Oppretter mako konfigurasjon...${NC}"
cat > "$MAKO_CONFIG" << 'EOF'
# Mako Notification Configuration - Archruud

# Appearance
font=JetBrains Mono 10
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#b8e6fd
border-size=2
border-radius=8
padding=15
margin=10

# Icons
icons=1
max-icon-size=48
icon-path=/usr/share/icons/Papirus-Dark

# Behavior
default-timeout=5000
ignore-timeout=0

# Positioning
anchor=top-right
width=350
height=150

# Grouping
group-by=app-name

# Urgency levels
[urgency=low]
border-color=#89b4fa
default-timeout=3000

[urgency=normal]
border-color=#b8e6fd
default-timeout=5000

[urgency=critical]
border-color=#f38ba8
default-timeout=0
ignore-timeout=1
EOF

echo -e "${GREEN}✓ Mako config opprettet${NC}"

# Legg til i hyprland.conf
echo -e "${GREEN}Legger til mako i hyprland.conf...${NC}"

# Fjern gamle mako linjer
sed -i '/exec-once.*mako/d' "$HYPRLAND_CONFIG"

# Legg til exec-once
if grep -q "### AUTOSTART ###" "$HYPRLAND_CONFIG"; then
    sed -i '/### AUTOSTART ###/a exec-once = mako' "$HYPRLAND_CONFIG"
else
    cat >> "$HYPRLAND_CONFIG" << 'EOF'

# Mako notifications (added by notifications script)
exec-once = mako
EOF
fi

echo -e "${GREEN}✓ Mako lagt til i hyprland.conf${NC}"

# Start mako nå
echo -e "${CYAN}Starter mako...${NC}"
pkill mako 2>/dev/null
mako &
sleep 1

# Test notification
if pgrep -x mako > /dev/null; then
    echo -e "${GREEN}✓ Mako kjører!${NC}"
    notify-send "Mako Notifications" "Notifications er nå aktivert!" -u normal
else
    echo -e "${RED}✗ Mako startet ikke${NC}"
fi

echo ""
echo -e "${GREEN}=== Notifications setup fullført! ===${NC}"
echo ""
echo -e "${YELLOW}Test notifications:${NC}"
echo "  notify-send 'Tittel' 'Melding'"
echo "  notify-send -u critical 'Viktig' 'Dette er viktig!'"
echo ""
echo -e "${YELLOW}Kontroller mako:${NC}"
echo "  makoctl dismiss    # Dismiss current notification"
echo "  makoctl dismiss -a # Dismiss all"
echo "  makoctl reload     # Reload config"
echo ""
echo -e "${YELLOW}Config fil:${NC}"
echo "  $MAKO_CONFIG"
echo ""
echo -e "${CYAN}Mako vil starte automatisk ved neste Hyprland oppstart!${NC}"
