#!/bin/bash
# Merge personal MCP servers into ~/.claude.json (Claude Code's user-scope
# config) without touching Claude's own state (auth, project history,
# counters). Servers load their API keys via the agent-secrets wrapper.
# Idempotent.
#
# NOTE: a running Claude rewrites ~/.claude.json on exit, so apply with Claude
# closed (and restart it) for the change to stick and load.
set -e

CLAUDE_JSON="$HOME/.claude.json"
[ -f "$CLAUDE_JSON" ] || echo '{}' > "$CLAUDE_JSON"

tmpfile=$(mktemp)
jq '.mcpServers.perplexity = {
  "type": "stdio",
  "command": "with-agent-secrets",
  "args": ["npx", "-y", "@perplexity-ai/mcp-server"]
} | .mcpServers.context7 = {
  "type": "stdio",
  "command": "with-agent-secrets",
  "args": ["npx", "-y", "@upstash/context7-mcp"]
}' "$CLAUDE_JSON" > "$tmpfile" && mv "$tmpfile" "$CLAUDE_JSON"
