#!/bin/bash
# Wire the vendored widgets into omarchy's shell config. omarchy owns this file
# and rewrites it at runtime (disabled plugins, clone-source restores, bar
# rearrangements), so only these entries are managed: each is merged over in
# whichever section it already sits, so per-widget state and a bar section the
# user moved it to both survive, and inserted after the tray only when absent
# everywhere.
#
# Control D's commands are the vendored `dns-controld`; that widget does
# nothing without them, so cloning the plugin alone only does half the job.
set -e

config="$HOME/.config/omarchy/shell.json"
[ -f "$config" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

entries='[
  {
    "id": "io.github.joaodrp.controld",
    "statusCommand": "dns-controld --status",
    "pauseCommand": "dns-controld --pause",
    "resumeCommand": "dns-controld"
  },
  {
    "id": "io.github.joaodrp.auto-brightness"
  },
  {
    "id": "io.github.joaodrp.green-room"
  }
]'

# The Control D widget looks for cdctl once, when it loads. On a first apply
# cdctl is built after this runs, so hold the widget back until the next one.
if ! command -v cdctl >/dev/null 2>&1; then
    entries=$(jq -c 'map(select(.id != "io.github.joaodrp.controld"))' <<<"$entries")
fi

# Swap Nautilus's dock pin for Strata. The dock reads Omarchy's default pins
# only while dock.pinned is absent, so seed it from them once; after that the
# user's own order is kept.
defaults="${OMARCHY_PATH:-/usr/share/omarchy}/config/omarchy/shell.json"

# The shell reloads on every write, so write only when something changed.
# Sibling of the config so the mv is an atomic rename, not a cross-device copy.
tmpfile=$(mktemp "$config.XXXXXX")
trap 'rm -f "$tmpfile"' EXIT
jq --argjson entries "$entries" --slurpfile defaults "$defaults" '
  reduce $entries[] as $entry (.;
    ($entry.id) as $id
    | if any(.bar.layout // {} | .[]? | arrays | .[]? | objects; .id == $id)
      then (.bar.layout[] | arrays | .[] | objects | select(.id == $id)) |= . * $entry
      else .bar.layout.right = (
             (.bar.layout.right // []) as $r
             | ($r | map(if type == "object" then .id else null end) | index("omarchy.tray")) as $i
             | if $i == null then $r + [$entry]
               else $r[0:$i+1] + [$entry] + $r[$i+1:]
               end)
      end
  )
  | .dock.pinned = ((.dock.pinned // $defaults[0].dock.pinned // [])
    | map(if . == "org.gnome.Nautilus" then "io.github.lgse.Strata" else . end))
' "$config" >"$tmpfile"
cmp -s "$tmpfile" "$config" || mv "$tmpfile" "$config"
