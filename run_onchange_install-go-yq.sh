#!/bin/bash
# Install mikefarah/yq for TOML/YAML/JSON manipulation with jq-like syntax.
# Pacman name is go-yq to disambiguate from the older python-yq.
set -e

omarchy pkg add go-yq
