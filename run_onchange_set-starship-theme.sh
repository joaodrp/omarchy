#!/bin/bash
# Default to Omarchy's Starship theme, once per machine, so a later switch
# sticks; and drop the Obsidian Circuit theme this used to install. Starship
# ships from Omarchy 4.5; before that, nothing changes.
set -e

[[ -d /usr/share/omarchy/themes/starship ]] || exit 0

current=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
if [[ $current != starship ]]; then
  omarchy-theme-set starship
fi

if [[ -d $HOME/.config/omarchy/themes/obsidian-circuit ]]; then
  omarchy-theme-remove obsidian-circuit >/dev/null
fi
