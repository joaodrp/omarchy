# merge_file PATH SEED COMMAND...: seed PATH with SEED when missing, run
# COMMAND on PATH's content (stdin), and replace PATH only when the output
# differs, so apps that reload on write are left alone. The temp file sits
# beside PATH, so the replacement is an atomic rename.
merge_file() {
    local path=$1 seed=$2 tmp
    shift 2
    mkdir -p "$(dirname "$path")"
    [ -f "$path" ] || printf '%s' "$seed" >"$path"
    tmp=$(mktemp "$path.XXXXXX")
    "$@" <"$path" >"$tmp" || { rm -f "$tmp"; return 1; }
    cmp -s "$tmp" "$path" || mv "$tmp" "$path" || { rm -f "$tmp"; return 1; }
    rm -f "$tmp"
}
