#!/bin/bash
# Install Mosh (mobile shell) for roaming-resilient remote sessions over
# Tailscale. Idempotent.
set -e

omarchy pkg add mosh
