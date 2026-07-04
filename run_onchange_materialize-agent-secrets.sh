#!/bin/bash
# Materialize the agent-secrets env file on first apply; key rotations use the
# refresh-agent-secrets command. Non-fatal when 1Password is locked.
set -e
"$HOME/.local/bin/refresh-agent-secrets" || true
