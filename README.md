# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) (Arch + Hyprland).

## Bootstrap on a new machine

```bash
omarchy pkg add chezmoi
chezmoi init <git-remote-url>
chezmoi apply           # may prompt for sudo (udev rule)
```

`chezmoi apply` is idempotent — re-run after any drift.

## Layout

- `dot_local/bin/` — user scripts (→ `~/.local/bin/`)
- `dot_config/hypr/modify_bindings.conf` — appends bindings to Omarchy's
  `~/.config/hypr/bindings.conf` idempotently (guarded by a marker)
- `dot_config/omarchy/hooks/post-update` — re-runs `chezmoi apply` after
  every `omarchy update` so migrations can't quietly clobber overrides
- `system/` — files installed outside `$HOME` by `run_onchange_*` scripts
  (excluded from apply by `.chezmoiignore`)

## What's managed

- **Apple Studio Display brightness**: `asd-brightness` wrapper + udev rule +
  Hyprland keybindings overriding Omarchy's `brightnessctl`-only defaults.
