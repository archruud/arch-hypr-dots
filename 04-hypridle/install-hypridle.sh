#!/bin/bash

# Hypridle Installation & Configuration Script
# Dette scriptet setter opp hypridle for Hyprland

# Farger for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Hypridle Setup ===${NC}"

# Definer paths
HYPRIDLE_CONFIG="$HOME/.config/hypr/hypridle.conf"
HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"

# Sjekk om hypridle er installert
if ! command -v hypridle &> /dev/null; then
    echo -e "${YELLOW}Hypridle er ikke installert. Installerer...${NC}"
    if command -v yay &> /dev/null; then
        yay -S --noconfirm hypridle
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm hypridle
    else
        echo -e "${RED}Feil: Kan ikke finne yay eller paru for å installere hypridle${NC}"
        echo -e "${YELLOW}Installer manuelt: yay -S hypridle${NC}"
        exit 1
    fi
fi

# Opprett config directory hvis den ikke eksisterer
mkdir -p "$HOME/.config/hypr"

# Opprett hypridle.conf
echo -e "${GREEN}Oppretter hypridle konfigurasjon...${NC}"
cat > "$HYPRIDLE_CONFIG" << 'EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock       # Kjør hyprlock hvis den ikke kjører allerede
    before_sleep_cmd = loginctl lock-session    # Lås før suspend
    after_sleep_cmd = hyprctl dispatch dpms on  # Skru på skjerm etter suspend
    ignore_dbus_inhibit = false                 # Ignorer om program blokkerer idle
}

# Listener for å dimme skjerm etter 5 minutter
listener {
    timeout = 300                               # 5 minutter
    on-timeout = brightnessctl -s set 10%       # Dimme til 10%
    on-resume = brightnessctl -r                # Gjenopprett lysstyrke
}

# Listener for å skru av skjerm etter 10 minutter
listener {
    timeout = 600                               # 10 minutter
    on-timeout = hyprctl dispatch dpms off      # Skru av skjerm
    on-resume = hyprctl dispatch dpms on        # Skru på skjerm
}

# Listener for å låse skjerm etter 15 minutter
listener {
    timeout = 900                               # 15 minutter
    on-timeout = loginctl lock-session          # Lås session
}

# Listener for suspend etter 30 minutter
listener {
    timeout = 1800                              # 30 minutter
    on-timeout = systemctl suspend              # Suspend system
}
EOF

echo -e "${GREEN}Hypridle konfigurasjon opprettet: $HYPRIDLE_CONFIG${NC}"

# Sjekk om hypridle allerede er i hyprland.conf
if grep -q "exec-once.*hypridle" "$HYPRLAND_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}Hypridle er allerede aktivert i hyprland.conf${NC}"
else
    # Legg til exec-once for hypridle i hyprland.conf
    echo -e "${GREEN}Legger til hypridle i hyprland.conf...${NC}"
    
    # Sjekk om filen eksisterer
    if [ ! -f "$HYPRLAND_CONFIG" ]; then
        echo -e "${RED}Feil: Kan ikke finne $HYPRLAND_CONFIG${NC}"
        exit 1
    fi
    
    # Legg til exec-once i starten av filen (etter eventuelle kommentarer)
    sed -i '/^[^#]/i exec-once = hypridle' "$HYPRLAND_CONFIG"
    
    echo -e "${GREEN}Hypridle aktivert i hyprland.conf${NC}"
fi

# Sjekk om hyprlock er installert (trengs for locking)
if ! command -v hyprlock &> /dev/null; then
    echo -e "${YELLOW}Hyprlock er ikke installert (anbefales for locking)${NC}"
    echo -e "${YELLOW}Installere hyprlock? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if command -v yay &> /dev/null; then
            yay -S --noconfirm hyprlock
        elif command -v paru &> /dev/null; then
            paru -S --noconfirm hyprlock
        fi
    fi
fi

# Sjekk om brightnessctl er installert (trengs for dimming)
if ! command -v brightnessctl &> /dev/null; then
    echo -e "${YELLOW}Brightnessctl er ikke installert (trengs for auto-dimming)${NC}"
    echo -e "${YELLOW}Installere brightnessctl? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo pacman -S --noconfirm brightnessctl
    fi
fi

echo -e "${GREEN}=== Hypridle setup fullført! ===${NC}"
echo -e "${YELLOW}Tips:${NC}"
echo "  - Hypridle vil starte automatisk ved neste Hyprland oppstart"
echo "  - Skjerm dimmes etter 5 min, skrus av etter 10 min"
echo "  - System låses etter 15 min og suspends etter 30 min"
echo "  - For å starte nå: hypridle &"
echo "  - For å stoppe: pkill hypridle"
echo "  - Rediger timings: $HYPRIDLE_CONFIG"
echo ""
echo -e "${YELLOW}Timeouts:${NC}"
echo "  300s  (5 min)  - Dimme skjerm til 10%"
echo "  600s  (10 min) - Skru av skjerm"
echo "  900s  (15 min) - Lås skjerm"
echo "  1800s (30 min) - Suspend system"
