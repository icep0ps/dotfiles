#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"
CACHE_FILE="$CACHE_DIR/verse.json"

# Create the cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Check if the cache file exists and is less than 1 hour old
if [[ -f "$CACHE_FILE" && $(find "$CACHE_FILE" -mmin -60) ]]; then
  # Use cached data
  DATA=$(cat "$CACHE_FILE")
else
  # Try to fetch fresh data. The timeout prevents the script from hanging.
  FETCH_DATA=$(curl -s --max-time 10 'https://beta.ourmanna.com/api/v1/get?format=json&order=daily')

  # Check if the curl command was successful
  if [[ $? -eq 0 && ! -z "$FETCH_DATA" ]]; then
    # Cache the new data
    echo "$FETCH_DATA" >"$CACHE_FILE"
    DATA="$FETCH_DATA"
  else
    # Fallback to cached data if it exists, otherwise provide a default message
    if [[ -f "$CACHE_FILE" ]]; then
      DATA=$(cat "$CACHE_FILE")
    else
      # Default message to use when offline and no cache is available
      DATA='{"verse": {"details": {"text": "No internet and no cached verse.", "reference": "Offline"}}}'
    fi
  fi
fi

case "$1" in
--text)
  echo "$DATA" | jq -r '.verse.details.text'
  ;;
--ref)
  echo "$DATA" | jq -r '.verse.details.reference'
  ;;
*)
  echo "Usage: get_verse.sh [--text | --ref]"
  ;;
esac
