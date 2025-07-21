#!/usr/bin/env bash

playerctl metadata --format --player=spotify_player "{{mpris:artUrl}}" --follow | while IFS= read -r line; do
  if [[ $line == *"http"* ]]; then
    cache_dir="$XDG_RUNTIME_DIR/album_art_cache"
    mkdir -p "$cache_dir"
    file_name=$(basename "$line")
    file_path="$cache_dir/$file_name"

    # Check if file exists
    if [ -e "$file_path" ]; then
      # File exists, return path immediately
      echo "file://$file_path"
    else
      curl --output "$file_path" "$line" >/dev/null 2>&1
      echo "file://$file_path"
    fi
  else
    # artUrl doesn't have a link, nothing to do
    echo "$line"
  fi
done
