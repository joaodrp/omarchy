# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) (Arch + Hyprland).

## Bootstrap on a new machine

```bash
omarchy pkg add chezmoi
mkdir -p ~/Developer/github.com/joaodrp
chezmoi init --source=~/Developer/github.com/joaodrp/omarchy \
  https://github.com/joaodrp/omarchy.git
chezmoi apply
```

The source tree lives at `~/Developer/github.com/joaodrp/omarchy` (mirrors
my standard repo layout). The `--source=` flag writes that location into
`~/.config/chezmoi/chezmoi.toml` so subsequent `chezmoi` commands find it
automatically — no environment variable or per-invocation flag needed.

`chezmoi apply` is idempotent — re-run after any drift.

## Layout

- `dot_config/hypr/modify_bindings.conf` — strip-and-replace script that
  idempotently maintains a fenced block of personal Hyprland bindings
  inside Omarchy's `~/.config/hypr/bindings.conf`. Editing the canonical
  block in this file propagates on the next `chezmoi apply`.
- `dot_config/omarchy/hooks/post-update` — re-runs `chezmoi apply` after
  every `omarchy update`, so migrations can't quietly clobber overrides.
- `run_after_*.sh` — always-run scripts (ensure `~/Developer/` exists, etc.)
- `run_onchange_install-*.sh` — per-app installers that re-execute only
  when their content changes. Each one wraps an `omarchy install` helper.
- `run_remove-omarchy-apps.sh` — strips `.desktop` entries and packages
  I don't use on every apply (idempotent via `rm -f` + `omarchy pkg drop`).

## What's managed

- **Brightness on F1/F2**: bound to `omarchy-brightness-display`, which
  already handles Apple Studio Displays (via `asdcontrol` with NOPASSWD
  sudo configured at install time) and laptop backlights (via
  `brightnessctl`). Variants: plain ±5%, `SHIFT` jumps to min/max,
  `ALT` ±2% fine. XF86MonBrightness keys remain wired by Omarchy's
  upstream defaults.
- **Removed defaults**: 37signals webapps (HEY, Basecamp), Figma, Fizzy,
  Google Photos, Google Messages, plus their keybinding overrides.
- **Installs**: dev environments (Ruby/Go/Rust/Zig), Dropbox, Tailscale,
  Gmail as a webapp with `mailto:` registered as default, and Chromium
  Google OAuth flags so signing in works.
