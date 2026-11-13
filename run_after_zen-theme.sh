#!/bin/bash
# Make Zen follow the Omarchy theme. Omarchy renders the zen.css template on
# every theme change; each Zen profile imports it from userChrome.css and picks
# it up on its next start. Converged applies change nothing.
set -e

zen="$HOME/.config/zen"
rendered="$HOME/.local/state/omarchy/current/theme/zen.css"
template="$HOME/.config/omarchy/themed/zen.css.tpl"

[ -f "$zen/profiles.ini" ] || exit 0

# Templates render only on a theme change, so render once when the template
# is new or edited.
if [ ! -f "$rendered" ] || [ "$template" -nt "$rendered" ]; then
    omarchy theme refresh
fi

grep '^Path=' "$zen/profiles.ini" | cut -d= -f2- | while IFS= read -r path; do
    profile="$zen/$path"
    [ -d "$profile" ] || continue
    mkdir -p "$profile/chrome"

    [ -L "$profile/chrome/omarchy.css" ] || ln -sfn "$rendered" "$profile/chrome/omarchy.css"

    # @import must precede every other rule; the user's own rules follow it
    # and still win.
    css="$profile/chrome/userChrome.css"
    if ! grep -qsF '@import "omarchy.css";' "$css"; then
        { echo '@import "omarchy.css";'; cat "$css" 2>/dev/null || true; } > "$css.tmp"
        mv "$css.tmp" "$css"
    fi

    pref='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
    grep -qsF "$pref" "$profile/user.js" || echo "$pref" >> "$profile/user.js"
done
