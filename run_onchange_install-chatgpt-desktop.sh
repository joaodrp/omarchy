#!/bin/bash
# Install the official ChatGPT desktop app, which bundles Codex.
# The pkg guard avoids re-running omarchy's installer, which launches the app.
set -e

if ! omarchy pkg present openai-codex-desktop; then
    omarchy install ai-chatgpt
fi
