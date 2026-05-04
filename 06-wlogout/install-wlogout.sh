#!/bin/bash

# Wlogout Installation Script
# Installerer wlogout (logout menu) med Archruud theme

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Wlogout Setup ===${NC}"
echo ""

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
WLOGOUT_DIR="$HOME/.config/wlogout"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installer wlogout
if ! command -v wlogout &> /dev/null; then
    echo -e "${YELLOW}Installerer wlogout...${NC}"
    if command -v yay &> /dev/null; then
        yay -S --noconfirm wlogout
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm wlogout
    else
        echo -e "${RED}Installer wlogout manuelt: yay -S wlogout${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Wlogout er allerede installert${NC}"
fi

# Opprett config directory
mkdir -p "$WLOGOUT_DIR"

# Lag layout config
echo -e "${GREEN}Oppretter layout config...${NC}"
cat > "$WLOGOUT_DIR/layout" << 'EOF'
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
{
    "label" : "hibernate",
    "action" : "systemctl hibernate",
    "text" : "Hibernate",
    "keybind" : "h"
}
{
    "label" : "logout",
    "action" : "hyprctl dispatch exit",
    "text" : "Logout",
    "keybind" : "e"
}
{
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Shutdown",
    "keybind" : "s"
}
{
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Suspend",
    "keybind" : "u"
}
{
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Reboot",
    "keybind" : "r"
}
EOF

# Lag style.css
echo -e "${GREEN}Oppretter style config...${NC}"
cat > "$WLOGOUT_DIR/style.css" << 'EOF'
* {
    background-image: none;
    box-shadow: none;
}

window {
    background-color: rgba(12, 12, 12, 0.9);
}

button {
    border-radius: 8px;
    border: 3px solid #b8e6fd;
    background-color: rgba(30, 30, 46, 0.7);
    background-repeat: no-repeat;
    background-position: center;
    background-size: 25%;
    color: #cdd6f4;
    font-size: 20px;
    margin: 10px;
    min-width: 150px;
    min-height: 150px;
}

button:focus,
button:active,
button:hover {
    background-color: rgba(180, 190, 254, 0.3);
    outline-style: none;
}

#lock {
    background-image: image(url("/usr/share/wlogout/icons/lock.png"));
}

#logout {
    background-image: image(url("/usr/share/wlogout/icons/logout.png"));
}

#suspend {
    background-image: image(url("/usr/share/wlogout/icons/suspend.png"));
}

#hibernate {
    background-image: image(url("/usr/share/wlogout/icons/hibernate.png"));
}

#shutdown {
    background-image: image(url("/usr/share/wlogout/icons/shutdown.png"));
}

#reboot {
    background-image: image(url("/usr/share/wlogout/icons/reboot.png"));
}
EOF

# Legg til keybinding i hyprland.conf
echo -e "${GREEN}Legger til wlogout keybinding...${NC}"

# Fjern gamle wlogout keybindings
sed -i '/wlogout/d' "$HYPRLAND_CONFIG"

# Legg til keybinding
if grep -q "### KEYBINDINGS ###" "$HYPRLAND_CONFIG"; then
    sed -i '/### KEYBINDINGS ###/a \
# Wlogout menu\
bind = SUPER, X, exec, wlogout -b 5 -c 0 -r 0 -m 0' "$HYPRLAND_CONFIG"
else
    cat >> "$HYPRLAND_CONFIG" << 'EOF'

# Wlogout menu (added by wlogout script)
bind = SUPER, X, exec, wlogout -b 5 -c 0 -r 0 -m 0
EOF
fi

echo -e "${GREEN}✓ Keybinding lagt til${NC}"

echo ""
echo -e "${GREEN}=== Wlogout setup fullført! ===${NC}"
echo ""
echo -e "${YELLOW}Keybinding:${NC}"
echo "  SUPER + X  → Åpne wlogout menu"
echo ""
echo -e "${YELLOW}I wlogout menu:${NC}"
echo "  L  → Lock (hyprlock)"
echo "  E  → Logout (exit Hyprland)"
echo "  S  → Shutdown"
echo "  R  → Reboot"
echo "  U  → Suspend"
echo "  H  → Hibernate"
echo "  ESC → Cancel"
echo ""
echo -e "${YELLOW}Kommando:${NC}"
echo "  wlogout                    # Åpne menu"
echo "  wlogout -b 5 -c 0 -r 0 -m 0  # Åpne med spacing"
echo ""
echo -e "${YELLOW}Config filer:${NC}"
echo "  Layout: $WLOGOUT_DIR/layout"
echo "  Style:  $WLOGOUT_DIR/style.css"
echo ""
echo -e "${CYAN}Tips: Tilpass farger i style.css for å matche ditt theme${NC}"
