#!/bin/bash
# Prefer a USB Wi-Fi dongle over the built-in Wi-Fi card.
#
# NetworkManager gives every Wi-Fi connection the same default route metric
# (600), so when a dongle and the built-in card are both connected the default
# route is a tie and the kernel may pick either. If a dongle is plugged in, it
# should win.
#
# The metric lives on the connection profile, which is keyed by SSID -- and the
# same SSID roams across both radios, so it cannot encode which radio is
# preferred. The choice has to be made when a link comes up, hence a dispatcher
# script: on `up` for a USB-attached Wi-Fi interface, drop that profile to
# metric 300, slotting it between Ethernet (100) and built-in Wi-Fi (600):
#   Ethernet > USB Wi-Fi dongle > built-in Wi-Fi.
# The built-in card stays connected as an automatic fallback.
#
# Inert on machines with no USB Wi-Fi dongle: the bus check matches nothing.
set -e

target=/etc/NetworkManager/dispatcher.d/10-prefer-wifi-dongle

content=$(cat <<'DISPATCHER'
#!/bin/bash
iface=$1
action=$2

[ "$action" = "up" ] || exit 0
[ -d "/sys/class/net/$iface/wireless" ] || exit 0
case "$(readlink -f "/sys/class/net/$iface/device" 2>/dev/null)" in
    *usb*) ;;
    *) exit 0 ;;
esac

[ -n "${CONNECTION_UUID:-}" ] || exit 0

# Bail when already correct, so the reapply below cannot retrigger this script.
[ "$(nmcli -g ipv4.route-metric connection show "$CONNECTION_UUID")" = "300" ] && exit 0

nmcli connection modify "$CONNECTION_UUID" ipv4.route-metric 300 ipv6.route-metric 300
nmcli device reapply "$iface"
DISPATCHER
)

if [ "$(sudo cat "$target" 2>/dev/null)" != "$content" ]; then
    printf '%s\n' "$content" | sudo tee "$target" >/dev/null
    # NetworkManager silently skips dispatcher scripts that are not owned by
    # root or are group/other-writable.
    sudo chown root:root "$target"
    sudo chmod 0755 "$target"
fi

# The systemd-networkd rule this replaces; networkd is disabled under omarchy 4.
sudo rm -f /etc/systemd/network/10-wifi-dongle.network
