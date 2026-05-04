#!/bin/bash

# ============================================================
# Installasjon Verifisering Script
# Sjekker at alt er installert riktig
# ============================================================

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Hyprland Installasjon Verifisering${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""

# Tellere
PASSED=0
FAILED=0
WARNINGS=0

# Funksjon for å sjekke fil/mappe
check_exists() {
    local path=$1
    local name=$2
    
    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $name ${RED}(mangler)${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Funksjon for å sjekke kommando
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} $name ${RED}(ikke installert)${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Funksjon for å sjekke systemd service
check_service() {
    local service=$1
    local name=$2
    
    if systemctl is-enabled "$service" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name ${GREEN}(enabled)${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name ${YELLOW}(ikke enabled)${NC}"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 1. Hyprland Core${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "Hyprland" "Hyprland binary"
check_exists "$HOME/.config/hypr/hyprland.conf" "hyprland.conf"
check_exists "$HOME/.config/hypr/scripts" "Scripts mappe"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 2. Display Manager (SDDM)${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "sddm" "SDDM binary"
check_exists "/usr/share/sddm/themes/archruud" "SDDM tema"
check_exists "/etc/sddm.conf.d/theme.conf" "SDDM config"
check_service "sddm.service" "SDDM service"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 3. Waybar${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "waybar" "Waybar binary"
check_exists "$HOME/.config/waybar" "Waybar config mappe"
check_exists "$HOME/.config/waybar/style.css" "Waybar style.css"

# Sjekk for enten config eller config.jsonc (kun én trengs)
if [ -f "$HOME/.config/waybar/config" ] || [ -f "$HOME/.config/waybar/config.jsonc" ]; then
    echo -e "${GREEN}✓${NC} Waybar config"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} Waybar config ${RED}(mangler både config og config.jsonc)${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 4. Rofi${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "rofi" "Rofi binary"
check_exists "$HOME/.config/rofi" "Rofi config"
check_exists "$HOME/.config/rofi/launchers/type-2" "Rofi launcher"
check_exists "$HOME/.config/rofi/powermenu/type-3" "Rofi powermenu"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 5. Notifications${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "dunst" "Dunst binary"
check_exists "$HOME/.config/dunst/dunstrc" "Dunst config"
check_command "mako" "Mako binary"
check_exists "$HOME/.config/mako/config" "Mako config"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 6. Terminal & Shell${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "kitty" "Kitty binary"
check_exists "$HOME/.config/kitty/kitty.conf" "Kitty config"
check_exists "$HOME/.bashrc" ".bashrc"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 7. Utilities${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "hyprlock" "Hyprlock"
check_exists "$HOME/.config/hypr/hyprlock.conf" "Hyprlock config"
check_command "hypridle" "Hypridle"
check_exists "$HOME/.config/hypr/hypridle.conf" "Hypridle config"
check_command "wlogout" "Wlogout"
check_exists "$HOME/.config/wlogout" "Wlogout config"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 8. Screenshot Tools${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "grim" "Grim"
check_command "slurp" "Slurp"
check_command "swappy" "Swappy"
check_exists "$HOME/.config/swappy/config" "Swappy config"
check_exists "$HOME/Bilder/Screenshots" "Screenshots mappe"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 9. Wallpaper & Theming${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "swww" "SWWW"
check_exists "$HOME/.config/hypr/swww-wallpaper.sh" "SWWW script"
check_exists "$HOME/.config/hypr/wallpapers" "Wallpapers mappe"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 10. Network Tools${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "nmgui" "nmgui (WiFi)"
check_command "blueman-manager" "Blueman (Bluetooth)"
check_service "NetworkManager.service" "NetworkManager"
check_service "bluetooth.service" "Bluetooth"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 11. Quickshell Overview${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "qs" "Quickshell binary"
check_exists "$HOME/.config/quickshell/overview" "Quickshell overview"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 12. Fuzzel Hyprpicker${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "fuzzel" "Fuzzel"
check_command "hyprpicker" "Hyprpicker"
check_exists "$HOME/.config/hypr/scripts/fuzzel-hyprpicker.sh" "Fuzzel-hyprpicker script"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 13. File Manager${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
check_command "dolphin" "Dolphin"
check_command "filezilla" "FileZilla"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} 14. Scripts Executable${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"

SCRIPT_COUNT=0
EXECUTABLE_COUNT=0

if [ -d "$HOME/.config/hypr/scripts" ]; then
    for script in "$HOME/.config/hypr/scripts"/*.sh; do
        if [ -f "$script" ]; then
            SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
            if [ -x "$script" ]; then
                EXECUTABLE_COUNT=$((EXECUTABLE_COUNT + 1))
            fi
        fi
    done
    
    if [ $SCRIPT_COUNT -eq $EXECUTABLE_COUNT ]; then
        echo -e "${GREEN}✓${NC} Alle $SCRIPT_COUNT scripts er kjørbare"
        PASSED=$((PASSED + 1))
    else
        echo -e "${YELLOW}⚠${NC} $EXECUTABLE_COUNT av $SCRIPT_COUNT scripts er kjørbare"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} Scripts mappe finnes ikke"
    FAILED=$((FAILED + 1))
fi

# Oppsummering
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Oppsummering${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✓ Passed:    $PASSED${NC}"

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Warnings:  $WARNINGS${NC}"
fi

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Failed:    $FAILED${NC}"
fi

echo ""

# Konklusjon
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN} ✓ Installasjonen ser bra ut!${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Neste steg:"
    echo "  1. Reboot systemet: sudo reboot"
    echo "  2. Logg inn med Hyprland fra SDDM"
    echo "  3. Test at alt fungerer!"
    echo ""
    exit 0
else
    echo -e "${RED}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED} ⚠ Noen komponenter mangler!${NC}"
    echo -e "${RED}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Sjekk feilene over og kjør installer på nytt hvis nødvendig."
    echo ""
    exit 1
fi
