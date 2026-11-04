#!/bin/bash
# Install Apple's SF Pro, SF Mono and New York straight from Apple, so web
# pages using the -apple-system / system-ui / ui-monospace / ui-serif stack
# (GitHub, etc.) render like macOS. Inter is the fallback when they are absent.
#
# Not the apple-fonts AUR package: Apple republishes the DMGs at the same URL
# without a version bump, which leaves any checksum-pinned package unbuildable
# for weeks. HTTPS from Apple's CDN is the trust anchor instead, and each
# family's ETag is kept so an unchanged DMG is never downloaded twice.
# (Apple licenses SF for Apple platforms; using it here is personal.)
#
# Runs every apply: three HEAD requests when nothing changed. A family is
# swapped in only once fully extracted, and a failure (offline, layout change)
# warns and keeps what is installed rather than aborting the apply.
set -uo pipefail

BASE=https://devimages-cdn.apple.com/design/resources/download
DEST=$HOME/.local/share/fonts/apple
FAMILIES=(SF-Pro SF-Mono NY)

omarchy-pkg-missing inter-font && omarchy pkg add inter-font

# Superseded by the direct install; both would register the same families.
omarchy-pkg-present apple-fonts && omarchy pkg drop apple-fonts

if ! command -v 7z >/dev/null; then
    echo "apple fonts: 7z missing; skipped" >&2
    exit 0
fi

etag() {
    curl -fsIL --max-time 15 "$1" | tr -d '\r' |
        awk 'tolower($1) == "etag:" { tag = $2 } END { if (tag == "") exit 1; print tag }'
}

# dmg -> product .pkg (xar) -> component dir with Payload (cpio) -> Library/Fonts.
# Fonts land in $2/fonts.
extract() {
    local url=$1 work=$2 payload
    curl -fsSL --max-time 600 -o "$work/font.dmg" "$url" &&
        7z e "$work/font.dmg" -o"$work/dmg" '*.pkg' -r -y >/dev/null &&
        find "$work/dmg" -maxdepth 1 -name '*.pkg' -type f \
            -exec 7z x -txar {} -o"$work/xar" -y \; >/dev/null || return 1
    payload=$(find "$work/xar" -name Payload -type f -print -quit)
    [[ -n $payload ]] || return 1
    (cd "${payload%/*}" && 7z x Payload -y >/dev/null && 7z x 'Payload~' -y >/dev/null) || return 1

    mkdir -p "$work/fonts"
    find "$work/xar" -path '*/Library/Fonts/*' -type f \( -name '*.otf' -o -name '*.ttf' \) \
        -exec cp -t "$work/fonts" {} + || return 1
    compgen -G "$work/fonts/*" >/dev/null || return 1
    find "$work/xar" -path '*English.lproj/License.rtf' -exec cp {} "$work/fonts/LICENSE.rtf" \; -quit
}

install_family() {
    local name=$1 dir=$DEST/$1 tag work rc=0
    tag=$(etag "$BASE/$name.dmg") || { echo "apple fonts: $name: Apple unreachable; kept" >&2; return 0; }
    [[ -f $dir/.etag && $(<"$dir/.etag") == "$tag" ]] && return 0

    # Under $DEST's filesystem, so the swap is two renames.
    mkdir -p "$DEST"
    work=$(mktemp -d "$DEST/.work-XXXXXX")
    if extract "$BASE/$name.dmg" "$work"; then
        printf '%s\n' "$tag" >"$work/fonts/.etag"
        rm -rf "$dir.old"
        { [[ ! -d $dir ]] || mv "$dir" "$dir.old"; } && mv "$work/fonts" "$dir" && rm -rf "$dir.old"
        echo "apple fonts: $name installed ($tag)"
        changed=1
    else
        rc=1
    fi
    rm -rf "$work"
    return "$rc"
}

rm -rf "$DEST"/.work-*  # left by an interrupted run
changed=0
for family in "${FAMILIES[@]}"; do
    install_family "$family" || echo "apple fonts: $family failed; kept what was installed" >&2
done
(( changed )) && fc-cache -f "$DEST" >/dev/null
exit 0
