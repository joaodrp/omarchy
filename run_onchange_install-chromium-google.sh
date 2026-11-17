#!/bin/bash
# Add Google OAuth client id/secret flags to chromium-flags.conf so Chromium
# (which has no API keys of its own) can sign in to Google accounts.
#
# Idempotent at the helper layer: omarchy-install-chromium-google-account
# uses `grep -qxF` to skip already-present lines.
#
# Touch the flags file first: the helper silently no-ops without it, and only
# Omarchy's config seeding creates it.
set -e

mkdir -p "$HOME/.config"
touch "$HOME/.config/chromium-flags.conf"
omarchy install chromium-google-account
