#!/bin/bash
# Zen as the default browser, set once per machine so a later switch sticks.
# Web apps keep opening in Chromium, which Omarchy uses whenever the default
# is not Chromium-based.
set -e

if omarchy-pkg-missing zen-browser-bin; then
    omarchy install browser zen
fi

omarchy default browser zen
