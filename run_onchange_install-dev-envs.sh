#!/bin/bash
# Install development environments via omarchy-install-dev-env.
# Ruby/Go/Zig use mise (which pins to the resolved version of @latest on
# first install). Rust uses rustup (omarchy delegates to sh.rustup.rs)
# because rustup manages toolchain components mise cannot.
#
# Re-runs only when this file's content changes (run_onchange). The inner
# helpers are idempotent at the install layer:
#  - mise: already-installed versions are detected and skipped.
#  - rustup-init -y: no-ops when rustup is already on the system.
#  - omarchy-pkg-add: pacman skips installed packages.
set -e

for env in ruby go rust zig; do
    omarchy install dev-env "$env"
done
