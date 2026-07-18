#!/bin/bash
# Install direnv and hook it into bash. Idempotent: omarchy pkg add no-ops if
# already installed, and the hook is only appended once.
set -e

omarchy pkg add direnv

HOOK='eval "$(direnv hook bash)"'
grep -qxF "$HOOK" "$HOME/.bashrc" || echo "$HOOK" >>"$HOME/.bashrc"
