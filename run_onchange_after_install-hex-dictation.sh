#!/bin/bash
# Hex dictation (anomalyco/hex) as the dictation backend, through Omarchy's own
# installer where it ships one and the vendored copy in ~/.local/bin before.
# Its selection lands in ~/.config/omarchy/defaults/dictation, which Omarchy
# 4.5 reads for its push-to-talk keys and its Voxtype migration skips.
#
# hex-bin comes from the AUR, which Hex's maintainers update on release, rather
# than the omarchy repo, which lags. Both use one package name, so updates keep
# coming from the omarchy repo: rerun `yay -S aur/hex-bin` to catch up again.
set -e

yay -S --noconfirm --needed aur/hex-bin
# A running Hex keeps the old binary after an upgrade and refuses `hex`
# commands from the new one, so restart it before the installer talks to it.
systemctl --user try-restart hex.service
omarchy-install-dictation-hex
