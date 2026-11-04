#!/bin/bash
# Install Inter, the font mapped over the CSS system-ui / -apple-system stack.
#
# Also removes the Apple fonts this repo used to install (downloaded into
# ~/.local/share/fonts/apple, or the apple-fonts AUR package), whose license
# covers Apple platforms only. Idempotent.
set -e

omarchy pkg add inter-font

omarchy-pkg-present apple-fonts && omarchy pkg drop apple-fonts
if [[ -d $HOME/.local/share/fonts/apple ]]; then
    rm -rf "$HOME/.local/share/fonts/apple"
    fc-cache -f >/dev/null
fi
exit 0
