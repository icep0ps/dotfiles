# Sway Configuration

Wayland compositor configuration for tiling window management.

## Keybindings

### Core

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (foot) |
| `Mod+Shift+q` | Kill focused window |
| `Mod+d` | Application launcher (rofi) |
| `Mod+Shift+c` | Reload configuration |
| `Mod+Shift+e` | Exit sway |

### Window Management

| Key | Action |
|-----|--------|
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window left/down/up/right |
| `Mod+b` | Split horizontal |
| `Mod+v` | Split vertical |
| `Mod+f` | Toggle fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Space` | Toggle focus floating/tiling |
| `Mod+a` | Focus parent container |

### Layouts

| Key | Action |
|-----|--------|
| `Mod+s` | Stacking layout |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |

### Workspaces

| Key | Action |
|-----|--------|
| `Mod+1-9` | Switch to workspace 1-9 |
| `Mod+Shift+1-9` | Move window to workspace 1-9 |

### Media & System

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `Mod+m` | Toggle music widget |
| `Print` | Screenshot (region select) |

### Scratchpad

| Key | Action |
|-----|--------|
| `Mod+Shift+minus` | Move to scratchpad |
| `Mod+minus` | Show scratchpad |

## Features

### Auto-tiling
Automatically alternates between horizontal and vertical splits.

**Disable:**
```bash
# Comment out in config:
# exec autotiling
```

### Screenshot Tool
Region selection with slurp, saves to `~/Pictures/screenshots/` and copies to clipboard.

**Script:** `.config/sway/screenshot.sh`

### Gaps & Borders
- Inner gaps: 5px
- Outer gaps: 5px
- Border width: 2px

**Customize:**
```
gaps inner 5
gaps outer 5
default_border pixel 2
```

## Autostart

Services started on sway launch:
- `waybar` - Status bar
- `mako` - Notifications
- `autotiling` - Auto split direction
- `swaybg` - Wallpaper
- Power monitor (battery notifications)

## Display Configuration

### Multiple Monitors
Edit output configuration in `config`:
```
output HDMI-A-1 resolution 1920x1080 position 0,0
output eDP-1 resolution 1920x1080 position 1920,0
```

**List outputs:**
```bash
swaymsg -t get_outputs
```

### Wallpaper
```
output * bg ~/Pictures/wallpaper.jpg fill
```

## Customization

### Change Modifier Key
```
set $mod Mod4  # Super/Windows key
# or
set $mod Mod1  # Alt key
```

### Font
```
font pango:JetBrainsMono Nerd Font 8
```

### Colors
Window border colors defined in config. Modify the `client.*` lines.

## Troubleshooting

### Waybar not showing
```bash
killall waybar
waybar &
```

### Autotiling not working
```bash
pip install autotiling
```

### Screenshot not working
Install dependencies:
```bash
sudo pacman -S grim slurp wl-clipboard
```

## Dependencies

```bash
# Core
sway swaybg swaylock swayidle

# Tools
waybar mako rofi foot
grim slurp wl-clipboard
autotiling

# Fonts
ttf-jetbrains-mono-nerd
```
