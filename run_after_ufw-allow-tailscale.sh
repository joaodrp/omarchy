#!/bin/bash
# Trust the Tailscale interface in ufw. Tailnet peers reach Mosh's UDP and
# wayvnc on 5900; both bind to the tailnet address only, and access is gated by
# tailnet ACLs rather than by port. Reconciled on every apply: ufw can be
# inactive at first apply, and enabling it later changes no script's hash.
set -e

systemctl is-active --quiet ufw || exit 0

# ufw's rule files are world-readable, so a converged apply needs no sudo.
if ! grep -q 'in_tailscale0$' /etc/ufw/user.rules /etc/ufw/user6.rules 2>/dev/null; then
    sudo ufw allow in on tailscale0
fi
