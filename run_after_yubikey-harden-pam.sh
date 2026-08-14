#!/bin/bash
# Add the options omarchy's FIDO2 setup leaves off its pam_u2f lines.
#
# `omarchy setup security fido2` owns the scaffolding: it installs libfido2 and
# pam-u2f, and prepends this to /etc/pam.d/sudo and /etc/pam.d/polkit-1:
#     auth  sufficient  pam_u2f.so cue authfile=/etc/fido2/fido2
# That authenticates on *presence* -- any touch by any finger satisfies it, so
# the Bio's sensor is reduced to a button. Since the rule is `sufficient` it
# also skips the password, so presence alone would approve every polkit action,
# 1Password's "system authentication" included.
#
# userverification=1 makes the key match an enrolled fingerprint on-device
# instead (pinverification=0 keeps it from falling back to the key's PIN), and
# origin/appid pin the credential to a fixed name rather than pam://$hostname,
# so it survives a rename and works across machines. Keep ORIGIN in sync with
# omarchy-yubikey-enroll.
#
# Self-gating and idempotent: no-ops until both the authfile and omarchy's
# pam_u2f lines exist, and only writes when a line is not already hardened.
# Teardown belongs to `omarchy remove security fido2`, which strips any
# pam_u2f line regardless of the options on it.
set -e

AUTHFILE=/etc/fido2/fido2
ORIGIN=pam://omarchy
OPTS="origin=$ORIGIN appid=$ORIGIN authfile=$AUTHFILE cue userverification=1 pinverification=0"

sudo test -s "$AUTHFILE" || exit 0

for f in /etc/pam.d/sudo /etc/pam.d/polkit-1; do
    sudo test -f "$f" || continue
    # Nothing to harden until omarchy's setup has written its line.
    sudo grep -q 'pam_u2f\.so' "$f" || continue
    sudo grep -qF "pam_u2f.so $OPTS" "$f" && continue

    sudo sed -i -E \
        "s|^([[:space:]]*auth[[:space:]]+sufficient[[:space:]]+)pam_u2f\.so.*|\1pam_u2f.so $OPTS|" "$f"
    echo "yubikey-harden-pam: hardened pam_u2f in $f"
done
