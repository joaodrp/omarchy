#!/bin/bash
# Manage Wi-Fi power save per machine, keyed on chassis type.
#
# Why: with power save on, iwlwifi uses SM Power Save and asks the AP to send a
# single spatial stream, so RX drops to NSS 1 (TX stays NSS 2) and download is
# roughly halved. On AC-powered machines there's no upside, so turn it off; on
# battery-class machines (laptops) power save is wanted, so leave it alone.
#
# Selection is automatic via `hostnamectl chassis` — no per-machine config:
#   laptop/tablet/handset/convertible/watch -> keep power save (remove our rule)
#   everything else (desktop/server/vm/...)  -> disable power save
#
# The udev rule re-applies the setting on every Wi-Fi interface (re)creation
# (boot, driver reload, rfkill toggle). iwd does not manage 802.11 power save,
# so once cleared it stays cleared across (re)associations. Idempotent and
# reversible: flipping chassis (or moving the repo to a laptop) removes the rule.
set -e

RULE=/etc/udev/rules.d/81-wifi-powersave.rules
RULE_CONTENT='ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="/usr/bin/iw dev $name set power_save off"'

case "$(hostnamectl chassis 2>/dev/null)" in
    laptop | tablet | handset | convertible | watch)
        # Battery-class machine: keep power save. Drop our override if present.
        if [ -f "$RULE" ]; then
            sudo rm -f "$RULE"
            sudo udevadm control --reload
        fi
        exit 0
        ;;
esac

# AC-powered machine: install the rule (skip if unchanged, to avoid a needless reload).
if [ "$(cat "$RULE" 2>/dev/null)" != "$RULE_CONTENT" ]; then
    printf '%s\n' "$RULE_CONTENT" | sudo tee "$RULE" >/dev/null
    sudo udevadm control --reload
fi

# Apply now to any Wi-Fi interface already up (the rule covers future boots).
for dev in /sys/class/net/*/wireless; do
    [ -e "$dev" ] || continue
    iface=$(basename "$(dirname "$dev")")
    sudo iw dev "$iface" set power_save off || true
done
