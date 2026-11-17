#!/bin/bash
# Brave Origin, the default browser, also runs the YouTube web app.
set -e

if omarchy-pkg-missing brave-origin-bin; then
  omarchy install browser brave-origin
fi

# Reconciled on every apply: omarchy-refresh-applications copies its own
# YouTube.desktop over this one, and runs during user provisioning.
omarchy-webapp-install "YouTube" "https://youtube.com/" youtube \
  "setsid uwsm-app -- brave-origin --app=https://youtube.com/"
