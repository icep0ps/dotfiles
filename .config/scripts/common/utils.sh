#!/usr/bin/env bash
# Common utility functions for dotfiles scripts

# Notifications
notify() {
  notify-send "$1" "${2:-}" "${@:3}"
}

notify_error() {
  notify-send -u critical "$1" "${2:-}" "${@:3}"
}

notify_success() {
  notify-send -u normal "$1" "${2:-}" "${@:3}"
}

# Logging
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if service is running
service_running() {
  systemctl --user is-active "$1" >/dev/null 2>&1
}

# Get config directory
get_config_dir() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}"
}

# Check if file exists and is readable
file_readable() {
  [[ -f "$1" && -r "$1" ]]
}

# Safe source a file
safe_source() {
  if file_readable "$1"; then
    source "$1"
    return 0
  else
    log_error "Cannot source file: $1"
    return 1
  fi
}

# Export functions for use in other scripts
export -f notify notify_error notify_success
export -f log log_error
export -f command_exists service_running
export -f get_config_dir file_readable safe_source
