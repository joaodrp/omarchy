#!/bin/bash
# Merge personal Claude Code settings into ~/.claude/settings.json without
# touching omarchy defaults, runtime-added keys (permission grants), or any
# future omarchy/Claude Code additions. Idempotent: re-running produces the
# same result.
#
# Currently the only managed key is the statusLine pointer, which activates
# ~/.claude/statusline.sh. Additional keys can be added to the jq filter
# below as needed.
set -e

SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

tmpfile=$(mktemp)
jq '. + {
  "statusLine": {
    "type": "command",
    "command": "$HOME/.claude/statusline.sh"
  }
}' "$SETTINGS" > "$tmpfile" && mv "$tmpfile" "$SETTINGS"
