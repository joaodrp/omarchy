#!/bin/bash
# Tailscale settings that need an installed, authenticated node. Reconciled on
# every apply rather than from an installer: authenticating happens long after
# the install, and does not change any script's hash.
#
# `--ssh` lets tailnet peers SSH/Mosh in, ACL-gated, no keys.
#
# `--accept-dns` lets tailscaled own MagicDNS on its own link, leaving ControlD
# the default. Safe only while the tailnet's "Override DNS servers" is off; with
# it on, this machine silently moves to the shared tailnet profile.
set -e

command -v tailscale >/dev/null || exit 0
tailscale status >/dev/null 2>&1 || exit 0

sudo tailscale set --ssh --accept-dns=true
