#!/bin/bash

# ============================================================
# Master Install Script - Med Minimal Sudo
# Kun SDDM trenger sudo - resten spør selv eller trenger ikke
# ============================================================

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Hyprland Complete Installation${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""

# Sjekk at vi er i riktig mappe
if [ ! -f "install-order.conf" ]; then
    echo -e "${RED}❌ FEIL: Må kjøres fra repo-roten!${NC}"
    echo "   cd ~/Arch-Linux-Hyprland-Install-Scripts"
    exit 1
fi

REPO_ROOT=$(pwd)
echo -e "${CYAN}📁 Repository: $REPO_ROOT${NC}"
echo ""

# Gjør alle scripts kjørbare først
echo -e "${YELLOW}🔧 Gjør alle scripts kjørbare...${NC}"
find . -name "*.sh" -type f -exec chmod +x {} \;
echo -e "${GREEN}✓ Alle scripts er nå kjørbare${NC}"
echo ""

# Definer installasjonsrekkefølge
INSTALL_ORDER=(
    "01-base"
    "02-post-install"
    "03-awww"
    "04-hypridle"
    "05-hyprlock"
    "06-wlogout"
    "07-power-button"
    "08-notifications"
    "09-dropdown-terminal"
    "10-overview"
    "11-fuzzel-hyprpicker"
    "12-kitty"
    "13-rofi"
    "14-screenshots"
    "15-sddm"
    "16-dunst"
    "17-waybar"
    "18-network"
    "19-make-executable"
    "20-gpu-drivers"
    "25-scripts-and-files"
)

# Kun SDDM trenger sudo
NEEDS_SUDO=(
    "15-sddm"
)

# Funksjon for å sjekke om komponent trenger sudo
needs_sudo() {
    local component=$1
    for item in "${NEEDS_SUDO[@]}"; do
        if [ "$item" = "$component" ]; then
            return 0
        fi
    done
    return 1
}

# Tell totalt
TOTAL=${#INSTALL_ORDER[@]}
INSTALLED=0
FAILED=0

echo -e "${CYAN}Installerer $TOTAL komponenter...${NC}"
echo ""
echo -e "${YELLOW}📝 Merk:${NC}"
echo "  • Kun SDDM trenger sudo (kopierer til /usr/share/)"
echo "  • Pakkeinstallasjoner (pacman) spør selv om passord"
echo "  • 20-gpu-drivers oppdager GPU automatisk (Intel iGPU / Arc)
  • 25-scripts-and-files kjører SIST (overskriver med ferdig hyprland.conf)"
echo ""

# Installer hver komponent
for component in "${INSTALL_ORDER[@]}"; do
    if [ ! -d "$component" ]; then
        echo -e "${YELLOW}⚠ Hopper over $component (mappen eksisterer ikke)${NC}"
        continue
    fi
    
    # Finn install-script
    INSTALL_SCRIPT=$(find "$component" -maxdepth 1 -name "install*.sh" -type f | head -n 1)
    
    if [ -z "$INSTALL_SCRIPT" ]; then
        echo -e "${YELLOW}⚠ Ingen install-script i $component${NC}"
        continue
    fi
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN} Installerer: $component${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    # Kjør med eller uten sudo
    if needs_sudo "$component"; then
        echo -e "${YELLOW}🔐 Krever sudo (kopierer til system-mapper)${NC}"
        if sudo bash "$INSTALL_SCRIPT"; then
            echo -e "${GREEN}✓ $component installert${NC}"
            INSTALLED=$((INSTALLED + 1))
        else
            echo -e "${RED}✗ $component feilet${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
        # Kjør uten sudo - pacman vil spørre om passord hvis nødvendig
        if bash "$INSTALL_SCRIPT"; then
            echo -e "${GREEN}✓ $component installert${NC}"
            INSTALLED=$((INSTALLED + 1))
        else
            echo -e "${RED}✗ $component feilet${NC}"
            FAILED=$((FAILED + 1))
        fi
    fi
done

# Gjør hypr scripts kjørbare
if [ -d "$HOME/.config/hypr/scripts" ]; then
    echo ""
    echo -e "${CYAN}🔧 Gjør hypr scripts kjørbare...${NC}"
    chmod +x "$HOME/.config/hypr/scripts/"* 2>/dev/null
    echo -e "${GREEN}✓ Hypr scripts er kjørbare${NC}"
fi

# Oppsummering
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Installasjon Fullført!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Totalt: $TOTAL komponenter"
echo -e "${GREEN}✓ Installert: $INSTALLED${NC}"

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Feilet: $FAILED${NC}"
else
    echo -e "${GREEN}✓ Ingen feil!${NC}"
fi

echo ""
echo -e "${YELLOW}Neste steg:${NC}"
echo "  1. Verifiser installasjon: ./check-installation.sh"
echo "  2. Reboot systemet: sudo reboot"
echo "  3. Logg inn med Hyprland fra SDDM"
echo ""
echo -e "${CYAN}📍 Alt installert i: $HOME/.config/${NC}"
echo -e "${CYAN}📍 SDDM tema: /usr/share/sddm/themes/archruud${NC}"
echo ""
