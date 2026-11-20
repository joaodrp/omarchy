#!/bin/bash
# After an apply, say when a tracked upstream fix has reached this machine or
# a pinned plugin has new commits to review. At most once a day, silent when
# nothing needs action or GitHub is out of reach, and never fails the apply.

stamp="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-doctor/upstream-checked"
[ -z "$(find "$stamp" -mmin -1440 2>/dev/null)" ] || exit 0
command -v dotfiles-doctor >/dev/null || exit 0
timeout 10 gh api rate_limit >/dev/null 2>&1 || exit 0

dotfiles-doctor --upstream --quiet || true
mkdir -p "${stamp%/*}" && touch "$stamp"
