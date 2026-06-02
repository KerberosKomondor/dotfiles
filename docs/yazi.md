# Yazi Configuration

## Dracula Theme

Yazi supports theming via "flavors". The Dracula flavor was manually installed from [yazi-rs/flavors](https://github.com/yazi-rs/flavors).

**Files:**
- `~/.config/yazi/theme.toml` — sets the active flavor
- `~/.config/yazi/flavors/dracula.yazi/` — the flavor files

**To activate a flavor**, `theme.toml` must contain only `[flavor]` (no other style overrides unless intentional):

```toml
[flavor]
dark = "dracula"
```

## Plugins

Plugins are managed via `ya pkg` and tracked in `~/.config/yazi/packages.toml`.

### git.yazi

Shows git status (modified, untracked, added, etc.) as linemode in the file list.

- Registered as a fetcher in `yazi.toml`
- Initialized in `init.lua` with `require("git"):setup { order = 1500 }`

### smart-enter.yazi

Binds `l` to open files or enter directories with one key (instead of separate `open`/`enter` bindings).

- Configured in `keymap.toml` as `[[mgr.prepend_keymap]]`

### Installing more plugins

```sh
ya pkg add yazi-rs/plugins:<name>
ya pkg add <github-user>/<repo>:<plugin-name>
```

## Updating the Flavor

Re-copy from the upstream repo, or use the `ya` package manager:

```sh
ya pkg add yazi-rs/flavors:dracula
```

Note: `ya pkg` manages flavors as git submodules under `~/.config/yazi/flavors/`.
