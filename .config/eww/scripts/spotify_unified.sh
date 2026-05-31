#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config/eww"
ENV_FILE="$CONFIG_DIR/spotify.env"
TOKEN_CACHE="/tmp/spotify_token_cache"
LOG_FILE="/tmp/spotify_unified.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

load_credentials() {
  if [[ ! -f "$ENV_FILE" ]]; then
    log "ERROR: $ENV_FILE not found. Run spotify_auth_setup.sh first"
    return 1
  fi
  source "$ENV_FILE"
  if [[ -z "$SPOTIFY_CLIENT_ID" || -z "$SPOTIFY_CLIENT_SECRET" || -z "$SPOTIFY_REFRESH_TOKEN" ]]; then
    log "ERROR: Missing credentials in $ENV_FILE"
    return 1
  fi
  return 0
}

refresh_access_token() {
  log "Refreshing access token..."
  local response=$(curl -s --max-time 10 -X POST "https://accounts.spotify.com/api/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$SPOTIFY_REFRESH_TOKEN" \
    -d "client_id=$SPOTIFY_CLIENT_ID" \
    -d "client_secret=$SPOTIFY_CLIENT_SECRET" 2>&1)
  
  if [[ $? -ne 0 ]]; then
    log "ERROR: Network error during token refresh"
    return 1
  fi
  
  local access_token=$(echo "$response" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  
  if [[ -z "$access_token" ]]; then
    log "ERROR: Failed to get access token. Response: $response"
    return 1
  fi
  
  local expiry=$(($(date +%s) + 3500))
  echo "$access_token" > "$TOKEN_CACHE"
  echo "$expiry" >> "$TOKEN_CACHE"
  log "Access token refreshed successfully"
  echo "$access_token"
  return 0
}

get_valid_token() {
  if [[ -f "$TOKEN_CACHE" ]]; then
    local token=$(head -n1 "$TOKEN_CACHE")
    local expiry=$(tail -n1 "$TOKEN_CACHE")
    local now=$(date +%s)
    
    if [[ $now -lt $expiry ]]; then
      echo "$token"
      return 0
    fi
  fi
  
  refresh_access_token
}

get_api_playback() {
  local token=$(get_valid_token)
  
  if [[ -z "$token" ]]; then
    log "ERROR: Failed to get valid token"
    return 1
  fi
  
  local response=$(curl -s --max-time 10 -w "\n%{http_code}" -H "Authorization: Bearer $token" \
    "https://api.spotify.com/v1/me/player" 2>&1)
  
  if [[ $? -ne 0 ]]; then
    log "ERROR: Network error during API call"
    return 1
  fi
  
  local http_code=$(echo "$response" | tail -n1)
  local body=$(echo "$response" | sed '$d')
  
  if [[ "$http_code" == "204" || "$http_code" == "404" ]]; then
    log "INFO: No active playback (HTTP $http_code)"
    return 1
  fi
  
  if [[ "$http_code" == "401" ]]; then
    log "WARN: Token expired (HTTP 401), clearing cache"
    rm -f "$TOKEN_CACHE"
    return 1
  fi
  
  if [[ "$http_code" != "200" ]]; then
    log "ERROR: API returned HTTP $http_code"
    return 1
  fi
  
  local is_playing=$(echo "$body" | jq -r '.is_playing // false')
  local status="Paused"
  [[ "$is_playing" == "true" ]] && status="Playing"
  
  local title=$(echo "$body" | jq -r '.item.name // "Unknown"')
  local artist=$(echo "$body" | jq -r '.item.artists[0].name // "Unknown"')
  local album=$(echo "$body" | jq -r '.item.album.name // "Unknown"')
  local device=$(echo "$body" | jq -r '.device.name // "Unknown Device"')
  local art_url=$(echo "$body" | jq -r '.item.album.images[0].url // ""')
  local progress_ms=$(echo "$body" | jq -r '.progress_ms // 0')
  local duration_ms=$(echo "$body" | jq -r '.item.duration_ms // 0')
  
  local position="0:00"
  local length="0:00"
  
  if [[ "$progress_ms" != "0" && "$progress_ms" != "null" ]]; then
    local pos_sec=$((progress_ms / 1000))
    position=$(printf "%d:%02d" $((pos_sec / 60)) $((pos_sec % 60)))
  fi
  
  if [[ "$duration_ms" != "0" && "$duration_ms" != "null" ]]; then
    local len_sec=$((duration_ms / 1000))
    length=$(printf "%d:%02d" $((len_sec / 60)) $((len_sec % 60)))
  fi
  
  log "INFO: API playback detected - $title by $artist on $device"
  
  cat <<EOF
{"status":"$status","title":"$title","artist":"$artist","album":"$album","position":"$position","length":"$length","device":"$device","art_url":"$art_url","source":"api"}
EOF
  return 0
}

get_local_playback() {
  local status=$(playerctl status --player=spotify_player 2>/dev/null)
  
  if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
    return 1
  fi
  
  local title=$(playerctl metadata --player=spotify_player title 2>/dev/null || echo "Unknown")
  local artist=$(playerctl metadata --player=spotify_player artist 2>/dev/null || echo "Unknown")
  local album=$(playerctl metadata --player=spotify_player album 2>/dev/null || echo "Unknown")
  local art_url=$(playerctl metadata --player=spotify_player mpris:artUrl 2>/dev/null || echo "")
  local position=$(playerctl metadata --player=spotify_player --format '{{duration(position)}}' 2>/dev/null || echo "0:00")
  local length=$(playerctl metadata --player=spotify_player --format '{{duration(mpris:length)}}' 2>/dev/null || echo "0:00")
  
  cat <<EOF
{"status":"$status","title":"$title","artist":"$artist","album":"$album","position":"$position","length":"$length","device":"spotify-player","art_url":"$art_url","source":"local"}
EOF
  return 0
}

load_credentials || {
  log "FATAL: Failed to load credentials"
  # Output error state for widget
  while true; do
    echo '{"status":"Error","title":"Configuration Error","artist":"Run spotify_auth_setup.sh","album":"","position":"0:00","length":"0:00","device":"","art_url":"","source":"none"}'
    sleep 10
  done
  exit 1
}

log "INFO: Starting spotify_unified.sh"

# Main loop with error handling
while true; do
  output=""
  if output=$(get_local_playback 2>/dev/null); then
    echo "$output"
    echo "$output" | grep -o '"art_url":"[^"]*"' | cut -d'"' -f4 > /tmp/spotify_art_url 2>/dev/null
  elif output=$(get_api_playback 2>/dev/null); then
    echo "$output"
    echo "$output" | grep -o '"art_url":"[^"]*"' | cut -d'"' -f4 > /tmp/spotify_art_url 2>/dev/null
  else
    echo '{"status":"Stopped","title":"No Music Playing","artist":"","album":"","position":"0:00","length":"0:00","device":"","art_url":"","source":"none"}'
    echo "" > /tmp/spotify_art_url 2>/dev/null
  fi
  sleep 5
done
