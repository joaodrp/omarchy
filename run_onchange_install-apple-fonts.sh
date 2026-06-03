#!/bin/bash
# Install the real Apple system fonts (SF Pro, SF Mono, ...) so web pages that
# use the -apple-system / system-ui font stack (GitHub, etc.) render like macOS.
#
# The apple-fonts AUR package downloads the fonts directly from Apple at build
# time; this repo only carries the install command and the fontconfig mapping
# (dot_config/fontconfig/conf.d/30-apple-system-fonts.conf) — never Apple's
# font files. (Apple licenses SF for Apple platforms; using it here is personal.)
#
# Idempotent: omarchy pkg aur add uses pacman --needed, a no-op once installed.
set -e

omarchy pkg aur add apple-fonts
