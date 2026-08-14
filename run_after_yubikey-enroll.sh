#!/bin/bash
# Offer to enroll a YubiKey during `chezmoi apply`, but only when it makes
# sense: no authfile yet, a key is plugged in, and a human is at the terminal.
# Keyless or unattended runs skip silently so applies never block. Declining is
# always safe -- password auth is unaffected.
set -e

AUTHFILE="/etc/fido2/fido2"
ENROLL="$HOME/.local/bin/omarchy-yubikey-enroll"

[ -s "$AUTHFILE" ] && exit 0                             # already enrolled here
[ -t 0 ] || exit 0                                       # unattended
[ -x "$ENROLL" ] || exit 0
command -v fido2-token >/dev/null || exit 0
fido2-token -L 2>/dev/null | grep -q . || exit 0         # no FIDO key present

printf 'YubiKey detected, not yet enrolled for sudo/polkit unlock. Enroll now? [y/N] ' >&2
read -t 30 -r reply || reply=""
case "$reply" in
    [yY] | [yY][eE][sS])
        OMARCHY_ENROLL_FROM_APPLY=1 "$ENROLL" \
            || echo "yubikey-enroll: enrollment did not complete; skipped" >&2
        ;;
    *)
        echo "yubikey-enroll: skipped (run omarchy-yubikey-enroll later to enroll)" >&2
        ;;
esac
exit 0
