# omarchy dotfiles (chezmoi)

chezmoi-managed dotfiles for omarchy (Arch + Hyprland). Files here are the
source; `chezmoi apply` renders them into `~`.

## Target

omarchy 4 (`quattro`) and later. It ships as pacman packages, so
`/usr/share/omarchy` is package-owned and `~/.local/share/omarchy` is a symlink
to it. Hyprland is configured in Lua (`~/.config/hypr/*.lua`), and the desktop
is Quickshell — no waybar, walker, mako, hyprlock or hypridle.

## Principles

- Layer on omarchy, do not restate it. Before adding an installer, check
  `omarchy install --help` and `ls /usr/bin/omarchy-install-*` — several
  things that look absent are an `omarchy install <x>` away, and duplicating
  one leaves two definitions to keep in sync. Prefer `omarchy pkg add` /
  `omarchy install` over raw pacman, and omarchy's own extension points
  (`~/.config/omarchy/hooks/<event>.d/`, shell plugins,
  `~/.config/omarchy/backgrounds/<theme>/`) over hand-rolled equivalents.
- Do not re-assert configuration pacman already preserves. Files that produce
  a `.pacnew` are protected by that mechanism; vendoring them here just fights
  the package manager.
- Always prefer idempotent and safe solutions. The `run_onchange_*` /
  `run_after_*` scripts and any system or config change must be re-runnable
  without side effects, guard against partial or repeated application, and
  avoid destructive or hard-to-reverse operations.
- Keep comments brief and written for a skilled reader: state the what/why
  plus any idempotency note, and skip padding, cross-references to sibling
  scripts by name, and explanations of standard tool behavior (git, chezmoi,
  and pacman defaults). Keep genuinely non-obvious rationale (hardware quirks,
  ordering, security).

## Workflow

- Develop on a feature branch and validate (`chezmoi apply` / test) before
  merging. Self-merge to `main` once validated; no PR or external review
  needed (personal dotfiles repo).
