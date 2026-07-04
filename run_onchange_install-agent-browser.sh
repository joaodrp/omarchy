#!/bin/bash
# Install agent-browser, a CLI for browser automation, via mise's npm
# backend so it survives node upgrades.
# Idempotent.
set -e

mise use -g npm:agent-browser@latest
mise exec -- agent-browser install
