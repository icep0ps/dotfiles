#!/usr/bin/env bash
# Health check script for dotfiles setup

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PASS="\033[0;32m✓\033[0m"
FAIL="\033[0;31m✗\033[0m"
WARN="\033[0;33m⚠\033[0m"
INFO="\033[0;34mℹ\033[0m"

check_count=0
pass_count=0
fail_count=0
warn_count=0

check() {
  ((check_count++))
  if eval "$2" &>/dev/null; then
    echo -e "$PASS $1"
    ((pass_count++))
    return 0
  else
    echo -e "$FAIL $1"
    ((fail_count++))
    [[ -n "${3:-}" ]] && echo -e "  $INFO Fix: $3"
    return 1
  fi
}

warn() {
  ((check_count++))
  ((warn_count++))
  echo -e "$WARN $1"
  [[ -n "${2:-}" ]] && echo -e "  $INFO Note: $2"
}

section() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

echo "Dotfiles Health Check"
echo "====================="

# Core Dependencies
section "Core Dependencies"
check "Sway installed" "command -v sway" "sudo pacman -S sway"
check "Waybar installed" "command -v waybar" "sudo pacman -S waybar"
check "Eww installed" "command -v eww" "yay -S eww"
check "Rofi installed" "command -v rofi" "sudo pacman -S rofi"
check "Mako installed" "command -v mako" "sudo pacman -S mako"
check "Foot terminal installed" "command -v foot" "sudo pacman -S foot"

# Music Widget Dependencies
section "Music Widget Dependencies"
check "Playerctl installed" "command -v playerctl" "sudo pacman -S playerctl"
check "Spotify Player installed" "command -v spotify_player" "yay -S spotify_player"
check "curl installed" "command -v curl" "sudo pacman -S curl"
check "jq installed" "command -v jq" "sudo pacman -S jq"

# Spotify API Configuration
section "Spotify API Configuration"
if check "Spotify env file exists" "[[ -f $CONFIG_DIR/eww/spotify.env ]]" "Run ~/.config/eww/scripts/spotify_auth_setup.sh"; then
  source "$CONFIG_DIR/eww/spotify.env"
  check "Client ID configured" "[[ -n ${SPOTIFY_CLIENT_ID:-} ]]" "Edit ~/.config/eww/spotify.env"
  check "Client Secret configured" "[[ -n ${SPOTIFY_CLIENT_SECRET:-} ]]" "Edit ~/.config/eww/spotify.env"
  check "Refresh Token configured" "[[ -n ${SPOTIFY_REFRESH_TOKEN:-} ]]" "Run ~/.config/eww/scripts/spotify_auth_setup.sh"
  
  if [[ -f /tmp/spotify_token_cache ]]; then
    token=$(head -n1 /tmp/spotify_token_cache 2>/dev/null)
    if [[ -n "$token" ]]; then
      if curl -s --max-time 5 -H "Authorization: Bearer $token" \
        "https://api.spotify.com/v1/me/player" &>/dev/null; then
        check "Spotify API connection" "true"
      else
        warn "Spotify API connection failed" "Token may be expired, will refresh automatically"
      fi
    fi
  fi
fi

# System Services
section "System Services"
check "NetworkManager running" "systemctl is-active NetworkManager" "sudo systemctl start NetworkManager"
check "Bluetooth service available" "systemctl list-unit-files | grep -q bluetooth" "sudo pacman -S bluez"

# Utilities
section "Utilities"
check "Screenshot tools (grim)" "command -v grim" "sudo pacman -S grim"
check "Screenshot tools (slurp)" "command -v slurp" "sudo pacman -S slurp"
check "Clipboard (wl-copy)" "command -v wl-copy" "sudo pacman -S wl-clipboard"
check "Autotiling" "command -v autotiling" "pip install autotiling"
check "nmcli (NetworkManager)" "command -v nmcli" "sudo pacman -S networkmanager"
check "pactl (PulseAudio)" "command -v pactl" "sudo pacman -S pulseaudio"

# Fonts
section "Fonts"
if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  check "JetBrainsMono Nerd Font installed" "true"
else
  check "JetBrainsMono Nerd Font installed" "false" "sudo pacman -S ttf-jetbrains-mono-nerd"
fi

# Configuration Files
section "Configuration Files"
check "Sway config exists" "[[ -f $CONFIG_DIR/sway/config ]]"
check "Waybar config exists" "[[ -f $CONFIG_DIR/waybar/config.jsonc ]]"
check "Eww config exists" "[[ -f $CONFIG_DIR/eww/eww.yuck ]]"
check "Rofi config exists" "[[ -f $CONFIG_DIR/rofi/config.rasi ]]"

# Scripts
section "Scripts"
check "Spotify unified script" "[[ -x $CONFIG_DIR/eww/scripts/spotify_unified.sh ]]"
check "Music progress script" "[[ -x $CONFIG_DIR/eww/scripts/get_music_progress.sh ]]"
check "Album art script" "[[ -x $CONFIG_DIR/eww/scripts/getImage.sh ]]"
check "Wi-Fi rofi script" "[[ -x $CONFIG_DIR/eww/scripts/wifi_rofi.sh ]]"
check "Screenshot script" "[[ -x $CONFIG_DIR/sway/screenshot.sh ]]"

# Runtime Checks
section "Runtime Status"
if pgrep -x sway >/dev/null; then
  check "Sway running" "true"
  check "Waybar running" "pgrep -x waybar"
  check "Mako running" "pgrep -x mako"
  
  if command -v eww &>/dev/null; then
    if eww ping &>/dev/null; then
      check "Eww daemon running" "true"
    else
      warn "Eww daemon not running" "Start with: eww daemon"
    fi
  fi
else
  warn "Sway not running" "Start Sway to check runtime status"
fi

# Summary
section "Summary"
echo "Total checks: $check_count"
echo -e "$PASS Passed: $pass_count"
[[ $warn_count -gt 0 ]] && echo -e "$WARN Warnings: $warn_count"
[[ $fail_count -gt 0 ]] && echo -e "$FAIL Failed: $fail_count"

if [[ $fail_count -eq 0 ]]; then
  echo ""
  echo "✨ All critical checks passed!"
  exit 0
else
  echo ""
  echo "⚠️  Some checks failed. See above for fixes."
  exit 1
fi
