#!/usr/bin/env bash

EWW="${HOME}/.local/share/eww/eww"
DIR="$HOME/.config/rofi"

reload_sway="$(printf '\U000F0453')  Reload Sway Config"
restart_waybar="$(printf '\U000F0570')  Restart Waybar"
reload_waybar="$(printf '\U000F03D8')  Reload Waybar Theme"
restart_eww="$(printf '\U000F0403')  Restart Eww"

options="$reload_sway\n$restart_waybar\n$reload_waybar\n$restart_eww"

chosen=$(echo -e "$options" | rofi -dmenu \
  -p "$(printf '\U000F0493')  Reload Components" -selected-row 0)

case "$chosen" in
  "$reload_sway")
    swaymsg reload
    notify-send "Rice" "Sway configuration reloaded"
    ;;
  "$restart_waybar")
    killall waybar
    setsid waybar &>/dev/null &
    notify-send "Rice" "Waybar restarted"
    ;;
  "$reload_waybar")
    killall -SIGUSR2 waybar
    notify-send "Rice" "Waybar theme reloaded"
    ;;
  "$restart_eww")
    "$EWW" kill
    setsid "$EWW" daemon &>/dev/null &
    notify-send "Rice" "Eww restarted"
    ;;
esac
