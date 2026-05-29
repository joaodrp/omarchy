#!/bin/bash
# Install Omarchy apps and dev environments I use. Re-runs only when this
# file's content changes (run_onchange) — installs can prompt for sudo,
# Tailscale web auth, and Dropbox login, so re-running on every apply
# would be intrusive and pointless.
#
# Underlying helpers are idempotent for the package layer (pacman/mise
# skip already-installed). Explicit guards wrap installs whose post-step
# is not (e.g. `tailscale up`, `dropbox-cli start`).
set -e

# Development environments (mise + pacman, as omarchy-install-dev-env defines).
for env in ruby go rust zig; do
    omarchy install dev-env "$env"
done

# Cloud sync, VPN. Both prompt for auth/login on first install. Skip if
# already installed so re-applies don't re-trigger `tailscale up` or
# `dropbox-cli start`.
if ! omarchy pkg present dropbox; then
    omarchy install dropbox
fi
if ! omarchy pkg present tailscale; then
    omarchy install tailscale
fi

# Gmail as default mailto handler. The webapp installer registers
# Gmail.desktop with MimeType=x-scheme-handler/mailto; xdg-mime then
# promotes it to the user default.
if [ ! -f "$HOME/.local/share/applications/Gmail.desktop" ]; then
    omarchy webapp install "Gmail" \
        "https://mail.google.com" \
        "https://www.google.com/s2/favicons?domain=mail.google.com&sz=128" \
        "" \
        "x-scheme-handler/mailto"
fi
xdg-mime default Gmail.desktop x-scheme-handler/mailto
