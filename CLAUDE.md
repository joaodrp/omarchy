# omarchy dotfiles (chezmoi)

chezmoi-managed dotfiles for omarchy (Arch + Hyprland). Files here are the
source; `chezmoi apply` renders them into `~`.

## Principles

- Always prefer idempotent and safe solutions. The `run_onchange_*` /
  `run_after_*` scripts and any system or config change must be re-runnable
  without side effects, guard against partial or repeated application, and
  avoid destructive or hard-to-reverse operations.

## Workflow

- Develop on a feature branch and validate (`chezmoi apply` / test) before
  merging. Self-merge to `main` once validated; no PR or external review
  needed (personal dotfiles repo).
