#!/bin/bash
# Brave Origin as the default browser, set once per machine so a later switch
# sticks. Omarchy's web apps follow a Chromium-based default, so they open in
# it too. Zen, the previous default, is dropped; its profile data stays.
set -e

if omarchy-pkg-missing brave-origin-bin; then
    omarchy install browser brave-origin
fi

omarchy default browser brave-origin
omarchy pkg drop zen-browser-bin
