#!/bin/bash
# Install Telegram Desktop — the official native Linux client (better
# notifications, system tray, and voice/video calls than the web app).
#
# Idempotent: omarchy pkg add skips packages that are already installed.
set -e

omarchy pkg add telegram-desktop
