#!/bin/bash
# Install Dropbox. Guarded with `omarchy pkg present` so re-apply (when
# the script content changes for unrelated reasons) does not re-trigger
# dropbox-cli start. First install still requires browser auth via the
# tray-icon flow.
set -e

if ! omarchy pkg present dropbox; then
    omarchy install dropbox
fi
