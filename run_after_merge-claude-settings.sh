#!/bin/bash
# Merge personal Claude Code settings into ~/.claude/settings.json, keeping
# every other key (omarchy defaults, permission grants).
#
# Managed: statusLine, pointing at ~/.claude/statusline.sh, and
# attribution.sessionUrl=false, which keeps private session links out of public
# commits and PRs but leaves the Co-Authored-By trailer. Other attribution keys,
# or attribution=false, are kept.
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
