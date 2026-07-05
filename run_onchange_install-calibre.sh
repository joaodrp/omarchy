#!/bin/bash
# Calibre e-book manager; the package bundles the GUI and the CLI tools
# (ebook-convert, calibredb, ebook-meta, ...).
#
# Idempotent.
set -e

omarchy pkg add calibre
