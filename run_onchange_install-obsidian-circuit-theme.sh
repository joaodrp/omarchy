#!/bin/bash
# Install the Obsidian Circuit theme (last-refuge) so it is selectable; never
# switches to it. Tracks upstream: pull changes with `omarchy theme update`.
#
# Idempotent: skips when already installed, since `omarchy theme install`
# deletes and re-clones.
set -e

[[ -d $HOME/.config/omarchy/themes/obsidian-circuit ]] ||
  omarchy theme install https://github.com/last-refuge/omarchy-obsidian-circuit-theme.git
