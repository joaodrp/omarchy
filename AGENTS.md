# omarchy dotfiles (chezmoi)

chezmoi-managed dotfiles for omarchy (Arch + Hyprland). Files here are the
source; `chezmoi apply` renders them into `~`.

## Principles

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
