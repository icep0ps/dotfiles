#!/bin/sh

# Icons
ICON_PLAY="󰐊"
ICON_PAUSE=""
ICON_OFFLINE="󰎇"

# Check local playerctl first
status=$(playerctl --player=spotify_player status 2>/dev/null)

if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
  artist=$(playerctl --player=spotify_player metadata artist 2>/dev/null)
  title=$(playerctl --player=spotify_player metadata title 2>/dev/null)
  
  [ -z "$title" ] && title="Unknown Title"
  
  if [ "$status" = "Playing" ]; then
    icon="$ICON_PLAY"
  else
    icon="$ICON_PAUSE"
  fi
  
  if [ -n "$artist" ]; then
    echo "$icon $artist - $title"
  else
    echo "$icon $title"
  fi
else
  # Check if unified script has detected API playback
  if [ -f "$HOME/.config/eww/spotify.env" ] && command -v jq >/dev/null 2>&1; then
    token=$(head -n1 /tmp/spotify_token_cache 2>/dev/null)
    if [ -n "$token" ]; then
      response=$(curl -s --max-time 2 -H "Authorization: Bearer $token" \
        "https://api.spotify.com/v1/me/player" 2>/dev/null)
      
      if [ -n "$response" ]; then
        is_playing=$(echo "$response" | jq -r '.is_playing // false')
        title=$(echo "$response" | jq -r '.item.name // ""')
        artist=$(echo "$response" | jq -r '.item.artists[0].name // ""')
        
        if [ "$is_playing" = "true" ]; then
          icon="$ICON_PLAY"
        elif [ -n "$title" ]; then
          icon="$ICON_PAUSE"
        fi
        
        if [ -n "$artist" ] && [ -n "$title" ]; then
          echo "$icon $artist - $title"
          exit 0
        fi
      fi
    fi
  fi
  
  echo "$ICON_OFFLINE MUSIC PLAYER: [OFF]"
fi

exit 0
