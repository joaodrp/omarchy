#!/bin/bash
# Android SDK: command-line tools, platform 36 and build-tools 36 (which ships
# apksigner and adb). Kept under $HOME so sdkmanager can install its own
# components without sudo or a group.
#
# ANDROID_HOME and the PATH entries come from the vendored mise config. The
# bootstrap zip is pinned by build and SHA256; sdkmanager updates itself after
# that. To refresh, take the build from
# dl.google.com/android/repository/repository2-1.xml, check the zip against its
# SHA-1 there, and record its SHA256 here.
set -e

SDK="$HOME/Android/Sdk"
CMDLINE="$SDK/cmdline-tools/latest"
ZIP=commandlinetools-linux-16111833_latest.zip
SHA256=0877a1d048fe4a24efe2eff536ca4223f7adeb58648bb81909d33c446918cfa8

# sdkmanager needs only the JDK the vendored mise config declares, run through
# mise exec since this can precede mise's shell activation. Installing every
# tool here fails on a fresh machine: cargo-backed ones precede rustup.
mise install java >/dev/null

if [ ! -x "$CMDLINE/bin/sdkmanager" ]; then
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL -o "$tmp/$ZIP" "https://dl.google.com/android/repository/$ZIP"
    echo "$SHA256  $tmp/$ZIP" | sha256sum -c --quiet
    bsdtar -xf "$tmp/$ZIP" -C "$tmp"
    mkdir -p "$CMDLINE"
    mv "$tmp"/cmdline-tools/* "$CMDLINE/"
fi

export ANDROID_HOME="$SDK"

# Licences accepted non-interactively, with explicit authorisation. sdkmanager
# refuses to install anything until they are.
yes | mise exec java -- "$CMDLINE/bin/sdkmanager" --licenses >/dev/null

mise exec java -- "$CMDLINE/bin/sdkmanager" --install \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0"
