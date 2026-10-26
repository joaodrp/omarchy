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

# Tailscale SSH services Unix-socket forwarding from the root tailscaled
# process, so an unprivileged session can reach root-only sockets. Unpatched as
# of 1.104.2; the daemon's kill switch drops the vector while leaving shells and
# Mosh intact. Set to 0 to retire, apply, then drop this block. Reconciles both
# ways and restarts only on a real change, so a routine apply never cuts the
# tunnel.
ssh_forwarding_disabled=1

env_file=/etc/default/tailscaled
key=TS_SSH_DISABLE_FORWARDING

wanted=$(sed "/^$key=/d" "$env_file")
if [[ $ssh_forwarding_disabled == 1 ]]; then
    wanted+=$'\n'"$key=1"
fi

if [[ $wanted != "$(cat "$env_file")" ]]; then
    printf '%s\n' "$wanted" | sudo tee "$env_file" >/dev/null
    sudo systemctl restart tailscaled
fi
