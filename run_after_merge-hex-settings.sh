#!/bin/bash
# Pin the Hex dictation settings below; the rest stay the Hex window's.
# Applied through Hex's CLI, which writes settings.json itself whether or not
# Hex runs. Idempotent: settings already set, and an installed model, are
# no-ops. Skipped until Hex is installed.
set -e

command -v hex >/dev/null || exit 0

hex settings apply - >/dev/null <<'JSON'
{
  "transcription.model": "parakeet_v3",
  "transcription.language": "en",
  "enable_on_launch": true
}
JSON
# Selecting a model doesn't download it.
hex model install >/dev/null
