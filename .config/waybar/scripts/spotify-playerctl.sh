#!/bin/sh

ICON_PLAY="󰐊"
ICON_PAUSE=""
ICON_OFFLINE="󰎇"

# Try local playerctl first — timeout prevents D-Bus hangs in waybar's polling context
status=$(timeout 2 playerctl --player=spotify_player status 2>/dev/null)

if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
  artist=$(timeout 2 playerctl --player=spotify_player metadata artist 2>/dev/null)
  title=$(timeout 2 playerctl --player=spotify_player metadata title 2>/dev/null)
  [ -z "$title" ] && title="Unknown Title"
  [ "$status" = "Playing" ] && icon="$ICON_PLAY" || icon="$ICON_PAUSE"
  [ -n "$artist" ] && echo "$icon $artist - $title" || echo "$icon $title"
  exit 0
fi

# API fallback — self-sufficient token refresh so this works without eww open
ENV_FILE="$HOME/.config/eww/spotify.env"
TOKEN_CACHE="/tmp/spotify_token_cache"

[ -f "$ENV_FILE" ] || { echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"; exit 0; }
command -v jq >/dev/null 2>&1 || { echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"; exit 0; }
. "$ENV_FILE"

# Check token validity
token=""
if [ -f "$TOKEN_CACHE" ]; then
  token=$(head -n1 "$TOKEN_CACHE")
  expiry=$(tail -n1 "$TOKEN_CACHE")
  [ "$(date +%s)" -ge "$expiry" ] && token=""
fi

# Refresh if stale/missing
if [ -z "$token" ] && [ -n "$SPOTIFY_CLIENT_ID" ] && [ -n "$SPOTIFY_REFRESH_TOKEN" ]; then
  resp=$(curl -s --max-time 5 -X POST "https://accounts.spotify.com/api/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token&refresh_token=$SPOTIFY_REFRESH_TOKEN&client_id=$SPOTIFY_CLIENT_ID&client_secret=$SPOTIFY_CLIENT_SECRET")
  token=$(echo "$resp" | jq -r '.access_token // ""')
  if [ -n "$token" ]; then
    printf '%s\n%s\n' "$token" "$(($(date +%s) + 3500))" > "$TOKEN_CACHE"
  fi
fi

[ -z "$token" ] && { echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"; exit 0; }

response=$(curl -s --max-time 3 -H "Authorization: Bearer $token" \
  "https://api.spotify.com/v1/me/player")

[ -z "$response" ] && { echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"; exit 0; }

is_playing=$(echo "$response" | jq -r '.is_playing // false')
title=$(echo "$response" | jq -r '.item.name // ""')
artist=$(echo "$response" | jq -r '.item.artists[0].name // ""')

[ -z "$title" ] && { echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"; exit 0; }

[ "$is_playing" = "true" ] && icon="$ICON_PLAY" || icon="$ICON_PAUSE"
[ -n "$artist" ] && echo "$icon $artist - $title" || echo "$icon $title"
