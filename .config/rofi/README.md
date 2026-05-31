# Rofi Configuration

Application launcher and menu system.

## Usage

### Application Launcher
```bash
rofi -show drun
```

**Keybinding:** `Mod+d` (in Sway)

### Window Switcher
```bash
rofi -show window
```

### Run Command
```bash
rofi -show run
```

## Custom Scripts

### Restart Rice Menu (`scripts/restart-rice-menu.sh`)
Menu to restart various components of the rice.

**Options:**
- Restart Waybar
- Restart Eww
- Restart Mako
- Reload Sway config
- Restart all

**Usage:**
```bash
~/.config/rofi/scripts/restart-rice-menu.sh
```

## Themes

Rofi themes are located in the rofi config directory.

### Change Theme
Edit `config.rasi`:
```
@theme "theme-name"
```

### Available Themes
List themes:
```bash
rofi-theme-selector
```

## Customization

### Window Size
```
configuration {
  width: 600;
  lines: 10;
}
```

### Font
```
configuration {
  font: "JetBrainsMono Nerd Font 10";
}
```

### Colors
Modify theme file or create custom theme in `~/.config/rofi/themes/`.

## Integration

### Wi-Fi Manager
The eww control center uses rofi for Wi-Fi network selection.

**Script:** `.config/eww/scripts/wifi_rofi.sh`

**Features:**
- Network list with signal strength
- Security type indicators
- Connect/disconnect/forget
- Hidden network support

## Troubleshooting

### Rofi not showing
```bash
# Test rofi
rofi -show drun

# Check for errors
rofi -show drun -no-lazy-grab -show-icons
```

### Theme not loading
```bash
# Validate config
rofi -dump-config

# Reset to default
rm ~/.config/rofi/config.rasi
```

### Icons not showing
Install icon theme:
```bash
sudo pacman -S papirus-icon-theme
```

## Dependencies

```bash
# Core
rofi

# For icons
papirus-icon-theme

# Fonts
ttf-jetbrains-mono-nerd
```

## Tips

### Fuzzy Search
Rofi supports fuzzy matching by default. Type partial matches to filter.

### Multi-select
Use `Shift+Enter` to keep rofi open after selection (in some modes).

### Custom Modi
You can create custom rofi modi (modes) with scripts. See `scripts/` for examples.
