#!/bin/bash
# Default to Omarchy's Starship theme, once per machine, so a later switch
# sticks.
set -e

current=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)
if [[ $current != starship ]]; then
  omarchy theme set starship
fi
