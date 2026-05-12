
# Arch Linux Hyprland Install Scripts

A modular, automated installation system for setting up Hyprland on Arch Linux with a comprehensive collection of tools and configurations.

## Overview

This repository contains a collection of installation scripts designed to help you quickly set up a fully functional Hyprland desktop environment on Arch Linux. Each component is modular and can be installed independently or as part of the complete system.

## Features

- **Modular Design**: Install only what you need, or install everything at once
- **Automated Installation**: Each module handles package installation and configuration
- **Comprehensive Coverage**: Includes window management, wallpapers, notifications, lock screen, GPU drivers and more
- **GPU Auto-Detection**: Automatically detects Intel iGPU and Intel Arc discrete GPU
- **Local AI Support**: Optional Ollama + Open WebUI for private, offline AI
- **Easy to Customize**: Clear structure makes it simple to modify or extend
- **Battle-Tested**: Based on real-world usage and refined configurations

## Prerequisites

- Fresh or existing Arch Linux installation
- Basic knowledge of Linux command line
- Git installed (`sudo pacman -S git`)
- AUR helper installed (`yay` or `paru`)
- Internet connection

## Quick Start

### Clone the Repository

```bash
git clone https://github.com/archruud/arch-hypr-dots.git
cd arch-hypr-dots
```

### Run the Installer

```bash
chmod +x run-install.sh
./run-install.sh
```

The installer will guide you through the installation process, allowing you to select which components to install.

## Repository Structure

```
.
├── 01-base/                 # Core Hyprland installation
├── 02-post-install/         # Post-installation configurations
├── 03-awww/                 # Wallpaper daemon (awww — erstatter swww)
├── 04-hypridle/             # Idle management
├── 05-hyprlock/             # Screen lock
├── 06-wlogout/              # Logout menu
├── 07-power-button/         # Power button configuration
├── 08-notifications/        # Notification system
├── 09-dropdown-terminal/    # hdrop (valgfritt alternativ — se README der)
├── 10-overview/             # Workspace overview
├── 11-fuzzel-hyprpicker/    # Application launcher and color picker
├── 12-kitty/                # Kitty terminal configuration
├── 13-rofi/                 # Application launcher
├── 14-screenshots/          # Screenshot tools and configuration
├── 15-sddm/                 # Display manager (SDDM)
├── 16-dunst/                # Notification daemon
├── 17-waybar/               # Status bar
├── 18-network/              # Network configuration
├── 19-make-executable/      # Script permissions setup
├── 20-gpu-drivers/          # GPU drivers: Intel iGPU + Intel Arc AI
├── 25-scripts-and-files/    # Additional scripts and configuration files
├── install-order.conf       # Installation order configuration
├── run-install.sh           # Main installer script
└── check-installation.sh    # Verify installation
```

## Components

### Core Components

- **Hyprland**: Dynamic tiling Wayland compositor
- **Waybar**: Highly customizable status bar
- **SDDM**: Display manager for login

### Functionality

- **AWWW**: Wallpaper daemon for dynamic backgrounds (erstatter swww)
- **Hypridle**: Idle daemon for automatic actions
- **Hyprlock**: Screen locking utility
- **Wlogout**: Logout menu with power options

### GPU Drivers (20-gpu-drivers)

Støtter følgende oppsett automatisk:

| Maskin | GPU | Hva installeres |
|---|---|---|
| Dell Pro 16 | Intel integrert | Mesa, Vulkan, VA-API |
| Lenovo (12. gen) | Intel integrert | Mesa, Vulkan, VA-API |
| Medion Erazer Major X10 | Intel Iris Xe + **Arc A730M 12GB** | iGPU-drivere + Arc AI-drivere |

**Intel Arc A730M AI-stack:**
- Intel Compute Runtime (OpenCL + Level Zero)
- Intel Graphics Compiler
- PyTorch XPU (Intel Arc GPU-akselerasjon)
- Transformers, Diffusers, LangChain, og mer
- Ollama + Open WebUI (valgfritt)

### Local AI (Ollama + Open WebUI)

- **Ollama**: Lokal LLM-motor med Intel Arc XPU-støtte
- **Open WebUI**: ChatGPT-lignende grensesnitt, støtter RAG og dokumentanalyse
- Installeres som del av `20-gpu-drivers`

### Utilities

- **Rofi**: Application launcher og menysystem
- **Fuzzel**: Alternativ launcher og fargevelger
- **Kitty**: GPU-akselerert terminalemulator
- **Dropterminal**: JaKooLit sin dropdown terminal — følger aktivt workspace, slide-animasjon
- **Dunst**: Lettvekts varslingsdaemon
- **Screenshots**: Komplett skjermbildeløsning med redigeringsverktøy
- **Make Executable**: Setter automatisk riktige rettigheter for alle scripts

### Networking

- Nettverksadministrasjon og konfigurasjoner

## Installation Methods

### Method 1: Interactive Installer (Recommended)

```bash
./run-install.sh
```

Følg instruksjonene for å velge hvilke komponenter du vil installere.

### Method 2: Manual Installation

Naviger til en komponent-mappe og kjør installasjonsskriptet:

```bash
cd 20-gpu-drivers
./install-gpu-driver.sh
```

### Method 3: Custom Order

Rediger `install-order.conf` for å definere din egen installasjonsrekkefølge, og kjør deretter installeren.

## GPU Driver Details

### Automatisk GPU-oppdagelse

`install-gpu-driver.sh` oppdager automatisk hvilke GPUer som er tilstede:

