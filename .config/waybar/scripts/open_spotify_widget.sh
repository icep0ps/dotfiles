#!/usr/bin/env bash

is_spotify_open=$(${HOME}/.local/share/eww/eww active-windows | grep -q "music" && echo true)

if [ $is_spotify_open ]; then
  ${HOME}/.local/share/eww/eww close music
else
  ${HOME}/.local/share/eww/eww open music
fi

exit 0
