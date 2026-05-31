#!/bin/bash
# Install the Chromium browser binary for Playwright CLI.
#
# omarchy provides the playwright-cli launcher (npx-based, via mise node); the
# browser binaries are downloaded separately into ~/.cache/ms-playwright. This
# pulls just Chromium (the default for testing/browsing). No sudo required.
#
# --with-deps is intentionally omitted: it only supports Debian/Ubuntu apt and
# errors on Arch. The bundled browser libs work on omarchy; install any missing
# one from the Arch repos by hand.
#
# Idempotent and safe: no-op if the launcher isn't present yet, and
# playwright-cli install skips the download once Chromium is already there.
set -e

command -v playwright-cli >/dev/null || exit 0

playwright-cli install chromium
