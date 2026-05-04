#!/bin/bash

################################################################################
#  DUNST INSTALLASJON - Notification Daemon
#  Installer Dunst med konfigurasjon for Hyprland
################################################################################

set -e

# Farger for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logger funksjon
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ADVARSEL]${NC} $1"
}

# Banner
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                     ║
║          🔔  DUNST INSTALLASJON & KONFIGURASJON  🔔                ║
║                                                                     ║
║  Notification Daemon · Custom Styling · Priority Support          ║
║                                                                     ║
╚═══════════════════════════════════════════════════════════════════╝
EOF

echo ""

# Sjekk om scriptet kjøres som root
if [ "$EUID" -eq 0 ]; then 
    error "Ikke kjør dette scriptet som root!"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
#  1. INSTALLER PAKKER
# ═══════════════════════════════════════════════════════════════════════════

log "Installerer Dunst og nødvendige pakker..."

# Sjekk om pakker allerede er installert
PACKAGES="dunst libnotify"
TO_INSTALL=""

for pkg in $PACKAGES; do
    if ! pacman -Qi $pkg &> /dev/null; then
        TO_INSTALL="$TO_INSTALL $pkg"
    fi
done

if [ -n "$TO_INSTALL" ]; then
    log "Installerer:$TO_INSTALL"
    sudo pacman -S --needed --noconfirm $TO_INSTALL || {
        error "Feil under installasjon av pakker"
        exit 1
    }
    success "Pakker installert"
else
    success "Alle pakker er allerede installert"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  2. LAG DUNST KONFIGURASJON
# ═══════════════════════════════════════════════════════════════════════════

log "Lager Dunst konfigurasjon..."

# Backup eksisterende konfigurasjon hvis den finnes
if [ -d "$HOME/.config/dunst" ]; then
    warning "Eksisterende Dunst konfigurasjon funnet"
    BACKUP_DIR="$HOME/.config/dunst.backup.$(date +%Y%m%d_%H%M%S)"
    log "Lager backup til: $BACKUP_DIR"
    mv "$HOME/.config/dunst" "$BACKUP_DIR"
    success "Backup lagret"
fi

# Lag dunst konfigurasjonsmappen
mkdir -p "$HOME/.config/dunst"

# Lag dunstrc konfigurasjon
log "Genererer dunstrc..."

cat > "$HOME/.config/dunst/dunstrc" << 'DUNSTRC'
################################################################################
#  DUNST KONFIGURASJON FOR HYPRLAND
#  Modern notification daemon med custom styling
################################################################################

[global]
    # Display
    monitor = 0
    follow = mouse
    
    # Geometry
    width = (300, 400)
    height = 300
    origin = top-right
    offset = 10x50
    
    # Appearance
    padding = 15
    horizontal_padding = 15
    frame_width = 2
    gap_size = 5
    
    # Text
    font = JetBrainsMono Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    word_wrap = yes
    
    # Icons
    icon_position = left
    min_icon_size = 32
    max_icon_size = 64
    icon_path = /usr/share/icons/Papirus-Dark/48x48/status:/usr/share/icons/Papirus-Dark/48x48/devices:/usr/share/icons/Papirus-Dark/48x48/apps
    
    # Progress bar
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    
    # Behavior
    sticky_history = yes
    history_length = 20
    show_indicators = yes
    
    # Mouse
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all
    
    # Timeouts
    idle_threshold = 120
    
    # Misc
    corner_radius = 12
    notification_limit = 5
    separator_height = 2
    transparency = 0
    separator_color = frame
    sort = yes
    
    # Wayland/Hyprland specific
    layer = overlay
    force_xwayland = false

[urgency_low]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#89b4fa"
    timeout = 5
    highlight = "#89b4fa"

[urgency_normal]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#89b4fa"
    timeout = 10
    highlight = "#89b4fa"

[urgency_critical]
    background = "#1e1e2e"
    foreground = "#cdd6f4"
    frame_color = "#f38ba8"
    timeout = 0
    highlight = "#f38ba8"

################################################################################
#  CUSTOM RULES - Spesielle styling for ulike applikasjoner
################################################################################

# Volume notifications
[volume]
    appname = "Volume"
    urgency = low
    frame_color = "#89dceb"
    timeout = 2

# Brightness notifications
[brightness]
    appname = "Brightness"
    urgency = low
    frame_color = "#f9e2af"
    timeout = 2

