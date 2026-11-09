# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) 4 (`quattro`) — Arch + Hyprland, with Hyprland
configured in Lua and the desktop provided by Quickshell.

## Bootstrap on a new machine

Full sequence, including the manual steps nothing can vendor (firmware,
1Password toggles, logins), is in [BOOTSTRAP.md](BOOTSTRAP.md), written so an
agent can walk it with you. The core is:

```bash
omarchy pkg add chezmoi
chezmoi init --source ~/Developer/github.com/joaodrp/omarchy joaodrp/omarchy
chezmoi apply
```

`init` prompts for the personal email, this machine's ControlD resolver ID,
and whether to authorize the Thunderbolt dock at the LUKS prompt (`auto`
installs that hook only where the dock's keyboard needs it). The first two can
be left blank. The clone lives under `~/Developer/<host>/<org>/<repo>` like any
other project; `sourceDir` is persisted so later commands find it.

`chezmoi apply` is idempotent — re-run after any drift. `dotfiles-doctor`
reports what is still missing.

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
| `dot_config/hypr/modify_input.lua` | Maintains a fenced block of personal input overrides inside Omarchy's `input.lua`: slower touchpad scrolling in Chromium-based browsers and their webapps. |
| `dot_config/systemd/user/wayvnc-tailnet.service` | Supervised wayvnc on the Tailscale address, started with the graphical session. |
| `dot_local/bin/clone-my-repos` | Clones every non-archived source repo of the account and its orgs under `~/Developer`, and fast-forwards existing default branches that aren't checked out. Run daily by `clone-my-repos.timer`. |
| `dot_local/bin/dotfiles-doctor` | Read-only check of the state chezmoi cannot vendor (1Password toggles, logins, per-machine answers). |
| `dot_local/bin/reboot-windows` | Reboots once into Limine's Windows entry, the boot path BitLocker is sealed to. Installed only where Limine has a Windows entry. |
| `dot_config/omarchy/hooks/post-update.d/chezmoi-apply` | Re-runs `chezmoi apply` after every `omarchy update` so migrations can't clobber overrides. |
| `dot_config/mise/config.toml` | Declares the mise-managed toolchains and CLIs; `run_after_mise-install.sh` realizes it. Vendored so the tool list is versioned rather than living only in a file several installers mutate. It leaves the stock agents and CLIs to Omarchy's own system-wide declarations. |
| `.chezmoitemplates/install-webapp.sh` | Shared webapp install logic; `run_onchange_install-webapps.sh.tmpl` lists the webapps. |
| `run_after_merge-*.sh` | Merge personal keys into agent/CLI configs (Claude, Codex, opencode) without touching each tool's runtime state. |
| `run_after_yubikey-harden-pam.sh` | Adds the options Omarchy's FIDO2 setup omits, so the key verifies a fingerprint rather than mere presence. |
| `run_remove-omarchy-apps.sh` | Strips unwanted webapp `.desktop` entries on every apply. Package orphans are left to `omarchy update`. |

## What's managed

| Area | Details |
| --- | --- |
| Hyprland | Personal bindings block; PiP right-edge placement fix; slower touchpad scrolling in Chromium-based browsers. |
| Desktop | Default agent (Claude Code, set only if unset); Starship theme set once per machine, so a later switch sticks; Superwhisper dictation through omarchy's own installer and keys, pinned to its local Offline Lite mode (Parakeet TDT 0.6B v3; English and Portuguese among 25 European languages), automatic language detection, balanced tone, vocabulary learned from corrections, and restoring the clipboard after inserting text. |
| Security | YubiKey Bio for `sudo` and polkit: Omarchy's `omarchy setup security fido2` owns the packages, authfile and PAM lines; this repo layers on a fixed `pam://omarchy` origin and `userverification=1` so a fingerprint match is required, not just a touch. |
| Removed defaults | Basecamp and HEY, plus their keybindings. |
| Webapps | Gmail (`mailto:` default), Google Calendar, Google Sheets, Claude Design, Perplexity, YNAB, Home Assistant, GitHub — with explicit Dashboard Icons glyphs. |
| Networking | Tailscale (SSH enabled); per-machine ControlD over DoT in systemd-resolved, with NetworkManager kept out of DNS so no uplink falls back to DHCP; `dns-controld --pause` to switch resolver temporarily; USB Wi-Fi dongle preferred via a route-metric dispatcher; `usb_modeswitch`; ufw trusts `tailscale0` for Mosh and wayvnc. |
| Git | `~/.gitconfig` over Omarchy's defaults; GitHub `includeIf` `noreply` email; delta pager; `gitleaks` pre-commit scan. |
| Dev environments | Ruby/Go/Zig via mise, Rust via rustup. |
| CLI tooling | `agent-browser`, `defuddle`, `td` (Todoist), `glab`, `git-delta`, `go-yq`, `gitleaks`, `cfspeedtest`, `cdctl`, `mosh`, `release-plz`, `ansible`, `7zip`. |
| AI agents | `~/.claude/CLAUDE.md` is the single source of global prefs, rendered into per-agent `AGENTS.md` for Codex/OpenCode; Perplexity + Context7 MCP servers load keys from a `chmod 600` env file materialized from 1Password (`refresh-agent-secrets`), so they start without an `op` prompt over SSH. ChatGPT desktop (bundles Codex) via `omarchy install ai-chatgpt`, Claude desktop via `omarchy install ai claude`. Todoist CLI skill installed for every agent. |
| Fonts | Inter and JetBrains Mono mapped over the CSS `system-ui`/`-apple-system`/`ui-monospace` stack, so macOS-styled pages (GitHub, etc.) get open-source look-alikes; Apple's SF fonts are licensed for Apple platforms only. |
| Apps | Dropbox, Telegram, Calibre, LaTeX (TeX Live), PhotoCraft and LightCraft (photo editing; latest upstream release, per user, checksum-verified), Chromium Google OAuth flags. |
| Hardware | HDA codec power-save disabled on AC machines (by chassis) to stop idle pops; AirPlay receivers (HomePod, Apple TV) as PipeWire outputs via `pipewire-zeroconf`; `hid_apple` fnmode override; the Framework light sensor rebound after resume, where it reads 0 until then; the Framework power button blinks while the fingerprint reader waits for a touch; `dmidecode`. |
