#!/bin/bash
# Merge personal entries into ~/.claude.json (Claude Code's user-scope config)
# without touching Claude's own state (auth, project history, counters).
# Currently just the Perplexity MCP server, mirroring the codex/opencode
# configs. `op run` resolves PERPLEXITY_API_KEY from 1Password at server
# startup; nothing secret lands on disk. Idempotent.
#
# NOTE: a running Claude rewrites ~/.claude.json on exit, so apply with Claude
# closed (and restart it) for the change to stick and load.
set -e

CLAUDE_JSON="$HOME/.claude.json"
[ -f "$CLAUDE_JSON" ] || echo '{}' > "$CLAUDE_JSON"

tmpfile=$(mktemp)
jq '.mcpServers.perplexity = {
  "type": "stdio",
  "command": "op",
  "args": ["run", "--no-masking", "--", "npx", "-y", "@perplexity-ai/mcp-server"],
  "env": { "PERPLEXITY_API_KEY": "op://Personal/Perplexity/claude_api_key" }
}' "$CLAUDE_JSON" > "$tmpfile" && mv "$tmpfile" "$CLAUDE_JSON"
