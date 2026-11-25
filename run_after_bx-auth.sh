#!/bin/bash
# Give bx its Brave API keys from 1Password, once each. A key covers one plan,
# so Search and Answers each get a config file: config.json is bx's default,
# answers.json the research one. `bx config set-key` prompts on a terminal
# only, so write the file it would: the same JSON, 600 in a 700 dir. Needs no
# bx, so it works before mise has installed it. A locked 1Password retries on
# the next apply.
dir=${XDG_CONFIG_HOME:-$HOME/.config}/brave-search
for pair in config:search_api_key answers:answers_api_key; do
    file=$dir/${pair%%:*}.json
    [ -e "$file" ] && continue
    key=$(op read "op://Private/Brave/Security/${pair#*:}" 2>/dev/null)
    if [ -z "$key" ]; then
        echo "bx: no key for $file (1Password locked?); retrying next apply" >&2
        continue
    fi
    ( umask 077; mkdir -p "$dir" && chmod 700 "$dir" &&
      tmp=$(mktemp "$dir/.${pair%%:*}.XXXXXX") &&
      { printf '%s' "$key" | jq -Rs '{api_key: .}' >"$tmp" && mv "$tmp" "$file" ||
        { rm -f "$tmp"; false; }; } ) || echo "bx: could not write $file" >&2
done
