#!/bin/bash

# --- CONFIGURATION ---
# Replace 'AC' with your actual adapter name found in Phase 1
ADAPTER_NAME="ADP0"
STATUS_FILE="/sys/class/power_supply/$ADAPTER_NAME/online"

# Check if the file actually exists to prevent errors
if [ ! -f "$STATUS_FILE" ]; then
  notify-send -u critical "Power Monitor Error" "Could not find adapter: $ADAPTER_NAME"
  exit 1
fi

# Get the initial state (so we don't spam on startup)
# 1 = Charging, 0 = Discharging
PREV_STATUS=$(cat "$STATUS_FILE")

# Loop forever checking status every 2 seconds
while true; do
  CURRENT_STATUS=$(cat "$STATUS_FILE")

  if [ "$CURRENT_STATUS" != "$PREV_STATUS" ]; then
    if [ "$CURRENT_STATUS" == "1" ]; then
      # Event: Plugged In
      notify-send \
        -u normal \
        -i battery-charging \
        -h string:x-canonical-private-synchronous:power-notification \
        "Power Connected" "Laptop is now charging"
    else
      # Event: Unplugged
      notify-send \
        -u critical \
        -i battery-missing \
        -h string:x-canonical-private-synchronous:power-notification \
        "Power Disconnected" "Laptop is running on battery"
    fi

    # Update the previous status
    PREV_STATUS="$CURRENT_STATUS"
  fi

  # Wait 2 seconds before checking again to save CPU
  sleep 2
done
