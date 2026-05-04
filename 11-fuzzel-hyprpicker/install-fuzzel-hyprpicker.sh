#!/usr/bin/env bash
# Komplett installasjons-script for fuzzel-hyprpicker
# Installerer alle nødvendige programmer og setter opp alt automatisk

set -e

# Farger for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Fuzzel-Hyprpicker Installasjon           ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo ""

# Sjekk om vi kjører på Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}[FEIL] Dette scriptet er kun for Arch Linux!${NC}"
    exit 1
fi

# Funksjon for å sjekke om en pakke er installert
check_package() {
    if pacman -Qi "$1" &> /dev/null; then
        echo -e "${GREEN}[✓] $1 er allerede installert${NC}"
        return 0
    else
        echo -e "${YELLOW}[ ] $1 er ikke installert${NC}"
        return 1
    fi
}

# Funksjon for å installere pakker
install_packages() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if ! check_package "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        echo -e "\n${BLUE}[→] Installerer: ${to_install[*]}${NC}"
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        echo -e "${GREEN}[✓] Installasjon fullført!${NC}\n"
    else
        echo -e "${GREEN}[✓] Alle pakker er allerede installert!${NC}\n"
    fi
}

# Steg 1: Installer nødvendige pakker
echo -e "${BLUE}[1/6] Sjekker og installerer nødvendige pakker...${NC}"
REQUIRED_PACKAGES=(
    "hyprpicker"    # Fargeplukker for Hyprland
    "fuzzel"        # Launcher/dmenu
    "wl-clipboard"  # Wayland clipboard utilities
    "libnotify"     # Desktop notifications (gir notify-send)
)

install_packages "${REQUIRED_PACKAGES[@]}"

# Steg 2: Lag nødvendige mapper
echo -e "${BLUE}[2/6] Lager nødvendige mapper...${NC}"

HYPR_SCRIPTS_DIR="$HOME/.config/hypr/scripts"
CONFIG_DIR="$HOME/.config/fuzzel-hyprpicker"
ICONS_DIR="$CONFIG_DIR/icons"

# Lag mapper
mkdir -p "$HYPR_SCRIPTS_DIR"
mkdir -p "$ICONS_DIR"
touch "$CONFIG_DIR/colors.txt"

echo -e "${GREEN}[✓] Mapper opprettet:${NC}"
echo -e "    • $HYPR_SCRIPTS_DIR"
echo -e "    • $CONFIG_DIR"
echo -e "    • $ICONS_DIR"
echo ""

# Steg 3: Lag fuzzel-hyprpicker script
echo -e "${BLUE}[3/6] Lager fuzzel-hyprpicker script...${NC}"

SCRIPT_PATH="$HYPR_SCRIPTS_DIR/fuzzel-hyprpicker.sh"

# Lag scriptet med notify-send
cat > "$SCRIPT_PATH" << 'EOFSCRIPT'
#!/usr/bin/env bash
# A tool to pick colors from the screen using hyprpicker and fuzzel

set +u  # Disable nounset
APP_NAME="fuzzel-hyprpicker"

# Set up the storage directory and file
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$APP_NAME"
HISTORY_FILE="$CONFIG_DIR/colors.txt"
HISTORY_NUM=10
ICONS_DIR="$CONFIG_DIR/icons"

# Create directories and history if they don't exist
mkdir -p "$ICONS_DIR"
touch "$HISTORY_FILE"

# Funksjon for å sende notifikasjoner
notify() {
    local title="$1"
    local message="$2"
    notify-send -a "$APP_NAME" -i "org.gnome.design.Palette" "$title" "$message"
}

