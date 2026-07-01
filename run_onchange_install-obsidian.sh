#!/bin/bash
# Install Obsidian, a Markdown-based knowledge base / note-taking app.
#
# Idempotent: omarchy pkg add skips packages that are already installed.
set -e

omarchy pkg add obsidian
