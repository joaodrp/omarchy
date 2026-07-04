#!/bin/bash
# Add the perplexity and context7 MCP servers to
# ~/.config/opencode/opencode.json. `op run` resolves each API key from
# 1Password at server-startup time; nothing secret lands on disk.
#
# Idempotent. Preserves omarchy defaults and opencode's runtime writes.
set -e

config="$HOME/.config/opencode/opencode.json"
mkdir -p "$(dirname "$config")"
[ -f "$config" ] || echo '{}' > "$config"

tmpfile=$(mktemp)
jq '. + {
  mcp: ((.mcp // {}) + {
    perplexity: {
      type: "local",
      command: ["op", "run", "--no-masking", "--", "npx", "-y", "@perplexity-ai/mcp-server"],
      env: {
        PERPLEXITY_API_KEY: "op://Personal/Perplexity/opencode_api_key"
      },
      enabled: true
    },
    context7: {
      type: "local",
      command: ["op", "run", "--no-masking", "--", "npx", "-y", "@upstash/context7-mcp"],
      env: {
        CONTEXT7_API_KEY: "op://Personal/Context7/api_key"
      },
      enabled: true
    }
  })
}' "$config" > "$tmpfile" && mv "$tmpfile" "$config"
