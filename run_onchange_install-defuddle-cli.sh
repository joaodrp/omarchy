#!/bin/bash
# Install the Defuddle CLI (`defuddle`) — extract a web page's main content as
# Markdown, locally. Via mise's npm backend so it survives node upgrades.
# Idempotent: mise skips already-installed versions.
set -e

mise use -g npm:defuddle-cli@latest
