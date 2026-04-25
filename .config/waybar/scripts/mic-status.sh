#!/bin/bash

muted=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -c "yes")
in_use=$(pactl list source-outputs 2>/dev/null | grep -c "Source Output")

mic=$'\uf130'

if [ "$muted" -gt 0 ]; then
  echo "{\"text\": \"$mic\", \"class\": \"muted\", \"tooltip\": \"Microphone muted\"}"
elif [ "$in_use" -gt 0 ]; then
  echo "{\"text\": \"$mic\", \"class\": \"active\", \"tooltip\": \"Microphone in use\"}"
else
  echo "{\"text\": \"$mic\", \"class\": \"idle\", \"tooltip\": \"Microphone idle\"}"
fi
