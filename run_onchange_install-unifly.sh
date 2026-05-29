#!/bin/bash
# Install unifly — CLI + TUI for UniFi Network Controllers
# (github.com/hyperb1iss/unifly) — plus its Claude Code skill bundle.
# Tool + skill ship together so agents that know how to drive the CLI
# arrive on the machine in lockstep with the CLI itself.
#
# Skill scope: --agent claude-code only. If other agents (codex,
# opencode, etc.) get installed later, they wont silently inherit
# this skill — re-run with --agent '*' if thats desired.
#
# Idempotent:
# - omarchy pkg aur add skips already-installed packages.
# - The skill install is guarded on the claude-code symlink (skills add
#   re-clones the upstream repo each time, so skipping when present
#   avoids unnecessary work).
set -e

omarchy pkg aur add unifly-bin

if [ ! -L "$HOME/.claude/skills/unifly" ]; then
    npx --yes skills add hyperb1iss/unifly --global --agent claude-code --yes
fi
