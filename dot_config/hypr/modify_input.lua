#!/bin/bash
# Maintain personal Hyprland input overrides idempotently: strip any
# previously-applied block between markers, trim trailing blank lines, then
# re-append the canonical block.
set -e

awk '
  /^-- >>> dotfiles: .* >>>$/ { skip = 1; next }
  skip && /^-- <<< dotfiles: .* <<<$/ { skip = 0; next }
  !skip
' | awk '
  { lines[NR] = $0; if (NF) last = NR }
  END { for (i = 1; i <= last; i++) print lines[i] }
'

cat <<'EOF2'

-- >>> dotfiles: personal input >>>
-- Chromium-based browsers (and their webapps) add their own smooth-scroll
-- acceleration, so the global touchpad scroll_factor feels far too fast there.
o.window("(chromium|chrome-.*|brave-.*)", { scroll_touchpad = 0.25 })
-- <<< dotfiles: personal input <<<
EOF2
