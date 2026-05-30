#!/bin/bash
# Prefer a USB Wi-Fi dongle over the built-in Wi-Fi card.
#
# omarchy does DHCP/routing via systemd-networkd, and its shipped
# 20-wlan.network gives every wl* interface the same RouteMetric=600. So when a
# dongle and the built-in card are both connected the default route is a tie
# and the kernel may pick either. If a Wi-Fi dongle is plugged in, it should win.
#
# This higher-priority file matches any USB-attached Wi-Fi interface (Name=wl*
# on the USB bus, so the built-in PCIe/M.2 card is excluded) and gives it
# RouteMetric=300, slotting it between Ethernet (100) and built-in Wi-Fi (600):
#   Ethernet > USB Wi-Fi dongle > built-in Wi-Fi.
# The built-in card stays connected as an automatic fallback.
#
# Inert on machines with no USB Wi-Fi dongle: the [Match] matches nothing.
set -e

target=/etc/systemd/network/10-wifi-dongle.network
content='[Match]
Name=wl*
Path=*usb*

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
MulticastDNS=yes

[DHCPv4]
RouteMetric=300

[IPv6AcceptRA]
RouteMetric=300'

if [ "$(cat "$target" 2>/dev/null)" != "$content" ]; then
  printf '%s\n' "$content" | sudo tee "$target" >/dev/null
  sudo networkctl reload
  # Reapply addressing on any connected USB Wi-Fi dongle so the metric takes effect now.
  for dev in /sys/class/net/*; do
    [ -d "$dev/wireless" ] || continue
    case "$(readlink -f "$dev/device" 2>/dev/null)" in
      *usb*) sudo networkctl reconfigure "$(basename "$dev")" || true ;;
    esac
  done
fi
