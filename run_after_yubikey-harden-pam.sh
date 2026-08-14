#!/bin/bash
# Add the options omarchy's FIDO2 setup leaves off its pam_u2f lines.
#
# `omarchy setup security fido2` installs pam-u2f and prepends a bare
# `pam_u2f.so cue authfile=...` line to /etc/pam.d/{sudo,polkit-1}. That
# authenticates on *presence* -- any touch by any finger satisfies it, so the
# Bio's sensor is reduced to a button. The rule is `sufficient`, so presence
# alone then approves every polkit action, 1Password's "system authentication"
# included.
#
# userverification=1 makes the key match an enrolled fingerprint on-device
# instead (pinverification=0 keeps it from falling back to the key's PIN), and
# origin/appid pin the credential to a fixed name rather than pam://$hostname,
# so it survives a rename and works across machines. Keep ORIGIN in sync with
# the enroller.
#
# Teardown belongs to `omarchy remove security fido2`, which strips any
# pam_u2f line regardless of the options on it.
set -e

AUTHFILE=/etc/fido2/fido2
ORIGIN=pam://omarchy
OPTS="origin=$ORIGIN appid=$ORIGIN authfile=$AUTHFILE cue userverification=1 pinverification=0"

# Only the rewrite needs root: /etc/fido2 and both PAM files are world-readable.
# This runs on every apply, including the non-interactive post-update hook,
# where escalating just to discover there is nothing to do would prompt into a
# terminal nobody is watching.
[ -s "$AUTHFILE" ] || exit 0

for f in /etc/pam.d/sudo /etc/pam.d/polkit-1; do
    [ -f "$f" ] || continue
    grep -q 'pam_u2f\.so' "$f" || continue

    # Compare the option tail exactly. A substring test would read a line with
    # extra options appended (a stray `debug`, say) as already hardened.
    current=$(sed -n -E \
        's|^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_u2f\.so[[:space:]]+(.*)$|\1|p' "$f" | head -1)
    [ "$current" = "$OPTS" ] && continue

    # A pam_u2f line in a shape this does not recognise (a different control
    # field, say) would otherwise be skipped silently, leaving presence-only
    # auth in place -- the exact downgrade this script exists to prevent.
    if [ -z "$current" ]; then
        echo "yubikey-harden-pam: unrecognised pam_u2f line in $f, not hardened" >&2
        continue
    fi

    sudo sed -i -E \
        "s|^([[:space:]]*auth[[:space:]]+sufficient[[:space:]]+)pam_u2f\.so.*|\1pam_u2f.so $OPTS|" "$f"
    echo "yubikey-harden-pam: hardened pam_u2f in $f"
done
