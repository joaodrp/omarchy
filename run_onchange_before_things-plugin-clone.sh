#!/bin/bash
# The Things widget moved from a pinned archive to a clone of my fork. chezmoi
# only pulls an existing directory, so set aside an archive copy (no .git)
# once; the clone then takes its place. A symlinked dev checkout is left alone.
set -e

dir=$HOME/.config/omarchy/plugins/reysu.things
if [ -d "$dir" ] && [ ! -L "$dir" ] && [ ! -d "$dir/.git" ]; then
    backups=${XDG_CACHE_HOME:-$HOME/.cache}/plugin-backups
    mkdir -p "$backups"
    mv "$dir" "$backups/reysu.things-$(date +%Y%m%d%H%M%S)"
fi
