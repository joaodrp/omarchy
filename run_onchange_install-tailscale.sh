#!/bin/bash
# Install Tailscale and accept advertised subnet routes (e.g. the home LAN via
# the raspberry-pi subnet router), so route acceptance is reproducible per
# machine.
#
# The pkg guard avoids re-triggering `tailscale up`, which blocks on web auth.
# `set --accept-routes` is idempotent and skipped until tailscale is authed.
set -e

if ! omarchy pkg present tailscale; then
    omarchy install tailscale
fi

if tailscale status >/dev/null 2>&1; then
    sudo tailscale set --accept-routes
fi
