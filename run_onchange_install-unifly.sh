#!/bin/bash
# Install unifly — CLI + TUI for UniFi Network Controllers
# (github.com/hyperb1iss/unifly) — plus its Claude Code skill bundle.
# Tool + skill ship together so the CLI and the agent that knows how
# to drive it arrive on the machine in lockstep.
#
# How npx skills lays things out:
# - Canonical skill storage is ~/.agents/skills/<name>. Agents that
#   read directly from there (codex, opencode, etc.) pick it up without
#   any per-agent step.
# - Claude Code reads from ~/.claude/skills/ instead, so it needs an
#   explicit symlink there. Passing --agent claude-code creates that
#   symlink. Without it the skill would be installed in ~/.agents but
#   invisible to Claude Code.
#
# Idempotent:
# - omarchy pkg aur add skips already-installed packages.
# - The skill install is guarded on the ~/.claude/skills/unifly
#   symlink. skills add re-clones the upstream repo each time, so
#   skipping when the symlink already exists avoids the noise.
set -e

omarchy pkg aur add unifly-bin

if [ ! -L "$HOME/.claude/skills/unifly" ]; then
    npx --yes skills add hyperb1iss/unifly --global --agent claude-code --yes
fi
