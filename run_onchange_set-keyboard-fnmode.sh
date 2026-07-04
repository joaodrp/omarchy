#!/bin/bash
# Make the top-row media keys primary (no Fn needed) on hid_apple keyboards.
#
# Why: the Lofree Flow84 doesn't enumerate cleanly on Linux, so the kernel
# drives it through hid_apple and the keyboard's own `Fn + Lock` toggle is dead.
# hid_apple's `fnmode` is the OS-side equivalent:
#   fnmode=2 (kernel default here) -> F1-F12 primary, media via Fn
#   fnmode=1                       -> media primary, F1-F12 via Fn
# We want volume/brightness on a bare press, so fnmode=1.
#
# Persists via modprobe.d (read whenever hid_apple loads; the module is not in
# initramfs here, so no initramfs rebuild needed) and also pokes the live sysfs
# param so it takes effect now. Harmless when no hid_apple keyboard is attached
# (the sysfs param exists only while the module is loaded). Idempotent: only
# writes when content differs.
set -e

CONF=/etc/modprobe.d/keyboard-fnmode.conf
CONF_CONTENT='options hid_apple fnmode=1'

# Install the conf (skip if unchanged).
if [ "$(cat "$CONF" 2>/dev/null)" != "$CONF_CONTENT" ]; then
    printf '%s\n' "$CONF_CONTENT" | sudo tee "$CONF" >/dev/null
fi

# Apply now (the modprobe.d conf covers future boots / module reloads).
param=/sys/module/hid_apple/parameters/fnmode
[ -f "$param" ] && echo 1 | sudo tee "$param" >/dev/null || true
