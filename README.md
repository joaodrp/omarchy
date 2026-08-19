# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) 4 (`quattro`) — Arch + Hyprland, with Hyprland
configured in Lua and the desktop provided by Quickshell.

## Bootstrap on a new machine

```bash
omarchy pkg add chezmoi
chezmoi init https://github.com/joaodrp/omarchy.git
chezmoi apply
```

`init` prompts for the personal email, this machine's ControlD resolver ID,
and whether to authorize the Thunderbolt dock at the LUKS prompt. Any can be
left blank; a headless bootstrap has to supply them another way.

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
| `dot_config/hypr/modify_bindings.lua` | Maintains a fenced block of personal Hyprland bindings inside Omarchy's `bindings.lua`: drops unwanted preinstalled webapp keys, rebinds mail/calendar to the Google webapps, and corrects Picture-in-Picture placement. |
| `dot_config/hypr/modify_autostart.lua` | Starts `wayvnc-tailnet` with the session. |
| `dot_config/omarchy/hooks/post-update` | Re-runs `chezmoi apply` after every `omarchy update` so migrations can't clobber overrides. |
| `.chezmoitemplates/install-webapp.sh` | Shared webapp install logic; per-webapp `.tmpl` scripts just pass parameters. |
| `run_after_merge-*.sh` | Merge personal keys into agent/CLI configs (Claude, Codex, opencode) without touching each tool's runtime state. |
| `run_after_yubikey-harden-pam.sh` | Adds the options Omarchy's FIDO2 setup omits, so the key verifies a fingerprint rather than mere presence. |
| `run_remove-omarchy-apps.sh` | Strips unwanted `.desktop` entries and sweeps package orphans on every apply. |
| `run_after_retire-polkit-plugin-clone.sh` | Self-retiring carrier for an upstream polkit fix; deletes itself once Omarchy ships it. |

## What's managed

| Area | Details |
| --- | --- |
| Hyprland | Personal bindings block; wayvnc autostart; PiP right-edge placement fix. |
| Security | YubiKey Bio for `sudo` and polkit: Omarchy's `omarchy setup security fido2` owns the packages, authfile and PAM lines; this repo layers on a fixed `pam://omarchy` origin and `userverification=1` so a fingerprint match is required, not just a touch. |
| Removed defaults | Basecamp, HEY, Google Photos, plus their keybindings. |
| Webapps | Gmail (`mailto:` default), Google Calendar, Google Sheets, Claude, Claude Design, Perplexity, YNAB, Home Assistant, GitHub — with explicit Dashboard Icons glyphs. |
| Networking | Tailscale (SSH enabled); per-machine ControlD over DoT in systemd-resolved, with NetworkManager kept out of DNS so no uplink falls back to DHCP; `dns-controld --pause` to switch resolver temporarily; USB Wi-Fi dongle preferred via a route-metric dispatcher; `usb_modeswitch`; ufw trusts `tailscale0` for Mosh and wayvnc. |
| Git | `~/.gitconfig` over Omarchy's defaults; GitHub `includeIf` `noreply` email; delta pager; `gitleaks` pre-commit scan. |
| Dev environments | Ruby/Go/Zig via mise, Rust via rustup. |
| CLI tooling | `agent-browser`, `defuddle`, `glab`, `git-delta`, `go-yq`, `gitleaks`, `cfspeedtest`, `cdctl`, `mosh`, `release-plz`, `ansible`. |
| AI agents | `~/.claude/CLAUDE.md` is the single source of global prefs, rendered into per-agent `AGENTS.md` for Codex/OpenCode; Perplexity + Context7 MCP servers load keys from a `chmod 600` env file materialized from 1Password (`refresh-agent-secrets`), so they start without an `op` prompt over SSH. ChatGPT desktop (bundles Codex) via `omarchy install ai-chatgpt`. |
| Fonts | Apple system fonts mapped over the CSS `system-ui`/`-apple-system` stack. |
| Apps | Dropbox, Telegram, Calibre, LaTeX (TeX Live), Chromium Google OAuth flags. |
| Hardware | HDA codec power-save disabled on AC machines (by chassis) to stop idle pops; `hid_apple` fnmode override; `dmidecode`. |
