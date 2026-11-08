# install_root_file PATH MODE CONTENT [COMMAND...]: make PATH a root-owned file
# holding CONTENT, writing only when it differs, then run COMMAND, if given, on
# a real change. Reads a world-readable file without sudo.
install_root_file() {
    local path=$1 mode=$2 content=$3 current
    shift 3
    if [ -r "$path" ]; then
        current=$(cat "$path")
    else
        current=$(sudo cat "$path" 2>/dev/null) || current=
    fi
    [ "$current" = "$content" ] && return 0
    printf '%s\n' "$content" | sudo install -D -o root -g root -m "$mode" /dev/stdin "$path"
    if [ $# -gt 0 ]; then "$@"; fi
}
