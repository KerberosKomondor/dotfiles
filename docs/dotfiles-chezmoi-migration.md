# Dotfiles migration: bare-repo → chezmoi

## Why

Current setup is a bare git repo (`~/.cfg`, worktree=`$HOME`, aliased as `config`). Works, but has no way to express per-machine variance. Need to support work vs personal machines across arch/mac/wsl, which the bare-repo approach can't do — everything in the worktree is unconditional.

## Status

Design phase, not yet implemented. This doc will be updated to a retrospective ("what was configured") once migration lands.

## Tool choice: chezmoi

Considered chezmoi, yadm, Nix home-manager.

- **yadm** — closest UX to current bare-repo aliasing, lowest switching cost, but machine variance is naming-convention-based (`file##hostname.foo`, `file##distro.arch`) with no real template language. Doesn't cleanly express two independent axes (OS × work/personal) — alt-file naming gets combinatorial fast.
- **Nix home-manager** — most powerful, but a full ecosystem buy-in (Nix package manager, flakes, new language). Bigger project than a dotfiles migration.
- **chezmoi (chosen)** — Go template engine handles multi-axis variance directly (`.chezmoi.os`, custom `.class` data var for work/personal). Native secret integration (`age` encryption, live `bitwarden`/`onepassword` template funcs) fits the existing `bw unlock` habit already used in `env_vars.sh`. Steeper learning curve than yadm, justified by the actual requirement (2-axis templating + secrets).

## Repo

- New repo, fresh history — no import from `.cfg`. Source lives at `~/.local/share/chezmoi`, its own git repo, bootstrapped via `chezmoi init`.
- Old `.cfg` bare repo left untouched during migration, archived (not deleted) once confidence is established post-cutover.

## Templating scheme

- `.chezmoi.toml.tmpl` prompts on `chezmoi init` for machine class (`work` / `personal`), stored as `.class` in `~/.config/chezmoi/chezmoi.toml`.
- OS axis auto-detected: `.chezmoi.os` (`darwin`/`linux`); WSL detected via `.chezmoi.kernel.osrelease` containing `microsoft`.
- Variant files become `.tmpl`, e.g. `dot_zshrc.tmpl` branching on `{{ if eq .chezmoi.os "darwin" }}...{{ else if .isWSL }}...{{ else }}...{{ end }}` and `{{ if eq .class "work" }}...{{ end }}`.
- `.chezmoiignore.tmpl` skips whole files per axis (e.g. skip `dot_config/hypr/` on darwin).
- Candidates already showing OS/class branching today: `.zshrc`, `.zshrc.mac.zsh`, `.zshrc.systemd.zsh`, `hyprland.lua`.

## Secrets

- Replace the manual `env_vars.sh` (gitignored) + `env_vars-example.sh` (committed) split with chezmoi's native `bitwarden` template func — live pulls at `apply` time, secrets never touch the repo.
- Example: `dot_config/env_vars.sh.tmpl` containing `{{ (bitwarden "item" "jira-api-token").login.password }}`.
- Relies on the same `bw unlock` flow already in use.

## Icons/themes (out of scope for VCS)

- `.icons` and `.themes` (2895 + 1412 files, ~57G of the current 57G `.cfg` dir) are vendored theme assets, not config — dropped from tracking entirely.
- Replaced with `run_onchange_install-themes.sh.tmpl` (chezmoi run-script, re-runs when its content hash changes) that installs the Dracula theme via pacman/AUR or a pinned git clone instead of tracking every file.

## Migration steps

1. `doas pacman -S chezmoi` (verify it's in extra/community, not AUR-only)
2. Resolve/commit current WIP in `.cfg` before snapshotting (unrelated in-flight ags/hyprland changes — user's call on timing)
3. `chezmoi init` — fresh repo, no history import
4. `chezmoi add` everything except `.icons`/`.themes`
5. Convert host/class-variant files to `.tmpl`, starting with the candidates listed above
6. Wire up `bitwarden` template funcs, migrate `env_vars.sh` content in, retire the gitignore-split pattern
7. Write `run_onchange_install-themes.sh.tmpl`
8. Verify on this machine: `chezmoi diff`, `chezmoi apply --dry-run`
9. Test the second axis: dry-run against a WSL or mac target if available, otherwise review templates by hand
10. Cutover: `chezmoi apply` for real, archive `.cfg`
11. Update this doc from plan → retrospective

## Known issues / open questions

- None yet — pre-implementation.
