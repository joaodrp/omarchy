#!/bin/bash
# Install the official Claude desktop app.
# The pkg guard avoids re-running omarchy's installer, which launches the app.
set -e

if ! omarchy pkg present claude-desktop; then
    omarchy install ai claude
fi
