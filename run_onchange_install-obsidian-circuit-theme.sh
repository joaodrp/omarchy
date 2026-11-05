#!/bin/bash
# Install the Obsidian Circuit theme (last-refuge) so it is selectable, without
# applying it. Tracks upstream: pull changes with `omarchy theme update`.
#
# `omarchy theme install` switches to the theme it installs, so switch back to
# whichever theme was active. Idempotent: skips when already installed, since
# the installer deletes and re-clones.
set -e

[[ -d $HOME/.config/omarchy/themes/obsidian-circuit ]] && exit 0

current_file=$HOME/.local/state/omarchy/current/theme.name
current=$(cat "$current_file" 2>/dev/null || true)

omarchy theme install https://github.com/last-refuge/omarchy-obsidian-circuit-theme.git

if [[ -n $current && $current != obsidian-circuit ]]; then
  omarchy-theme-set "$current"
fi