```bash
cd 20-gpu-drivers
./install-gpu-driver.sh
```

### Intel integrert GPU (alle maskiner)

Installerer: `mesa`, `vulkan-intel`, `intel-media-driver`, `libva-utils`, `vulkan-tools`

### Intel Arc A730M (Medion Erazer Major X10)

Installerer i tillegg:
- `intel-compute-runtime` — OpenCL + Level Zero
- `level-zero-loader` — AI-akselerasjon
- `intel-graphics-compiler-bin` — forhåndsbygd (sparer 30-60 min)
- PyTorch XPU i eget venv: `~/.venvs/intel-ai`

Kernel-parametere settes automatisk:
```
xe.force_probe=56a0 i915.force_probe=!56a0
```

### Ollama modeller

Anbefalte startmodeller (velges under installasjon):

| Modell | Størrelse | Beskrivelse |
|---|---|---|
| `qwen2.5:7b` | ~4.7 GB | Smart og rask — anbefalt |
| `llama3.2:3b` | ~2.0 GB | Lynrask, bra for testing |
| `qwen2.5:14b` | ~9.0 GB | Kraftig, bedre svar |
| `deepseek-r1:7b` | ~4.7 GB | Resonnering og AI-tenking |

## Configuration

Etter installasjon plasseres konfigurasjonsfiler i standard lokasjoner:

- `~/.config/hypr/` — Hyprland konfigurasjon + GPU env
- `~/.config/hypr/scripts/` — Alle scripts inkl. `awww-wallpaper.sh`
- `~/.config/hypr/wallpapers/` — Bakgrunnsbilder
- `~/.config/waybar/` — Waybar konfigurasjon
- `~/.config/kitty/` — Kitty terminalkonfigurasjon
- `~/.config/rofi/` — Rofi konfigurasjon
- `~/.venvs/intel-ai/` — Python AI virtualenv (kun Medion)

## Post-Installation

1. **Reboot**:
   ```bash
   sudo reboot
   ```

2. **Velg Hyprland** i SDDM loginskjerm

3. **Verifiser installasjon**:
   ```bash
   ./check-installation.sh
   ```

4. **GPU-status** (kun Arc A730M):
   ```bash
   xpu-smi
   vainfo
   vulkaninfo --summary
   ```

5. **Aktiver AI-venv** (kun Medion):
   ```bash
   source ~/.venvs/intel-ai/bin/activate
   python -c "import torch; print(torch.xpu.is_available())"
   ```

## Keybindings Quick Reference

Vanlige keybindinger:
- `Super + Q` — Lukk vindu
- `Super + Enter` — Åpne terminal
- `Super + D` — Programstarter
- `Super + L` — Lås skjerm
- `Super + Shift + R` — Reload Hyprland
- `Super + Shift + Return` — Toggle dropdown terminal
- `Super + Shift + PIL` — Endre størrelse på dropdown terminal

## Troubleshooting

### Display Issues

```bash
nano ~/.config/hypr/hyprland.conf
```

### Missing Dependencies

```bash
pacman -Qi <package-name>
```

### Scripts Not Executable

```bash
cd 19-make-executable
./make-executable.sh
```

### AWWW starter ikke (wallpaper)

```bash
# Sjekk om daemon kjører
pgrep -x awww-daemon

# Start manuelt
awww-daemon &
awww img ~/.config/hypr/wallpapers/ARCHRUUD_1920x1200.png --transition-type fade
```

### Intel Arc GPU ikke oppdaget

```bash
# Sjekk at xe-driver er aktiv
lspci -k | grep -A3 "Arc"

# Sjekk render-enheter
ls /dev/dri/

# Sjekk at bruker er i render-gruppen
groups $USER | grep render
```

### Ollama + Open WebUI

```bash
# Sjekk Ollama status
curl http://localhost:11434

# List installerte modeller
ollama list

# Open WebUI (Docker)
docker ps | grep open-webui
```

## Customization

Hver komponent er designet for enkel tilpasning:

1. Naviger til konfigurasjonsmappen
2. Rediger relevante konfigurasjonsfiler
3. Reload Hyprland med `Super + Shift + R`

## Contributing

Bidrag er velkomne! Gjerne:

- Rapporter bugs
- Foreslå nye funksjoner
- Send pull requests
- Del dine konfigurasjoner

## Credits

Opprettet og vedlikeholdt av [Archruud](https://github.com/archruud)

Bygget med inspirasjon fra Hyprland-fellesskapet og diverse dotfile-repositories.

## License

Dette prosjektet er open source. Bruk, modifiser og distribuer fritt.

## Support

For problemer, spørsmål eller forslag:

- Åpne en issue på GitHub
- Sjekk eksisterende issues for løsninger
- Se Hyprland wiki: https://wiki.hyprland.org

## Additional Resources

- [Hyprland Official Website](https://hyprland.org)
- [Arch Linux Wiki](https://wiki.archlinux.org)
- [AWWW Wallpaper Daemon](https://codeberg.org/LGFae/awww)
- [Waybar Documentation](https://github.com/Alexays/Waybar)
- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Ollama](https://ollama.com)
- [Open WebUI](https://github.com/open-webui/open-webui)

---

**Note**: Dette oppsettet er basert på faktisk bruk og oppdateres kontinuerlig.
Fungerer godt for vedlikeholderens oppsett, men resultater kan variere avhengig av
hardware og preferanser. Les alltid gjennom scripts før du kjører dem.
