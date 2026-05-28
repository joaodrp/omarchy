# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) (Arch + Hyprland).

## Bootstrap on a new machine

```bash
omarchy pkg add chezmoi
chezmoi init <git-remote-url>
chezmoi apply
```

`chezmoi apply` is idempotent — re-run after any drift.

## Layout

- `dot_config/hypr/modify_bindings.conf` — strip-and-replace script that
  idempotently maintains a fenced block of personal Hyprland bindings
  inside Omarchy's `~/.config/hypr/bindings.conf`. Editing the canonical
  block in this file propagates on the next `chezmoi apply`.
- `dot_config/omarchy/hooks/post-update` — re-runs `chezmoi apply` after
  every `omarchy update`, so migrations can't quietly clobber overrides.

## What's managed

- **Brightness on F1/F2**: bound to `omarchy-brightness-display`, which
  already handles Apple Studio Displays (via `asdcontrol` with NOPASSWD
  sudo configured at install time) and laptop backlights (via
  `brightnessctl`). Variants: plain ±5%, `SHIFT` jumps to min/max,
  `ALT` ±2% fine. XF86MonBrightness keys remain wired by Omarchy's
  upstream defaults.
