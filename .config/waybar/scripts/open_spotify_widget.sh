#!/usr/bin/env bash

is_spotify_open=$(eww active-windows | grep -q "music" && echo true)

if [ $is_spotify_open ]; then
  eww close music
else
  eww open music
fi

exit 0
