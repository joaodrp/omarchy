#!/bin/bash
# Install development environments via omarchy-install-dev-env.
# Ruby/Go/Zig use mise (which pins to the resolved version of @latest on
# first install). Rust uses rustup (omarchy delegates to sh.rustup.rs)
# because rustup manages toolchain components mise cannot.
#
# Inner helpers are idempotent: mise, rustup, and pacman all skip
# already-installed versions/packages.
set -e

for env in ruby go rust zig; do
    omarchy install dev-env "$env"
done
