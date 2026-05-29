#!/bin/bash
# Install Tailscale. Guarded with `omarchy pkg present` so re-apply does
# not re-trigger `sudo tailscale up`, which on first install prints the
# login URL and blocks until web auth completes.
set -e

if ! omarchy pkg present tailscale; then
    omarchy install tailscale
fi
