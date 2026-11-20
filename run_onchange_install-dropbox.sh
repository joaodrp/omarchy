#!/bin/bash
# Install Dropbox. Guarded with `omarchy pkg present` so re-apply does not
# re-trigger dropbox-cli start. First install still requires browser auth via
# the tray-icon flow.
#
# dropbox-cli, which Omarchy's installer and bar toggle use, runs the daemon
# from ~/.dropbox-dist and downloads its own copy there when it is missing,
# while login autostart runs the package. Two daemons on one account stall
# syncing, so point ~/.dropbox-dist at the package: one binary, updated only
# by pacman. Idempotent: a downloaded copy is replaced only while none of its
# processes run; otherwise the script fails so the next apply retries.
set -e

dist="$HOME/.dropbox-dist"
if [ "$(readlink "$dist")" != /opt/dropbox ]; then
    if [ -e "$dist/dropboxd" ] && [ ! -L "$dist" ]; then
        real=$(realpath "$dist")
        for exe in /proc/[0-9]*/exe; do
            case $(readlink "$exe" 2>/dev/null) in
            "$real"/*)
                echo "Dropbox runs from $dist; quit it, then re-apply." >&2
                exit 1
                ;;
            esac
        done
        rm -rf "$dist"
    fi
    [ -e "$dist" ] || ln -s /opt/dropbox "$dist"
fi

if ! omarchy pkg present dropbox; then
    omarchy install service dropbox
fi
