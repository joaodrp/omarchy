#!/bin/bash
# Install caligula, a TUI for writing disk images to removable media — picks the
# target device interactively and verifies the write, unlike bare dd.
#
# Idempotent.
set -e

omarchy pkg add caligula
