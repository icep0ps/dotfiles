# dotfiles

Configuration files for my Arch Linux / Sway setup.

## Stack

| Component       | Tool                        |
|-----------------|-----------------------------|
| Compositor      | Sway                        |
| Bar             | Waybar                      |
| Widgets         | Eww                         |
| Notifications   | Mako                        |
| Launcher        | Rofi                        |
| Terminal        | Foot                        |
| Editor          | Neovim                      |
| Shell           | Zsh                         |

## Features

- **Eww widgets**: Multi-device music player (Spotify via playerctl + Web API), control center with Wi-Fi, Bluetooth, DND, power profile, and disk usage
- **Waybar**: Workspace indicator, mic status, battery, network, memory, VPN status, Spotify integration
- **Rofi-based Wi-Fi manager**: Signal strength, security icons, connect/disconnect/forget support
- **Screenshot tool**: Region select with slurp, auto-saved and copied to clipboard
- **Power notifications**: Battery alerts via Mako on AC plug/unplug

## Quick Start

### Health Check
Validate your setup and check for missing dependencies:
```sh
~/.config/scripts/health-check.sh
```

### Component Documentation
- [Eww Widgets](.config/eww/README.md) - Music player, control center
- [Sway](.config/sway/README.md) - Keybindings and configuration
- [Waybar](.config/waybar/README.md) - Status bar modules
- [Rofi](.config/rofi/README.md) - Launcher and menus
- [Spotify Widget](.config/eww/SPOTIFY_WIDGET_README.md) - Multi-device setup

## Dependencies

```
sway swaybg autotiling foot rofi mako eww waybar
playerctl spotify-player grim slurp wl-copy
nmcli bluetoothctl pactl tlp libnotify curl jq
ttf-jetbrains-mono-nerd
```

## Setup

```sh
git clone https://github.com/icep0ps/dotfiles ~/dotfiles
cd ~/dotfiles
stow --target="$HOME" .
```

### Spotify Multi-Device Setup
To enable Spotify playback from any device (phone, web, etc.):
```sh
~/.config/eww/scripts/spotify_auth_setup.sh
```

## Utilities

### Backup & Restore
```sh
# Create backup
~/.config/scripts/backup.sh

# Restore from backup
~/.config/scripts/restore.sh <backup-file.tar.gz>
```

### Health Check
```sh
~/.config/scripts/health-check.sh
```

## Screenshots

![Home](screenshots/1.png)
![Terminals](screenshots/2.png)
![Neovim](screenshots/3.png)
