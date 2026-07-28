#!/bin/bash
# Install herdr, a terminal workspace manager for AI coding agents, via mise's
# aqua backend (upstream release binaries). Managed by mise rather than its
# bundled `herdr update`, which would drift from the pinned version.
# Idempotent.
set -e

mise use -g herdr@latest
