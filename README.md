# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) (Arch + Hyprland).

## Bootstrap on a new machine

```bash
omarchy pkg add chezmoi
chezmoi init https://github.com/joaodrp/omarchy.git
chezmoi apply
```

The source tree lives at `~/.local/share/chezmoi/` — chezmoi's XDG default.
Run `chezmoi cd` to drop into a subshell there.

Optionally, for navigating the repo the same way as any other project under
`~/Developer/<host>/<org>/<repo>`:

```bash
mkdir -p ~/Developer/github.com/joaodrp
ln -s ~/.local/share/chezmoi ~/Developer/github.com/joaodrp/omarchy
```

`chezmoi apply` is idempotent — re-run after any drift.

## Layout

Source-state prefixes encode behaviour:

| Prefix | Behaviour |
| --- | --- |
| `run_onchange_*` | Re-runs only when its rendered content changes (installers). |
| `run_after_*` | Runs on *every* apply (config merges that must re-assert after an app rewrites its own file). |
| `modify_*` | Filters the existing target through the script (idempotent in-place edits). |
| `*.tmpl` | Rendered via chezmoi's template engine; secrets pulled from 1Password. |

Notable files:

| Path | Purpose |
| --- | --- |
| `dot_config/hypr/modify_bindings.conf` | Maintains a fenced block of personal Hyprland bindings (brightness + disabled webapp launchers) inside Omarchy's `bindings.conf`. |
| `dot_config/omarchy/hooks/post-update` | Re-runs `chezmoi apply` after every `omarchy update` so migrations can't clobber overrides. |
| `.chezmoitemplates/install-webapp.sh` | Shared webapp install + icon logic; per-webapp `.tmpl` scripts just pass parameters. |
| `run_after_merge-*.sh` | Merge personal keys into agent/CLI configs (Claude, Codex, opencode) without touching each tool's runtime state. |
| `run_remove-omarchy-apps.sh` | Strips unused `.desktop` entries and sweeps package orphans on every apply. |

## What's managed

| Area | Details |
| --- | --- |
| Brightness | F1/F2 → `omarchy-brightness-display` (±5%; `SHIFT` min/max; `ALT` ±2%). Handles Apple Studio Displays and laptop backlights. |
| Removed defaults | HEY, Basecamp, Figma, Fizzy, Google Photos, Google Messages + their keybindings. |
| Git | `~/.gitconfig` over Omarchy's defaults; GitHub `includeIf` `noreply` email; delta pager; `gitleaks` pre-commit scan. |
| Dev environments | Ruby/Go/Zig via mise, Rust via rustup. |
| Webapps | Gmail (`mailto:` default) and Google Sheets, with explicit Dashboard Icons glyphs. |
| Networking | Tailscale; per-machine ControlD via `ctrld`; USB Wi-Fi dongle preferred via route metric; `usb_modeswitch`; Wi-Fi power-save disabled on AC machines (by chassis). |
| CLI tooling | Context7 (`ctx7`) per agent; `git-delta`, `go-yq`, `gitleaks`, Playwright Chromium, `cfspeedtest`. |
| Fonts | Apple system fonts mapped over the CSS `system-ui`/`-apple-system` stack. |
| Apps | Dropbox, LaTeX (TeX Live), Chromium Google OAuth flags. |
| Audio | HDA codec power-save disabled on AC machines (by chassis) to stop idle pops. |
| Waybar | Battery module stripped on machines with no system battery, dodges an upstream waybar crash on wireless-mouse (`hidpp`) battery churn ([#5019](https://github.com/Alexays/waybar/issues/5019)). |
