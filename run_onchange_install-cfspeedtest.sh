#!/bin/bash
# Install cfspeedtest, a CLI for Cloudflare's speed test (speed.cloudflare.com).
# Benchmarks down/up/latency from the terminal. Preferred over the older
# speedtest-cli, whose speedtest.net endpoint frequently 403s.
#
# AUR package. Idempotent.
set -e

omarchy pkg aur add cfspeedtest