function create_eye_dropper_svg() {
  local color="#C8D1EE"
  local icon_path="$ICONS_DIR/eyedropper.svg"

  # Create an SVG for the eyedropper icon if it doesn't exist
  if [ ! -f "$icon_path" ]; then
    cat > "$icon_path" <<EOF
<svg fill="$color" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <g id="eyedropper">
    <path
      d="M223.99658,67.50391a35.73557,35.73557,0,0,0-11.26172-25.66114c-14.01806-13.2705-36.71875-12.771-50.60254,1.11328L140.18408,64.90479a24.02939,24.02939,0,0,0-33.15429.75195L100,72.68652a16.01779,16.01779,0,0,0,0,22.627l2.05908,2.05908L51.71533,147.71582a40.15638,40.15638,0,0,0-11.01074,35.771l-9.78271,22.40869a13.66329,13.66329,0,0,0,2.87744,15.21728,15.915,15.915,0,0,0,11.27929,4.70313,16.077,16.077,0,0,0,6.43555-1.353l20.999-9.16748a40.15391,40.15391,0,0,0,35.771-11.01123l50.34326-50.34326L160.68652,156a16.01779,16.01779,0,0,0,22.627,0l7.02978-7.02979a24.02843,24.02843,0,0,0,.752-33.15429l22.36036-22.36035A35.71726,35.71726,0,0,0,223.99658,67.50391ZM96.9707,192.9707a24.09567,24.09567,0,0,1-23.1914,6.21436,8.0052,8.0052,0,0,0-5.26416.39746L47.044,208.95605l9.37353-21.47119a8.00234,8.00234,0,0,0,.39746-5.26416,24.0986,24.0986,0,0,1,6.21436-23.1914L113.37256,108.686l33.9414,33.9414Z">
      id="eyedropper_path" />
  </g>
</svg>
EOF
  fi
}

function create_trash_svg() {
  local color="#C8D1EE"
  local icon_path="$ICONS_DIR/trash.svg"

  # Create an SVG for the trash icon if it doesn't exist
  if [ ! -f "$icon_path" ]; then
    cat > "$icon_path" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<svg fill="$color" width="800px" height="800px" viewBox="0 0 256 256" id="Flat" xmlns="http://www.w3.org/2000/svg">
  <path d="M215.99609,48H176V40a24.02718,24.02718,0,0,0-24-24H104A24.02718,24.02718,0,0,0,80,40v8H39.99609a8,8,0,0,0,0,16h8V208a16.01833,16.01833,0,0,0,16,16h128a16.01833,16.01833,0,0,0,16-16V64h8a8,8,0,0,0,0-16ZM112,168a8,8,0,0,1-16,0V104a8,8,0,0,1,16,0Zm48,0a8,8,0,0,1-16,0V104a8,8,0,0,1,16,0Zm0-120H96V40a8.00917,8.00917,0,0,1,8-8h48a8.00917,8.00917,0,0,1,8,8Z"/>
</svg>
EOF
  fi
}

# Function to add a color to history
function add_color_to_history() {
  local color="$1"

  # Don't add duplicates
  if ! grep -q "^$color$" "$HISTORY_FILE"; then
    # Add to beginning of file
    echo "$color" > "$HISTORY_FILE.new"
    cat "$HISTORY_FILE" >> "$HISTORY_FILE.new"
    # Limit history to HISTORY_NUM entries
    head -n $HISTORY_NUM "$HISTORY_FILE.new" > "$HISTORY_FILE" && rm "$HISTORY_FILE.new"  
  fi
  HISTORY_LEN=$(wc -l < "$HISTORY_FILE")
}

# Function to generate color square .svg icon
function generate_svg_icon() {
  local color="$1"
  local icon_path="$ICONS_DIR/$color.svg"

  # Create an SVG for the color if it doesn't exist
  if [ ! -f "$icon_path" ]; then
    cat > "$icon_path" <<EOF
<svg width="128" height="128" xmlns="http://www.w3.org/2000/svg">
  <rect width="128" height="128" fill="#$color" />
</svg>
EOF
  fi
}

# Function to pick a color from screen
function pick_color() {
  sleep 0.5
  color=$(hyprpicker --format=hex --no-fancy --autocopy | tail -n 1)
  if [ -n "$color" ]; then
    notify "Color Picker" "Color <span color=\"$color\">⬤ $color</span> copied to clipboard."
    # Remove leading # if present
    color="${color#\#}"
    generate_svg_icon "$color"
    add_color_to_history "$color"
  fi
}

