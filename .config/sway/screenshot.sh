#!/bin/bash

# --- 1. Prevent Reactivation ---
# Check if 'slurp' is already running.
# If it is, the script exits immediately so you don't get multiple crosshairs.
if pgrep -x "slurp" >/dev/null; then
  exit 1
fi

# --- 2. Setup Filename ---
# Change this directory to wherever you want your screenshots saved
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILENAME="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

# --- 3. Get Selection ---
# Run slurp to select the area.
# We capture the output into a variable so we can check if the user cancelled.
REGION=$(slurp)

# If the user pressed Escape (REGION is empty), exit without doing anything.
if [ -z "$REGION" ]; then
  exit 0
fi

# --- 4. Capture, Save, and Copy ---
# 'grim' takes the screenshot using the region.
# 'tee' saves it to the file AND passes it to the next pipe.
# 'wl-copy' takes that data and puts it on the clipboard.
grim -g "$REGION" - | tee "$FILENAME" | wl-copy

# --- 5. Optional Notification ---
# Requires 'libnotify' to be installed
notify-send "Screenshot Taken" "Saved to $FILENAME and copied to clipboard."
