# Arch Linux Hyprland Install Scripts

A modular, automated installation system for setting up Hyprland on Arch Linux with a comprehensive collection of tools and configurations.

## Overview

This repository contains a collection of installation scripts designed to help you quickly set up a fully functional Hyprland desktop environment on Arch Linux. Each component is modular and can be installed independently or as part of the complete system.

## Features

- **Modular Design**: Install only what you need, or install everything at once
- **Automated Installation**: Each module handles package installation and configuration
- **Comprehensive Coverage**: Includes window management, wallpapers, notifications, lock screen, and more
- **Easy to Customize**: Clear structure makes it simple to modify or extend
- **Battle-Tested**: Based on real-world usage and refined configurations

## Prerequisites

- Fresh or existing Arch Linux installation
- Basic knowledge of Linux command line
- Git installed (`sudo pacman -S git`)
- Internet connection

## Quick Start

### Clone the Repository

```bash
git clone https://github.com/archruud/Arch-Linux-Hyprland-Install-Scripts.git
cd Arch-Linux-Hyprland-Install-Scripts
```

### Run the Installer

```bash
chmod +x run-installer.sh
./run-installer.sh
```

The installer will guide you through the installation process, allowing you to select which components to install.

## Repository Structure

```
.
├── 01-base/                 # Core Hyprland installation
├── 02-post-install/         # Post-installation configurations
├── 03-swww/                 # Wallpaper daemon
├── 04-hypridle/             # Idle management
├── 05-hyprlock/             # Screen lock
├── 06-wlogout/              # Logout menu
├── 07-power-button/         # Power button configuration
├── 08-notifications/        # Notification system
├── 09-dropdown-terminal/    # Dropdown terminal setup
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
├── 25-scripts-and-files/    # Additional scripts and configuration files
├── install-order.conf       # Installation order configuration
└── run-installer.sh         # Main installer script
```

## Components

### Core Components

- **Hyprland**: Dynamic tiling Wayland compositor
- **Waybar**: Highly customizable status bar
- **SDDM**: Display manager for login

### Functionality

- **SWWW**: Wallpaper daemon for dynamic backgrounds
- **Hypridle**: Idle daemon for automatic actions
- **Hyprlock**: Screen locking utility
- **Wlogout**: Logout menu with power options

### Utilities

- **Rofi**: Application launcher and menu system
- **Fuzzel**: Alternative launcher and color picker
- **Kitty**: GPU-accelerated terminal emulator
- **Dunst**: Lightweight notification daemon
- **Screenshots**: Complete screenshot solution with editing tools
- **Make Executable**: Automatically sets correct permissions for all scripts

### Networking

- Network management tools and configurations

## Installation Methods

### Method 1: Interactive Installer (Recommended)

```bash
./run-installer.sh
```

Follow the prompts to select which components you want to install.

### Method 2: Manual Installation

Navigate to any component directory and run its installation script:

```bash
cd 01-base
./install.sh
```

### Method 3: Custom Order

Edit `install-order.conf` to define your custom installation order, then run the installer.

## Configuration

After installation, configuration files will be placed in standard locations:

- `~/.config/hypr/` - Hyprland configuration
- `~/.config/waybar/` - Waybar configuration
- `~/.config/kitty/` - Kitty terminal configuration
- `~/.config/rofi/` - Rofi configuration
- Additional configs in respective `~/.config/` directories

## Post-Installation

1. **Reboot or restart your display manager**:
   ```bash
   sudo systemctl restart sddm
   ```

2. **Select Hyprland** at the login screen

3. **Review keybindings**: Check `~/.config/hypr/hyprland.conf` for default keybindings

4. **Customize**: Modify configuration files to match your preferences

## Keybindings Quick Reference

Run the quick reference script for a list of keybindings:

```bash
./quick-reference.sh
```

Common keybindings:
- `Super + Q` - Close window
- `Super + Enter` - Open terminal
- `Super + D` - Application launcher
- `Super + L` - Lock screen
- And many more...

## Troubleshooting

### Display Issues

If you encounter display issues, check your `hyprland.conf` for proper monitor configuration:

```bash
nano ~/.config/hypr/hyprland.conf
```

### Missing Dependencies

If any components fail to work, ensure all dependencies are installed:

```bash
pacman -Qi <package-name>
```

### Scripts Not Executable

The 19-make-executable module handles this automatically during installation. If you need to fix permissions manually:

```bash
cd 19-make-executable
./make-executable.sh
```

## Customization

Each component is designed to be easily customizable:

1. Navigate to the configuration directory
2. Edit the relevant configuration files
3. Reload Hyprland with `Super + Shift + R` or restart

## Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest new features
- Submit pull requests
- Share your configurations

## Credits

Created and maintained by [Archruud](https://github.com/archruud)

Built with inspiration from the Hyprland community and various dotfile repositories.

## License

This project is open source. Feel free to use, modify, and distribute as needed.

## Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Check existing issues for solutions
- Review the Hyprland wiki: https://wiki.hyprland.org

## Additional Resources

- [Hyprland Official Website](https://hyprland.org)
- [Arch Linux Wiki](https://wiki.archlinux.org)
- [Waybar Documentation](https://github.com/Alexays/Waybar)
- [Rofi Documentation](https://github.com/davatorium/rofi)

---

**Note**: This setup is based on real-world usage and continuously updated. While it works well for the maintainer's setup, your mileage may vary depending on your hardware and preferences. Always review scripts before running them on your system.