# Build menu options
function build_menu() {
  echo -e "Pick a color\0icon\x1f$ICONS_DIR/eyedropper.svg"
  # Add history items if they exist
  if [ -s "$HISTORY_FILE" ]; then
    while read -r color; do
      # If the preview icon doesn't exist, generate it
      if [ ! -e "$ICONS_DIR/$color.svg" ]; then
        generate_svg_icon "$color"
      fi
      # Display the color with a preview
      echo -e "#$color\0icon\x1f$ICONS_DIR/$color.svg"
    done < "$HISTORY_FILE"
  fi
  if [ "$HISTORY_LEN" -gt 0 ]; then
    echo -e "Clear history\0icon\x1f$ICONS_DIR/trash.svg"
  fi
}

create_eye_dropper_svg
create_trash_svg
HISTORY_LEN=$(wc -l < "$HISTORY_FILE")
selection=$(build_menu | fuzzel --dmenu --prompt="🎨  " --lines=$((HISTORY_LEN + 2)) --width=24)
[[ -z "$selection" ]] && exit 0

if [[ "$selection" == "Pick a color"* ]]; then
  pick_color
elif [[ "$selection" == "Clear history"* ]]; then
  rm -f "$HISTORY_FILE"
  rm -f "$ICONS_DIR"/*.svg
  create_eye_dropper_svg
  create_trash_svg
  notify "Color Picker" "History cleared."
else
  echo "$selection" | wl-copy --trim-newline
  notify "Color Picker" "Color <span color=\"$selection\">⬤ $selection</span> copied to clipboard."
fi
EOFSCRIPT

# Gjør scriptet kjørbart
chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}[✓] Script opprettet: $SCRIPT_PATH${NC}\n"

# Steg 4: Lag initial SVG icons
echo -e "${BLUE}[4/6] Lager standard ikoner...${NC}"

# Eyedropper icon
cat > "$ICONS_DIR/eyedropper.svg" << 'EOFSVG'
<svg fill="#C8D1EE" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">
  <g id="eyedropper">
    <path
      d="M223.99658,67.50391a35.73557,35.73557,0,0,0-11.26172-25.66114c-14.01806-13.2705-36.71875-12.771-50.60254,1.11328L140.18408,64.90479a24.02939,24.02939,0,0,0-33.15429.75195L100,72.68652a16.01779,16.01779,0,0,0,0,22.627l2.05908,2.05908L51.71533,147.71582a40.15638,40.15638,0,0,0-11.01074,35.771l-9.78271,22.40869a13.66329,13.66329,0,0,0,2.87744,15.21728,15.915,15.915,0,0,0,11.27929,4.70313,16.077,16.077,0,0,0,6.43555-1.353l20.999-9.16748a40.15391,40.15391,0,0,0,35.771-11.01123l50.34326-50.34326L160.68652,156a16.01779,16.01779,0,0,0,22.627,0l7.02978-7.02979a24.02843,24.02843,0,0,0,.752-33.15429l22.36036-22.36035A35.71726,35.71726,0,0,0,223.99658,67.50391ZM96.9707,192.9707a24.09567,24.09567,0,0,1-23.1914,6.21436,8.0052,8.0052,0,0,0-5.26416.39746L47.044,208.95605l9.37353-21.47119a8.00234,8.00234,0,0,0,.39746-5.26416,24.0986,24.0986,0,0,1,6.21436-23.1914L113.37256,108.686l33.9414,33.9414Z">
      id="eyedropper_path" />
  </g>
</svg>
EOFSVG

# Trash icon
cat > "$ICONS_DIR/trash.svg" << 'EOFSVG'
<?xml version="1.0" encoding="utf-8"?>
<svg fill="#C8D1EE" width="800px" height="800px" viewBox="0 0 256 256" id="Flat" xmlns="http://www.w3.org/2000/svg">
  <path d="M215.99609,48H176V40a24.02718,24.02718,0,0,0-24-24H104A24.02718,24.02718,0,0,0,80,40v8H39.99609a8,8,0,0,0,0,16h8V208a16.01833,16.01833,0,0,0,16,16h128a16.01833,16.01833,0,0,0,16-16V64h8a8,8,0,0,0,0-16ZM112,168a8,8,0,0,1-16,0V104a8,8,0,0,1,16,0Zm48,0a8,8,0,0,1-16,0V104a8,8,0,0,1,16,0Zm0-120H96V40a8.00917,8.00917,0,0,1,8-8h48a8.00917,8.00917,0,0,1,8,8Z"/>
</svg>
EOFSVG

echo -e "${GREEN}[✓] Ikoner opprettet${NC}\n"

# Steg 5: Sett opp Hyprland keybinding
echo -e "${BLUE}[5/6] Setter opp Hyprland keybinding...${NC}"

HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"

if [ -f "$HYPR_CONFIG" ]; then
    # Sjekk om keybinding allerede eksisterer
    if grep -q "fuzzel-hyprpicker" "$HYPR_CONFIG"; then
        echo -e "${YELLOW}[!] Keybinding finnes allerede i hyprland.conf${NC}\n"
    else
        # Legg til keybinding
        echo "" >> "$HYPR_CONFIG"
        echo "# Fuzzel-Hyprpicker - Color picker" >> "$HYPR_CONFIG"
        echo "bind = CTRL ALT, K, exec, ~/.config/hypr/scripts/fuzzel-hyprpicker.sh" >> "$HYPR_CONFIG"
        echo -e "${GREEN}[✓] Keybinding lagt til: CTRL + ALT + K${NC}\n"
    fi
else
    echo -e "${RED}[!] Fant ikke hyprland.conf på: $HYPR_CONFIG${NC}"
    echo -e "${YELLOW}[→] Du må legge til denne linjen manuelt:${NC}"
    echo -e "${YELLOW}    bind = CTRL ALT, K, exec, ~/.config/hypr/scripts/fuzzel-hyprpicker.sh${NC}\n"
fi

# Steg 6: Test at alt fungerer
echo -e "${BLUE}[6/6] Tester installasjonen...${NC}"

# Sjekk at alle kommandoer finnes
COMMANDS=("hyprpicker" "fuzzel" "wl-copy" "notify-send")
ALL_OK=true

for cmd in "${COMMANDS[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}[✓] $cmd funnet${NC}"
    else
        echo -e "${RED}[✗] $cmd ikke funnet!${NC}"
        ALL_OK=false
    fi
done

# Sjekk at script eksisterer
if [ -f "$SCRIPT_PATH" ]; then
    echo -e "${GREEN}[✓] fuzzel-hyprpicker.sh funnet${NC}"
else
    echo -e "${RED}[✗] fuzzel-hyprpicker.sh ikke funnet!${NC}"
    ALL_OK=false
fi

# Sjekk at mapper eksisterer
if [ -d "$CONFIG_DIR" ]; then
    echo -e "${GREEN}[✓] Config-mappe: $CONFIG_DIR${NC}"
else
    echo -e "${RED}[✗] Config-mappe mangler!${NC}"
    ALL_OK=false
fi

if [ -d "$ICONS_DIR" ]; then
    echo -e "${GREEN}[✓] Ikoner-mappe: $ICONS_DIR${NC}"
else
    echo -e "${RED}[✗] Ikoner-mappe mangler!${NC}"
    ALL_OK=false
fi

echo ""

# Ferdig!
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      Installasjon fullført! ✓             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Hvor ligger alt:${NC}"
    echo -e "  • Script:  ${YELLOW}$SCRIPT_PATH${NC}"
    echo -e "  • Config:  ${YELLOW}$CONFIG_DIR${NC}"
    echo -e "  • Ikoner:  ${YELLOW}$ICONS_DIR${NC}"
    echo ""
    echo -e "${BLUE}Bruksanvisning:${NC}"
    echo -e "  1. Trykk ${YELLOW}CTRL + ALT + K${NC} for å åpne color picker"
    echo -e "  2. Velg ${YELLOW}'Pick a color'${NC} og klikk på en farge på skjermen"
    echo -e "  3. Fargen kopieres automatisk til clipboard!"
    echo -e "  4. Historikk av tidligere farger vises i menyen"
    echo ""
    echo -e "${BLUE}Tips:${NC}"
    echo -e "  • Du må restarte Hyprland for at keybinding skal fungere"
    echo -e "  • Kjør: ${YELLOW}hyprctl reload${NC} eller logg ut og inn igjen"
    echo ""
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   Installasjon fullført med advarsler!    ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Noen komponenter mangler. Sjekk feilmeldingene over.${NC}\n"
fi
