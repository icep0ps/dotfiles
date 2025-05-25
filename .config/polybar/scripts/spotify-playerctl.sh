#!/bin/sh

# Get the status of the spotify player(s)
# Check for spotify_player, spotify, and spotifyd names
status=$(playerctl --player=spotify_player,spotify,spotifyd status 2>/dev/null)

# Use the original offline icon
offline_icon="ﱘ"

# Check if a player is active and get metadata
if [ "$status" = "Playing" ]; then
  # Use original play/pause icons
  play_icon="ﱘ"
  artist=$(playerctl --player=spotify_player,spotify,spotifyd metadata artist 2>/dev/null)
  title=$(playerctl --player=spotify_player,spotify,spotifyd metadata title 2>/dev/null)
  # Handle cases where metadata might be missing
  if [ -n "$artist" ] && [ -n "$title" ]; then
    echo "$play_icon $artist - $title"
  elif [ -n "$title" ]; then
    echo "$play_icon $title" # Display only title if artist is missing
  else
    echo "$play_icon Unknown Title"
  fi

elif [ "$status" = "Paused" ]; then
  # Use original play/pause icons
  pause_icon=""
  artist=$(playerctl --player=spotify_player,spotify,spotifyd metadata artist 2>/dev/null)
  title=$(playerctl --player=spotify_player,spotify,spotifyd metadata title 2>/dev/null)
  if [ -n "$artist" ] && [ -n "$title" ]; then
    echo "$pause_icon $artist - $title"
  elif [ -n "$title" ]; then
    echo "$pause_icon $title"
  else
    echo "$pause_icon Unknown Title"
  fi
else
  # No player is active or recognised
  echo "$offline_icon Offline"
fi

exit 0
