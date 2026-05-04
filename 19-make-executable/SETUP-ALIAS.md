# Setup for make-executable script

## Installasjon

### 1. Kopier script til riktig sted
```bash
mkdir -p ~/.config/hypr/scripts
cp make-executable.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/make-executable.sh
```

### 2. Legg til alias i din shell config

#### For Bash (~/.bashrc)
```bash
echo "alias run='~/.config/hypr/scripts/make-executable.sh'" >> ~/.bashrc
source ~/.bashrc
```

#### For Zsh (~/.zshrc)
```bash
echo "alias run='~/.config/hypr/scripts/make-executable.sh'" >> ~/.zshrc
source ~/.zshrc
```

#### For Fish (~/.config/fish/config.fish)
```bash
echo "alias run='~/.config/hypr/scripts/make-executable.sh'" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

## Bruk

### Gjør én fil kjørbar
```bash
run ~/scripts/install.sh
```

### Gjør alle .sh filer i en mappe kjørbare
```bash
run ~/Github/Arch-Linux-Hyprland-Install-Scripts
```

### Gjør alle .sh i nåværende mappe kjørbare
```bash
cd ~/mitt-prosjekt
run
```

## Eksempler

```bash
# Eksempel 1: Enkeltfil
run ~/Downloads/setup.sh

# Eksempel 2: Hele Github prosjektet
run ~/Github/Arch-Linux-Hyprland-Install-Scripts

# Eksempel 3: Nåværende mappe
cd ~/scripts
run

# Eksempel 4: Med full path
run /home/archruud/.config/hypr/scripts/
```

## Test at det virker

```bash
# Sjekk at alias fungerer
which run

# Test på en mappe
run ~/Github/Arch-Linux-Hyprland-Install-Scripts
```
