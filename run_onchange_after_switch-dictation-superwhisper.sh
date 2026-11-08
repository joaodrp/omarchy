#!/bin/bash
# Superwhisper as the dictation backend, through Omarchy's own installer, which
# also selects it and puts it on Omarchy's keys (Alt + Space toggles, Right Alt
# holds). Then pin its Offline Lite mode, Parakeet TDT 0.6B v3: local, 25
# European languages including English and Portuguese, and far lighter than
# Offline's Cohere Transcribe (2B, plus a cleanup LLM, 12 GB) for about one
# point of English WER.
set -e

omarchy-install-dictation-superwhisper --background
# Selecting a mode doesn't download its models, and Superwhisper runs one
# model operation at a time, returning before it ends. Right after a select it
# re-checks each model, so wait out work in progress and start a download only
# for a model that is absent; one refused for overlapping is retried.
superwhisper models select offline_lite
model_state() {
  superwhisper models show | jq -r --arg id "$1" '.models[] | select(.id == $id) | .download.state'
}
for model in transcription vocabulary voice-detection; do
  for ((waited = 0; ; waited += 2)); do
    state=$(model_state "$model")
    case $state in
      installed) break ;;
      checking | downloading | queued) ;;
      paused) echo "Superwhisper model $model download is paused" >&2; exit 1 ;;
      *) superwhisper models download "$model" >/dev/null 2>&1 || true ;;
    esac
    if ((waited >= 1800)); then
      echo "Superwhisper model $model did not download (state: $state)" >&2
      exit 1
    fi
    sleep 2
  done
done
