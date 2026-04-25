#!/usr/bin/env bash

EWW="${HOME}/.local/share/eww/eww"

# Ordered entries: "Label:Icon"
MENU=(
  "Reload Sway Config:󰑓"
  "Restart Waybar:"
  "Reload Waybar Theme:"
  "Restart Eww:"
)

run() {
  case "$1" in
    "Reload Sway Config")
      swaymsg reload
      ;;
    "Restart Waybar")
      killall waybar
      setsid waybar &>/dev/null &
      ;;
    "Reload Waybar Theme")
      killall -SIGUSR2 waybar
      ;;
    "Restart Eww")
      "$EWW" kill
      setsid "$EWW" daemon &>/dev/null &
      ;;
  esac
}

if [[ -z "$*" ]]; then
  printf '\0prompt\x1fRice\n'
  for entry in "${MENU[@]}"; do
    label="${entry%%:*}"
    icon="${entry##*:}"
    printf '%s\0display\x1f%s  %s\n' "$label" "$icon" "$label"
  done
  exit 0
fi

selected="$*"
run "$selected" && notify-send "Rice" "$selected"
