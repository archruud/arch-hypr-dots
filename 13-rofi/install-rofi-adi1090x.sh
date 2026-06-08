#!/bin/bash

################################################################################
#  ROFI INSTALLASJON - adi1090x Collection
#  Archruud Custom - Type-3 Launcher + style-11 (navy #000A22 + transparency)
#  Powermenu Type-3 Style-2 + Clipboard Manager
#
#  GitHub: https://github.com/archruud/arch-hypr-dots
################################################################################

set -e

# Farger
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()     { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
warning() { echo -e "${YELLOW}[ADVARSEL]${NC} $1"; }

# Banner
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║           🚀  ROFI INSTALLASJON - Archruud Custom  🚀                ║
║                                                                       ║
║   Launcher Type-3 · Style-11 (navy) · Powermenu · Clipboard         ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
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
sudo pacman -S --needed --noconfirm rofi wl-clipboard cliphist git || {
    error "Feil under installasjon av pakker"
    exit 1
}
success "Pakker installert"

# ═══════════════════════════════════════════════════════════════════════════
#  2. CLONE ADI1090X ROFI REPO
# ═══════════════════════════════════════════════════════════════════════════

log "Cloner adi1090x/rofi repository..."
TEMP_DIR="/tmp/rofi-adi1090x"
[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

git clone --depth=1 https://github.com/adi1090x/rofi.git "$TEMP_DIR" || {
    error "Feil ved cloning av repo"
    exit 1
}
success "Repository clonet"

# ═══════════════════════════════════════════════════════════════════════════
#  3. KJØR SETUP SCRIPT
# ═══════════════════════════════════════════════════════════════════════════

log "Kjører adi1090x setup script..."
cd "$TEMP_DIR"
chmod +x setup.sh
./setup.sh || {
    error "Feil under setup"
    exit 1
}
success "adi1090x rofi installert"

# ═══════════════════════════════════════════════════════════════════════════
#  4. INSTALLER ARCHRUUD CUSTOM STYLE-11
#     Navy #000A22 med transparency - ikke endre originalfiler!
# ═══════════════════════════════════════════════════════════════════════════

log "Installerer Archruud custom style-11 (navy #000A22 + transparency)..."

LAUNCHER_DIR="$HOME/.config/rofi/launchers/type-3"

cat > "$LAUNCHER_DIR/style-11.rasi" << 'STYLE11'
/**
 *
 * Author : Aditya Shakya (adi1090x)
 * Github : @adi1090x
 *
 * Modified by : Archruud (Terje Ruud)
 * Github : @archruud
 *
 * Rofi Theme File - style-11 (Archruud custom)
 * Navy #000A22 bakgrunn med transparency — fullscreen grid launcher
 * Rofi Version: 1.7.3+
 *
 * Transparency tips (endre archruud-bg alpha):
 *   ff=100%  ee=93%  dd=87%  cc=80%  bb=73%  88=53%  55=33%
 **/

/*****----- Configuration -----*****/
configuration {
    modi:                       "drun";
    show-icons:                 true;
    display-drun:               "";
    drun-display-format:        "{name}";
    icon-theme:                 "Papirus-Dark";
}

/*****----- Global Properties -----*****/
@import                          "shared/colors.rasi"
@import                          "shared/fonts.rasi"

* {
    archruud-bg:      #000A22ee;
    archruud-overlay: #1E90FF18;
    archruud-accent:  #1E90FF;
    archruud-border:  #1E90FF44;
}

/*****----- Main Window -----*****/
window {
    transparency:                "real";
    location:                    center;
    anchor:                      center;
    fullscreen:                  true;
    width:                       100%;
    height:                      100%;
    x-offset:                    0px;
    y-offset:                    0px;

    enabled:                     true;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px;
    background-color:            @archruud-bg;
    cursor:                      "default";
}

/*****----- Main Box -----*****/
mainbox {
    enabled:                     true;
    orientation:                 vertical;
    spacing:                     50px;
    margin:                      0px;
    padding:                     100px 20%;
    border:                      0px solid;
    background-color:            transparent;
    children:                    [ "inputbar", "listview" ];
}

/*****----- Inputbar -----*****/
inputbar {
    enabled:                     true;
    spacing:                     12px;
    margin:                      0px 10%;
    padding:                     16px 24px;
    border:                      1px solid;
    border-radius:               14px;
    border-color:                @archruud-accent;
    background-color:            @archruud-overlay;
    text-color:                  @foreground;
    children:                    [ "prompt", "entry" ];
}

prompt {
    enabled:                     true;
    background-color:            transparent;
    text-color:                  @archruud-accent;
}
textbox-prompt-colon {
    enabled:                     true;
    expand:                      false;
    str:                         "";
    background-color:            transparent;
    text-color:                  @archruud-accent;
}
entry {
    enabled:                     true;
    background-color:            transparent;
    text-color:                  @foreground;
    cursor:                      text;
    placeholder:                 "Søk etter app...";
    placeholder-color:           #ffffff44;
}

/*****----- Listview -----*****/
listview {
    enabled:                     true;
    columns:                     8;
    lines:                       4;
    cycle:                       true;
    dynamic:                     true;
    scrollbar:                   false;
    layout:                      vertical;
    reverse:                     false;
    fixed-height:                true;
    fixed-columns:               true;
    spacing:                     0px;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    background-color:            transparent;
    text-color:                  @foreground;
    cursor:                      "default";
}
scrollbar {
    handle-width:                5px;
    handle-color:                @archruud-accent;
    border-radius:               3px;
    background-color:            @archruud-overlay;
}

/*****----- Elements -----*****/
element {
    enabled:                     true;
    spacing:                     10px;
    margin:                      4px;
    padding:                     28px 8px;
    border:                      1px solid;
    border-radius:               14px;
    border-color:                transparent;
    background-color:            transparent;
    text-color:                  @foreground;
    orientation:                 vertical;
    cursor:                      pointer;
}
element normal.normal {
    background-color:            transparent;
    border-color:                transparent;
    text-color:                  @foreground;
}
element normal.urgent {
    background-color:            transparent;
    text-color:                  @urgent;
}
element normal.active {
    background-color:            transparent;
    text-color:                  @active;
}
element selected.normal {
    background-color:            @archruud-overlay;
    border-color:                @archruud-accent;
    text-color:                  @foreground;
}
element selected.urgent {
    background-color:            @urgent;
    text-color:                  @foreground;
}
element selected.active {
    background-color:            @active;
    text-color:                  @foreground;
}
element-icon {
    background-color:            transparent;
    text-color:                  inherit;
    size:                        72px;
    cursor:                      inherit;
}
element-text {
    background-color:            transparent;
    text-color:                  inherit;
    highlight:                   inherit;
    cursor:                      inherit;
    vertical-align:              0.5;
    horizontal-align:            0.5;
}

/*****----- Message -----*****/
error-message {
    padding:                     100px;
    border:                      1px solid;
    border-radius:               14px;
    border-color:                @archruud-accent;
    background-color:            @archruud-bg;
    text-color:                  @foreground;
}
textbox {
    background-color:            transparent;
    text-color:                  @foreground;
    vertical-align:              0.5;
    horizontal-align:            0.0;
    highlight:                   none;
}
STYLE11

success "style-11.rasi installert i $LAUNCHER_DIR"

# ═══════════════════════════════════════════════════════════════════════════
#  5. OPPDATER LAUNCHER.SH TIL STYLE-11
# ═══════════════════════════════════════════════════════════════════════════

log "Oppdaterer launcher.sh til style-11..."

cat > "$LAUNCHER_DIR/launcher.sh" << 'LAUNCHER'
#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
##
## Modified : Archruud (Terje Ruud)
## Github   : @archruud
##
## Rofi Launcher - Type-3
##
## Styles:
## style-1  style-2  style-3  style-4  style-5
## style-6  style-7  style-8  style-9  style-10
## style-11 (Archruud custom - navy #000A22 + transparency)

dir="$HOME/.config/rofi/launchers/type-3"
theme='style-11'

## Kill eksisterende rofi-instanser og start ny
pkill -x rofi 2>/dev/null; sleep 0.1

rofi \
    -show drun \
    -theme "${dir}/${theme}.rasi"
LAUNCHER

# Sett execute-bit på ALLE .sh filer under rofi-config (unngår "Ikke tilgang")
find "$HOME/.config/rofi" -name "*.sh" -exec chmod +x {} \;
success "chmod +x på alle rofi scripts ✓"

# Dobbeltsjekk at theme faktisk er style-11 (forsikring mot fremtidige feil)
if ! grep -q "theme='style-11'" "$LAUNCHER_DIR/launcher.sh"; then
    warning "theme var ikke style-11 — tvinger riktig verdi..."
    sed -i "s/theme='style-[0-9][0-9]*'/theme='style-11'/" "$LAUNCHER_DIR/launcher.sh"
fi
success "launcher.sh oppdatert → theme='style-11' ✓"

# ═══════════════════════════════════════════════════════════════════════════
#  6. KONFIGURER POWERMENU TYPE-3 STYLE-2
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer powermenu type-3 style-2..."
POWERMENU_SCRIPT="$HOME/.config/rofi/powermenu/type-3/powermenu.sh"

if [ -f "$POWERMENU_SCRIPT" ]; then
    sed -i "s/theme='style-[0-9][0-9]*'/theme='style-2'/" "$POWERMENU_SCRIPT"
    chmod +x "$POWERMENU_SCRIPT"
    success "Powermenu type-3 style-2 konfigurert"
else
    warning "Powermenu script ikke funnet på $POWERMENU_SCRIPT"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  7. KONFIGURER CLIPBOARD MANAGER
# ═══════════════════════════════════════════════════════════════════════════

log "Konfigurerer clipboard manager..."

cat > "$HOME/.config/rofi/clipboard.rasi" << 'CLIPBOARD_THEME'
/*******************************************************************************
 * ROFI CLIPBOARD THEME - Archruud style (matcher style-11)
 *******************************************************************************/

* {
    archruud-bg:      #000A22ee;
    archruud-overlay: #000A2299;
    archruud-accent:  #1E90FF;
    foreground:       #cdd6f4FF;
    background-alt:   #0d1b3bFF;
    urgent:           #f38ba8FF;
    active:           #a6e3a1FF;
}

window {
    transparency:     "real";
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            650px;
    x-offset:         0px;
    y-offset:         0px;
    enabled:          true;
    margin:           0px;
    padding:          0px;
    border:           1px solid;
    border-radius:    14px;
    border-color:     @archruud-accent;
    background-color: @archruud-bg;
    cursor:           "default";
}

mainbox {
    enabled:          true;
    spacing:          10px;
    margin:           0px;
    padding:          20px;
    background-color: transparent;
    children:         [ "inputbar", "listview" ];
}

inputbar {
    enabled:          true;
    spacing:          10px;
    margin:           0px;
    padding:          12px 16px;
    border:           1px solid;
    border-radius:    10px;
    border-color:     @archruud-accent;
    background-color: @archruud-overlay;
    text-color:       @foreground;
    children:         [ "prompt", "entry" ];
}

prompt {
    enabled:          true;
    background-color: transparent;
    text-color:       @archruud-accent;
}

entry {
    enabled:          true;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           text;
    placeholder:      "Søk i clipboard...";
    placeholder-color: #ffffff55;
}

listview {
    enabled:          true;
    columns:          1;
    lines:            8;
    cycle:            true;
    dynamic:          true;
    scrollbar:        true;
    layout:           vertical;
    spacing:          5px;
    padding:          5px 0px;
    background-color: transparent;
    text-color:       @foreground;
}

scrollbar {
    handle-width:     6px;
    handle-color:     @archruud-accent;
    border-radius:    3px;
    background-color: @archruud-overlay;
}

element {
    enabled:          true;
    spacing:          10px;
    margin:           0px;
    padding:          10px 12px;
    border-radius:    8px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:           pointer;
}

element normal.normal {
    background-color: transparent;
    text-color:       @foreground;
}

element selected.normal {
    background-color: @archruud-overlay;
    border:           1px solid;
    border-color:     @archruud-accent;
    text-color:       @foreground;
}

element-text {
    background-color: transparent;
    text-color:       inherit;
    vertical-align:   0.5;
    horizontal-align: 0.0;
}
CLIPBOARD_THEME

success "Clipboard tema opprettet (matcher style-11)"

# ═══════════════════════════════════════════════════════════════════════════
#  8. RYDD OPP
# ═══════════════════════════════════════════════════════════════════════════

log "Rydder opp temp filer..."
cd "$HOME"
rm -rf "$TEMP_DIR"
success "Ferdig"

# ═══════════════════════════════════════════════════════════════════════════
#  9. OPPDATER HYPRLAND KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║              ✅ ROFI INSTALLASJON FULLFØRT                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
HYPR_KEYBINDS="$HOME/.config/hypr/keybinds.conf"

# Sjekk om rofi allerede er konfigurert
HYPR_TARGET=""
if [ -f "$HYPR_KEYBINDS" ]; then
    HYPR_TARGET="$HYPR_KEYBINDS"
elif [ -f "$HYPR_CONF" ]; then
    HYPR_TARGET="$HYPR_CONF"
fi

ROFI_LAUNCHER="$HOME/.config/rofi/launchers/type-3/launcher.sh"
ROFI_POWERMENU="$HOME/.config/rofi/powermenu/type-3/powermenu.sh"

if [ -n "$HYPR_TARGET" ] && grep -q "rofi" "$HYPR_TARGET" 2>/dev/null; then
    success "Rofi allerede konfigurert i Hyprland ($HYPR_TARGET)"
    log "Sjekker om launcher-sti peker riktig..."

    # Fiks vanlig feil: feil type i launcher-sti
    if grep -q "type-2/launcher.sh" "$HYPR_TARGET"; then
        warning "Oppdaterer type-2 → type-3 i keybind..."
        sed -i "s|type-2/launcher.sh|type-3/launcher.sh|g" "$HYPR_TARGET"
        success "Sti oppdatert til type-3"
    fi

    # Sørg for at launcher.sh er kjørbar
    chmod +x "$ROFI_LAUNCHER"
    chmod +x "$ROFI_POWERMENU" 2>/dev/null || true

    echo ""
    warning "Rofi virket ikke fra keybinding/waybar — mest sannsynlig årsak:"
    echo ""
    echo "   1. Feil sti til launcher script"
    echo "   2. Script ikke kjørbart (chmod +x)"
    echo "   3. Miljøvariabler mangler (DISPLAY/WAYLAND_DISPLAY)"
    echo ""
    echo "   ✅ Fikset: chmod +x på alle launcher scripts"
    echo "   ✅ Fikset: pkill rofi i launcher (dreper hengede instanser)"
    echo ""
    log "Reload Hyprland nå:"
    echo "   hyprctl reload"
    echo "   — ELLER —"
    echo "   Super + Shift + R  (standard Hyprland reload)"
    echo ""
else
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "  LEGG TIL I HYPRLAND.CONF (eller keybinds.conf):"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    cat << HYPR_CONFIG
# ── ROFI ────────────────────────────────────────────────────────────────────
# Launcher
\$menu = pkill -x rofi || \$HOME/.config/rofi/launchers/type-3/launcher.sh

# Powermenu
\$powermenu = \$HOME/.config/rofi/powermenu/type-3/powermenu.sh

# Clipboard
bind = \$mainMod, V, exec, cliphist list | rofi -dmenu -theme \$HOME/.config/rofi/clipboard.rasi -p " Clipboard" | cliphist decode | wl-copy

# Keybinds
bind = \$mainMod, A,     exec, \$menu
bind = \$mainMod, X,     exec, \$powermenu

# Clipboard daemon (i exec-once seksjonen)
exec-once = wl-paste --type text  --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
HYPR_CONFIG
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""

    # Spør om auto-tillegg
    read -p "Vil du legge til keybinds automatisk i hyprland.conf? [j/N]: " SVAR
    if [[ "$SVAR" =~ ^[jJ]$ ]] && [ -f "$HYPR_CONF" ]; then
        cat >> "$HYPR_CONF" << APPEND_CONF

# ── ROFI (lagt til av install-rofi-adi1090x.sh) ─────────────────────────────
\$menu = pkill -x rofi || \$HOME/.config/rofi/launchers/type-3/launcher.sh
\$powermenu = \$HOME/.config/rofi/powermenu/type-3/powermenu.sh

bind = \$mainMod, A, exec, \$menu
bind = \$mainMod, X, exec, \$powermenu
bind = \$mainMod, V, exec, cliphist list | rofi -dmenu -theme \$HOME/.config/rofi/clipboard.rasi -p " Clipboard" | cliphist decode | wl-copy

exec-once = wl-paste --type text  --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
APPEND_CONF
        success "Keybinds lagt til i $HYPR_CONF"
        log "Kjør: hyprctl reload"
    fi
fi

echo ""
echo "📦 Installert:"
echo "   • adi1090x rofi collection (launchers type-1→7, powermenus)"
echo "   • style-11.rasi  — Archruud custom (navy #000A22 + transparency)"
echo "   • launcher.sh    — type-3 / style-11"
echo "   • clipboard.rasi — matcher style-11"
echo ""
echo "⌨️  Snarveier:"
echo "   Super + A  → Rofi launcher (type-3 / style-11)"
echo "   Super + V  → Clipboard manager"
echo "   Super + X  → Powermenu (type-3 / style-2)"
echo ""
echo "🎨 Endre transparency i style-11:"
echo "   nano ~/.config/rofi/launchers/type-3/style-11.rasi"
echo "   Endre: archruud-bg: #000A22dd;  (dd=87% cc=80% bb=73% 88=53% 55=33%)"
echo ""
echo "🔄 Reload Hyprland:"
echo "   hyprctl reload"
echo ""
success "Ferdig! Kjør 'hyprctl reload' for å aktivere endringene."
echo ""
