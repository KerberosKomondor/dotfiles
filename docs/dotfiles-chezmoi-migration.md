# Dotfiles migration: bare-repo → chezmoi

## Why

Current setup is a bare git repo (`~/.cfg`, worktree=`$HOME`, aliased as `config`). Works, but has no way to express per-machine variance. Need to support work vs personal machines across arch/mac/wsl, which the bare-repo approach can't do — everything in the worktree is unconditional.

## Status

Implemented 2026-07-15. Source repo: `~/.local/share/chezmoi`. Old bare repo archived at `~/.cfg.archived-20260715` (renamed, not deleted).

## Tool choice: chezmoi

Considered chezmoi, yadm, Nix home-manager.

- **yadm** — closest UX to current bare-repo aliasing, lowest switching cost, but machine variance is naming-convention-based (`file##hostname.foo`, `file##distro.arch`) with no real template language. Doesn't cleanly express two independent axes (OS × work/personal) — alt-file naming gets combinatorial fast.
- **Nix home-manager** — most powerful, but a full ecosystem buy-in (Nix package manager, flakes, new language). Bigger project than a dotfiles migration.
- **chezmoi (chosen)** — Go template engine handles multi-axis variance directly (`.chezmoi.os`, custom `.class` data var for work/personal). Native secret integration (`age` encryption, live `bitwarden`/`onepassword` template funcs) fits the existing `bw unlock` habit already used in `env_vars.sh`. Steeper learning curve than yadm, justified by the actual requirement (2-axis templating + secrets).

## Repo

- New repo, fresh history — no import from `.cfg`. Source lives at `~/.local/share/chezmoi`, its own git repo, bootstrapped via `chezmoi init`.
- Old `.cfg` bare repo left untouched during migration, archived (not deleted) once confidence is established post-cutover.

## Templating scheme

- `.chezmoi.toml.tmpl` prompts on `chezmoi init` for machine class (`work` / `personal`), stored as `.class` in `~/.config/chezmoi/chezmoi.toml`. This machine is classed `personal`.
- OS axis auto-detected: `.chezmoi.os` (`darwin`/`linux`); WSL detected via `.chezmoi.kernel.osrelease` containing `microsoft`.
- `.chezmoiignore.tmpl` skips whole Linux-desktop-only `.config` subdirs (ags, hypr, waybar, dunst, polybar, wireplumber, xdg-desktop-portal, environment.d, systemd, gtk-3.0, fontconfig) plus `.xinitrc` on darwin/WSL. It also permanently ignores `.config/neomutt/accounts`, `*id_rsa*`, and `.config/nvim/lazy-lock.json`, matching the old `.gitignore`'s secret/lockfile exclusions.
- `hyprland.lua` and the rest of `.config/hypr` are Hyprland/Arch-only and were **not** templated internally — no OS branching exists in the file itself, so they're handled entirely by `.chezmoiignore.tmpl` instead.
- `.zshrc` already branches on `uname`/`command -v systemctl` at shell runtime (sourcing `.zshrc.mac.zsh` / `.zshrc.systemd.zsh`) — migrated as plain files via `chezmoi add`, no chezmoi-level templating needed.
- Gitconfig (`dot_gitconfig`) stays a single unconditional file, no work/personal split — its Azure DevOps/VSTS aliases were already live on this personal-classed machine and splitting them would have removed working functionality; decided to leave as-is.

## Secrets

