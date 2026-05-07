#!/bin/bash

# ============================================================
# 20-gpu-drivers — Hoved installasjonsfil
# Oppdager GPU automatisk og kjører riktige sub-scripts
#
# Støttede maskiner:
#   Dell Pro 16        — Intel integrert GPU
#   Lenovo (12. gen)   — Intel integrert GPU
#   Medion Erazer X10  — Intel Iris Xe + Intel Arc A730M
# ============================================================

# Farger
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

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  20-gpu-drivers — GPU Driver Installasjon${NC}"
echo -e "${CYAN}  Arch Linux Hyprland | archruud${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo ""

# ── Sjekk ikke root ───────────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
    err "Ikke kjør som root. Scriptet bruker sudo der det trengs."
    exit 1
fi

# ── Sjekk multilib ────────────────────────────────────────────────────────────
step "Sjekker multilib"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    warn "multilib er ikke aktivert i /etc/pacman.conf"
    warn "lib32-pakker krever multilib. Aktiverer nå..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    log "multilib aktivert og synkronisert"
else
    log "multilib er allerede aktivert"
fi

# ── Oppdater system ───────────────────────────────────────────────────────────
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
    echo -e "${YELLOW}Dette installerer AI/ML drivere og biblioteker.${NC}"
    echo -e "${YELLOW}Noen pakker er over 1 GB — du vil bli spurt underveis.${NC}"
    read -p "Installer Intel Arc AI-drivere? (j/n): " arc_choice
    if [[ "$arc_choice" =~ ^[jJ]$ ]]; then
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

# ── Del 3: Ollama + Open WebUI ───────────────────────────────────────────────
echo ""
read -p "Installer Ollama + Open WebUI (lokal AI)? (j/n): " ollama_choice
if [[ "$ollama_choice" =~ ^[jJ]$ ]]; then
    step "Del 3: Ollama + Open WebUI"
    bash "$SCRIPT_DIR/install-ollama.sh" "$AUR_HELPER"
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
fi
echo ""
echo -e "${CYAN}Reboot: sudo reboot${NC}"
echo ""
