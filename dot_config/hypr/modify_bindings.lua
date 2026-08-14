#!/bin/bash
# Maintain personal Hyprland bindings idempotently.
# Strips any previously-applied block between markers, trims trailing blank
# lines, then re-appends the canonical block -- so editing this file
# propagates on the next `chezmoi apply`.
set -e

# Match the marker prefix (not an exact title) so renaming the block still
# strips the previously-applied copy instead of leaving a duplicate behind.
awk '
  /^-- >>> dotfiles: .* >>>$/ { skip = 1; next }
  skip && /^-- <<< dotfiles: .* <<<$/ { skip = 0; next }
  !skip
' | awk '
  { lines[NR] = $0; if (NF) last = NR }
  END { for (i = 1; i <= last; i++) print lines[i] }
'

cat <<'EOF'

-- >>> dotfiles: personal hyprland >>>
-- Drop the preinstalled webapp bindings I don't use. Unbound one by one
-- rather than via omarchy_preinstalled_bindings=false, which would also take
-- the preinstalled bindings I do want (herdr, Obsidian, 1Password, ChatGPT).
hl.unbind("SUPER + SHIFT + E") -- Hey email
hl.unbind("SUPER + SHIFT + C") -- Hey calendar
hl.unbind("SUPER + SHIFT + P") -- Google Photos

-- Reclaim the freed mail/calendar keys for the Google webapps.
-- launch_webapp_sole matches its pattern as a word-boundary regex against the
-- window class *or* title. The webapp class (chrome-mail.google.com__-Default)
-- has no word boundary before the `__`, so the pattern only ever matches on
-- the title.
o.bind("SUPER + SHIFT + E", "Gmail",
  o.launch_webapp_sole("Gmail", "https://mail.google.com"))
o.bind("SUPER + SHIFT + C", "Google Calendar",
  o.launch_webapp_sole("Google Calendar", "https://calendar.google.com"))

-- Fix Picture-in-Picture clipping off the right screen edge. omarchy's pip
-- rules compute X from window_w (Chromium's intrinsic ~512px PiP width)
-- *before* the `size = { 600, 338 }` rule widens the window, so the right edge
-- overhangs. Recompute X from the forced 600px width: monitor_w - 600 (width)
-- - 40 (margin) = monitor_w - 640. This file loads after the defaults, so the
-- later move wins. monitor_w/_h are per-monitor and logical, so this stays
-- correct across screens and HiDPI scales.
--
-- Still reproducible on omarchy 4.0.0: with this rule removed, a PiP window on
-- a 2560px-wide logical screen lands at x=2008 (= 2560-512-40), putting its
-- right edge at 2608 and clipping 48px off-screen. With the rule, x=1920.
--
-- Self-neutralising: once window_w resolves to the forced 600, upstream's
-- formula and this one agree, so the override becomes a no-op rather than a
-- regression -- re-test by deleting it, not by reading the code. Keep 640 in
-- sync if omarchy changes the size default.
o.window({ tag = "pip" }, {
  move = { "(monitor_w-640)", "(monitor_h*0.04)" },
})
-- <<< dotfiles: personal hyprland <<<
EOF
