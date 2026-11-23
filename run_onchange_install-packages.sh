#!/bin/bash
# Packages that need no setup beyond installing. Anything with config,
# a service or a cleanup step keeps its own run_onchange_install-* script.
set -e

repo=(
    7zip                  # also unpacks macOS .dmg/.pkg archives
    ansible               # ansible-core plus the community collections
    calibre               # e-book manager, GUI and CLI tools
    caligula              # TUI disk-image writer that verifies the write
    clang                 # also clang-format and clang-tidy for C and C++
    cmake                 # C and C++ builds
    dcraw                 # camera RAW decoder for image previews
    dmidecode             # hardware inventory from the DMI/SMBIOS tables
    git-delta             # syntax-highlighting pager for lazygit and git diff
    gitleaks              # the global pre-commit secret scan
    git-filter-repo       # history rewrites (scrubbing secrets and identifiers)
    xorg-server-xvfb      # Xvfb; off-screen X display for agent browser tests
    glab                  # GitLab CLI
    googleworkspace-cli   # gws; Google Workspace CLI (Calendar, Gmail, Drive, ...)
    herdr-core            # hc; Herdr core runtime
    python-huggingface-hub   # hf; Hugging Face model downloads
    go-yq                 # mikefarah/yq; the merge scripts edit TOML with it
    just                  # command runner for project justfiles
    libyaml               # Ruby's psych extension, for mise's precompiled Ruby
    mosh                  # roaming-resilient shells over Tailscale
    radare2               # disassembler, Windows PE files included
    release-plz           # release automation for Rust crates
    ruff                  # Python linter and formatter
    shellcheck            # shell script linter
    squashfs-tools        # unsquashfs reads AppImage icons for thumbnails
    telegram-desktop      # native client, better integrated than the webapp
    usb_modeswitch        # flips the TP-Link TX20U Wi-Fi dongle out of CD-ROM mode
    wayvnc                # VNC over Tailscale; see wayvnc-tailnet.service
    pam-u2f yubikey-manager   # YubiKey Bio unlock via polkit/PAM
    # LaTeX to PDF: pdf/xe/lua-latex, latexmk, latexindent, chktex; skips the
    # multi-GB texlive-meta group.
    texlive-basic texlive-latex texlive-latexrecommended texlive-latexextra
    texlive-fontsrecommended texlive-fontsextra texlive-langenglish texlive-binextra
)
aur=(
    # Moves, clicks and scrolls through the compositor's virtual pointer: no
    # daemon or /dev/uinput, unlike ydotool, and confined to this session.
    wlrctl
    # things3; Things 3 to-dos through Things Cloud, read by the Things widget.
    things3-cloud
)

omarchy pkg add "${repo[@]}"
omarchy pkg aur add "${aur[@]}"

# gcloud and bq, from [extra]; its own component manager is disabled. Omarchy's
# pinned mirror may not carry it yet: an existing install (from the AUR, where
# it used to live) then stays, and a system update moves it to [extra] later.
if pacman -Si google-cloud-cli >/dev/null 2>&1; then
    omarchy pkg add google-cloud-cli
fi
