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
# preferred. The choice has to be made when a link comes up, hence a dispatcher:
#   Ethernet (100) > USB Wi-Fi dongle (300) > built-in Wi-Fi (600).
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
[ -n "${CONNECTION_UUID:-}" ] || exit 0

case "$(readlink -f "/sys/class/net/$iface/device" 2>/dev/null)" in
    *usb*) want=300 ;;
    *) want=-1 ;;
esac

# Reset to -1 (NM's 600 default) too, or the built-in card keeps the dongle's
# priority once the dongle is unplugged. Bailing when already correct stops the
# reapply below retriggering this.
[ "$(nmcli -g ipv4.route-metric connection show "$CONNECTION_UUID")" = "$want" ] && exit 0

nmcli connection modify "$CONNECTION_UUID" ipv4.route-metric "$want" ipv6.route-metric "$want"
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

# networkd is unused under omarchy 4; clear its rule.
sudo rm -f /etc/systemd/network/10-wifi-dongle.network
