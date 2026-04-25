#!/usr/bin/env bash

ADAPTER="ADP0"
STATUS_FILE="/sys/class/power_supply/$ADAPTER/online"

if [[ ! -f "$STATUS_FILE" ]]; then
  notify-send -u critical "Power Monitor" "Adapter not found: $ADAPTER"
  exit 1
fi

notify_power() {
  if [[ "$(< "$STATUS_FILE")" == "1" ]]; then
    notify-send -u normal -i battery-charging \
      -h string:x-canonical-private-synchronous:power \
      "Power Connected" "Laptop is now charging"
  else
    notify-send -u critical -i battery-missing \
      -h string:x-canonical-private-synchronous:power \
      "Power Disconnected" "Running on battery"
  fi
}

udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null | while read -r line; do
  [[ "$line" == *"$ADAPTER"* ]] || continue
  notify_power
done
