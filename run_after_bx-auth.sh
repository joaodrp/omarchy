#!/bin/bash
# Give bx its Brave Search API key from 1Password, once. `bx config set-key`
# prompts on a terminal only, so write the file it would: the same JSON, 600
# in a 700 dir. A locked 1Password retries on the next apply.
command -v bx >/dev/null || exit 0
dir=${XDG_CONFIG_HOME:-$HOME/.config}/brave-search
[ -e "$dir/config.json" ] && exit 0
if key=$(op read "op://Private/Brave/Security/search_api_key" 2>/dev/null); then
    ( umask 077; mkdir -p "$dir" && chmod 700 "$dir" &&
      KEY=$key jq -n '{api_key: env.KEY}' >"$dir/config.json.tmp" &&
      mv "$dir/config.json.tmp" "$dir/config.json" ) || echo "bx: could not write $dir/config.json" >&2
else echo "bx: no API key (1Password locked?); retrying next apply" >&2; fi
