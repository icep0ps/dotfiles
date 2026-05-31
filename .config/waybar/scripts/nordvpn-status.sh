#!/usr/bin/env bash
# Enhanced VPN status for OpenVPN + NordVPN

# Check if VPN interface is up
vpn_active=false
for iface in nordlynx tun0; do
  if ip link show "$iface" &>/dev/null && ip link show "$iface" | grep -q "UP"; then
    vpn_active=true
    vpn_iface="$iface"
    vpn_ip=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    break
  fi
done

if [[ "$vpn_active" == "false" ]]; then
  printf '{"text":"󰌿 VPN: [OFF]","class":"disconnected","tooltip":"Click to connect"}\n'
  exit 0
fi

# Try to get server info from OpenVPN process
server_name="Unknown"
if pgrep -x openvpn >/dev/null; then
  config=$(ps aux | grep '[o]penvpn.*--config' | grep -o '/[^ ]*\.ovpn' | head -1)
  if [[ -n "$config" ]]; then
    server_name=$(basename "$config" .ovpn)
  fi
fi

tooltip="Connected via ${vpn_iface}\\nServer: ${server_name}\\nIP: ${vpn_ip}"
printf '{"text":"󰌾 VPN: [ACTIVE]","class":"connected","tooltip":"%s"}\n' "$tooltip"
