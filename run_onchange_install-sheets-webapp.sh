#!/bin/bash
# Install Google Sheets as a webapp.
#
# Icon: the Sheets glyph from Dashboard Icons (omarchy's convention, see
# dashboardicons.com). Without an explicit icon the installer falls back to
# Google's favicon service, which can return a generic/low-res icon.
set -e

ICON_URL="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-sheets.png"
ICON_PATH="$HOME/.local/share/applications/icons/Google Sheets.png"

if [ ! -f "$HOME/.local/share/applications/Google Sheets.desktop" ]; then
    omarchy webapp install "Google Sheets" \
        "https://sheets.google.com" \
        "$ICON_URL"
fi

# Ensure the icon is the Sheets glyph even on machines provisioned before this
# fix (the desktop-entry guard above skips reinstall, so refresh it directly).
mkdir -p "$(dirname "$ICON_PATH")"
curl -fsSL -o "$ICON_PATH" "$ICON_URL" || true
