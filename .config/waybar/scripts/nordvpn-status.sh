#!/bin/bash

# Check if tun0 (OpenVPN interface) exists and is up
if ip a show tun0 up >/dev/null 2>&1; then
  # Optional: get VPN server IP (remote IP assigned by OpenVPN)
  server_ip=$(ip addr show tun0 | awk '/inet / {print $2}' | cut -d/ -f1)

  printf '{"text":" VPN: [ACTIVE]","class":"connected","tooltip":"Connected via OpenVPN (tun0) - %s"}\n' "$server_ip"
else
  printf '{"text":" VPN: [OFF]","class":"disconnected","tooltip":"OpenVPN is disconnected"}\n'
fi
