#!/usr/bin/env bash

entries="󰌾 Lock\n󰒲 Suspend\n󰜉 Reboot\n󰐥 Shutdown"

choice=$(printf "$entries" | rofi -dmenu -i \
  -theme "$HOME/.config/rofi/powermenu.rasi" \
  -p "Power")

case "$choice" in
  *Lock*)     swaylock ;;
  *Suspend*)  systemctl suspend ;;
  *Reboot*)   systemctl reboot ;;
  *Shutdown*) systemctl poweroff ;;
esac
