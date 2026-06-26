#!/bin/bash
# Install wayvnc, a VNC server for wlroots/Hyprland, for remote desktop over
# Tailscale. Idempotent via omarchy pkg add.
set -e

omarchy pkg add wayvnc
