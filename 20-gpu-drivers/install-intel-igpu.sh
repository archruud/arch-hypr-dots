#!/bin/bash

# ============================================================
# install-intel-igpu.sh
# Intel integrert GPU — alle maskiner
# Mesa, Vulkan, VA-API for Intel iGPU
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

echo ""
echo -e "${CYAN}  Intel Integrert GPU — Drivere${NC}"
echo ""

# ── Kjernepakker ──────────────────────────────────────────────────────────────
step "Installerer Intel iGPU drivere"

IGPU_PACKAGES=(
    mesa                    # Open source OpenGL/Vulkan — selve kjernedriveren
    vulkan-intel            # Intel Vulkan driver (ANV) — kreves av Hyprland
    intel-media-driver      # VA-API hardware video decode/encode (Gen 11+)
    libva-utils             # vainfo — test VA-API
    vulkan-tools            # vulkaninfo — test Vulkan
    libva                   # VA-API bibliotek
    libvdpau                # VDPAU bibliotek
    mesa-utils              # glxinfo, glxgears
    xf86-video-intel        # Xorg Intel driver (for Xwayland-kompatibilitet)
)

info "Installerer pakker..."
sudo pacman -S --needed --noconfirm "${IGPU_PACKAGES[@]}"
log "Intel iGPU pakker installert"

# ── lib32-pakker (multilib) ───────────────────────────────────────────────────
step "lib32-pakker (32-bit støtte)"

LIB32_PACKAGES=(
    lib32-mesa
    lib32-vulkan-intel
)

info "Installerer lib32-pakker..."
if sudo pacman -S --needed --noconfirm "${LIB32_PACKAGES[@]}" 2>/dev/null; then
    log "lib32-pakker installert"
else
    warn "lib32-pakker kunne ikke installeres (multilib ikke aktivert?)"
    warn "Kjør: sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf"
fi

# ── Environment variables ─────────────────────────────────────────────────────
step "Setter Intel GPU environment variabler"

ENV_FILE="$HOME/.config/hypr/env-gpu.conf"
mkdir -p "$HOME/.config/hypr"

cat > "$ENV_FILE" << 'EOF'
# Intel GPU Environment Variables
# Inkluderes fra hyprland.conf: source = ~/.config/hypr/env-gpu.conf

# Bruk Intel VA-API driver
env = LIBVA_DRIVER_NAME,iHD

# Vulkan ICD
env = VK_ICD_FILENAMES,/usr/share/vulkan/icd.d/intel_icd.x86_64.json

# Mesa OpenGL
env = MESA_D3D12_DEFAULT_ADAPTER_NAME,Intel
EOF

log "GPU env-fil opprettet: $ENV_FILE"
info "Legg til i hyprland.conf: source = ~/.config/hypr/env-gpu.conf"

# ── Verifisering ──────────────────────────────────────────────────────────────
step "Verifiserer installasjon"

echo ""
info "VA-API status:"
vainfo 2>/dev/null | grep -E "driver|profile" | head -5 || warn "vainfo feiler — reboot kan hjelpe"

echo ""
info "Vulkan status:"
vulkaninfo --summary 2>/dev/null | grep -E "GPU|apiVersion" | head -5 || warn "vulkaninfo feiler — reboot kan hjelpe"

echo ""
log "Intel iGPU installasjon fullført!"
echo ""
