#!/bin/bash
# Install cdctl (the `cdctl` binary from the controld-cli crate), a CLI for the
# Control D account API, via mise's cargo backend like the other CLI tooling.
# Idempotent.
#
# mise withholds releases younger than `minimum_release_age` (24h default), so
# an own just-published version needs `mise up cargo:controld-cli` by hand.
set -e

# The cargo backend shells out to cargo, and rustup's bin dir is absent from
# PATH on a first apply. Installing rust here keeps this independent of the
# order chezmoi happens to run the installers in.
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
command -v cargo >/dev/null || omarchy install dev-env rust

mise use -g cargo:controld-cli@latest

# Retire the pre-mise install so it cannot shadow the shim.
cargo uninstall controld-cli >/dev/null 2>&1 || true

# Bash completions: bash-completion lazy-loads by command name from this dir, so
# no bashrc sourcing is needed. Regenerated from the just-installed binary so
# they always match its version.
compdir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -p "$compdir"
mise exec -- cdctl completions bash >"$compdir/cdctl"
