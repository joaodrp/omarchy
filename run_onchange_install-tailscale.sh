#!/bin/bash
# Install Tailscale. The pkg guard avoids re-running `tailscale up`, which
# blocks on web auth.
set -e

if ! omarchy pkg present tailscale; then
    omarchy install tailscale
fi
