#!/bin/bash
# Remove webapps I don't use, Omarchy's defaults and ones superseded by a
# desktop app. Idempotent — skips
# items that are already gone. Runs on every `chezmoi apply`, including
# the post-update hook, so anything omarchy re-creates after an update
# gets re-removed automatically.
set -e

APPS_DIR="$HOME/.local/share/applications"

# Basecamp and HEY are omarchy's, re-copied on every
# `omarchy refresh applications`; Claude is the webapp before claude-desktop.
REMOVE_DESKTOP_FILES=(
    "Basecamp.desktop"
    "HEY.desktop"
    "Claude.desktop"
)

# `omarchy webapp remove` also clears the icon and refreshes the desktop
# database; it is quiet about apps that are already gone.
for f in "${REMOVE_DESKTOP_FILES[@]}"; do
    OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "${f%.desktop}" >/dev/null 2>&1 || rm -f "$APPS_DIR/$f"
done
