#!/bin/bash
# Log the readwise CLI in from 1Password, once: it keeps the token in
# ~/.readwise-cli.json. A locked 1Password retries on the next apply.
command -v readwise >/dev/null || exit 0
[ -e "$HOME/.readwise-cli.json" ] && exit 0
if token=$(op read "op://Private/Readwise/API Access Token/Readwise" 2>/dev/null); then
    printf '%s\n' "$token" | readwise login-with-token >/dev/null 2>&1 ||
        echo "readwise: login failed; run readwise login" >&2
else echo "readwise: not logged in (1Password locked?); retrying next apply" >&2; fi
