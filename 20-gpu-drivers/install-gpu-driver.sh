#!/bin/bash

# ============================================================
# 20-gpu-drivers — Hoved installasjonsfil
# Oppdager GPU automatisk og kjører riktige sub-scripts
#
# Støttede maskiner:
#   Dell Pro 16        — Intel integrert GPU
#   Lenovo (12. gen)   — Intel integrert GPU
#   Medion Erazer X10  — Intel Iris Xe + Intel Arc A730M
#
# Respekterer INSTALL_MODE=auto|interaktiv fra run-install.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_MODE="${INSTALL_MODE:-auto}"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  20-gpu-drivers — GPU Driver Installasjon${NC}"
echo -e "${CYAN}  Modus: ${INSTALL_MODE^^}${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo ""

# Hjelpefunksjon: spør kun i interaktiv modus
spor() {
    local sporsmal="$1"
    if [ "$INSTALL_MODE" = "interaktiv" ]; then
        read -rp "  $sporsmal [J/n]: " svar
        svar=${svar:-J}
        [[ "$svar" =~ ^[JjYy]$ ]]
    else
        return 0  # AUTO: alltid ja
    fi
}

# ── Sjekk ikke root ───────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    err "Ikke kjør som root. Scriptet bruker sudo der det trengs."
    exit 1
fi

# ── Sjekk multilib ────────────────────────────────────────────────────────────
step "Sjekker multilib"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    warn "multilib ikke aktivert — aktiverer nå..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    log "multilib aktivert"
else
    log "multilib allerede aktivert"
fi

# ── Oppdater pakkebase ────────────────────────────────────────────────────────
step "Oppdaterer pakkebase"
sudo pacman -Sy --noconfirm
log "Pakkebase oppdatert"

# ── Sjekk AUR-helper ──────────────────────────────────────────────────────────
step "Sjekker AUR-helper"
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    log "Bruker: yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    log "Bruker: paru"
else
    err "Ingen AUR-helper funnet (yay eller paru). Installer en og prøv igjen."
    exit 1
fi

# ── Oppdager GPUer ────────────────────────────────────────────────────────────
step "Oppdager GPU(er)"
GPU_LIST=$(lspci | grep -iE "VGA|Display|3D")
echo "$GPU_LIST"
echo ""

HAS_INTEL_IGPU=false
HAS_ARC=false

if echo "$GPU_LIST" | grep -qi "Intel"; then
    HAS_INTEL_IGPU=true
    log "Intel integrert GPU funnet"
fi

if echo "$GPU_LIST" | grep -qi "Arc\|DG2\|A730\|A770\|A580\|A380"; then
    HAS_ARC=true
    log "Intel Arc diskret GPU funnet!"
fi

# ── Del 1: Intel iGPU (alle maskiner) ────────────────────────────────────────
if $HAS_INTEL_IGPU; then
    step "Del 1: Intel integrert GPU"
    bash "$SCRIPT_DIR/install-intel-igpu.sh"
    if [[ $? -ne 0 ]]; then
        err "Intel iGPU installasjon feilet"
        exit 1
    fi
fi

# ── Del 2: Intel Arc A730M (kun Medion) ──────────────────────────────────────
if $HAS_ARC; then
    echo ""
    echo -e "${YELLOW}Intel Arc diskret GPU oppdaget!${NC}"
    echo -e "${YELLOW}Dette installerer AI/ML drivere og biblioteker (stor nedlasting).${NC}"

    if spor "Installer Intel Arc AI-drivere?"; then
        step "Del 2: Intel Arc A730M AI-drivere"
        bash "$SCRIPT_DIR/install-intel-arc.sh" "$AUR_HELPER"
        if [[ $? -ne 0 ]]; then
            err "Intel Arc installasjon feilet"
            exit 1
        fi
    else
        info "Hopper over Intel Arc AI-drivere"
    fi
fi

# ── Del 3: Ollama + Open WebUI (KUN på Arc-maskin) ───────────────────────────
if $HAS_ARC; then
    echo ""
    echo -e "${YELLOW}Ollama + Open WebUI — Lokal AI (~21 GB nedlasting)${NC}"

    if spor "Installer Ollama + Open WebUI med alle AI-modeller?"; then
        step "Del 3: Ollama + Open WebUI"
        bash "$SCRIPT_DIR/install-ollama.sh" "$AUR_HELPER"
    else
        info "Hopper over Ollama — kan installeres manuelt: bash 20-gpu-drivers/install-ollama.sh"
    fi
else
    info "Ingen Arc GPU — Ollama installeres ikke (kun relevant for Medion Erazer X10)"
fi

# ── Ferdig ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  GPU Driver Installasjon Fullført!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Viktig:${NC}"
echo "  • Reboot anbefales for at alle drivere skal aktiveres"
if $HAS_ARC; then
    echo "  • Arc GPU: kjør 'xpu-smi' for å se GPU-status"
    echo "  • AI venv: source ~/.venvs/intel-ai/bin/activate"
    echo "  • Open WebUI: http://localhost:3000"
fi
echo ""
echo -e "${CYAN}Reboot: sudo reboot${NC}"
echo ""
