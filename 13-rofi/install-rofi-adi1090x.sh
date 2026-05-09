#!/bin/bash

################################################################################
#  ROFI INSTALLASJON - adi1090x Collection
#  Type-2 Launcher + Powermenu Type-3 Style-2 + Clipboard Manager
################################################################################

set -e

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
║              🚀  ROFI INSTALLASJON - adi1090x  🚀                  ║
║                                                                     ║
║  Launcher Type-2 · Powermenu Type-3 · Clipboard Manager           ║
║                                                                     ║
╚═══════════════════════════════════════════════════════════════════╝
EOF

echo ""

# Sjekk root
if [ "$EUID" -eq 0 ]; then 
    error "Ikke kjør som root!"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
#  1. INSTALLER PAKKER
# ═══════════════════════════════════════════════════════════════════════════

log "Installerer Rofi og nødvendige pakker..."

PACKAGES="rofi wl-clipboard cliphist git"

log "Installerer: $PACKAGES"
sudo pacman -S --needed --noconfirm $PACKAGES || {
    error "Feil under installasjon"
    exit 1
}

success "Pakker installert"

# ═══════════════════════════════════════════════════════════════════════════
#  2. CLONE ADI1090X ROFI REPO
# ═══════════════════════════════════════════════════════════════════════════

log "Cloner adi1090x/rofi repository..."

TEMP_DIR="/tmp/rofi-adi1090x"

if [ -d "$TEMP_DIR" ]; then
    log "Fjerner eksisterende temp directory"
    rm -rf "$TEMP_DIR"
fi

git clone --depth=1 https://github.com/adi1090x/rofi.git "$TEMP_DIR" || {
    error "Feil ved cloning av repo"
    exit 1
}

success "Repository clonet til $TEMP_DIR"

# ═══════════════════════════════════════════════════════════════════════════
#  3. KJØR SETUP SCRIPT
# ═══════════════════════════════════════════════════════════════════════════

log "Kjører adi1090x setup script..."

cd "$TEMP_DIR"
chmod +x setup.sh

# Kjør setup (lager automatisk backup)
./setup.sh || {
    error "Feil under setup"
    exit 1
}

success "adi1090x rofi installert"

# ═══════════════════════════════════════════════════════════════════════════
#  4. KONFIGURER TYPE-2 LAUNCHER
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer type-2 launcher som standard..."

LAUNCHER_SCRIPT="$HOME/.config/rofi/launchers/type-3/launcher.sh"

if [ -f "$LAUNCHER_SCRIPT" ]; then
    # Sett default style til style-1 (du kan endre dette senere)
    sed -i "s/theme='style-[0-9]'/theme='style-1'/" "$LAUNCHER_SCRIPT"
    chmod +x "$LAUNCHER_SCRIPT"
    success "Type-2 launcher konfigurert"
else
    warning "Launcher script ikke funnet"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  5. KONFIGURER POWERMENU TYPE-3 STYLE-2
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer powermenu type-3 style-2..."

POWERMENU_SCRIPT="$HOME/.config/rofi/powermenu/type-3/powermenu.sh"

if [ -f "$POWERMENU_SCRIPT" ]; then
    # Sett style til style-2
    sed -i "s/theme='style-[0-9]'/theme='style-2'/" "$POWERMENU_SCRIPT"
    chmod +x "$POWERMENU_SCRIPT"
    success "Powermenu type-3 style-2 konfigurert"
else
    warning "Powermenu script ikke funnet"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  6. KONFIGURER CLIPBOARD MANAGER
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer clipboard manager..."

# Lag clipboard tema
mkdir -p "$HOME/.config/rofi"

cat > "$HOME/.config/rofi/clipboard.rasi" << 'CLIPBOARD_THEME'
/*******************************************************************************
 * ROFI CLIPBOARD THEME - adi1090x style
 *******************************************************************************/

* {
    background:     #1e1e2eFF;
    background-alt: #313244FF;
    foreground:     #cdd6f4FF;
    selected:       #89b4faFF;
    active:         #a6e3a1FF;
    urgent:         #f38ba8FF;
}

window {
    transparency:   "real";
    location:       center;
    anchor:         center;
    fullscreen:     false;
    width:          600px;
    x-offset:       0px;
    y-offset:       0px;
    enabled:        true;
    margin:         0px;
    padding:        0px;
    border:         2px solid;
    border-radius:  12px;
    border-color:   @selected;
    background-color: @background;
    cursor:         "default";
}

mainbox {
    enabled:        true;
    spacing:        10px;
    margin:         0px;
    padding:        20px;
    border:         0px solid;
    border-radius:  0px;
    border-color:   @selected;
    background-color: transparent;
    children:       [ "inputbar", "message", "listview" ];
}

inputbar {
    enabled:        true;
    spacing:        10px;
    margin:         0px;
    padding:        10px;
    border:         0px solid;
    border-radius:  8px;
    border-color:   @selected;
    background-color: @background-alt;
    text-color:     @foreground;
    children:       [ "prompt", "entry" ];
}

prompt {
    enabled:        true;
    background-color: inherit;
    text-color:     inherit;
}

entry {
    enabled:        true;
    background-color: inherit;
    text-color:     inherit;
    cursor:         text;
    placeholder:    "Søk i clipboard...";
    placeholder-color: @foreground;
}

