#!/bin/bash
# Install agent-browser, a Rust CLI for browser automation, via mise's npm
# backend so it survives node upgrades.
# Idempotent: mise skips already-installed versions; `agent-browser install`
# skips the browser download once it's already there.
set -e

mise use -g npm:agent-browser@latest
mise exec -- agent-browser install
