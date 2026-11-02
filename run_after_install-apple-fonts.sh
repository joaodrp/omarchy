#!/bin/bash
# Install the real Apple system fonts (SF Pro, SF Mono, ...) so web pages that
# use the -apple-system / system-ui font stack (GitHub, etc.) render like macOS.
#
# The apple-fonts AUR package downloads the fonts directly from Apple at build
# time; this repo only carries the install command and the fontconfig mapping
# (dot_config/fontconfig/fonts.conf) -- never Apple's
# font files. (Apple licenses SF for Apple platforms; using it here is personal.)
#
# Non-blocking and retried on every apply until installed: Apple republishes
# the DMGs under the same version, so the AUR checksums go stale for weeks and
# a fatal failure would abort the rest of a bootstrap over cosmetics.
set -e

if omarchy-pkg-missing apple-fonts; then
    omarchy pkg aur add apple-fonts ||
        echo "apple-fonts: AUR build failed (stale checksums?); retrying next apply" >&2
fi
