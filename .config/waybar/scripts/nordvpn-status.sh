#!/usr/bin/env bash

for iface in nordlynx tun0; do
  if ip link show "$iface" &>/dev/null && ip link show "$iface" | grep -q "UP"; then
    ip=$(ip -4 addr show "$iface" | awk '/inet / {print $2}' | cut -d/ -f1)
    printf '{"text":" 󰌾 VPN: [ACTIVE]","class":"connected","tooltip":"Connected via %s — %s"}\n' "$iface" "${ip:-no ip}"
    exit 0
  fi
done

printf '{"text":" 󰌿 VPN: [OFF]","class":"disconnected","tooltip":"VPN disconnected"}\n'
