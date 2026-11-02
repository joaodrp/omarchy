#!/bin/bash
# Install Voxtype dictation with omarchy's default config. Mirrors
# omarchy-voxtype-install minus its gum confirm, which cannot run unattended,
# then marks omarchy's one-time install invitation done so it never pops up.
set -e

if omarchy-pkg-missing voxtype-bin; then
    omarchy-pkg-add wtype voxtype-bin
    mkdir -p ~/.config/voxtype
    [ -f ~/.config/voxtype/config.toml ] ||
        cp /usr/share/omarchy/default/voxtype/config.toml ~/.config/voxtype/
    voxtype setup --download --no-post-install
    omarchy-hw-vulkan && { voxtype setup gpu --enable || true; }
    voxtype setup systemd
fi

omarchy-done mark voxtype-install-invitation
