#!/bin/bash
# Install Gmail as a webapp and register it as the default mailto handler.
# The omarchy webapp installer writes Gmail.desktop with the supplied
# MimeType; xdg-mime promotes it to the user default. Both steps are
# idempotent — file-existence guard for the desktop entry, and xdg-mime
# default just rewrites the mapping.
set -e

if [ ! -f "$HOME/.local/share/applications/Gmail.desktop" ]; then
    omarchy webapp install "Gmail" \
        "https://mail.google.com" \
        "https://www.google.com/s2/favicons?domain=mail.google.com&sz=128" \
        "" \
        "x-scheme-handler/mailto"
fi
xdg-mime default Gmail.desktop x-scheme-handler/mailto
