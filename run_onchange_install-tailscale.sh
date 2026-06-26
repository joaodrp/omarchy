#!/bin/bash
# Install Tailscale and enable Tailscale SSH (lets tailnet peers SSH/Mosh in,
# ACL-gated, no keys). The pkg guard avoids re-running `tailscale up`, which
# blocks on web auth. `set --ssh` is idempotent and skipped until authed.
set -e

if ! omarchy pkg present tailscale; then
    omarchy install tailscale
fi

if tailscale status >/dev/null 2>&1; then
    sudo tailscale set --ssh
fi
