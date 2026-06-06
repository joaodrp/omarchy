#!/bin/bash
# Install cfspeedtest, a CLI for Cloudflare's speed test (speed.cloudflare.com).
# Handy for benchmarking down/up/latency from the terminal when diagnosing
# internet or Wi-Fi link performance, no browser, scriptable output. Preferred
# over the older speedtest-cli, whose speedtest.net endpoint frequently 403s.
#
# AUR package. Idempotent: omarchy pkg aur add uses pacman --needed, a no-op
# once installed.
set -e

omarchy pkg aur add cfspeedtest
