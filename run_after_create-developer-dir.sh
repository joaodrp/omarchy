#!/bin/bash
# Ensure ~/Developer exists. Repo nesting (<host>/<org>/[subpath]/<repo>)
# fills in as repositories are cloned — only the base directory is managed.
set -e
mkdir -p "$HOME/Developer"
