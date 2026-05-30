#!/bin/bash
# Add the perplexity MCP server to ~/.config/opencode/opencode.json
# via a jq merge. `op run` resolves PERPLEXITY_API_KEY from 1Password
# at server-startup time; nothing secret lands on disk.
#
# Idempotent. Preserves all other opencode settings — omarchy defaults
# and opencode's runtime writes pass through.
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
    }
  })
}' "$config" > "$tmpfile" && mv "$tmpfile" "$config"
