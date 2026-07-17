#!/bin/bash
# Install bluez-utils for bluetoothctl. Omarchy's bluetui TUI (omarchy-base)
# covers day-to-day pairing; bluetoothctl adds scriptable, non-interactive
# Bluetooth control for troubleshooting.
set -e

omarchy pkg add bluez-utils
