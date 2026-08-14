#!/bin/bash
# Remove Omarchy default apps and addons I don't use. Idempotent — skips
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
    "Google Photos.desktop"
)

# `omarchy webapp remove` also clears the icon and refreshes the desktop
# database; it is quiet about apps that are already gone.
for f in "${REMOVE_DESKTOP_FILES[@]}"; do
    OMARCHY_REMOVE_NOTIFY=false omarchy webapp remove "${f%.desktop}" >/dev/null 2>&1 || rm -f "$APPS_DIR/$f"
done

# Sweep orphaned dependencies — packages installed as deps that now have no
# reverse dependency. `pacman -Qtdq` returns only true orphans, so this is
# safe to run automatically. Quiet when there are none.
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    # Echo what's about to be removed so the automatic removal is auditable, not
    # silent.
    echo "removing orphaned packages:" $orphans
    # shellcheck disable=SC2086
    sudo pacman -Rns --noconfirm $orphans
fi
