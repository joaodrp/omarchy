#!/bin/bash
# Sunshine, the Moonlight streaming host. omarchy's installer also opens the
# ufw ports for private LANs and tailscale0, and installs the admin web app.
#
# run_after rather than run_onchange: the autostart removal below has to
# reconverge, since a later repair or re-run of omarchy's installer re-adds
# the entry.
set -e

# The installer opens the admin UI in a browser, so only call it when the
# package is absent.
if omarchy-pkg-missing sunshine; then
  omarchy install service sunshine
fi

# The installer appends this entry, but the packaged unit is
# WantedBy=graphical-session.target and already enabled, so the entry starts a
# second sunshine that cannot bind the ports.
autostart="$HOME/.config/hypr/autostart.lua"
if [ -f "$autostart" ]; then
  sed -i '/^o\.launch_on_start("sunshine")$/d' "$autostart"
fi
