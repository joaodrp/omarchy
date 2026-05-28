#!/bin/bash
# Remove Omarchy default apps and addons I don't use. Idempotent — skips
# items that are already gone. Runs on every `chezmoi apply`, including
# the post-update hook, so anything omarchy re-creates after an update
# gets re-removed automatically.
set -e

APPS_DIR="$HOME/.local/share/applications"

# Webapp .desktop files created by omarchy's first-run / webapp generator.
REMOVE_DESKTOP_FILES=(
    "Basecamp.desktop"
    "HEY.desktop"
    "Figma.desktop"
    "Fizzy.desktop"
    "Google Photos.desktop"
    "Google Messages.desktop"
)

for f in "${REMOVE_DESKTOP_FILES[@]}"; do
    rm -f "$APPS_DIR/$f"
done

# Pacman packages to drop. `omarchy pkg drop` is idempotent (skips packages
# that aren't installed). Empty list is a no-op.
DROP_PACKAGES=()

if (( ${#DROP_PACKAGES[@]} > 0 )); then
    omarchy pkg drop "${DROP_PACKAGES[@]}"
fi

# Sweep orphaned dependencies — packages installed as deps that now have no
# reverse dependency. `pacman -Qtdq` returns only true orphans, so this is
# safe to run automatically. Quiet when there are none.
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    # shellcheck disable=SC2086
    sudo pacman -Rns --noconfirm $orphans
fi
