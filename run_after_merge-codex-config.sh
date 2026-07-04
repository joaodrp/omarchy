#!/bin/bash
# Merge personal Codex CLI settings into ~/.codex/config.toml. Same
# pattern as run_after_merge-claude-settings.sh but for TOML, using
# mikefarah/yq instead of jq. Preserves codex's runtime additions
# (trusted projects, plugin toggles, future keys) and rewrites only
# the managed keys below.
#
# Idempotent. Skips quietly when yq isn't installed yet (first apply
# on a fresh machine; install-go-yq runs in the same apply, but order
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
    "command": "op",
    "args": ["run", "--no-masking", "--", "npx", "-y", "@perplexity-ai/mcp-server"],
    "env": {"PERPLEXITY_API_KEY": "op://Personal/Perplexity/codex_api_key"}
  } |
  .mcp_servers.context7 = {
    "command": "op",
    "args": ["run", "--no-masking", "--", "npx", "-y", "@upstash/context7-mcp"],
    "env": {"CONTEXT7_API_KEY": "op://Personal/Context7/api_key"}
  } |
  .plugins."github@openai-curated".enabled = true
' "$config"
