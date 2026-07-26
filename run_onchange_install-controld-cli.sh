#!/bin/bash
# Install cdctl (the `cdctl` binary from the controld-cli crate), a CLI for the
# Control D account API. Installed with cargo rather than mise's cargo backend:
# mise hides just-published releases behind minimum_release_age, which blocks
# tracking the latest of an own, freshly-released crate. Idempotent: cargo
# install skips when the current version is already present, and re-runs pick up
# newer published versions.
set -e

cargo install controld-cli --locked
