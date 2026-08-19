#!/bin/bash
# Realize the tools declared in the vendored mise config, then the per-tool
# post-install steps. run_after because the declarations live in another file:
# a run_onchange hash tracks this script's text, not the config's.
set -e

# mise's cargo backend shells out to cargo, and rustup's bin dir is absent from
# PATH on a first apply.
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
command -v cargo >/dev/null || omarchy install dev-env rust

mise install

# Browser binaries for agent-browser. The installer takes seconds even when
# they are already present, so key it on the directory it creates.
[ -d "$HOME/.agent-browser/browsers" ] || mise exec -- agent-browser install

# cdctl completions: bash-completion lazy-loads by command name from this dir,
# so no bashrc sourcing is needed. Regenerated from the installed binary so
# they always match its version.
compdir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -p "$compdir"
mise exec -- cdctl completions bash >"$compdir/cdctl"
