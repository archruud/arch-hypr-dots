#!/bin/bash

################################################################################
#  WAYBAR INSTALLASJON - Archruud's Setup
#  Komplett automatisk installasjon med nmgui, blueman og pavucontrol
################################################################################

set -e

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[ADVARSEL]${NC} $1"; }

# Banner
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                     ║
║              📊  WAYBAR INSTALLASJON  📊                           ║
║                                                                     ║
║  Status Bar · nmgui · Bluetooth · Audio Control                   ║
║                                                                     ║
╚═══════════════════════════════════════════════════════════════════╝
EOF

echo ""

# Sjekk root
if [ "$EUID" -eq 0 ]; then 
    error "Ikke kjør som root!"
    exit 1
fi

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ═══════════════════════════════════════════════════════════════════════════
#  1. INSTALLER PAKKER
# ═══════════════════════════════════════════════════════════════════════════

log "Installerer Waybar og nødvendige pakker..."

# Official repos pakker
PACKAGES="waybar blueman pavucontrol"

log "Installerer fra official repos: $PACKAGES"
sudo pacman -S --needed --noconfirm $PACKAGES || {
    error "Feil under installasjon"
    exit 1
}

success "Official pakker installert"

# Installer nmgui-bin fra AUR
log "Installerer nmgui-bin fra AUR..."

# Sjekk om yay eller paru er installert
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    error "Ingen AUR helper funnet (yay eller paru)"
    error "Installer yay med: sudo pacman -S --needed base-devel git && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    exit 1
fi

log "Bruker AUR helper: $AUR_HELPER"

# Sjekk om nmgui-bin allerede er installert
if pacman -Qi nmgui-bin &> /dev/null; then
    success "nmgui-bin er allerede installert"
else
    log "Installerer nmgui-bin (pre-kompilert binær)..."
    $AUR_HELPER -S nmgui-bin --noconfirm || {
        error "Feil under installasjon av nmgui-bin"
        error "Prøv manuelt: yay -S nmgui-bin"
        exit 1
    }
    success "nmgui-bin installert"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  2. BACKUP OG KOPIER KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

log "Kopierer Waybar konfigurasjon..."

# Backup hvis finnes
if [ -d "$HOME/.config/waybar" ]; then
    BACKUP_DIR="$HOME/.config/waybar.backup.$(date +%Y%m%d_%H%M%S)"
    warning "Eksisterende konfigurasjon funnet"
    log "Lager backup: $BACKUP_DIR"
    mv "$HOME/.config/waybar" "$BACKUP_DIR"
    success "Backup lagret"
fi

# Sjekk om waybar-clean mappen finnes
if [ -d "$SCRIPT_DIR/waybar-clean" ]; then
    log "Kopierer waybar-clean fra $SCRIPT_DIR/waybar-clean"
    cp -r "$SCRIPT_DIR/waybar-clean" "$HOME/.config/waybar"
    success "Waybar konfigurasjon kopiert"
elif [ -d "$SCRIPT_DIR/waybar" ]; then
    log "Kopierer waybar fra $SCRIPT_DIR/waybar"
    cp -r "$SCRIPT_DIR/waybar" "$HOME/.config/waybar"
    success "Waybar konfigurasjon kopiert"
else
    error "Finner ikke waybar mappen!"
    error "Leter etter: $SCRIPT_DIR/waybar-clean eller $SCRIPT_DIR/waybar"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
#  3. LEGG TIL HYPRLAND KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer Hyprland..."

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

if [ ! -f "$HYPR_CONF" ]; then
    error "Finner ikke Hyprland konfigurasjon: $HYPR_CONF"
    exit 1
fi

# Sjekk om waybar autostart allerede finnes
if ! grep -q "exec-once = waybar" "$HYPR_CONF"; then
    log "Legger til waybar autostart..."
    echo "" >> "$HYPR_CONF"
    echo "# Waybar autostart" >> "$HYPR_CONF"
    echo "exec-once = waybar" >> "$HYPR_CONF"
    success "Waybar autostart lagt til"
else
    success "Waybar autostart allerede konfigurert"
fi

