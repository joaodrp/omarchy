#!/bin/bash
# The YouTube web app runs in Brave Origin, the default browser. Reconciled on
# every apply: omarchy-refresh-applications copies its own YouTube.desktop over
# this one, and runs during user provisioning.
set -e

command -v brave-origin >/dev/null || exit 0
omarchy webapp install "YouTube" "https://youtube.com/" youtube \
  "setsid uwsm-app -- brave-origin --app=https://youtube.com/"
