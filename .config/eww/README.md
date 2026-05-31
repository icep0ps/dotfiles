# Eww Widgets

Eww (ElKowars wacky widgets) configuration for custom desktop widgets.

## Widgets

### Music Player (`music`)
Multi-device Spotify player with album art, controls, and device display.

**Features:**
- Shows playback from local spotify_player OR remote devices (phone, web, etc.)
- Local playback takes priority
- Displays device name
- Album art with caching
- Progress bar for both sources
- Playback controls (play/pause, next, previous, shuffle, repeat)

**Setup:**
See `SPOTIFY_WIDGET_README.md` for Spotify API configuration.

**Toggle:**
```bash
eww open music   # Show widget
eww close music  # Hide widget
```

**Keybinding (Sway):**
```
bindsym $mod+m exec ~/.config/waybar/scripts/open_spotify_widget.sh
```

### Control Center (`control_center`)
System controls panel with Wi-Fi, Bluetooth, DND, power profiles, and disk usage.

**Features:**
- Wi-Fi manager with network list
- Bluetooth toggle
- Do Not Disturb toggle
- Power profile switcher (performance/balanced/power-saver)
- Disk usage monitor

**Toggle:**
```bash
eww open control_center
eww close control_center
```

## Scripts

### `spotify_unified.sh`
Main script for music widget. Checks local playerctl first, falls back to Spotify API.

**Dependencies:**
- `playerctl` - Local playback detection
- `curl` - API calls
- `jq` - JSON parsing
- Spotify API credentials in `spotify.env`

### `get_music_progress.sh`
Calculates playback progress for both local and API sources.

### `getImage.sh`
Downloads and caches album artwork.

### `wifi_rofi.sh`
Rofi-based Wi-Fi manager with connect/disconnect/forget functionality.

**Features:**
- Signal strength indicators
- Security type icons (WPA, WEP, Open)
- 2.4GHz/5GHz band display
- Hidden network support
- IP address display

### `spotify_auth_setup.sh`
Interactive setup for Spotify API credentials.

## Customization

### Change Widget Position
Edit `windows/music.yuck`:
```lisp
(defwindow music
  :geometry (geometry :x "0%" :y "10px" :anchor "top center")
  ...)
```

### Modify Polling Intervals
Edit `modules/music.yuck`:
```lisp
(defpoll music_progress :interval "1s" ...)  ; Change interval
```

### Styling
Widget styles are defined in `eww.scss`. Modify colors, fonts, spacing there.

## Troubleshooting

### Music widget shows "No Music Playing" but music is playing
1. Check if spotify_player is running: `playerctl status --player=spotify_player`
2. Check Spotify API credentials: `cat spotify.env`
3. Check logs: `tail -f /tmp/spotify_unified.log`
4. Verify token: `cat /tmp/spotify_token_cache`

### Control center Wi-Fi not working
1. Ensure NetworkManager is running: `systemctl status NetworkManager`
2. Check nmcli works: `nmcli device wifi list`
3. Verify rofi is installed: `which rofi`

### Widget not appearing
1. Check eww is running: `eww ping`
2. View eww logs: `eww logs`
3. Reload config: `eww reload`

## Dependencies

```bash
# Core
eww

# Music widget
playerctl spotify-player curl jq

# Control center
nmcli bluetoothctl pactl rofi

# Fonts
ttf-jetbrains-mono-nerd
```
