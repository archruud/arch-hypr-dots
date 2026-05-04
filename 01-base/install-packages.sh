#!/bin/bash

# Package Installation Script
# Leser pacman-packages.txt og aur-packages.txt og installerer alt

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== Package Installation ===${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_LIST="$SCRIPT_DIR/pacman-packages.txt"
AUR_LIST="$SCRIPT_DIR/aur-packages.txt"

# Funksjon for å lese pakkeliste (ignorerer kommentarer og tomme linjer)
read_package_list() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo ""
        return
    fi
    
    # Les fil, fjern kommentarer og tomme linjer
    grep -v '^#' "$file" | grep -v '^[[:space:]]*$' | awk '{print $1}'
}

# Installer pacman pakker
if [ -f "$PACMAN_LIST" ]; then
    echo -e "${CYAN}=== Installerer Pacman pakker ===${NC}"
    echo ""
    
    PACMAN_PKGS=$(read_package_list "$PACMAN_LIST")
    
    if [ -n "$PACMAN_PKGS" ]; then
        echo -e "${YELLOW}Pakker som vil bli installert:${NC}"
        echo "$PACMAN_PKGS" | tr '\n' ' '
        echo ""
        echo ""
        
        read -p "Fortsette med installasjon? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Konverter newlines til space for pacman
            PKG_STRING=$(echo "$PACMAN_PKGS" | tr '\n' ' ')
            
            echo ""
            echo -e "${GREEN}Installerer...${NC}"
            sudo pacman -S --needed --noconfirm $PKG_STRING
            
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}✓ Pacman pakker installert${NC}"
            else
                echo ""
                echo -e "${RED}✗ Noen pakker feilet${NC}"
            fi
        else
            echo -e "${YELLOW}Hoppet over pacman pakker${NC}"
        fi
    else
        echo -e "${YELLOW}Ingen pacman pakker å installere${NC}"
    fi
else
    echo -e "${YELLOW}Ingen pacman-packages.txt fil funnet${NC}"
fi

echo ""

# Sjekk om AUR helper er installert
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}Ingen AUR helper (yay/paru) funnet${NC}"
    echo -e "${YELLOW}Vil du installere yay? (y/n)${NC}"
    read -p "> " install_yay
    
    if [[ "$install_yay" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installerer yay...${NC}"
        
        # Install dependencies
        sudo pacman -S --needed --noconfirm base-devel git
        
        # Clone og installer yay
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd "$SCRIPT_DIR"
        
        if command -v yay &> /dev/null; then
            echo -e "${GREEN}✓ yay installert${NC}"
        else
            echo -e "${RED}✗ yay installasjon feilet${NC}"
            echo -e "${YELLOW}Hopper over AUR pakker${NC}"
            exit 0
        fi
    else
        echo -e "${YELLOW}Hopper over AUR pakker${NC}"
        exit 0
    fi
fi

# Installer AUR pakker
if [ -f "$AUR_LIST" ]; then
    echo ""
    echo -e "${CYAN}=== Installerer AUR pakker ===${NC}"
    echo ""
    
    AUR_PKGS=$(read_package_list "$AUR_LIST")
    
    if [ -n "$AUR_PKGS" ]; then
        echo -e "${YELLOW}Pakker som vil bli installert:${NC}"
        echo "$AUR_PKGS" | tr '\n' ' '
        echo ""
        echo ""
        
        read -p "Fortsette med installasjon? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Installer én av gangen (AUR kan være tregt)
            while IFS= read -r pkg; do
                if [ -n "$pkg" ]; then
                    echo ""
                    echo -e "${GREEN}Installerer: $pkg${NC}"
                    
                    if command -v yay &> /dev/null; then
                        # --answerdiff=None og --answerclean=None håndterer AUR-spørsmål
                        # uten å henge seg opp slik --noconfirm gjør med visse pakker (f.eks hdrop-git)
                        yay -S --needed --answerdiff=None --answerclean=None "$pkg"
                    elif command -v paru &> /dev/null; then
                        paru -S --needed --noconfirm "$pkg"
                    fi
                fi
            done <<< "$AUR_PKGS"
            
            echo ""
            echo -e "${GREEN}✓ AUR pakker installert${NC}"
        else
            echo -e "${YELLOW}Hoppet over AUR pakker${NC}"
        fi
    else
        echo -e "${YELLOW}Ingen AUR pakker å installere${NC}"
    fi
else
    echo -e "${YELLOW}Ingen aur-packages.txt fil funnet${NC}"
fi

echo ""
echo -e "${GREEN}=== Installasjon fullført! ===${NC}"
echo ""
echo -e "${YELLOW}Tips:${NC}"
echo "  - Rediger pacman-packages.txt for å legge til/fjerne pakker"
echo "  - Rediger aur-packages.txt for å legge til/fjerne AUR pakker"
echo "  - Kjør scriptet igjen for å installere nye pakker"
echo "  - Pakker som allerede er installert hoppes over (--needed)"
