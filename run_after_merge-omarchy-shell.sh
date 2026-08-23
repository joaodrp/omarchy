#!/bin/bash
# Wire the Control D widget into omarchy's shell config. omarchy owns this file
# and rewrites it at runtime (disabled plugins, clone-source restores, bar
# rearrangements), so only this one entry is managed: it is replaced in place
# when present, and inserted after the tray when absent, leaving the rest of
# the bar as arranged.
#
# The commands are the vendored `dns-controld`; the widget does nothing without
# them, so cloning the plugin alone only does half the job.
set -e

config="$HOME/.config/omarchy/shell.json"
[ -f "$config" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

entry='{
  "id": "io.github.joaodrp.controld",
  "statusCommand": "dns-controld --status",
  "pauseCommand": "dns-controld --pause",
  "resumeCommand": "dns-controld"
}'

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
jq --argjson entry "$entry" '
  ($entry.id) as $id
  | .bar.layout.right = (
      (.bar.layout.right // []) as $r
      | if any($r[]; .id == $id)
        then $r | map(if .id == $id then $entry else . end)
        else ($r | map(.id) | index("omarchy.tray")) as $i
             | if $i == null then $r + [$entry]
               else $r[0:$i+1] + [$entry] + $r[$i+1:]
               end
        end
    )
' "$config" >"$tmpfile" && mv "$tmpfile" "$config"
