#!/usr/bin/env bash

EWW="${HOME}/.local/share/eww/eww"

if "$EWW" active-windows | grep -q "control_center"; then
  "$EWW" close control_center
else
  "$EWW" open control_center
fi
