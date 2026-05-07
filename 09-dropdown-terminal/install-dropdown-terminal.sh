#!/bin/bash

# ============================================================
# 09-dropdown-terminal — install-dropdown-terminal.sh
# Setter opp hdrop dropdown terminal for Hyprland
#
# hdrop: Dropdown terminal/program toggle for Hyprland
# Keybind: SUPER + SHIFT + RETURN
# AUR: hdrop-git
#
# Fungerer standalone OG som del av full installasjon.
# Ved full installasjon: 25-scripts-and-files skriver over
# hyprland.conf med ferdig konfig som allerede inneholder
# disse linjene.
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

HYPRCONF="$HOME/.config/hypr/hyprland.conf"

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  09-dropdown-terminal — hdrop Setup${NC}"
echo -e "${CYAN}  Keybind: SUPER + SHIFT + RETURN${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo ""

# ── Sjekk AUR-helper ──────────────────────────────────────────────────────────
step "Sjekker AUR-helper"
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    log "Bruker: yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    log "Bruker: paru"
else
    err "Ingen AUR-helper funnet (yay eller paru)."
    exit 1
fi

# ── Installer hdrop-git ───────────────────────────────────────────────────────
step "Installerer hdrop-git"

if pacman -Q hdrop-git &>/dev/null; then
    log "hdrop-git er allerede installert: $(hdrop --version 2>/dev/null || echo 'ok')"
else
    info "Installerer hdrop-git fra AUR..."
    $AUR_HELPER -S --needed --noconfirm hdrop-git
    if pacman -Q hdrop-git &>/dev/null; then
        log "hdrop-git installert"
    else
        err "hdrop-git installasjon feilet"
        exit 1
    fi
fi

# ── Kopier hdrop scripts til hypr/scripts ────────────────────────────────────
step "Kopierer hdrop scripts"

mkdir -p "$HOME/.config/hypr/scripts"

for SCRIPT in hdrop-init.sh hdrop-resize.sh; do
    if [ -f "$SCRIPT_DIR/$SCRIPT" ]; then
        cp "$SCRIPT_DIR/$SCRIPT" "$HOME/.config/hypr/scripts/$SCRIPT"
        chmod +x "$HOME/.config/hypr/scripts/$SCRIPT"
        log "Kopiert: ~/.config/hypr/scripts/$SCRIPT"
    else
        warn "$SCRIPT ikke funnet i $SCRIPT_DIR — last den ned manuelt"
    fi
done

# ── Sjekk at hyprland.conf eksisterer ────────────────────────────────────────
step "Sjekker hyprland.conf"

if [ ! -f "$HYPRCONF" ]; then
    warn "Fant ikke $HYPRCONF"
    warn "Oppretter minimal hyprland.conf..."
    mkdir -p "$HOME/.config/hypr"
    touch "$HYPRCONF"
fi

log "Bruker: $HYPRCONF"

# ── Hjelpefunksjon: legg til linje hvis den ikke finnes ──────────────────────
add_if_missing() {
    local search="$1"
    local line="$2"
    local section="$3"   # Valgfri seksjon å legge til under

    if grep -qF "$search" "$HYPRCONF"; then
        info "Finnes allerede: $search"
        return 0
    fi

    if [[ -n "$section" ]] && grep -qF "$section" "$HYPRCONF"; then
        # Legg til etter seksjonen
        sed -i "/$section/a $line" "$HYPRCONF"
    else
        # Legg til på slutten
        echo "" >> "$HYPRCONF"
        echo "$line" >> "$HYPRCONF"
    fi
    log "Lagt til: $line"
}

# ── 1) exec-once (linje ~35 i full conf) ─────────────────────────────────────
step "Legger til exec-once for hdrop"

add_if_missing \
    "hdrop -b -f" \
    "exec-once = hdrop -b -f -h 35 -w 75 -p top -g 57 kitty --class kitty_top" \
    "### AUTOSTART ###"

# ── 2) Keybind SUPER+SHIFT+RETURN (linje ~240) ───────────────────────────────
step "Legger til hdrop keybind"

add_if_missing \
    "hdrop -f -h 35" \
    "bind = \$mainMod SHIFT, RETURN, exec, hdrop -f -h 35 -w 75 -p top -g 57 kitty --class kitty_top" \
    "### KEYBINDINGS ###"

# ── 3) Dropdown resize-seksjon (linje ~344-353) ───────────────────────────────
step "Legger til dropdown terminal resize-keybinds"

if grep -q "DROPDOWN TERMINAL RESIZE" "$HYPRCONF"; then
    info "Resize-seksjon finnes allerede"
else
    cat >> "$HYPRCONF" << 'EOF'

# ═══════════════════════════════════════════════════════════════════════════
#  DROPDOWN TERMINAL RESIZE - Endre størrelse på dropdown terminal
# ═══════════════════════════════════════════════════════════════════════════
#  Hold Super + Alt + piltast for å endre størrelse på dropdown terminal
#  Fungerer på alle floating windows inkludert dropdown terminal
#  'binde' = kan holde tasten inne for kontinuerlig resize

binde = $mainMod ALT, left, resizeactive, -50 0          # Smalere (venstre)
binde = $mainMod ALT, right, resizeactive, 50 0          # Bredere (høyre)
binde = $mainMod ALT, up, resizeactive, 0 -50            # Lavere (opp)
binde = $mainMod ALT, down, resizeactive, 0 50           # Høyere (ned)
EOF
    log "Resize-seksjon lagt til"
fi

# ── 4) Window rules for kitty_top (linje ~393-395) ───────────────────────────
step "Legger til window rules for kitty_top"

if grep -q "kitty_top" "$HYPRCONF"; then
    info "Window rules for kitty_top finnes allerede"
else
    cat >> "$HYPRCONF" << 'EOF'

# ── hdrop window rules (ny syntaks Hyprland 0.48+) ─────────
windowrule = float on, match:class ^(kitty_top)$
windowrule = animation slidefadevert, match:class ^(kitty_top)$
EOF
    log "Window rules lagt til"
fi

# ── Verifisering ──────────────────────────────────────────────────────────────
step "Verifiserer konfigurasjon"

echo ""
echo -e "${YELLOW}hdrop-linjer i hyprland.conf:${NC}"
grep -n "hdrop\|kitty_top\|DROPDOWN TERMINAL" "$HYPRCONF" || warn "Ingen linjer funnet!"

# ── Ferdig ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  hdrop Dropdown Terminal Installert!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Keybinds:${NC}"
echo "  SUPER + SHIFT + RETURN  — Toggle dropdown terminal"
echo "  SUPER + ALT + ←→↑↓      — Resize dropdown terminal"
echo ""
echo -e "${YELLOW}hdrop parametere:${NC}"
echo "  -h 35   = 35% av skjermhøyden"
echo "  -w 75   = 75% av skjermbredden"
echo "  -p top  = plassert øverst"
echo "  -g 57   = offset/gap fra topp"
echo ""
echo -e "${CYAN}Reload Hyprland: SUPER + SHIFT + R${NC}"
echo ""
