#!/bin/bash
# Log things3 in to Things Cloud from 1Password. `things3 set-auth` reads the
# password from the terminal only, so write the file it would: the same JSON,
# owner-only. The secrets pass through the environment, never argv. Non-fatal:
# 1Password may be locked, and every apply retries until the file exists.

command -v things3 >/dev/null || exit 0
dir=${XDG_STATE_HOME:-$HOME/.local/state}/things3
[ -e "$dir/auth.json" ] && exit 0

item="op://Private/Things Cloud"
if email=$(op read "$item/username" 2>/dev/null) &&
    password=$(op read "$item/password" 2>/dev/null); then
    (
        umask 077
        mkdir -p "$dir" && chmod 700 "$dir" &&
            EMAIL=$email PASSWORD=$password \
                jq -n '{email: env.EMAIL, password: env.PASSWORD}' >"$dir/auth.json.tmp" &&
            mv "$dir/auth.json.tmp" "$dir/auth.json"
    ) || echo "things3: could not write $dir/auth.json" >&2
else
    echo "things3: not logged in (1Password locked?); retrying next apply" >&2
fi
