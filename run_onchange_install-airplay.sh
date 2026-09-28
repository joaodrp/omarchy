#!/bin/bash
# Expose AirPlay receivers (HomePod, Apple TV) as PipeWire sound outputs.
# pipewire-zeroconf ships the mDNS discover module; the stock 50-raop.conf
# fragment only takes effect once linked into pipewire.conf.d.
#
# The symlink is created here rather than as a managed file: PipeWire refuses
# to start if the fragment names a module that isn't installed yet, so the
# package must land first. Idempotent; restarts PipeWire only when the module
# isn't already loaded.
set -e

omarchy pkg add pipewire-zeroconf

conf_d=~/.config/pipewire/pipewire.conf.d
mkdir -p "$conf_d"
ln -sfn /usr/share/pipewire/pipewire.conf.avail/50-raop.conf "$conf_d/50-raop.conf"

if ! pw-cli list-objects Module 2>/dev/null | grep -q raop-discover; then
    systemctl --user try-restart pipewire pipewire-pulse wireplumber
fi