# Battery notifications
[battery]
    appname = "Battery"
    urgency = normal
    frame_color = "#a6e3a1"
    timeout = 10

[battery_critical]
    appname = "Battery"
    summary = "*[Cc]ritical*"
    urgency = critical
    frame_color = "#f38ba8"

# Network notifications
[network]
    appname = "NetworkManager"
    urgency = low
    frame_color = "#94e2d5"
    timeout = 5

# Screenshot notifications
[screenshot]
    appname = "Screenshot"
    urgency = low
    frame_color = "#cba6f7"
    timeout = 3

# Waybar notifications
[waybar]
    appname = "Waybar"
    urgency = low
    frame_color = "#89b4fa"
    timeout = 3

# Discord/Chat notifications
[discord]
    appname = "Discord"
    urgency = normal
    frame_color = "#7289da"
    timeout = 10

# Music player notifications
[music]
    appname = "Music"
    urgency = low
    frame_color = "#cba6f7"
    timeout = 5

[mpd]
    appname = "mpd"
    urgency = low
    frame_color = "#cba6f7"
    timeout = 5

[spotify]
    appname = "Spotify"
    urgency = low
    frame_color = "#1db954"
    timeout = 5

################################################################################
#  SHORTCUTS
################################################################################
# Close notification: click on notification
# Close all notifications: middle click on notification
# Redisplay last message: Ctrl+Shift+period
# Context menu: Ctrl+Shift+comma

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period
DUNSTRC

success "dunstrc konfigurasjon opprettet"

# ═══════════════════════════════════════════════════════════════════════════
#  3. LAG TEST NOTIFIKASJON SCRIPT
# ═══════════════════════════════════════════════════════════════════════════

log "Lager test notifikasjon script..."

mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/dunst-test" << 'TEST_SCRIPT'
#!/bin/bash
# Test Dunst notifikasjoner

echo "Testing Dunst notifications..."

# Test low urgency
notify-send "Low Urgency" "Dette er en low urgency notifikasjon" -u low -i dialog-information

sleep 2

# Test normal urgency
notify-send "Normal Urgency" "Dette er en normal notifikasjon" -u normal -i dialog-information

sleep 2

# Test critical urgency
notify-send "Critical Urgency" "Dette er en critical notifikasjon!" -u critical -i dialog-error

sleep 2

# Test med progress bar
for i in {0..100..10}; do
    notify-send "Download" "Progress: $i%" -h int:value:$i -u low -t 1000
    sleep 0.2
done

sleep 2

# Test volume notification
notify-send "Volume" "Volume satt til 50%" -u low -i audio-volume-medium -t 2000

sleep 2

# Test brightness notification
notify-send "Brightness" "Brightness satt til 75%" -u low -i display-brightness -t 2000

sleep 2

# Test screenshot notification
notify-send "Screenshot" "Screenshot tatt og lagret" -u low -i camera-photo -t 3000

echo "Dunst test ferdig!"
TEST_SCRIPT

chmod +x "$HOME/.local/bin/dunst-test"
success "Test script opprettet: dunst-test"

# ═══════════════════════════════════════════════════════════════════════════
#  4. LAG DUNST CONTROL SCRIPT
# ═══════════════════════════════════════════════════════════════════════════

log "Lager Dunst control script..."

cat > "$HOME/.local/bin/dunst-control" << 'CONTROL_SCRIPT'
#!/bin/bash
# Dunst kontroll script - pause/resume/toggle

case "$1" in
    pause)
        dunstctl set-paused true
        notify-send "Dunst" "Notifikasjoner pauset" -t 2000
        ;;
    resume)
        dunstctl set-paused false
        notify-send "Dunst" "Notifikasjoner gjenopptatt" -t 2000
        ;;
    toggle)
        if dunstctl is-paused | grep -q "true"; then
            dunstctl set-paused false
            notify-send "Dunst" "Notifikasjoner gjenopptatt" -t 2000
        else
            dunstctl set-paused true
            notify-send "Dunst" "Notifikasjoner pauset" -t 2000
        fi
        ;;
    close)
        dunstctl close
        ;;
    close-all)
        dunstctl close-all
        ;;
    history)
        dunstctl history-pop
        ;;
    context)
        dunstctl context
        ;;
    *)
        echo "Bruk: dunst-control {pause|resume|toggle|close|close-all|history|context}"
        exit 1
        ;;
esac
CONTROL_SCRIPT

