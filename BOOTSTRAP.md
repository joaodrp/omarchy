# New machine bootstrap

The full sequence from bare metal to a converged machine. Written to be walked
by an agent alongside the human: each step names who acts and how to verify it.
Steps are idempotent: resume from the first one whose check fails.

Agents: confirm each check before moving on, and ask the human only for the
steps marked **human**. `dotfiles-doctor` (installed by step 10) re-checks
everything that chezmoi cannot vendor; loop until it exits 0.

## Before install (human)

1. **Firmware:** Secure Boot off (the Omarchy ISO is unsigned).
2. **Dual boot only:** in Windows, turn BitLocker / Device encryption off and
   leave unallocated space for Omarchy. The installer refuses an encrypted disk.
3. **Install Omarchy.** Give it a separate EFI partition when dual booting, so
   Windows updates cannot touch Limine.

## First boot (human)

4. **Wi-Fi.**
5. **Fingerprint popup** (machines with a reader): accept and enroll a finger.
   Omarchy owns this; it is not vendored.
6. **Default agent popup:** pick the agent and log in to it. The choice itself
   is vendored (`~/.config/omarchy/defaults/agent`), so on a rebuild the popup
   only appears if it fires before the first apply.
7. **1Password app:** sign in, then Settings > Developer:
   - *Integrate with 1Password CLI*
   - *Use the SSH agent* (keys must be in a vault the agent may use)

   App settings are HMAC-signed per device, so none of this can be vendored.

   The apply reads secrets by `op://` reference, so they must already exist:
   the Perplexity and Context7 API keys, and the Control D API token that logs
   `cdctl` in for the bar widget.

   Check: `op account list` lists the account; `SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -l` lists keys.

Then open the agent and say: *bootstrap this machine from joaodrp/omarchy*.

## Converge (agent leads)

8. **Root for the apply (human).** About a dozen scripts need sudo, and an
   agent's shell has no terminal to type a password into (fingerprint PAM does
   not reach it either). In a real terminal:

   ```bash
   omarchy-sudo-passwordless 60
   ```

   Check: `sudo -n true`. Without this the apply stops part-way; the
   alternative is for the human to run step 10 in their own terminal.

9. **Clone and configure** (public repo, so no GitHub auth yet):

   ```bash
   omarchy pkg add chezmoi
   chezmoi init --source ~/Developer/github.com/joaodrp/omarchy joaodrp/omarchy
   ```

   Prompts, asked once and stored in `~/.config/chezmoi/chezmoi.toml`:
   - personal email
   - ControlD resolver ID: blank leaves DNS to Omarchy; add it later and re-apply
   - Thunderbolt dock at LUKS: `auto`

   An agent has no TTY, so it asks the human and passes the answers. The flags
   match on the full prompt text from `.chezmoi.toml.tmpl`, not the data key:
   `--promptString "Personal email=..." --promptString "<ControlD prompt>=..." --promptChoice "<Thunderbolt prompt>=auto"`.

10. **Apply:** `chezmoi apply --keep-going`, so one failing installer is
    reported instead of aborting the rest; re-run until clean. Long on a first
    run (TeX Live, Android SDK, toolchains). The **human** finishes these when
    they appear:
    - Tailscale: open the login URL `tailscale up` prints; approve the device
      in the admin console if the tailnet requires it
    - Dropbox: tray icon > sign in
    - ChatGPT desktop launches once; close it

11. **GitHub (human):** `gh auth login` (browser, one code). It covers both
    the `gh` CLI and git over HTTPS: `~/.gitconfig` routes GitHub credentials
    through `gh auth git-credential`, so remotes stay HTTPS and nothing
    prompts per push.

    Then `clone-my-repos`: every non-archived source repo of the account and
    its orgs, default branch only, into `~/Developer/github.com/<owner>/<repo>`.
    From then on a daily timer clones new repos and fast-forwards default
    branches that aren't checked out; `clone-my-repos --pull-checked-out` also
    fast-forwards clean checked-out ones. To develop a vendored bar
    widget, symlink its plugin path to the checkout; a checkout alone leaves
    the plugin managed.

12. **Restart the agent, then `chezmoi apply` again.** A running Claude Code
    rewrites `~/.claude.json` on exit, dropping the MCP servers merged while it
    ran.

13. **Verify:** `dotfiles-doctor` exits 0. Optional rows (ControlD, YubiKey) may stay
    `skip`.

## Later, per machine

- ControlD: set `controld_resolver_id` in `~/.config/chezmoi/chezmoi.toml`, then `chezmoi apply`.
- YubiKey: plug it in, `omarchy-yubikey-enroll`, `omarchy setup security fido2`, `chezmoi apply`.
- Thunderbolt keyboard at LUKS: `auto` decides on the first apply with the dock attached; see `run_after_thunderbolt-keyboard-at-luks.sh.tmpl`.
- Windows dual boot with BitLocker: with Secure Boot off, BitLocker seals to the boot chain it was enabled on, and Windows' own restarts go through Limine. Enable it after booting Windows from Limine's menu (or `reboot-windows`), keep starting Windows that way, and expect a recovery-key prompt after each Limine update. Move to Secure Boot (`sbctl enroll-keys -m`) once https://github.com/basecamp/omarchy/pull/12246 lands, fixing https://github.com/basecamp/omarchy/issues/10945: suspend BitLocker in Windows first, then re-add its TPM protector and confirm PCR profile 7, 11.
