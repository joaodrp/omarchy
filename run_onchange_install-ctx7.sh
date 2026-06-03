#!/bin/bash
# Install the Context7 CLI (ctx7) and wire it into each coding agent in CLI mode
# (no MCP server), matching the CLI-over-MCP preference. Installed via mise's
# npm backend so it survives node version changes (node is mise-managed and
# pinned to @latest).
#
# `ctx7 setup --cli` downloads the find-docs skill, installs a context7 rule,
# and stores the API key in ~/.context7/credentials.json (shared across all
# agents). Per agent it writes:
#   claude   -> ~/.claude/skills/find-docs + ~/.claude/rules/context7.md
#   codex    -> ~/.agents/skills/find-docs + a fenced block in ~/.codex/AGENTS.md
#   opencode -> ~/.agents/skills/find-docs + a fenced block in ~/.config/opencode/AGENTS.md
# The AGENTS.md edits are confined to <!-- context7 --> markers, so unrelated
# content in those files is preserved. The key is read from 1Password at apply
# time, so nothing secret lands in this repo.
#
# Re-runs only when this file changes (run_onchange). Both steps are idempotent:
# mise skips already-installed versions; `ctx7 setup -y` overwrites its own
# generated files. Setup is skipped quietly when op can't resolve the key (e.g.
# 1Password not signed in on the first apply). chezmoi records this script as
# run after a clean exit and will NOT re-run it on a plain re-apply, so if setup
# was skipped, run `ctx7 setup --<agent> --cli` manually once signed in (the
# shared credential makes every agent work thereafter).
#
# mise and `ctx7 setup` are chatty, so each step runs through `quiet`: output is
# suppressed on success and surfaced (with the failing command) only on error,
# keeping `chezmoi apply` clean without hiding failures.
set -e

# Run a command silently, but print its combined output and fail if it errors.
quiet() {
    local out
    if ! out="$("$@" 2>&1)"; then
        printf 'ctx7: command failed: %s\n%s\n' "$*" "$out" >&2
        return 1
    fi
}

quiet mise use -g npm:ctx7@latest

if api_key="$(op read 'op://Personal/Context7/api_key' 2>/dev/null)" && [ -n "$api_key" ]; then
    for agent in claude codex opencode; do
        quiet mise exec -- ctx7 setup --"$agent" --cli --api-key "$api_key" -y
    done
    echo "ctx7: configured for claude, codex, opencode"
else
    echo "ctx7: skipping setup (1Password key unavailable); run 'ctx7 setup --claude --cli' once signed in" >&2
fi