- Replaced the manual `env_vars.sh` (gitignored) + `env_vars-example.sh` (committed) split with chezmoi's native `bitwarden` template func — live pulls at `apply` time, secrets never touch the repo.
- Actual file: `res/env_vars.sh.tmpl` (matches the real source path `~/res/env_vars.sh` that `.zshrc:143` sources — **not** `~/.config/env_vars.sh`, an error in the original design draft caught during implementation).
- `JIRA_API_TOKEN`, `ATLASSIAN_CLOUD_ID`, `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN` are gated behind `{{ if eq .class "work" }}` — three Bitwarden login items required on any `work`-classed machine: `jira-api-token` (login.password), `atlassian-cloud-id` (login.password), `atlassian-api-token` (login.username = email, login.password = token). Not yet created — no `work`-classed machine exists yet.
- `BRANCHPREFIX` (used by `.gitconfig`'s `ticket`/`hotfix` aliases) is non-secret, stays a literal value (`"wh"`) in the template, unconditional.
- The `bw unlock`/`BW_SESSION` dance stays literal runtime shell code (inherently per-shell-session, can't be templated away).
- Applying on this (personal) machine removed the previously-live `JIRA_API_TOKEN`/`ATLASSIAN_*` exports — confirmed with the user this machine doesn't run jira-cli/Atlassian tooling day to day before applying.

## Icons/themes (out of scope for VCS)

- `.icons` and `.themes` (2895 + 1412 files, ~57G of the current 57G `.cfg` dir) are vendored theme assets, not config — dropped from tracking entirely.
- Replaced with `run_onchange_install-themes.sh.tmpl` (chezmoi run-script, re-runs when its content hash changes) that installs the Dracula theme via pacman/AUR or a pinned git clone instead of tracking every file.

## What actually happened

1. `doas pacman -S chezmoi` — v2.71.0, extra repo, as expected.
2. Bootstrapped `~/.local/share/chezmoi` fresh via `chezmoi init`, no history import. Set repo-local `user.name`/`user.email` (matching the identity already used by the old `.cfg` repo — not global, since global git config has none set).
3. Added `.chezmoiignore.tmpl` for OS/WSL exclusion.
4. Migrated `.zshrc`/`.zshrc.mac.zsh`/`.zshrc.systemd.zsh`/`.gitconfig`/`.gitconfig.dracula` as plain files — no templating turned out to be needed for any of them.
5. Built `res/env_vars.sh.tmpl` for Bitwarden-gated secrets (path corrected from an initial `.config/env_vars.sh` draft error — caught by grepping `.zshrc` for the actual source line).
6. Wrote `run_onchange_install-themes.sh.tmpl`; confirmed idempotent (no-op since `.icons`/`.themes` already existed on disk from before).
7. Bulk-add for `.config` and other top-level dirs (`res/`, `.local/`, `.claude`, `.var`, etc.) required care beyond the original plan: naive `chezmoi add ~/.config`, `~/.claude`, `~/.local` swept toward multi-GB app-state directories (`.config/google-chrome` 4.9G, `.config/discord` 529M, all of `~/.claude`'s plugin/session data) that were never part of the old bare repo's tracked set — only specific files within them were. Recovered by reverting the accidental adds and instead replicating the **exact file list** the old bare repo tracked (`git ls-tree -r`), file by file, rather than adding whole directories. This is the pattern to repeat on any future machine's initial `chezmoi add` pass.
8. Also caught mid-implementation: two systemd unit files (`lan-mouse.service`, `synergy.service`) that the old repo's HEAD tracked were already deleted on disk (matching in-flight WIP that predated this migration) — skipped rather than re-adding stale content.
9. Verified: `chezmoi diff` clean pre-apply, dry-run reviewed and confirmed with the user (the `JIRA_API_TOKEN` removal specifically), then `chezmoi apply` — clean, zero drift afterward.
10. Cross-checked the `work`-class branch by temporarily flipping `~/.config/chezmoi/chezmoi.toml`'s `class` value and re-rendering (read-only, no `apply` involved, restored immediately after) — confirmed the Bitwarden template func is correctly wired and reachable; full rendering needs a real unlocked vault, not available in this session.
11. Archived: `~/.cfg` → `~/.cfg.archived-20260715` (rename, not delete).

## Known issues / open questions

- **Bitwarden staleness**: secret values are baked into the rendered file at `chezmoi apply` time, not re-fetched per shell. Rotating a token in Bitwarden requires re-running `chezmoi apply` to pick it up.
- **A live JIRA API token was printed in plaintext into this session's tool output** (via `chezmoi diff`, comparing the old plaintext file against the new template, before the first `apply`). Recommend rotating that token.
- **Only one machine tested live** (this one, `personal`, Arch/Hyprland). The `work` class and the darwin/WSL branches of `.chezmoiignore.tmpl` are verified by template inspection and a temporary config-flip test only — not a real second machine. Set one up before trusting those paths fully.
- **`work`-classed machines need 3 Bitwarden items created first**: `jira-api-token`, `atlassian-cloud-id`, `atlassian-api-token` (see Secrets section for exact field mapping). None exist yet.
- **`~/docs/` is still tracked by the archived `.cfg` repo**, not by chezmoi — this doc included. Not brought into the chezmoi migration's scope. If `~/docs/` should stay version-controlled going forward, it needs its own decision (track under chezmoi too, or keep `.cfg.archived-20260715` alive specifically for docs, or something else) — unresolved.
