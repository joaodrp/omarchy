#!/bin/bash
# Development environments via Omarchy's installer. Rust comes through rustup,
# which manages toolchain components mise cannot.
set -e

for env in ruby go rust zig; do
    omarchy install dev-env "$env"
done
