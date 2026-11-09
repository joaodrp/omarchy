#!/bin/bash
# Packages that need no setup beyond installing. Anything with config,
# a service or a cleanup step keeps its own run_onchange_install-* script.
set -e

repo=(
    7zip                  # also unpacks macOS .dmg/.pkg archives
    ansible               # ansible-core plus the community collections
    calibre               # e-book manager, GUI and CLI tools
    caligula              # TUI disk-image writer that verifies the write
    dcraw                 # camera RAW decoder for image previews
    dmidecode             # hardware inventory from the DMI/SMBIOS tables
    git-delta             # syntax-highlighting pager for lazygit and git diff
    gitleaks              # the global pre-commit secret scan
    github-cli            # gh; clone-my-repos and the agents use it
    git-filter-repo       # history rewrites (scrubbing secrets and identifiers)
    glab                  # GitLab CLI
    go-yq                 # mikefarah/yq; the merge scripts edit TOML with it
    mosh                  # roaming-resilient shells over Tailscale
    radare2               # disassembler, Windows PE files included
    release-plz           # release automation for Rust crates
    squashfs-tools        # unsquashfs reads AppImage icons for thumbnails
    telegram-desktop      # native client, better integrated than the webapp
    usb_modeswitch        # flips the TP-Link TX20U Wi-Fi dongle out of CD-ROM mode
    wayvnc                # VNC over Tailscale; see wayvnc-tailnet.service
    wtype                 # types keystrokes into the Wayland session
    pam-u2f yubikey-manager libfido2   # YubiKey Bio unlock via polkit/PAM
    # LaTeX to PDF: pdf/xe/lua-latex, latexmk, latexindent, chktex; skips the
    # multi-GB texlive-meta group.
    texlive-basic texlive-latex texlive-latexrecommended texlive-latexextra
    texlive-fontsrecommended texlive-fontsextra texlive-langenglish texlive-binextra
)
aur=(
    # gcloud's own component manager is disabled; bq, gsutil and
    # gke-gcloud-auth-plugin are separate AUR packages.
    google-cloud-cli
    # Moves, clicks and scrolls through the compositor's virtual pointer: no
    # daemon or /dev/uinput, unlike ydotool, and confined to this session.
    wlrctl
)

omarchy pkg add "${repo[@]}"
omarchy pkg aur add "${aur[@]}"
