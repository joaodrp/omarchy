#!/bin/bash
# Wayland input tooling, so a script can drive the desktop rather than asking
# for a pair of hands: `wtype` types, `wlrctl` moves, clicks and scrolls.
#
# wlrctl over ydotool despite ydotool being in the official repos: wlrctl
# drives the compositor's own virtual-pointer protocol, so it needs no daemon
# and no /dev/uinput, and cannot reach past the session that started it.
# ydotool injects at the kernel input layer, which works everywhere -- lock
# screen and authentication prompts included.
set -e

omarchy pkg add wtype
omarchy pkg aur add wlrctl
