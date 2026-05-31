#!/usr/bin/env bash
# VPN control menu for Rofi

export PATH="/usr/bin:/usr/local/bin:/sbin:/bin:$HOME/.local/bin"

CONFIG_DIR="$HOME/.config/openvpn"
LAST_SERVER_FILE="$HOME/.config/vpn-last-server"
CRED_FILE="$HOME/.vpn_credentials"
ROFI_ARGS=(-theme-str 'window {width: 400px;}' -i -dmenu -p "VPN")

if pgrep -x openvpn >/dev/null; then
  config=$(ps aux | grep '[o]penvpn.*--config' | grep -o '/[^ ]*\.ovpn' | head -1)
  server=$(basename "$config" .ovpn)

  choice=$(printf "󰌾 Disconnect\n󰑓 Switch Server\n View Logs" | rofi "${ROFI_ARGS[@]}")

  case "$choice" in
    *Disconnect*)
      sudo pkill openvpn
      notify-send -i network-vpn "VPN" "Disconnected"
      ;;
    *Switch*)
      sudo pkill openvpn
      sleep 1
      kitty --detach -e startvpn
      ;;
    *Logs*)
      kitty --detach -e journalctl -u openvpn -f
      ;;
  esac
else
  last_label="Quick Connect"
  if [[ -f "$LAST_SERVER_FILE" ]]; then
    last_name=$(basename "$(cat "$LAST_SERVER_FILE")" .ovpn)
    last_label="Quick Connect: $last_name"
  fi

  choice=$(printf "󰌿 Connect to VPN\n%s\n⚙ Settings" "$last_label" | rofi "${ROFI_ARGS[@]}")

  case "$choice" in
    *"Connect to VPN"*)
      kitty --detach -e startvpn
      ;;
    *"Quick Connect"*)
      last_config=""
      [[ -f "$LAST_SERVER_FILE" ]] && last_config=$(cat "$LAST_SERVER_FILE")
      [[ -z "$last_config" || ! -f "$last_config" ]] && last_config=$(ls -t "$CONFIG_DIR"/*.ovpn 2>/dev/null | head -1)

      if [[ -n "$last_config" ]]; then
        notify-send -i network-vpn "VPN" "Connecting to $(basename "$last_config" .ovpn)..."
        kitty --detach -e bash -c "sudo openvpn --config '$last_config' --auth-user-pass '$CRED_FILE'; read -p 'Press enter to close...'"
      else
        notify-send -u critical "VPN" "No VPN configs found in $CONFIG_DIR"
      fi
      ;;
    *Settings*)
      last=$(cat "$LAST_SERVER_FILE" 2>/dev/null || echo "none")
      kitty --detach -e bash -c "echo 'OpenVPN configs in $CONFIG_DIR:'; ls -lh $CONFIG_DIR/*.ovpn 2>/dev/null; echo; echo 'Last used: $last'; read -p 'Press enter to close...'"
      ;;
  esac
fi
