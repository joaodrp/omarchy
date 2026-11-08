#!/bin/bash
# Add the perplexity and context7 MCP servers to
# ~/.config/opencode/opencode.json. Servers load their API keys via the
# agent-secrets wrapper.
#
# Preserves omarchy defaults and opencode's runtime writes; written only when
# it changes.
set -e

config="$HOME/.config/opencode/opencode.json"
mkdir -p "$(dirname "$config")"
[ -f "$config" ] || echo '{}' > "$config"

tmpfile=$(mktemp "$config.XXXXXX")
trap 'rm -f "$tmpfile"' EXIT
jq '. + {
  mcp: ((.mcp // {}) + {
    perplexity: {
      type: "local",
      command: ["with-agent-secrets", "npx", "-y", "@perplexity-ai/mcp-server"],
      enabled: true
    },
    context7: {
      type: "local",
      command: ["with-agent-secrets", "npx", "-y", "@upstash/context7-mcp"],
      enabled: true
    }
  })
}' "$config" > "$tmpfile"
cmp -s "$tmpfile" "$config" || mv "$tmpfile" "$config"
