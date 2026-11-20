# dotfiles

Personal config managed with [chezmoi](https://chezmoi.io), targeting
[Omarchy](https://omarchy.org/) 4.5 and later — Arch + Hyprland, with Hyprland
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

`init` prompts for the personal email, the Home Assistant URL for its webapp,
this machine's ControlD resolver ID, and whether to authorize the Thunderbolt
dock at the LUKS prompt (`auto` installs that hook only where the dock's
keyboard needs it). The URL and resolver ID can be left blank to skip them.
The clone lives under `~/Developer/<host>/<org>/<repo>` like any other
project; `sourceDir` is persisted so later commands find it.

`chezmoi apply` is idempotent — re-run after any drift. `dotfiles-doctor`
reports what is still missing.

## Layout

Source-state prefixes encode behaviour:

| Prefix | Behaviour |
| --- | --- |
| `run_onchange_*` | Re-runs only when its rendered content changes (installers). |
| `run_after_*` | Runs on *every* apply (config merges that must re-assert after an app rewrites its own file). |
| `modify_*` | Filters the existing target through the script (idempotent in-place edits). |
| `*.tmpl` | Rendered via chezmoi's template engine (per-machine data, shared snippets). Secrets never pass through templates: `refresh-agent-secrets` reads them from 1Password at runtime. |

Notable files:

| Path | Purpose |
| --- | --- |
| `dot_config/hypr/modify_bindings.lua.tmpl` | Fenced block of personal bindings inside Omarchy's `bindings.lua`: mail/calendar keys to the Google webapps, Strata as the file manager, a PiP placement fix, Shift+Mute output switch. |
| `dot_config/hypr/modify_input.lua.tmpl` | Fenced block inside Omarchy's `input.lua`: slower touchpad scrolling in Chromium-based browsers and their webapps. |
| `dot_config/systemd/user/wayvnc-tailnet.service` | Supervised wayvnc on the Tailscale address, started with the graphical session. |
| `dot_local/bin/executable_clone-my-repos` | Clones every non-archived source repo of the account and its orgs under `~/Developer`, and fast-forwards default branches that aren't checked out. Run daily by `clone-my-repos.timer`. |
| `dot_local/bin/executable_dotfiles-doctor` | Read-only check of the state chezmoi cannot vendor (1Password toggles, logins, per-machine answers). |
| `dot_local/bin/executable_reboot-windows` | Reboots once into Limine's Windows entry, the boot path BitLocker is sealed to. Installed only where Limine has a Windows entry. |
| `dot_config/omarchy/hooks/post-update.d/executable_chezmoi-apply` | Re-runs `chezmoi apply` after every `omarchy update` so migrations can't clobber overrides. |
| `dot_config/mise/config.toml` | The mise-managed toolchains and CLIs, realized by `run_after_mise-install.sh`. |
| `.chezmoitemplates/install-webapp.sh` | Shared webapp install logic; `run_onchange_install-webapps.sh.tmpl` lists the webapps. |
| `run_after_merge-*.sh{,.tmpl}` | Merge personal keys into agent/CLI configs (Claude, Codex, opencode) and the vendored bar widgets into Omarchy's shell config, without touching each tool's runtime state. |
| `run_after_yubikey-harden-pam.sh.tmpl` | Adds the options Omarchy's FIDO2 setup omits, so the key verifies a fingerprint rather than mere presence. |
| `run_remove-omarchy-apps.sh` | Strips unwanted webapp `.desktop` entries on every apply. Package orphans are left to `omarchy update`. |

## What's managed

| Area | Details |
| --- | --- |
| Hyprland | Personal bindings block; PiP right-edge placement fix; slower touchpad scrolling in Chromium-based browsers. |
| Desktop | Default agent (Claude Code, set only if unset); Starship theme set once per machine, so a later switch sticks; Strata as the file manager (folders, file chooser, "Show in folder"). |
| Dictation | Superwhisper through Omarchy's own installer and keys, pinned to its local offline model; automatic language detection, balanced tone, vocabulary learned from corrections, clipboard restored after inserting text. |
| Security | YubiKey Bio for `sudo` and polkit: Omarchy's `omarchy setup security fido2` owns the packages, authfile and PAM lines; this repo adds a fixed `pam://omarchy` origin and `userverification=1`, so a fingerprint match is required, not just a touch. |
| Removed defaults | Basecamp, HEY and Claude webapps. HEY's mail/calendar keys are rebound to Gmail/Google Calendar. |
| Webapps | Gmail (`mailto:` default), Google Calendar, Google Sheets, Claude Design, Perplexity, YNAB, Home Assistant, GitHub — with explicit Dashboard Icons glyphs. YouTube runs in Brave Origin. |
| Networking | Tailscale (SSH enabled); per-machine ControlD over DoT in systemd-resolved, with NetworkManager kept out of DNS so no uplink falls back to DHCP; `dns-controld --pause` to switch resolver temporarily; USB Wi-Fi dongle preferred via a route-metric dispatcher; ufw trusts `tailscale0` for Mosh and wayvnc. |
| Git | `~/.gitconfig` over Omarchy's defaults; GitHub `includeIf` `noreply` email; delta pager; `gitleaks` pre-commit scan. |
| Dev environments | Ruby, Go, Zig, Node (LTS), Java (LTS) and pnpm via mise; Rust via rustup. |
| CLI tooling | Highlights: `agent-browser`, `defuddle`, `td` (Todoist), `glab`, `gitleaks`. Main declarations in `run_onchange_install-packages.sh` and `dot_config/mise/config.toml`. |
| AI agents | `.chezmoitemplates/agent-preferences.md` is the single source of global prefs, rendered into `~/.claude/CLAUDE.md` and the Codex/OpenCode `AGENTS.md`. MCP servers load keys from a `chmod 600` env file materialized from 1Password (`refresh-agent-secrets`), so they start without an `op` prompt over SSH. ChatGPT and Claude desktop via `omarchy install`; Claude desktop's keyring flag in `claude-desktop-flags.conf`. A pinned writing skill (`.chezmoidata/agent-skills.toml`) and the Todoist CLI skill for every agent. |
| Fonts | Inter and JetBrains Mono mapped over the CSS `system-ui`/`-apple-system`/`ui-monospace` stack, so macOS-styled pages (GitHub, etc.) get open-source look-alikes; Apple's SF fonts are licensed for Apple platforms only. |
| Apps | Dropbox, Telegram, Calibre, LaTeX (TeX Live), PhotoCraft and LightCraft (latest upstream release, checksum-verified), Chromium Google OAuth flags; Brave Origin as the default browser (set once, so a later switch sticks), Firefox alongside it. Local models: Ollama in the build for the machine's GPU (CUDA on NVIDIA, Vulkan elsewhere, integrated GPUs included), at boot on 127.0.0.1, with llmfit to find models that fit; LM Studio and Jan as desktop apps. Obsidian runs with `--force-device-scale-factor=1` until omacom/omarchy#8574 is fixed. |
| Audio | HDA codec power save disabled on AC machines (by chassis) to stop idle pops; AirPlay receivers as PipeWire outputs via `pipewire-zeroconf`. |
| Speaker tuning | Laptop 13 Pro only: Framework's Windows (Dolby) tuning as a PipeWire filter-chain, rebuilt from the latest driver bundle and a pinned converter (an apply flags newer releases). Until omacom/omarchy discussion 19263 lands, the filter is hidden from the audio panel via platform hints, and Shift+Mute runs an `audio-output-switch` wrapper that steps past it. |
| Hardware | `hid_apple` fnmode override; `usb_modeswitch` for the Wi-Fi dongle; the Framework light sensor rebound after resume, where it reads 0 until then; the Framework power button blinks while the fingerprint reader waits for a touch, pausing while every display is off. |