listview {
    enabled:        true;
    columns:        1;
    lines:          8;
    cycle:          true;
    dynamic:        true;
    scrollbar:      true;
    layout:         vertical;
    reverse:        false;
    fixed-height:   true;
    fixed-columns:  true;
    spacing:        5px;
    margin:         0px;
    padding:        0px;
    border:         0px solid;
    border-radius:  0px;
    border-color:   @selected;
    background-color: transparent;
    text-color:     @foreground;
    cursor:         "default";
}

scrollbar {
    handle-width:   8px;
    handle-color:   @selected;
    border-radius:  8px;
    background-color: @background-alt;
}

element {
    enabled:        true;
    spacing:        10px;
    margin:         0px;
    padding:        10px;
    border:         0px solid;
    border-radius:  8px;
    border-color:   @selected;
    background-color: transparent;
    text-color:     @foreground;
    cursor:         pointer;
}

element normal.normal {
    background-color: transparent;
    text-color:     @foreground;
}

element selected.normal {
    background-color: @selected;
    text-color:     @background;
}

element-text {
    background-color: transparent;
    text-color:     inherit;
    highlight:      inherit;
    cursor:         inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
}

message {
    enabled:        true;
    margin:         0px;
    padding:        10px;
    border:         0px solid;
    border-radius:  8px;
    border-color:   @selected;
    background-color: @background-alt;
    text-color:     @foreground;
}

textbox {
    background-color: inherit;
    text-color:     inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
    highlight:      none;
}
CLIPBOARD_THEME

success "Clipboard tema opprettet"

# ═══════════════════════════════════════════════════════════════════════════
#  7. RYDD OPP
# ═══════════════════════════════════════════════════════════════════════════

log "Rydder opp..."
cd "$HOME"
rm -rf "$TEMP_DIR"
success "Temp files fjernet"

# ═══════════════════════════════════════════════════════════════════════════
#  8. HYPRLAND KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║              ✅ ROFI INSTALLASJON FULLFØRT                         ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
success "Rofi er installert!"
echo ""
echo "📦 Installert fra adi1090x/rofi:"
echo "   • Launchers (type-1 til type-7)"
echo "   • Powermenus (type-1 til type-6)"
echo "   • Applets (volume, battery, screenshot, etc.)"
echo "   • Clipboard manager"
echo ""
echo "⚙️  Konfigurert:"
echo "   • Type-2 Launcher (style-1)"
echo "   • Powermenu Type-3 Style-2"
echo "   • Clipboard manager tema"
echo ""
echo "📁 Konfigurasjon: ~/.config/rofi/"
echo ""

# Sjekk Hyprland konfigurasjon
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

if [ -f "$HYPR_CONF" ]; then
    if grep -q "type-2/launcher.sh" "$HYPR_CONF"; then
        success "Rofi launcher allerede konfigurert i Hyprland"
    else
        warning "Rofi ikke konfigurert i Hyprland"
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "LEGG TIL DISSE LINJENE I HYPRLAND.CONF:"
        echo "═══════════════════════════════════════════════════════════════════"
        echo ""
        cat << 'HYPR_CONFIG'
# ═══════════════════════════════════════════════════════════════════════════
#  ROFI KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

# Rofi Launcher
$menu = killall rofi || $HOME/.config/rofi/launchers/type-2/launcher.sh

# Rofi Powermenu
$powermenu = $HOME/.config/rofi/powermenu/type-3/powermenu.sh

# Rofi Clipboard
bind = $mainMod, V, exec, cliphist list | rofi -dmenu -theme ~/.config/rofi/clipboard.rasi -p "Clipboard" | cliphist decode | wl-copy

# Keybinds
bind = $mainMod, A, exec, $menu
bind = $mainMod, X, exec, $powermenu

# Clipboard daemon (autostart)
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
HYPR_CONFIG
        echo ""
    fi
else
    warning "Finner ikke Hyprland konfigurasjon"
fi

echo ""
echo "⌨️  Tastatursnarveier:"
echo "   • Super + A  → Åpne Rofi launcher (type-2)"
echo "   • Super + V  → Åpne clipboard manager"
echo "   • Super + X  → Åpne powermenu (type-3 style-2)"
echo ""
echo "🎨 Endre Styles:"
echo ""
echo "   Launcher (type-2):"
echo "   Rediger: ~/.config/rofi/launchers/type-2/launcher.sh"
echo "   Endre linjen: theme='style-1'"
echo "   Tilgjengelig: style-1 til style-15"
echo ""
echo "   Powermenu (type-3):"
echo "   Rediger: ~/.config/rofi/powermenu/type-3/powermenu.sh"
echo "   Endre linjen: theme='style-2'"
echo "   Tilgjengelig: style-1 til style-5"
echo ""
echo "   Farger:"
echo "   Launcher: ~/.config/rofi/launchers/type-2/shared/colors.rasi"
echo "   Powermenu: ~/.config/rofi/powermenu/type-3/shared/colors.rasi"
echo ""
echo "🚀 Test Rofi:"
echo "   rofi -show drun"
echo "   ~/.config/rofi/launchers/type-2/launcher.sh"
echo "   ~/.config/rofi/powermenu/type-3/powermenu.sh"
echo ""
log "Husk å legge til keybinds i hyprland.conf!"
echo ""
