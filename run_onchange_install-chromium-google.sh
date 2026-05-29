#!/bin/bash
# Add Google OAuth client id/secret flags to chromium-flags.conf so Chromium
# (which has no API keys of its own) can sign in to Google accounts.
#
# Idempotent at the helper layer: omarchy-install-chromium-google-account
# uses `grep -qxF` to skip already-present lines.
#
# Touch the flags file first because the upstream helper silently no-ops if
# ~/.config/chromium-flags.conf doesn't exist (chromium creates it lazily on
# first launch otherwise).
set -e

mkdir -p "$HOME/.config"
touch "$HOME/.config/chromium-flags.conf"
omarchy install chromium-google-account
