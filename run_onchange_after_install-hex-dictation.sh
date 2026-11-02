#!/bin/bash
# Hex dictation (anomalyco/hex) as the dictation backend, through Omarchy's own
# installer where it ships one and the vendored copy in ~/.local/bin before.
# Its selection lands in ~/.config/omarchy/defaults/dictation, which Omarchy
# 4.5 reads for its push-to-talk keys and its Voxtype migration skips.
set -e

omarchy-install-dictation-hex
