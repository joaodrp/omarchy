#!/bin/bash
# Install Firefox as a second browser, through Omarchy's installer so its
# Wayland and policy setup run too. It skips the package when present and
# leaves Brave Origin as the default browser.
set -e

omarchy install browser firefox
