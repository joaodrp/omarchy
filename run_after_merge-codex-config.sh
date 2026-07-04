#!/bin/bash
# Merge personal Codex CLI settings into ~/.codex/config.toml (TOML, via
# mikefarah/yq). Preserves codex's runtime additions (trusted projects,
# plugin toggles) and rewrites only the managed keys below.
#
# Idempotent. Skips quietly when yq isn't installed yet (first apply
# on a fresh machine; its installer runs in the same apply, but order
# isn't guaranteed).
set -e

if ! command -v yq >/dev/null 2>&1; then
    exit 0
fi

config="$HOME/.codex/config.toml"
mkdir -p "$(dirname "$config")"
[ -f "$config" ] || : > "$config"
chmod 600 "$config"

yq -i -p toml -o toml '
  .model = "gpt-5.5" |
  .model_reasoning_effort = "high" |
  .personality = "pragmatic" |
  .features.default_mode_request_user_input = true |
  del(.default_mode_request_user_input) |
  .mcp_servers.openaiDeveloperDocs = {"url": "https://developers.openai.com/mcp"} |
  .mcp_servers.perplexity = {
    "command": "with-agent-secrets",
    "args": ["npx", "-y", "@perplexity-ai/mcp-server"]
  } |
  .mcp_servers.context7 = {
    "command": "with-agent-secrets",
    "args": ["npx", "-y", "@upstash/context7-mcp"]
  } |
  .plugins."github@openai-curated".enabled = true
' "$config"
