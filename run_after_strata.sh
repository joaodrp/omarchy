#!/bin/bash
# Make Strata the file manager: folders, the portal file chooser and, via the
# vendored FileManager1 service, "Show in folder". Each step runs only when its
# check fails, so `omarchy refresh config` resetting the portal file is repaired
# on the next apply and a converged apply changes nothing.
set -e

bin="$HOME/.local/bin/strata"
desktop=io.github.lgse.Strata.desktop

# The installer resolves and verifies the latest stable release itself, and the
# app updates in place afterwards. It refuses to overwrite an existing binary.
if [ ! -x "$bin" ]; then
    curl -fsSL https://raw.githubusercontent.com/lgse/strata/v1.1.1/install.sh | bash -s -- \
        --non-interactive --with-desktop-entry --with-raw \
        --without-folder-association --without-file-manager --without-file-chooser \
        --without-smb --without-omarchy-keybinds --without-udiskie-unlock
fi

if [ "$(xdg-mime query default inode/directory)" != "$desktop" ]; then
    xdg-mime default "$desktop" inode/directory
fi

if ! grep -qs '^org\.freedesktop\.impl\.portal\.FileChooser=strata;' \
    "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"; then
    "$bin" --install-portal
fi
