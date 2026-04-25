#!/bin/bash
# =============================================================
#  wifi_rofi.sh — NetworkManager Wi-Fi manager for Rofi
# =============================================================

EWW_BIN="/home/overlord/.local/share/eww/eww"
ROFI_ARGS=(-theme-str 'window {width: 520px;}' -i -l 12 -no-custom)

$EWW_BIN close control_center

# -------------------------------------------------------------
#  HELPERS
# -------------------------------------------------------------

notify() { notify-send "$1" "${2:-}"; }
notify_err() { notify-send -u critical "$1" "${2:-}"; }
wifi_on() { nmcli radio wifi | grep -q "enabled"; }

get_ip() {
  local dev
  dev=$(nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
  nmcli -t -f IP4.ADDRESS dev show "$dev" 2>/dev/null | awk -F'[:/]' 'NR==1 {print $2}'
}

# -------------------------------------------------------------
#  BUILD NETWORK LIST
# -------------------------------------------------------------

declare -gA ssid_map
declare -gA security_map
declare -gA band_map
declare -gA connected_map

get_networks() {
  ssid_map=()
  security_map=()
  band_map=()
  connected_map=()
  local seen=()
  local rofi_list=""

  while IFS=':' read -r in_use ssid security bars freq; do
    [[ -z "$ssid" ]] && continue
    [[ " ${seen[*]} " == *" $ssid "* ]] && continue
    seen+=("$ssid")

    local band="2.4G"
    [[ "$freq" == *"5"* ]] && band=" 5G "

    local sec_icon="󰌿 "
    [[ -n "$security" && "$security" != "--" ]] && sec_icon="󰌾 "

    local active=""
    [[ "$in_use" == "*" ]] && {
      active=" 󰱓"
      connected_map["$ssid"]=1
    }

    local display="${bars}  ${sec_icon}  ${band}  ${ssid}${active}"

    ssid_map["$display"]="$ssid"
    security_map["$ssid"]="$security"
    band_map["$ssid"]="$band"
    rofi_list+="${display}\n"
  done < <(nmcli -t -f IN-USE,SSID,SECURITY,BARS,FREQ device wifi list 2>/dev/null)

  ROFI_LIST="${rofi_list%\\n}"
}

# -------------------------------------------------------------
#  CONNECTED SUBMENU
# -------------------------------------------------------------

connected_submenu() {
  local ssid="$1"
  local ip
  ip=$(get_ip)
  local band="${band_map[$ssid]}"

  local choice
  choice=$(printf '%s\n' \
    "󰌐  Disconnect" \
    "󰮯  Forget Network" \
    "󰁍  Back" |
    rofi -dmenu -p "${ssid}  |  ${ip:-no ip}  |  ${band:-?}" "${ROFI_ARGS[@]}")

  [[ -z "$choice" ]] && return

  case "$choice" in
  *Disconnect*)
    nmcli connection down "$ssid" &>/dev/null
    notify "Disconnected" "You left ${ssid}."
    ;;
  *Forget*)
    local confirm
    confirm=$(printf '%s\n' "Yes, forget it" "Cancel" |
      rofi -dmenu -p "Forget \"${ssid}\"?" "${ROFI_ARGS[@]}")
    [[ "$confirm" == "Yes"* ]] && {
      nmcli connection delete "$ssid" &>/dev/null
      notify "Forgotten" "${ssid} removed from saved networks."
    }
    ;;
  *Back*) main_menu ;;
  esac
}

# -------------------------------------------------------------
#  CONNECT
# -------------------------------------------------------------

connect_to() {
  local ssid="$1"
  local security="${security_map[$ssid]}"

  if nmcli connection show "$ssid" &>/dev/null; then
    notify "Connecting" "Reconnecting to ${ssid}..."
    nmcli connection up "$ssid" &>/dev/null &&
      notify "Connected" "Now on ${ssid}." ||
      notify_err "Failed" "Could not reconnect to ${ssid}."
    return
  fi

  if [[ -n "$security" && "$security" != "--" ]]; then
    local pw
    pw=$(rofi -dmenu -password -p "Password for \"${ssid}\"" "${ROFI_ARGS[@]}")
    [[ -z "$pw" ]] && return
    nmcli device wifi connect "$ssid" password "$pw" &>/dev/null
  else
    nmcli device wifi connect "$ssid" &>/dev/null
  fi

  [[ $? -eq 0 ]] &&
    notify "Connected" "Now on ${ssid}." ||
    notify_err "Failed" "Wrong password or ${ssid} unreachable."
}

# -------------------------------------------------------------
#  HIDDEN NETWORK
# -------------------------------------------------------------

connect_hidden() {
  local ssid pw
  ssid=$(rofi -dmenu -p "Hidden Network SSID" "${ROFI_ARGS[@]}")
  [[ -z "$ssid" ]] && return
  pw=$(rofi -dmenu -password -p "Password for \"${ssid}\"" "${ROFI_ARGS[@]}")
  [[ -z "$pw" ]] && return
  nmcli device wifi connect "$ssid" password "$pw" hidden yes &>/dev/null &&
    notify "Connected" "Now on hidden network ${ssid}." ||
    notify_err "Failed" "Could not connect to ${ssid}."
}

# -------------------------------------------------------------
#  MAIN MENU
# -------------------------------------------------------------

main_menu() {
  get_networks

  local toggle_label="󰖪  Disable Wi-Fi"
  ! wifi_on && toggle_label="󰖩  Enable Wi-Fi"

  local choice
  choice=$(printf '%s\n' \
    "$toggle_label" \
    "󰈀  Connect to Hidden Network" \
    "󰑐  Rescan Networks" \
    $(echo -e "$ROFI_LIST") |
    rofi -dmenu -p "  Wi-Fi" "${ROFI_ARGS[@]}")

  [[ -z "$choice" ]] && exit 0

  case "$choice" in
  *"Wi-Fi"*)
    if wifi_on; then
      nmcli radio wifi off && notify "Wi-Fi Off" "Wireless disabled."
    else
      nmcli radio wifi on && notify "Wi-Fi On" "Scanning for networks..." && sleep 2 && main_menu
    fi
    ;;
  *Hidden*)
    connect_hidden
    ;;
  *Rescan*)
    notify "Rescanning" "Refreshing network list..."
    nmcli device wifi rescan &>/dev/null
    sleep 2
    main_menu
    ;;
  *)
    local ssid="${ssid_map[$choice]}"
    [[ -z "$ssid" ]] && exit 0
    [[ -n "${connected_map[$ssid]}" ]] &&
      connected_submenu "$ssid" ||
      connect_to "$ssid"
    ;;
  esac
}

# -------------------------------------------------------------
#  ENTRY POINT — kick off a background rescan immediately
#  so by the time the user picks a network the list is fresh
# -------------------------------------------------------------

nmcli device wifi rescan &>/dev/null &

if ! wifi_on; then
  choice=$(printf '%s\n' "󰖩  Enable Wi-Fi" "  Cancel" |
    rofi -dmenu -p "  Wi-Fi is off" "${ROFI_ARGS[@]}")
  [[ "$choice" == *Enable* ]] && {
    nmcli radio wifi on
    sleep 2
    main_menu
  }
  exit 0
fi

main_menu
