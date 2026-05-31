# Waybar Configuration

Status bar for Sway with custom modules and styling.

## Modules

### Left Section
- **Workspaces** - Sway workspace indicator with click support

### Center Section
- **Spotify** - Current playing track (local or remote)
- **NordVPN** - VPN connection status

### Right Section
- **Microphone** - Mic status (muted/active/idle)
- **Pulseaudio** - Volume control with click to mute
- **Network** - Wi-Fi/Ethernet status
- **Memory** - RAM usage
- **Battery** - Battery level and charging status
- **Clock** - Date and time

## Module Details

### Spotify (`custom/spotify`)
Shows currently playing track from spotify_player or Spotify API.

**Script:** `.config/polybar/scripts/spotify-playerctl.sh`

**Click action:** Opens eww music widget

**Format:**
- Playing: `󰐊 Artist - Title`
- Paused: ` Artist - Title`
- Offline: `󰎇 MUSIC PLAYER: [OFF]`

### NordVPN (`custom/nordvpn`)
Displays VPN connection status.

**Script:** `.config/waybar/scripts/nordvpn-status.sh`

**States:**
- Connected: `󰌾 VPN: [ACTIVE]` (shows interface and IP)
- Disconnected: `󰌿 VPN: [OFF]`

### Microphone (`custom/mic`)
Shows microphone status.

**Script:** `.config/waybar/scripts/mic-status.sh`

**States:**
- Muted: Red icon
- Active (in use): Green icon
- Idle: Gray icon

### Battery
Shows battery percentage and charging status.

**States:**
- Charging: ` 75%`
- Discharging: ` 75%`
- Full: ` 100%`

**Warning:** Shows notification at 20% and 10%

## Customization

### Change Module Order
Edit `config.jsonc`:
```json
"modules-left": ["sway/workspaces"],
"modules-center": ["custom/spotify", "custom/nordvpn"],
"modules-right": ["custom/mic", "pulseaudio", "network", "memory", "battery", "clock"]
```

### Modify Update Intervals
```json
"custom/spotify": {
  "interval": 5,  // Update every 5 seconds
  ...
}
```

### Styling
Edit `style.css` to change colors, fonts, spacing.

**Example - Change background:**
```css
window#waybar {
  background-color: #1e1e2e;
}
```

## Scripts

### `spotify-playerctl.sh`
Checks local playerctl first, then Spotify API for remote playback.

### `nordvpn-status.sh`
Checks for active VPN interfaces (nordlynx, tun0).

### `mic-status.sh`
Uses pactl to check microphone mute status and usage.

### `open_spotify_widget.sh`
Toggles eww music widget.

### `restart-waybar.sh`
Kills and restarts waybar (useful after config changes).

## Troubleshooting

### Waybar not starting
```bash
# Check for errors
waybar -l debug

# Restart
killall waybar && waybar &
```

### Module not updating
1. Check script is executable: `ls -la ~/.config/waybar/scripts/`
2. Test script manually: `~/.config/waybar/scripts/script-name.sh`
3. Check interval setting in config

### Spotify module shows [OFF] but music is playing
1. Verify spotify_player is running: `playerctl status --player=spotify_player`
2. Check Spotify API credentials: `cat ~/.config/eww/spotify.env`
3. Test script: `~/.config/polybar/scripts/spotify-playerctl.sh`

### Icons not showing
Install Nerd Font:
```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

Then restart waybar.

## Configuration Files

- `config.jsonc` - Module configuration
- `style.css` - Styling and colors
- `scripts/` - Custom module scripts

## Dependencies

```bash
# Core
waybar

# Module dependencies
playerctl curl jq  # Spotify
pactl              # Microphone, audio
nmcli              # Network
ip                 # VPN status

# Fonts
ttf-jetbrains-mono-nerd
```

## Tips

### Reload After Changes
```bash
~/.config/waybar/scripts/restart-waybar.sh
```

### Hide Waybar
```bash
killall -SIGUSR1 waybar  # Toggle visibility
```

### Multiple Bars
You can define multiple bars in `config.jsonc` for multi-monitor setups.
