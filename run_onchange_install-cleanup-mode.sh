#!/bin/bash
# Cleanup mode: hypr-cleanup-mode, from the Arch package attached to its
# release, and its Omarchy bar plugin.
#
# Both repos are private, so this fetches through gh; on a new machine it
# fails until `gh auth login`.
set -eo pipefail

VERSION=0.4.0
CORE=joaodrp/hypr-cleanup-mode
PLUGIN_ID=io.github.joaodrp.cleanup-mode
PLUGIN_URL=https://github.com/joaodrp/omarchy-cleanup-mode.git

gh auth status >/dev/null 2>&1 || { echo "cleanup-mode: run gh auth login first" >&2; exit 1; }

if [[ $(pacman -Q hypr-cleanup-mode 2>/dev/null) != "hypr-cleanup-mode $VERSION-"* ]]; then
  dl=$(mktemp -d)
  trap 'rm -rf "$dl"' EXIT
  gh release download "v$VERSION" -R "$CORE" -D "$dl" -p 'hypr-cleanup-mode.pkg.tar.zst*'
  (cd "$dl" && sha256sum -c --quiet hypr-cleanup-mode.pkg.tar.zst.sha256)
  sudo pacman -U --noconfirm "$dl/hypr-cleanup-mode.pkg.tar.zst"
fi

# The plugin follows its main branch, as `omarchy plugin update` does.
dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$PLUGIN_ID"
if [[ -d $dir/.git ]]; then
  git -C "$dir" remote set-url origin "$PLUGIN_URL"
  omarchy plugin update "$PLUGIN_ID" --yes
else
  omarchy plugin add "$PLUGIN_URL" --enable --yes
fi