# Sjekk om waybar reload bind finnes
if ! grep -q "pkill -SIGUSR2 waybar" "$HYPR_CONF"; then
    log "Legger til waybar reload bind..."
    echo "" >> "$HYPR_CONF"
    echo "# Waybar reload" >> "$HYPR_CONF"
    echo "bind = \$mainMod, R, exec, pkill -SIGUSR2 waybar 2>/dev/null || (pkill waybar; nohup waybar &)" >> "$HYPR_CONF"
    success "Waybar reload bind lagt til"
else
    success "Waybar reload bind allerede konfigurert"
fi

# Sjekk om window rules finnes
if ! grep -q "FLOATING WINDOWS FOR WAYBAR MODULES" "$HYPR_CONF"; then
    log "Legger til window rules for waybar moduler..."
    cat >> "$HYPR_CONF" << 'WINDOW_RULES'

# ═══════════════════════════════════════════════════════════════════════════
#  FLOATING WINDOWS FOR WAYBAR MODULES
# ═══════════════════════════════════════════════════════════════════════════
#  Automatisk floating for WiFi, Bluetooth og Lydkontroll fra Waybar
#  Basert på eksakte window classes fra hyprctl clients

# WiFi/Network Manager - nmgui (com.network.manager)
windowrule = match:class ^(com\.network\.manager)$, float on
windowrule = match:class ^(com\.network\.manager)$, size 450 600
windowrule = match:class ^(com\.network\.manager)$, center on
windowrule = match:class ^(com\.network\.manager)$, animation slide

# Bluetooth Manager (blueman-manager)
windowrule = match:class ^(blueman-manager)$, float on
windowrule = match:class ^(blueman-manager)$, size 600 700
windowrule = match:class ^(blueman-manager)$, center on
windowrule = match:class ^(blueman-manager)$, animation slide

# Lyd & Mikrofon Kontroll (org.pulseaudio.pavucontrol)
windowrule = match:class ^(org\.pulseaudio\.pavucontrol)$, float on
windowrule = match:class ^(org\.pulseaudio\.pavucontrol)$, size 800 900
windowrule = match:class ^(org\.pulseaudio\.pavucontrol)$, center on
windowrule = match:class ^(org\.pulseaudio\.pavucontrol)$, animation slide
WINDOW_RULES
    success "Window rules lagt til"
else
    success "Window rules allerede konfigurert"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  4. START WAYBAR
# ═══════════════════════════════════════════════════════════════════════════

log "Starter Waybar..."

# Drep eksisterende waybar prosesser
pkill waybar 2>/dev/null || true

# Start waybar i bakgrunnen
nohup waybar > /dev/null 2>&1 &

sleep 1

# Sjekk om waybar kjører
if pgrep -x waybar > /dev/null; then
    success "Waybar kjører nå!"
else
    warning "Waybar startet ikke automatisk"
    log "Start manuelt med: waybar &"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  5. OPPSUMMERING
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ WAYBAR INSTALLASJON FULLFØRT                       ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
success "Waybar er installert og kjører!"
echo ""
echo "📦 Installerte pakker:"
echo "   • waybar"
echo "   • nmgui-bin (WiFi fra AUR - pre-kompilert binær)"
echo "   • blueman (Bluetooth)"
echo "   • pavucontrol (Audio)"
echo ""
echo "⚙️  Hyprland konfigurasjon oppdatert:"
echo "   • exec-once = waybar"
echo "   • Super + R = reload waybar"
echo "   • Window rules for floating moduler"
echo ""
echo "📁 Konfigurasjon: ~/.config/waybar/"
echo ""
echo "⌨️  Waybar moduler (samme design for alle):"
echo "   • Klikk på WiFi ikon → nmgui"
echo "   • Klikk på Bluetooth ikon → blueman-manager"
echo "   • Klikk på Audio ikon → pavucontrol"
echo ""
echo "🎨 Alle tre åpner som floating windows med samme design!"
echo ""
echo "🔄 Kontroller Waybar:"
echo "   • Super + R  → Reload waybar"
echo "   • pkill waybar && waybar &  → Restart waybar"
echo ""
log "Waybar vil starte automatisk ved neste Hyprland oppstart!"
echo ""
