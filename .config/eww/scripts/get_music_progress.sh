#!/usr/bin/env bash

# Check local playerctl first
if playerctl status --player=spotify_player &>/dev/null; then
  pos=$(playerctl metadata --player=spotify_player --format "{{ position }}" 2>/dev/null || echo "0")
  dur=$(playerctl metadata --player=spotify_player --format "{{ mpris:length }}" 2>/dev/null || echo "1")
  awk -v x="$pos" -v y="$dur" 'BEGIN { printf "%0.0f", (y > 0 ? x/y*100 : 0) }'
else
  # Try to get progress from API via token
  if [[ -f "$HOME/.config/eww/spotify.env" ]]; then
    source "$HOME/.config/eww/spotify.env"
    token=$(head -n1 /tmp/spotify_token_cache 2>/dev/null)
    
    if [[ -n "$token" ]]; then
      response=$(curl -s --max-time 2 -H "Authorization: Bearer $token" \
        "https://api.spotify.com/v1/me/player" 2>/dev/null)
      
      if [[ -n "$response" ]]; then
        progress_ms=$(echo "$response" | jq -r '.progress_ms // 0')
        duration_ms=$(echo "$response" | jq -r '.item.duration_ms // 0')
        
        if [[ "$progress_ms" != "0" && "$duration_ms" != "0" ]]; then
          awk -v x="$progress_ms" -v y="$duration_ms" 'BEGIN { printf "%0.0f", (y > 0 ? x/y*100 : 0) }'
          exit 0
        fi
      fi
    fi
  fi
  
  echo "0"
fi
