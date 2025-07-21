#!/usr/bin/env bash

is_control_center_open=$(${HOME}/.local/share/eww/eww active-windows | grep -q "control_center" && echo true)

if [ $is_control_center_open ]; then
  ${HOME}/.local/share/eww/eww close control_center
else
  ${HOME}/.local/share/eww/eww open control_center
fi

exit 0
