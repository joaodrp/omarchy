#!/bin/bash
# Cleanup mode: hypr-cleanup-mode, built as an Arch package from a release
# tag, and its Omarchy bar plugin.
#
# Both repos are private, so this fetches through gh rather than the
# PKGBUILD's anonymous URL; on a new machine it fails until `gh auth login`.
# TODO: `omarchy pkg aur add hypr-cleanup-mode` once it is public.
set -eo pipefail

VERSION=0.1.0
CORE=joaodrp/hypr-cleanup-mode
PLUGIN_ID=io.github.joaodrp.cleanup-mode
PLUGIN_URL=https://github.com/joaodrp/omarchy-cleanup-mode.git

gh auth status >/dev/null 2>&1 || { echo "cleanup-mode: run gh auth login first" >&2; exit 1; }

if [[ $(pacman -Q hypr-cleanup-mode 2>/dev/null) != "hypr-cleanup-mode $VERSION-"* ]]; then
  build=$(mktemp -d)
  trap 'rm -rf "$build"' EXIT
  gh release download "v$VERSION" -R "$CORE" --archive tar.gz -O "$build/hypr-cleanup-mode-$VERSION.tar.gz"
  gh api -H 'Accept: application/vnd.github.raw' "repos/$CORE/contents/packaging/PKGBUILD?ref=v$VERSION" >"$build/PKGBUILD"
  (cd "$build" && makepkg -si --noconfirm)
fi

# The plugin follows its main branch, as `omarchy plugin update` does.
dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$PLUGIN_ID"
if [[ -d $dir/.git ]]; then
  git -C "$dir" remote set-url origin "$PLUGIN_URL"
  omarchy plugin update "$PLUGIN_ID" --yes
else
  omarchy plugin add "$PLUGIN_URL" --enable --yes
fi
