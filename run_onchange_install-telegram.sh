#!/bin/bash
# Install Telegram Desktop — the official native Linux client, better desktop
# integration than the web app.
#
# Idempotent.
set -e

omarchy pkg add telegram-desktop
