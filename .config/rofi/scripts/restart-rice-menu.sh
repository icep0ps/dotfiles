#!/usr/bin/env bash

EWW="${HOME}/.local/share/eww/eww"

# Ordered entries: "Label:Icon"
# Icons: nf-md-refresh, nf-md-view-dashboard, nf-md-palette, nf-md-widgets
MENU=(
  "Reload Sway Config:\U000F0453"
  "Restart Waybar:\U000F0570"
  "Reload Waybar Theme:\U000F03D8"
  "Restart Eww:\U000F0403"
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
    icon=$(printf "${entry##*:}")
    printf '%s\0display\x1f%s  %s\n' "$label" "$icon" "$label"
  done
  exit 0
fi

selected="$*"
run "$selected" && notify-send "Rice" "$selected"
