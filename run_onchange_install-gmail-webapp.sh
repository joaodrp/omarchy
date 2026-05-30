#!/bin/bash
# Install Gmail as a webapp and register it as the default mailto handler.
# The omarchy webapp installer writes Gmail.desktop with the supplied
# MimeType; xdg-mime promotes it to the user default. Both steps are
# idempotent — file-existence guard for the desktop entry, and xdg-mime
# default just rewrites the mapping.
#
# Icon: pass the Gmail glyph from Dashboard Icons (omarchy's own convention,
# see dashboardicons.com). Without an explicit icon the installer falls back
# to Google's favicon service, which returns the generic Google "G" for
# mail.google.com rather than the Gmail envelope.
set -e

ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/gmail.png"
ICON_PATH="$HOME/.local/share/applications/icons/Gmail.png"

if [ ! -f "$HOME/.local/share/applications/Gmail.desktop" ]; then
    omarchy webapp install "Gmail" \
        "https://mail.google.com" \
        "$ICON_URL" \
        "" \
        "x-scheme-handler/mailto"
fi

# Ensure the icon is the Gmail glyph even on machines provisioned before this
# fix (the desktop-entry guard above skips reinstall, so refresh it directly).
mkdir -p "$(dirname "$ICON_PATH")"
curl -fsSL -o "$ICON_PATH" "$ICON_URL" || true

xdg-mime default Gmail.desktop x-scheme-handler/mailto
