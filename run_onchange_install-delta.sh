#!/bin/bash
# Install git-delta — the syntax-highlighting pager used by lazygit
# (config in ~/.config/lazygit/config.yml) and intended for plain `git
# diff` once the git config is ported.
#
# Idempotent: omarchy pkg add skips packages that are already installed.
set -e

omarchy pkg add git-delta