chmod +x "$HOME/.local/bin/dunst-control"
success "Control script opprettet: dunst-control"

# ═══════════════════════════════════════════════════════════════════════════
#  5. KONFIGURER HYPRLAND INTEGRASJON
# ═══════════════════════════════════════════════════════════════════════════

log "Sjekker Hyprland konfigurasjon..."

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

if [ -f "$HYPR_CONF" ]; then
    # Sjekk om dunst allerede er i autostart
    if grep -q "exec-once = dunst" "$HYPR_CONF"; then
        success "Dunst er allerede konfigurert i autostart"
    else
        warning "Dunst er ikke i autostart"
        echo ""
        echo "Legg til følgende i autostart-seksjonen i $HYPR_CONF:"
        echo "exec-once = dunst"
        echo ""
    fi
    
    # Foreslå keybinds for dunst control
    if ! grep -q "dunst-control" "$HYPR_CONF"; then
        echo "Foreslåtte keybinds for Dunst:"
        echo ""
        echo "# Dunst kontroll"
        echo "bind = \$mainMod, N, exec, dunst-control toggle    # Toggle pause/resume"
        echo "bind = \$mainMod SHIFT, N, exec, dunst-control close-all  # Lukk alle"
        echo "bind = \$mainMod CTRL, N, exec, dunst-control history     # Vis siste"
        echo ""
    fi
else
    warning "Finner ikke Hyprland konfigurasjon"
fi

# ═══════════════════════════════════════════════════════════════════════════
#  6. OPPSUMMERING
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ DUNST INSTALLASJON FULLFØRT                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
success "Dunst er installert og konfigurert!"
echo ""
echo "📋 Installerte komponenter:"
echo "   • Dunst notification daemon"
echo "   • Custom konfigurasjon for Hyprland"
echo "   • Priority-basert styling (low/normal/critical)"
echo "   • App-spesifikke rules (volume, brightness, etc.)"
echo "   • Progress bar support"
echo ""
echo "⌨️  Tastatursnarveier (foreslått for hyprland.conf):"
echo "   • Super + N        → Toggle pause/resume notifikasjoner"
echo "   • Super + Shift + N → Lukk alle notifikasjoner"
echo "   • Super + Ctrl + N  → Vis siste notifikasjon"
echo ""
echo "🔧 Kontroll kommandoer:"
echo "   • dunst-control pause      → Pause notifikasjoner"
echo "   • dunst-control resume     → Gjenoppta notifikasjoner"
echo "   • dunst-control toggle     → Toggle pause/resume"
echo "   • dunst-control close      → Lukk aktiv notifikasjon"
echo "   • dunst-control close-all  → Lukk alle notifikasjoner"
echo "   • dunst-control history    → Vis siste notifikasjon"
echo ""
echo "🧪 Test notifikasjoner:"
echo "   Kjør: dunst-test"
echo ""
echo "📁 Konfigurasjon: ~/.config/dunst/dunstrc"
echo ""
echo "🎨 Fargepalett (Catppuccin Mocha):"
echo "   • Low urgency:      Blå (89b4fa)"
echo "   • Normal urgency:   Blå (89b4fa)"
echo "   • Critical urgency: Rød (f38ba8)"
echo "   • Volume:           Cyan (89dceb)"
echo "   • Brightness:       Gul (f9e2af)"
echo "   • Battery:          Grønn (a6e3a1)"
echo "   • Screenshot:       Lilla (cba6f7)"
echo ""

# Test om dunst fungerer
log "Tester Dunst installasjon..."
if command -v dunst &> /dev/null; then
    success "Dunst er klar til bruk!"
    echo ""
    echo "Start Dunst med: dunst"
    echo "Eller restart Hyprland for autostart"
    echo ""
    echo "Test notifikasjoner med: dunst-test"
else
    error "Dunst ble ikke funnet i PATH"
    exit 1
fi

echo ""
log "Husk å restarte Hyprland eller start Dunst manuelt:"
log "   killall dunst; dunst &"
echo ""

# Send test notifikasjon
log "Sender test notifikasjon..."
if pgrep -x dunst > /dev/null; then
    notify-send "Dunst Installasjon" "Dunst er nå installert og konfigurert! 🎉" -u normal -i dialog-information -t 5000
    success "Test notifikasjon sendt"
else
    warning "Dunst kjører ikke, start med: dunst &"
fi

echo ""
