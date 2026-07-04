#!/bin/bash
# Claude Code Statusline
# Shows: model [agent] [style] | task | directory (branch) | context usage

input=$(cat)
IFS=$'\t' read -r model dir session used output_style agent_name <<< "$(echo "$input" | jq -r '[
  .model.display_name,
  .workspace.current_dir,
  .session_id,
  (.context_window.used_percentage // 0 | floor | tostring),
  (.output_style.name // ""),
  (.agent.name // "")
] | join("\t")')"

# Context window display
ctx=""
if [ "$used" -gt 0 ]; then
    filled=$((used / 10))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=filled; i<10; i++)); do bar+="░"; done

    # Color thresholds — all named ANSI codes so they follow the terminal theme.
    if [ "$used" -lt 40 ]; then
        ctx=$' \033[32m'"$bar $used%"$'\033[0m'
    elif [ "$used" -lt 80 ]; then
        ctx=$' \033[33m'"$bar $used%"$'\033[0m'
    else
        ctx=$' \033[5;31m'"$bar $used%"$'\033[0m'
    fi
fi

# Current task from todos
task=""
todo=$(ls -t "$HOME/.claude/todos/${session}"-agent-*.json 2>/dev/null | head -1)
if [[ -f "$todo" ]]; then
    task=$(jq -r '.[] | select(.status=="in_progress") | .activeForm' "$todo" 2>/dev/null | head -1)
fi

# Git branch and dirty indicators (skip optional locks)
branch=""
git_indicators=""
if [[ -d "$dir/.git" ]]; then
    branch=$(cd "$dir" && git --no-optional-locks branch --show-current 2>/dev/null)
    # Dirty: staged, unstaged, or untracked
    if ! (cd "$dir" && git diff-index --ignore-submodules --cached --quiet HEAD -- 2>/dev/null) \
       || ! (cd "$dir" && git diff --ignore-submodules --no-ext-diff --quiet --exit-code 2>/dev/null) \
       || (cd "$dir" && git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' 2>/dev/null) >/dev/null 2>&1; then
        git_indicators+="* "
    fi
    # Unpushed/unpulled commits
    upstream=$(cd "$dir" && git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [[ -n "$upstream" ]]; then
        counts=$(cd "$dir" && git rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null)
        to_push=$(echo "$counts" | cut -f1)
        to_pull=$(echo "$counts" | cut -f2)
        [[ "$to_push" -gt 0 ]] 2>/dev/null && git_indicators+="⇡"
        [[ "$to_pull" -gt 0 ]] 2>/dev/null && git_indicators+="⇣"
    fi
    # Stash
    stash_count=$(cd "$dir" && git rev-list --walk-reflogs --count refs/stash 2>/dev/null || echo "0")
    [[ "$stash_count" -gt 0 ]] 2>/dev/null && git_indicators+="≡"
fi

# Directory path (last 2 segments)
fulldir="$dir"
if [[ "$dir" == "$HOME"/* ]]; then
    fulldir="~${dir#$HOME}"
fi
dirparts=$(echo "$fulldir" | awk -F'/' '{
    n=NF
    if (n<=2) print $0
    else printf "%s/%s", $(n-1), $n
}')

# Build location string: dir (branch*⇡⇣≡)
path_green=$'\033[0;32m'
path_reset=$'\033[0m'
location="${path_green}${dirparts}${path_reset}"
if [[ -n "$branch" ]]; then
    indicator_color=$'\033[0;1;35m'
    ind_reset=$'\033[0m'
    colored_indicators=""
    if [[ -n "$git_indicators" ]]; then
        colored_indicators="${indicator_color}${git_indicators}${ind_reset}"
    fi
    blue=$'\033[0;34m'
    blue_reset=$'\033[0m'
    location="$location ${blue}${branch}${blue_reset}${colored_indicators}"
fi

# Build model string with agent and output style
cyan=$'\033[36m'
magenta=$'\033[35m'
reset=$'\033[0m'
model_str="$model"
if [[ -n "$agent_name" && "$agent_name" != "null" ]]; then
    model_str="$model_str [${cyan}${agent_name}${reset}]"
fi
if [[ -n "$output_style" && "$output_style" != "null" && "$output_style" != "default" ]]; then
    model_str="$model_str [${magenta}${output_style}${reset}]"
fi

# Output
if [[ -n "$task" ]]; then
    printf '\033[2m%s\033[0m | \033[1m%s\033[0m | \033[2m%s\033[0m%s' "$model_str" "$task" "$location" "$ctx"
else
    printf '\033[2m%s\033[0m | \033[2m%s\033[0m%s' "$model_str" "$location" "$ctx"
fi
