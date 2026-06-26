#!/bin/bash
# Install Mosh (mobile shell) for roaming-resilient remote sessions over
# Tailscale. Idempotent: omarchy pkg add is a no-op once installed.
set -e

omarchy pkg add mosh
