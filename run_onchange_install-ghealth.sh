#!/bin/bash
# Google Health CLI, the successor to the Fitbit Web API.
#
# Built from a pinned source tarball. go.mod declares the bare module path
# `ghealth`, so `go install <repo>@<rev>` cannot resolve it and no mise backend
# applies; upstream publishes no tag or release either. Bumping COMMIT rebuilds.
#
# TODO: drop this for a mise `go:` entry once the module path is fixed upstream:
# https://github.com/Google-Health-API/google-health-cli/pull/16
set -eo pipefail

COMMIT=9cf02743d9ca051500b7c1c181eb88a9ae8988a5

# Holds the OAuth client secret and refresh tokens. The CLI writes those 0600
# but creates the directory at the process umask.
install -d -m700 "${XDG_CONFIG_HOME:-$HOME/.config}/ghealth"

src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT
curl -fsSL "https://codeload.github.com/Google-Health-API/google-health-cli/tar.gz/$COMMIT" |
  tar -xz -C "$src" --strip-components=1

install -d "$HOME/.local/bin"
# mise exec rather than a bare `go`: this can run before the mise tools install.
(cd "$src" && mise exec go@latest -- go build -o "$HOME/.local/bin/ghealth" .)
