#!/bin/bash
# Install 7-Zip, which also unpacks macOS .dmg/.pkg archives. Idempotent.
set -e

omarchy pkg add 7zip
