#!/bin/bash
# Ensure the Whisper model referenced by the vendored voxtype config is present.
#
# voxtype itself is installed by omarchy (omarchy-voxtype-install), which also
# downloads omarchy's default model. The vendored dot_config/voxtype/config.toml
# pins model = "small.en" (a good speed/accuracy balance on this iGPU), so on a
# fresh machine the config would reference a model file that isn't there. This
# fills that gap.
#
# Idempotent and safe: no-op if voxtype isn't installed (e.g. a work machine) or
# if the model file already exists. The model name lives here, so changing it
# alongside the config naturally re-triggers the download.
set -e

command -v voxtype >/dev/null || exit 0

MODEL=small.en
if [ ! -f "$HOME/.local/share/voxtype/models/ggml-${MODEL}.bin" ]; then
    voxtype setup --download --model "$MODEL" --quiet
fi
