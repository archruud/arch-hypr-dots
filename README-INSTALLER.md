# Hyprland Installation Guide

## Overview

This guide will walk you through the installation process of a complete Hyprland desktop environment on Arch Linux using the automated installer script. The installation is modular, allowing you to select which components you want to install.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [What Gets Installed](#what-gets-installed)
4. [Post-Installation](#post-installation)
5. [Troubleshooting](#troubleshooting)
6. [Manual Installation](#manual-installation)

## Prerequisites

Before running the installer, ensure you have:

- **Arch Linux** installed and running (fresh or existing installation)
- **Internet connection** for downloading packages
- **Git** installed: `sudo pacman -S git`
- **Basic terminal knowledge**
- **Recommended**: At least 10GB of free disk space

### For NVIDIA GPU Users

If you have an NVIDIA GPU, the installer will handle driver installation automatically. However, be aware that:
- NVIDIA drivers can sometimes cause issues with Wayland
- The installer includes necessary NVIDIA-specific configurations
- GTX 900 series or newer is recommended

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/archruud/Arch-Linux-Hyprland-Install-Scripts.git
cd Arch-Linux-Hyprland-Install-Scripts
```

### 2. Make the Installer Executable

```bash
chmod +x run-installer.sh
```

### 3. Run the Installer

```bash
./run-installer.sh
```

### 4. Follow the Interactive Prompts

The installer will guide you through:
- Selecting which components to install
- Configuring system settings
- Setting up your preferred applications
- Installing additional utilities

### 5. Installation Process

The installer will:
- Check for existing installations
- Create backups of existing configurations
- Install required packages from official repos and AUR
- Copy configuration files to appropriate locations
- Set correct file permissions
- Enable necessary system services

### 6. Reboot

After installation completes:

```bash
sudo systemctl enable sddm
sudo systemctl reboot
```

## What Gets Installed

### Core System (01-base)
- **Hyprland** - Dynamic tiling Wayland compositor
- **Essential Wayland tools**
- **Base system utilities**

### Post-Installation Setup (02-post-install)
- System configuration
- User environment setup
- Performance optimizations

### Display & Wallpapers (03-swww)
- **SWWW** - Wallpaper daemon for Wayland
- Dynamic wallpaper support
- Transition effects

### Session Management
- **Hypridle (04-hypridle)** - Idle management daemon
- **Hyprlock (05-hyprlock)** - Screen lock utility
- **Wlogout (06-wlogout)** - Logout menu with power options
- **Power Button Handler (07-power-button)** - Power button configuration

### Notifications & Alerts
- **Notification System (08-notifications)** - Basic notification setup
- **Dunst (16-dunst)** - Notification daemon

### Terminal & Shell
- **Dropdown Terminal (09-dropdown-terminal)** - Quick-access terminal
- **Kitty (12-kitty)** - GPU-accelerated terminal emulator

### Window Management
- **Overview (10-overview)** - Workspace overview functionality
- **Fuzzel & Hyprpicker (11-fuzzel-hyprpicker)** - Application launcher and color picker

### Application Launchers
- **Rofi (13-rofi)** - Advanced application launcher and menu system

### Screenshots & Media
- **Screenshot Tools (14-screenshots)** - Complete screenshot solution with grim, slurp, and swappy

### Display Manager
- **SDDM (15-sddm)** - Display manager for login screen
- Custom SDDM themes (optional)

### Status Bar
- **Waybar (17-waybar)** - Highly customizable status bar
- Pre-configured modules for:
  - Workspaces
  - System resources
  - Network status
  - Audio controls
  - Date and time
  - Custom modules

### Networking
- **Network Tools (18-network)** - Network management utilities
- NetworkManager integration

### Scripts & Configuration
- **Scripts and Files (25-scripts-and-files)** - Additional helper scripts and configurations
- Custom Hyprland configuration
- Utility scripts in `~/.local/share/bin`

### Permissions
- **Make Executable (19-make-executable)** - Automatically sets correct permissions for all scripts

### Additional Utilities (99-utilities)
- File managers
- System monitors
- Media players
- Other useful tools

## Post-Installation

### First Login

1. **Select Hyprland** from the session menu at login
2. **Log in** with your user credentials
3. **Hyprland will start** with the default configuration

### Initial Configuration

Upon first login, you should:

#### 1. Check Monitor Setup
Edit `~/.config/hypr/hyprland.conf` to configure your monitors:

```bash
nano ~/.config/hypr/hyprland.conf
```

Look for the monitor section and adjust to your setup:

```
monitor=,preferred,auto,1
```

#### 2. Test Keybindings

Default keybindings (Super = Windows key):
- `Super + Enter` - Open terminal
- `Super + D` - Application launcher (Rofi)
- `Super + Q` - Close window
- `Super + L` - Lock screen
- `Super + M` - Exit menu (Wlogout)
- `Super + V` - Clipboard history
- `Super + Shift + S` - Screenshot area
- `Super + 1-9` - Switch workspaces
- `Super + Shift + 1-9` - Move window to workspace

#### 3. Customize Appearance

- **Wallpaper**: Copy your wallpapers to `~/Pictures/Wallpapers/`
- **Waybar**: Edit `~/.config/waybar/config` and `~/.config/waybar/style.css`
- **Rofi**: Customize in `~/.config/rofi/config.rasi`

#### 4. Set Up Applications

Install your preferred applications:

```bash
sudo pacman -S firefox thunar vlc
```

### Configuration Files

All configuration files are located in standard XDG locations:

- **Hyprland**: `~/.config/hypr/`
- **Waybar**: `~/.config/waybar/`
- **Kitty**: `~/.config/kitty/`
- **Rofi**: `~/.config/rofi/`
- **Dunst**: `~/.config/dunst/`
- **Scripts**: `~/.local/share/bin/`

### Backup Your Configs

After customization, back up your configuration:

```bash
cp -r ~/.config/hypr ~/backup/
cp -r ~/.config/waybar ~/backup/
# etc.
```

## Troubleshooting

### Installation Issues

#### Script Fails to Install Package

**Problem**: A package fails to install from AUR or official repos

**Solution**:
1. Update your system: `sudo pacman -Syu`
2. Clear package cache: `yay -Sc` or `paru -Sc`
3. Check `/var/log/pacman.log` for errors
4. Try installing the failing package manually

#### Permission Denied Errors

**Problem**: Scripts cannot be executed

**Solution**:
```bash
cd 19-make-executable
./make-executable.sh
```

Or manually:
```bash
find . -name "*.sh" -type f -exec chmod +x {} \;
```

### Runtime Issues

#### Black Screen After Login

**Problem**: Hyprland shows only a black screen

**Solution**:
1. Press `Ctrl + Alt + F2` to switch to TTY
2. Login and check logs: `cat ~/.hyprland/hyprland.log`
3. Check monitor configuration in `~/.config/hypr/hyprland.conf`
4. Verify Hyprland is installed: `pacman -Q hyprland`

#### NVIDIA Issues

**Problem**: Screen tearing, crashes, or poor performance with NVIDIA GPU

**Solution**:
1. Check `~/.config/hypr/hyprland.conf` for NVIDIA environment variables
2. Ensure DRM kernel mode setting is enabled
3. Update NVIDIA drivers: `sudo pacman -S nvidia-dkms nvidia-utils`
4. Add to `/etc/mkinitcpio.conf`: `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
5. Regenerate initramfs: `sudo mkinitcpio -P`

#### Waybar Not Showing

**Problem**: Status bar not visible

**Solution**:
1. Check if Waybar is running: `ps aux | grep waybar`
2. Kill and restart: `pkill waybar && waybar &`
3. Check configuration: `waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css`
4. View logs: `waybar --log-level debug`

#### Screenshots Not Working

**Problem**: Screenshot keybinding doesn't work

**Solution**:
1. Verify tools are installed: `pacman -Q grim slurp swappy`
2. Check keybinding in `~/.config/hypr/hyprland.conf`
3. Test manually: `grim -g "$(slurp)" - | swappy -f -`

#### Audio Issues

**Problem**: No sound or volume controls not working

**Solution**:
1. Ensure PipeWire is running: `systemctl --user status pipewire`
2. Install pavucontrol: `sudo pacman -S pavucontrol`
3. Check audio devices: `pactl list sinks`
4. Restart PipeWire: `systemctl --user restart pipewire`

### Display Issues

#### Monitor Not Detected

**Problem**: External monitor not working

**Solution**:
1. List displays: `hyprctl monitors`
2. Edit monitor configuration in `~/.config/hypr/hyprland.conf`
3. Reload Hyprland: `Super + Shift + R` or `hyprctl reload`

#### Scaling Issues

**Problem**: UI elements too large or small

**Solution**:
Edit monitor configuration:
```
monitor=,preferred,auto,1.5  # Adjust scale factor (1.0, 1.25, 1.5, 2.0)
```

## Manual Installation

If you prefer to install components individually:

### Installing Single Components

Navigate to any component directory and run its installation script:

```bash
cd 01-base
./install-base.sh
```

### Custom Installation Order

1. Edit `install-order.conf` to define your installation sequence
2. Comment out (with `#`) components you don't want
3. Run the main installer: `./run-installer.sh`

### Minimal Installation

For a minimal setup, install only:
1. 01-base (Hyprland core)
2. 15-sddm (Display manager)
3. 12-kitty (Terminal)

Then add components as needed.

## Getting Help

If you encounter issues:

1. **Check Logs**:
   - Hyprland: `~/.hyprland/hyprland.log`
   - System: `journalctl -xe`
   - Package manager: `/var/log/pacman.log`

2. **Community Resources**:
   - Hyprland Wiki: https://wiki.hyprland.org
   - Arch Wiki: https://wiki.archlinux.org
   - GitHub Issues: https://github.com/archruud/Arch-Linux-Hyprland-Install-Scripts/issues

3. **Quick Reference**:
   ```bash
   ./quick-reference.sh
   ```

## Tips and Recommendations

### Performance

- Enable hardware acceleration for your GPU
- Use lightweight applications when possible
- Monitor resource usage with `btop` or `htop`

### Customization

- Explore Hyprland Wiki for advanced configurations
- Check out other users' dotfiles for inspiration
- Back up configs before major changes

### Maintenance

- Update regularly: `yay -Syu` or `paru -Syu`
- Clean package cache periodically: `yay -Sc`
- Check for orphaned packages: `pacman -Qtdq`

### Security

- Use a strong password for screen lock
- Keep system updated
- Review installed packages regularly

---

**Enjoy your new Hyprland setup!** 🚀

For additional help or to contribute, visit: https://github.com/archruud/Arch-Linux-Hyprland-Install-Scripts
