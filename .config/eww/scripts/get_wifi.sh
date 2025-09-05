#!/usr/bin/env bash

# ~/.config/eww/scripts/get_wifi.sh

# Get a list of networks, filtering out empty SSIDs and the header line
# -t is for terse output, -f specifies fields.
# We use awk to handle potential spaces in SSIDs and format for jq.
nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes |
  grep -v '^--' |
  awk -F: '{
    # Escape double quotes in SSID for valid JSON
    gsub(/"/, "\\\"", $1);
    
    # Check if security field exists
    security = ($3 != "") ? $3 : "OPEN";
    
    # Print in a format that jq can easily parse
    printf "{\"ssid\":\"%s\", \"signal\":\"%s\", \"security\":\"%s\"}\n", $1, $2, security;
}' |
  jq -s '.' # Use jq to wrap the individual JSON objects into a single JSON array
