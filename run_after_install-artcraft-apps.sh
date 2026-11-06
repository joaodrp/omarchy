#!/bin/bash
# Keep PhotoCraft and LightCraft, ArtCraft's open-source Photoshop and
# Lightroom alternatives, at upstream's latest release, installed per user from
# its GitHub release tarballs: no AUR package, so no root and no third-party
# build script. Each download is checked against the release's SHA256SUMS.txt.
# Upstream signs releases, but publishes no public key to verify them with.
#
# Idempotent: does nothing while the installed version is the latest. Being
# offline, or GitHub failing, leaves the installed version in place.
set -euo pipefail

apps=(photocraft lightcraft)
# Environment for an app's launcher. LightCraft runs through XWayland, for file
# drag-and-drop, which Omarchy leaves unscaled, so it renders at half size on
# HiDPI (https://github.com/storytold/lightcraft/issues/3598); native Wayland
# scales. Drop it once Wayland drag-and-drop lands and upstream defaults to
# Wayland (https://github.com/storytold/lightcraft/issues/639).
declare -A app_env=([lightcraft]="LIGHTCRAFT_WAYLAND=1")
root=$HOME/.local/share/artcraft
arch=$(uname -m)

latest_version() {
  # The /releases/latest page redirects to the tag, without the API's rate limit.
  local url
  url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/storytold/$1/releases/latest") || return 1
  [[ $url =~ /releases/tag/v([0-9][0-9A-Za-z.+-]*)$ ]] || return 1
  echo "${BASH_REMATCH[1]}"
}

# A subshell with explicit checks: set -e does not apply inside an `if !`.
install_app() (
  app=$1 version=$2
  name=$app-$version-linux-$arch
  base=https://github.com/storytold/$app/releases/download/v$version
  tmp=$(mktemp -d "$root/.tmp.XXXXXX") || exit 1
  trap 'rm -rf "$tmp"' EXIT

  curl -fsSL -o "$tmp/$name.tar.gz" "$base/$name.tar.gz" || exit 1
  curl -fsSL -o "$tmp/SHA256SUMS.txt" "$base/SHA256SUMS.txt" || exit 1
  grep -E "^[0-9a-f]{64}  $name\.tar\.gz\$" "$tmp/SHA256SUMS.txt" >"$tmp/sum" || exit 1
  (cd "$tmp" && sha256sum -c --quiet sum) || exit 1

  tar -xzf "$tmp/$name.tar.gz" -C "$tmp" || exit 1
  [[ -x $tmp/$name/bin/$app ]] || exit 1
  rm -rf "${root:?}/$app-$version"
  mv "$tmp/$name" "$root/$app-$version" || exit 1
  # Switch the current link in one rename, so a launch never sees it missing.
  ln -sfn "$app-$version" "$root/.$app.new" || exit 1
  mv -T "$root/.$app.new" "$root/$app"
)

integrate_app() {
  local app=$1 current=$root/$1 id=ai.storyteller.$1
  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
  for bin in "$current"/bin/*; do
    ln -sfn "$current/bin/${bin##*/}" "$HOME/.local/bin/${bin##*/}"
  done
  # Absolute Exec, so the launcher finds it whatever its PATH.
  local env=${app_env[$app]:-}
  sed "s|^Exec=$app |Exec=${env:+env $env }$HOME/.local/bin/$app |; s|^TryExec=$app\$|TryExec=$HOME/.local/bin/$app|" \
    "$current/share/applications/$id.desktop" >"$HOME/.local/share/applications/$id.desktop"
  for icon in "$current"/share/icons/hicolor/*/apps/"$id".*; do
    local dest=$HOME/.local/share/icons/hicolor/${icon#"$current"/share/icons/hicolor/}
    mkdir -p "${dest%/*}"
    cp -f "$icon" "$dest"
  done
}

mkdir -p "$root"
rm -rf "$root"/.tmp.*
for app in "${apps[@]}"; do
  installed=$(readlink "$root/$app" 2>/dev/null || true)
  installed=${installed#"$app"-}
  if ! version=$(latest_version "$app"); then
    echo "artcraft: cannot reach GitHub for $app; keeping ${installed:-none}" >&2
    continue
  fi
  if [[ $installed != "$version" ]]; then
    if ! install_app "$app" "$version"; then
      echo "artcraft: installing $app $version failed; keeping ${installed:-none}" >&2
      continue
    fi
    echo "artcraft: $app ${installed:-none} -> $version"
  fi
  integrate_app "$app"
  # Drop superseded versions.
  find "$root" -mindepth 1 -maxdepth 1 -type d -name "$app-*" ! -name "$app-$version" -exec rm -rf {} +
done
