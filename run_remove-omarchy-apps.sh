#!/bin/bash
# Remove Omarchy default webapps I don't use. Idempotent — skips
# items that are already gone. Runs on every `chezmoi apply`, including
# the post-update hook, so anything omarchy re-creates after an update
# gets re-removed automatically.
set -e

APPS_DIR="$HOME/.local/share/applications"

# Webapp .desktop files omarchy ships and re-copies on every
# `omarchy refresh applications`.
REMOVE_DESKTOP_FILES=(
    "Basecamp.desktop"
    "HEY.desktop"
)

# `omarchy webapp remove` also clears the icon and refreshes the desktop
# database; it is quiet about apps that are already gone.
for f in "${REMOVE_DESKTOP_FILES[@]}"; do
    OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "${f%.desktop}" >/dev/null 2>&1 || rm -f "$APPS_DIR/$f"
done
