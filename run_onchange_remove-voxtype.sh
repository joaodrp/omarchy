#!/bin/bash
# Remove Voxtype: Hex is the dictation backend. Mirrors Omarchy 4.5's
# omarchy-remove-dictation-voxtype, models and config included, and keeps
# omarchy's one-time install invitation marked done so it never pops up.
set -e

if omarchy-cmd-present voxtype; then
    systemctl --user disable --now voxtype.service 2>/dev/null || true
    systemctl --user daemon-reload
    omarchy-pkg-drop voxtype-bin
    rm -rf ~/.config/voxtype ~/.local/share/voxtype
    config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/defaults/dictation"
    if [ -f "$config" ] && [ "$(cat "$config")" = voxtype ]; then
        rm "$config"
    fi
fi

omarchy-done mark voxtype-install-invitation
