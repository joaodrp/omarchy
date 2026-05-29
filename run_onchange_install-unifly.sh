#!/bin/bash
# Install unifly (CLI + TUI for UniFi Network Controllers) from the AUR.
#
# Used for talking to my CloudKey+ controller from the command line:
# device stats, channel/AP analysis, client experience scores, WAN
# bandwidth history, real-time events. Source: github.com/hyperb1iss/unifly.
#
# Idempotent: omarchy pkg aur add skips already-installed packages.
set -e

omarchy pkg aur add unifly-bin
