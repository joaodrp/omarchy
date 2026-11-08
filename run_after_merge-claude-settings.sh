#!/bin/bash
# Merge personal Claude Code settings into ~/.claude/settings.json without
# touching omarchy defaults, runtime-added keys (permission grants), or any
# future omarchy/Claude Code additions.
#
# Managed keys: the statusLine pointer, which activates
# ~/.claude/statusline.sh, and attribution.sessionUrl, which keeps the
# Claude-Session link to a private session out of public commits and PRs while
# leaving the Co-Authored-By trailer. Other attribution keys, and an attribution
# of false (no attribution at all), are kept.
set -e

SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

tmpfile=$(mktemp "$SETTINGS.XXXXXX")
trap 'rm -f "$tmpfile"' EXIT
jq '. + {
  "statusLine": {
    "type": "command",
    "command": "$HOME/.claude/statusline.sh"
  }
} | .attribution |= (if . == false then . else (. // {}) + {"sessionUrl": false} end)' "$SETTINGS" > "$tmpfile"
# Claude Code hot-reloads this file, so leave it alone when nothing changed.
cmp -s "$tmpfile" "$SETTINGS" || mv "$tmpfile" "$SETTINGS"
