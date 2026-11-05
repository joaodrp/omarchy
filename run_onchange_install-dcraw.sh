#!/bin/bash
# Install dcraw, a camera RAW decoder used for RAW image previews.
#
# Idempotent.
set -e

omarchy pkg add dcraw
