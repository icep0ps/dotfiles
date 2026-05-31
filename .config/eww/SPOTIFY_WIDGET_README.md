# Spotify Multi-Device Music Widget for eww

This widget displays Spotify playback from any device (local spotify_player or remote devices via Spotify Web API).

## Features

- **Priority System**: Local spotify_player takes precedence over remote devices
- **Device Display**: Shows which device is currently playing music
- **Multi-Source**: Supports both local playerctl and Spotify Web API
- **Auto-Refresh**: Polls Spotify API every 5 seconds for remote playback
- **Album Art**: Caches album artwork for both local and remote sources

## Setup

### 1. Create Spotify App

1. Go to https://developer.spotify.com/dashboard
2. Create a new app (or use existing)
3. Add `http://127.0.0.1:8888/callback` to Redirect URIs
   - **Important**: Use `127.0.0.1`, NOT `localhost` (Spotify requires explicit loopback IP)
4. Note your Client ID and Client Secret

### 2. Run Authentication Setup

```bash
~/.config/eww/scripts/spotify_auth_setup.sh
```

Follow the prompts to:
- Enter your Client ID and Client Secret
- Authorize the app in your browser
- Paste the authorization code

This creates `~/.config/eww/spotify.env` with your credentials.

### 3. Restart eww

```bash
eww reload
```

The widget will now show playback from any device!

## How It Works

1. **Local Priority**: Checks local spotify_player via playerctl first
2. **API Fallback**: If no local playback, queries Spotify Web API
3. **Device Name**: Displays "spotify-player" for local, actual device name for remote
4. **Album Art**: Unified script writes art URL to `/tmp/spotify_art_url` for getImage.sh

## Files Modified

- `modules/music.yuck` - Widget definition with device display
- `scripts/spotify_unified.sh` - Main script with priority logic
- `scripts/spotify_auth_setup.sh` - OAuth authentication helper
- `scripts/getImage.sh` - Album art handler for both sources
- `spotify.env` - Credentials (not committed to git)

## Troubleshooting

### Check logs
```bash
tail -f /tmp/spotify_unified.log
```

### Test unified script
```bash
~/.config/eww/scripts/spotify_unified.sh
```

Should output JSON with playback info.

### Re-authenticate
If you get authentication errors, run setup again:
```bash
~/.config/eww/scripts/spotify_auth_setup.sh
```

### No remote playback detected
- Ensure music is playing on a Spotify device
- Check that the app has `user-read-playback-state` scope
- Verify credentials in `~/.config/eww/spotify.env`

## Security

- `spotify.env` contains sensitive credentials - keep it private
- File permissions are set to 600 (owner read/write only)
- Never commit `spotify.env` to version control

## Rate Limits

The script polls Spotify API every 5 seconds, which is well within Spotify's rate limits for personal use. If you need to reduce API calls, increase the sleep interval in `spotify_unified.sh`.
