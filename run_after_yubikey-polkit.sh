#!/bin/bash
# Install the pam_u2f drop-in that lets a YubiKey fingerprint satisfy polkit --
# 1Password "system authentication" and every other polkit action. Self-gating
# on the enrolled authfile, so it activates only where the key was enrolled and
# reverts cleanly elsewhere:
#   /etc/Yubico/u2f_keys present -> install /etc/pam.d/polkit-1 override
#   absent                       -> remove our override, restoring vendor default
#
# `sufficient` keeps the login password as a fallback, so a lost key is an
# inconvenience, not a lockout. Origin MUST match omarchy-yubikey-enroll. The
# override is derived from the live vendor file, so it survives pam package
# updates. Idempotent; touches /etc (sudo) only when content actually changes.
set -e

VENDOR=/usr/lib/pam.d/polkit-1
OVERRIDE=/etc/pam.d/polkit-1
AUTHFILE=/etc/Yubico/u2f_keys
ORIGIN=pam://omarchy
MARKER="pam_u2f\.so.*$ORIGIN"
PAMLINE="auth       sufficient   pam_u2f.so origin=$ORIGIN appid=$ORIGIN authfile=$AUTHFILE cue userverification=1 pinverification=0"

if [ ! -s "$AUTHFILE" ]; then
    # No key enrolled here: drop our override (only if it's ours) and revert.
    if [ -f "$OVERRIDE" ] && grep -qE "$MARKER" "$OVERRIDE"; then
        sudo rm -f "$OVERRIDE"
        echo "yubikey-polkit: removed $OVERRIDE (no enrolled key)"
    fi
    exit 0
fi

[ -r "$VENDOR" ] || { echo "yubikey-polkit: $VENDOR missing (polkit not installed?)" >&2; exit 1; }

# Vendor stack with our auth rule inserted before the first auth line.
desired="$(awk -v ins="$PAMLINE" '!ins_done && /^auth[[:space:]]/ {print ins; ins_done=1} {print}' "$VENDOR")"

curr="$(cat "$OVERRIDE" 2>/dev/null || true)"
if [ "$curr" != "$desired" ]; then
    printf '%s\n' "$desired" | sudo tee "$OVERRIDE" >/dev/null
    echo "yubikey-polkit: wrote $OVERRIDE"
fi
