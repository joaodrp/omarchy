#!/bin/bash
# Android SDK: command-line tools, platform 36 and build-tools 36 (which ships
# apksigner and adb). Kept under $HOME so sdkmanager can install its own
# components without sudo or a group.
#
# ANDROID_HOME and the PATH entries come from the vendored mise config. The
# bootstrap zip is pinned; sdkmanager updates itself after that. Refresh the
# build number from dl.google.com/android/repository/repository2-1.xml if it
# ever 404s.
set -e

SDK="$HOME/Android/Sdk"
CMDLINE="$SDK/cmdline-tools/latest"
ZIP=commandlinetools-linux-16111833_latest.zip

# sdkmanager needs a JDK, which the vendored mise config declares.
mise install >/dev/null

if [ ! -x "$CMDLINE/bin/sdkmanager" ]; then
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/$ZIP" "https://dl.google.com/android/repository/$ZIP"
    bsdtar -xf "$tmp/$ZIP" -C "$tmp"
    mkdir -p "$CMDLINE"
    mv "$tmp"/cmdline-tools/* "$CMDLINE/"
fi

export ANDROID_HOME="$SDK"

# Licences accepted non-interactively, with explicit authorisation. sdkmanager
# refuses to install anything until they are.
yes | "$CMDLINE/bin/sdkmanager" --licenses >/dev/null

"$CMDLINE/bin/sdkmanager" --install \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0"
