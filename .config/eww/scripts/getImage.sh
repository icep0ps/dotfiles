#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/eww_album_art"
mkdir -p "$CACHE_DIR"

last_path=""

playerctl --follow metadata --player=spotify_player --format '{{mpris:artUrl}}' | while IFS= read -r url; do
  if [[ "$url" == http* ]]; then
    hash=$(echo -n "$url" | md5sum | cut -d' ' -f1)
    ext="${url##*.}"
    [[ "$ext" =~ ^(jpg|jpeg|png|webp)$ ]] || ext="jpg"
    file_path="$CACHE_DIR/${hash}.${ext}"

    if [[ -f "$file_path" ]]; then
      echo "$file_path"
      last_path="$file_path"
    else
      # Show old image immediately so widget doesn't go blank while downloading
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
done
