#!/bin/bash
# Open the Tailscale interface in ufw so tailnet peers can reach Mosh's UDP
# (Tailscale SSH itself works without this). Inert when ufw isn't active;
# idempotent (only adds the rule when absent).
set -e

systemctl is-active --quiet ufw || exit 0

if ! sudo ufw status | grep -q 'tailscale0'; then
    sudo ufw allow in on tailscale0
fi
