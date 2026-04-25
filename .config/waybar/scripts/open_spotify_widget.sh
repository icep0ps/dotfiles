#!/usr/bin/env bash

EWW="${HOME}/.local/share/eww/eww"

if "$EWW" active-windows | grep -q "music"; then
  "$EWW" close music
else
  "$EWW" open music
fi
