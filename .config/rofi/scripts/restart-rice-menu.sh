#!/bin/bash

declare -A ACTIONS
ACTIONS["Restart Sway"]="swaymsg reload"
ACTIONS["Restart Waybar"]="killall waybar && coproc (waybar &)"
ACTIONS["Reload Sway Config"]="swaymsg reload"
ACTIONS["Reload Waybar Config"]="killall -SIGUSR2 waybar"

declare -A NOTIFICATIONS
NOTIFICATIONS["Restart Sway"]="Sway has been reloaded!"
NOTIFICATIONS["Restart Waybar"]="Waybar has been restarted!"
NOTIFICATIONS["Reload Sway Config"]="Sway configuration reloaded!"
NOTIFICATIONS["Reload Waybar Config"]="Waybar configuration reloaded!"

declare -A ICONS
ICONS["Restart Sway"]=""
ICONS["Restart Waybar"]=""
ICONS["Reload Sway Config"]=""
ICONS["Reload Waybar Config"]=""

echo -en "\0prompt\x1fConfiguration Restart\n"

for action in "${!ACTIONS[@]}"; do
  glyph="${ICONS[$action]}"
  label="$glyph  $action"
  echo -en "$action\0display\x1f$label\n"
done

if [[ -n "$@" ]]; then
  selected="$@"

  command="${ACTIONS["$selected"]}"
  message="${NOTIFICATIONS["$selected"]}"

  if [[ -n "$command" ]]; then
    eval "$command"
    [[ -n "$message" ]] && notify-send "System Action" "$message"
    exit 0
  else
    notify-send "Rofi Action Error" "Unknown action: '$selected'"
  fi
fi

exit 0
