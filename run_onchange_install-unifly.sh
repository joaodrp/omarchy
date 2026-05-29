#!/bin/bash
# Install unifly — CLI + TUI for UniFi Network Controllers
# (github.com/hyperb1iss/unifly). Lets me query any controller from the
# command line: device stats, channel/AP analysis, client experience
# scores, WAN bandwidth history, real-time events.
#
# Idempotent: omarchy pkg aur add skips already-installed packages.
set -e

omarchy pkg aur add unifly-bin
