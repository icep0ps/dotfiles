#!/usr/bin/env bash

# ~/.config/eww/scripts/connect.sh

SSID="$1"
PASSWORD_REQUIRED=$(
  nmcli -t -f SECURITY dev wifi list | grep "$SSID" | awk -F: '{print $1}' | grep -E -v 'WPA|WEP|802.1X' &>/dev/null
  echo $?
)

if [ "$PASSWORD_REQUIRED" -eq 1 ]; then
  # Secured network, prompt for password
  PASSWORD=$(zenity --password --title="Connect to $SSID")
  if [ $? -eq 0 ]; then # If user clicks OK
    nmcli dev wifi connect "$SSID" password "$PASSWORD"
  fi
else
  # Open network, connect directly
  nmcli dev wifi connect "$SSID"
fi
