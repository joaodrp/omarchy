#!/bin/bash
# Install Dropbox. Guarded with `omarchy pkg present` so re-apply does not
# re-trigger dropbox-cli start. First install still requires browser auth via
# the tray-icon flow.
#
# dropbox-cli, which Omarchy's installer and bar toggle use, runs the daemon
# from ~/.dropbox-dist and downloads its own copy there when it is missing,
# while login autostart runs the package. Two daemons on one account stall
# syncing, so point ~/.dropbox-dist at the package: one binary, updated only
# by pacman. Idempotent: a downloaded copy is replaced only while not running.
set -e

dist="$HOME/.dropbox-dist"
if [ "$(readlink "$dist")" != /opt/dropbox ]; then
    if [ -e "$dist/dropboxd" ] && [ ! -L "$dist" ]; then
        if pgrep -f "^$dist/" >/dev/null; then
            echo "Dropbox runs from $dist; quit it and re-apply to link the package." >&2
        else
            rm -rf "$dist"
        fi
    fi
    [ -e "$dist" ] || ln -s /opt/dropbox "$dist"
fi

if ! omarchy pkg present dropbox; then
    omarchy install service dropbox
fi
