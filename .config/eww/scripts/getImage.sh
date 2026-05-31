#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/eww_album_art"
mkdir -p "$CACHE_DIR"

last_path=""
last_url=""

# Read art_url from unified script via a named pipe or poll
while true; do
  # Try to get art URL from local playerctl first
  url=$(playerctl metadata --player=spotify_player mpris:artUrl 2>/dev/null)
  
  # If no local playback, try to extract from a temp file that unified script could write
  # For now, we'll just use playerctl as the unified script outputs art_url in JSON
  # The widget will need to pass this separately or we poll it
  
  if [[ -z "$url" ]]; then
    # Fallback: check if there's a cached URL from API
    if [[ -f "/tmp/spotify_art_url" ]]; then
      url=$(cat /tmp/spotify_art_url)
    fi
  fi
  
  # Only process if URL changed
  if [[ "$url" != "$last_url" ]]; then
    last_url="$url"
    
    if [[ "$url" == http* ]]; then
      hash=$(echo -n "$url" | md5sum | cut -d' ' -f1)
      ext="${url##*.}"
      [[ "$ext" =~ ^(jpg|jpeg|png|webp)$ ]] || ext="jpg"
      file_path="$CACHE_DIR/${hash}.${ext}"

      if [[ -f "$file_path" ]]; then
        echo "$file_path"
        last_path="$file_path"
      else
        [[ -n "$last_path" ]] && echo "$last_path"
        if curl -sL --max-time 15 "$url" -o "$file_path" 2>/dev/null; then
          echo "$file_path"
          last_path="$file_path"
        else
          rm -f "$file_path"
        fi
      fi
    elif [[ -n "$url" && -f "$url" ]]; then
      echo "$url"
      last_path="$url"
    fi
  fi
  
  sleep 2
done
