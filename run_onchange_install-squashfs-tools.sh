#!/bin/bash
# Install squashfs-tools, whose unsquashfs reads AppImage icons for file
# manager thumbnails.
#
# Idempotent.
set -e

omarchy pkg add squashfs-tools
