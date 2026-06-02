#!/usr/bin/env bash

EWW="$HOME/.local/share/eww/eww"

# Kill duplicate daemons — multiple eww processes confuse active-windows
eww_count=$(pgrep -cx eww 2>/dev/null || echo 0)
if [ "$eww_count" -gt 1 ]; then
  killall eww
  sleep 0.2
  "$EWW" open music
  exit 0
fi

if "$EWW" active-windows 2>/dev/null | grep -q "music"; then
  "$EWW" close music
else
  "$EWW" open music
fi
