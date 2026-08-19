#!/bin/bash
# Trust the Tailscale interface in ufw. Tailnet peers reach Mosh's UDP and
# wayvnc on 5900; both bind to the tailnet address only, and access is gated by
# tailnet ACLs rather than by port. Reconciled on every apply: ufw can be
# inactive at first apply, and enabling it later changes no script's hash.
set -e

systemctl is-active --quiet ufw || exit 0

if ! sudo ufw status | grep -q 'tailscale0'; then
    sudo ufw allow in on tailscale0
fi
