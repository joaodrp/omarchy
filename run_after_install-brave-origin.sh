#!/bin/bash
# Brave Origin, used only for the YouTube web app, which keeps YouTube in its
# own browser profile. Installing a browser does not change the default, which
# stays Chromium.
set -e

if omarchy-pkg-missing brave-origin-bin; then
  omarchy install browser brave-origin
fi

# Reconciled on every apply: omarchy-refresh-applications copies its own
# YouTube.desktop over this one, and runs during user provisioning.
omarchy-webapp-install "YouTube" "https://youtube.com/" youtube \
  "setsid uwsm-app -- brave-origin --app=https://youtube.com/"
