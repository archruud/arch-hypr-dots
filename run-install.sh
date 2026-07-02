#!/bin/bash
# ============================================================
# Master Install Script
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Hyprland Complete Installation${NC}"
echo -e "${GREEN} github.com/archruud/arch-hypr-dots${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ ! -f "install-order.conf" ]; then
    echo -e "${RED}❌ FEIL: Må kjøres fra repo-roten!${NC}"
    echo "   cd ~/arch-hypr-dots"
    exit 1
fi

# ── Logg ─────────────────────────────────────────────────────────────────────
LOG_FILE="$(pwd)/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo -e "${CYAN}📝 Logg: $LOG_FILE${NC}"
echo ""

# ══════════════════════════════════════════════════════════════
#  VALG 1 — Installasjonsmodus
# ══════════════════════════════════════════════════════════════
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            VELG INSTALLASJONSMODUS                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}[1]${NC} AUTO        — Ja til alt, ingen spørsmål underveis"
echo -e "  ${YELLOW}[2]${NC} INTERAKTIV  — Spør meg ved hver komponent"
echo ""
read -rp "  Velg [1/2]: " modus_valg

case "$modus_valg" in
    2)
        export INSTALL_MODE="interaktiv"
        echo -e "${YELLOW}✓ Modus: INTERAKTIV — du blir spurt underveis${NC}"
        ;;
    *)
        export INSTALL_MODE="auto"
        echo -e "${GREEN}✓ Modus: AUTO — kjører uten spørsmål${NC}"
        ;;
esac
echo ""

# ══════════════════════════════════════════════════════════════
#  VALG 2 — Sudo-passord (kun én gang)
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}🔐 Skriv sudo-passord (kun én gang for hele installasjonen):${NC}"
sudo -v || { echo -e "${RED}Feil passord${NC}"; exit 1; }
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/hypr-install > /dev/null
trap 'sudo rm -f /etc/sudoers.d/hypr-install; echo "🔐 Sudo-tilgang tilbakestilt"' EXIT
echo -e "${GREEN}✓ Sudo aktivt — ingen flere passord-forespørsler${NC}"
echo ""

# ── Aktiver multilib ──────────────────────────────────────────────────────────
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "${CYAN}🔧 Aktiverer multilib...${NC}"
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    echo -e "${GREEN}✓ multilib aktivert${NC}"
fi

REPO_ROOT=$(pwd)
echo -e "${CYAN}📁 Repository: $REPO_ROOT${NC}"
echo ""

echo -e "${YELLOW}🔧 Gjør alle scripts kjørbare...${NC}"
find . -name "*.sh" -type f -exec chmod +x {} \;
echo -e "${GREEN}✓ Alle scripts er nå kjørbare${NC}"
echo ""

# ── Installasjonsrekkefølge ───────────────────────────────────────────────────
INSTALL_ORDER=(
    "01-base"
    "02-post-install"
    "03-awww"
    "04-hypridle"
    "05-hyprlock"
    "06-wlogout"
    "07-power-button"
    "08-notifications"
    # "09-dropdown-terminal"
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

NEEDS_SUDO=("15-sddm")

needs_sudo() {
    local component=$1
    for item in "${NEEDS_SUDO[@]}"; do
        [ "$item" = "$component" ] && return 0
    done
    return 1
}

TOTAL=${#INSTALL_ORDER[@]}
INSTALLED=0
FAILED=0

echo -e "${CYAN}Installerer $TOTAL komponenter  |  Modus: ${INSTALL_MODE^^}${NC}"
echo ""
echo -e "${YELLOW}📝 Merk:${NC}"
echo "  • Kun SDDM trenger sudo (kopierer til /usr/share/)"
echo "  • 20-gpu-drivers oppdager GPU automatisk (Intel iGPU / Arc)"
echo "  • 25-scripts-and-files kjører SIST (overskriver med ferdig hyprland.conf)"
echo ""

# ── Installer hver komponent ──────────────────────────────────────────────────
for component in "${INSTALL_ORDER[@]}"; do
    if [ ! -d "$component" ]; then
        echo -e "${YELLOW}⚠ Hopper over $component (mappen eksisterer ikke)${NC}"
        continue
    fi

    INSTALL_SCRIPT=$(find "$component" -maxdepth 1 -name "install*.sh" -type f | head -n 1)
    if [ -z "$INSTALL_SCRIPT" ]; then
        echo -e "${YELLOW}⚠ Ingen install-script i $component${NC}"
        continue
    fi

    # INTERAKTIV: spør om hver komponent
    if [ "$INSTALL_MODE" = "interaktiv" ]; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}  Neste: $component${NC}"
        read -rp "  Installer denne? [J/n]: " svar
        svar=${svar:-J}
        if [[ ! "$svar" =~ ^[JjYy]$ ]]; then
            echo -e "${YELLOW}  ⤵ Hoppet over $component${NC}"
            continue
        fi
    fi

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN} Installerer: $component${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"

    if needs_sudo "$component"; then
        echo -e "${YELLOW}🔐 Krever sudo${NC}"
        if sudo bash "$INSTALL_SCRIPT"; then
            echo -e "${GREEN}✓ $component installert${NC}"
            INSTALLED=$((INSTALLED + 1))
        else
            echo -e "${RED}✗ $component feilet${NC}"
            FAILED=$((FAILED + 1))
        fi
    else
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

# ── Oppsummering ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN} Installasjon Fullført!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Totalt: $TOTAL komponenter"
echo -e "${GREEN}✓ Installert: $INSTALLED${NC}"
[ $FAILED -gt 0 ] && echo -e "${RED}✗ Feilet: $FAILED${NC}" || echo -e "${GREEN}✓ Ingen feil!${NC}"
echo ""
echo -e "${YELLOW}Neste steg:${NC}"
echo "  1. Verifiser installasjon: ./check-installation.sh"
echo "  2. Reboot systemet: sudo reboot"
echo "  3. Logg inn med Hyprland fra SDDM"
echo ""
echo -e "${CYAN}📍 Alt installert i: $HOME/.config/${NC}"
echo -e "${CYAN}📍 SDDM tema: /usr/share/sddm/themes/archruud${NC}"
echo ""
