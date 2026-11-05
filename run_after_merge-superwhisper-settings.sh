#!/bin/bash
# Pin the Superwhisper settings below; the rest stay its Settings window's.
# Applied through its CLI, which talks to the running daemon, so skipped until
# Superwhisper is installed and running.
#
# - language "auto" follows the spoken language, for English and Portuguese.
# - clipboardBehaviour "bypass" restores the clipboard after inserting a
#   transcript, so dictating never replaces the last copy.
# - vocab auto learns words from corrections; the list itself stays the app's.
set -e

command -v superwhisper >/dev/null || exit 0
systemctl --user is-active --quiet superwhisper.service || exit 0

superwhisper general set language '"auto"' >/dev/null
superwhisper general set tone '"balanced"' >/dev/null
superwhisper general set clipboardBehaviour '"bypass"' >/dev/null
superwhisper vocab auto on >/dev/null
