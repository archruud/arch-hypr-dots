#!/bin/bash

# Screenshot Setup Script for Hyprland
# Installerer grim, slurp, swappy, jq, wl-clipboard og setter opp config
# Alt-i-ett løsning for komplett screenshot-funksjonalitet

echo "================================================"
echo "  Screenshot Setup for Hyprland"
echo "================================================"
echo ""

# Installer nødvendige pakker
echo "Installerer grim, slurp, swappy, jq og wl-clipboard..."
sudo pacman -S --needed --noconfirm grim slurp swappy jq wl-clipboard

# Opprett nødvendige mapper
echo ""
echo "Oppretter mapper..."
mkdir -p ~/.config/swappy
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Bilder/Screenshots

# Kopier swappy config
echo ""
echo "Setter opp swappy config..."
cat > ~/.config/swappy/config << 'EOF'
[Default]
save_dir=/home/archruud/Bilder/Screenshots
save_filename_format=screenshot-%Y%m%d-%H%M%S.png
show_panel=false
line_size=5
text_size=20
text_font=sans-serif
EOF

# Lag screenshot-window.sh script
echo ""
echo "Lager screenshot-window.sh script..."
cat > ~/.config/hypr/scripts/screenshot-window.sh << 'EOF'
#!/bin/bash
geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
grim -g "$geometry" - | swappy -f -
EOF

# Gjør scriptet kjørbart
chmod +x ~/.config/hypr/scripts/screenshot-window.sh

# Backup av hyprland.conf
echo ""
echo "Lager backup av hyprland.conf..."
if [ -f ~/.config/hypr/hyprland.conf ]; then
    cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.backup-$(date +%Y%m%d-%H%M%S)
    echo "Backup lagret: hyprland.conf.backup-$(date +%Y%m%d-%H%M%S)"
fi

# Sjekk om screenshot-bindinger allerede eksisterer
if grep -q "Screenshot shortcuts" ~/.config/hypr/hyprland.conf 2>/dev/null; then
    echo ""
    echo "ADVARSEL: Screenshot-bindinger ser ut til å allerede eksistere!"
    echo "Hopper over automatisk oppdatering av hyprland.conf"
    echo "Sjekk filen manuelt hvis du vil legge til nye bindinger."
else
    # Legg til screenshot-bindinger i hyprland.conf
    echo ""
    echo "Legger til screenshot-bindinger i hyprland.conf..."
    cat >> ~/.config/hypr/hyprland.conf << 'EOF'

# Screenshot shortcuts
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -
bind = $mainMod CTRL, S, exec, sh -c "grim - | swappy -f -"
bind = $mainMod ALT, S, exec, ~/.config/hypr/scripts/screenshot-window.sh
EOF
    echo "Screenshot-bindinger lagt til i hyprland.conf"
fi

echo ""
echo "================================================"
echo "  Installasjon fullført!"
echo "================================================"
echo ""
echo "Screenshot-shortcuts:"
echo "  Super + Shift + S  = Velg område"
echo "  Super + Ctrl + S   = Helt skjerm"
echo "  Super + Alt + S    = Aktivt vindu"
echo ""
echo "Screenshots lagres i: ~/Bilder/Screenshots"
echo ""
echo "Swappy-funksjonalitet:"
echo "  💾 Save-knapp    = Lagrer til ~/Bilder/Screenshots"
echo "  📋 Copy-knapp    = Kopierer til clipboard (kan limes inn)"
echo "  ✏️  Verktøy      = Tegne, tekst, piler, etc."
echo ""
echo "For å aktivere: hyprctl reload (eller logg ut/inn)"
echo ""
