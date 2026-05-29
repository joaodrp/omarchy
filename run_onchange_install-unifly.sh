#!/bin/bash
# Install unifly CLI/TUI (github.com/hyperb1iss/unifly) and its Claude
# Code skill. The skill install needs --agent claude-code to symlink
# into ~/.claude/skills/ (skills land in ~/.agents/skills/ either way).
set -e

omarchy pkg aur add unifly-bin

if [ ! -L "$HOME/.claude/skills/unifly" ]; then
    npx --yes skills add hyperb1iss/unifly --global --agent claude-code --yes
fi
