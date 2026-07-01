# Hyprland Configuration

## Files

- `~/.config/hypr/hyprland.lua` — main config (Lua format, 0.55+)
- `~/.config/hypr/hyprland.conf` — kept as fallback reference (old format)
- `~/.config/hypr/hyprpaper.conf`, `hypridle.conf`, `hyprlock.conf` — companion configs

## Lua Config (0.55+)

Hyprland 0.55 added Lua as the primary config format. The file must be named `hyprland.lua` in `~/.config/hypr/`. The global `hl` namespace exposes the full API.

Key API surface:
- `hl.monitor({})` — monitor setup
- `hl.config({})` — all settings blocks (general, input, decoration, animations, dwindle, xwayland, misc)
- `hl.animation({})` — per-leaf animation config
- `hl.workspace_rule({})` — workspace rules including names
- `hl.window_rule({})` — window rules (match by class/title/xwayland/float/etc.)
- `hl.on("hyprland.start", fn)` — replaces `exec-once`
- `hl.bind(key, dispatcher, opts?)` — keybindings; `{ repeating = true }` = binde, `{ release = true }` = bindr, `{ mouse = true }` = bindm
- `hl.submap("name")` / `hl.submap("reset")` — submap context blocks
- `hl.dsp.*` — dispatchers: `exec_cmd`, `focus`, `window.close`, `window.move`, `window.resize`, `window.float`, `window.drag`, `window.fullscreen`, `layout`, `submap`, `workspace.move_to_monitor`

Reference example: `/usr/share/hypr/hyprland.lua`

## Window Manager Setup

- Monitors: DP-1 (right, 144Hz, primary), DP-2 (left, 240Hz)
- Mod key: ALT (WM), SUPER (app launches)
- Layout: dwindle with preserve_split
- Theme: Dracula (border active = #8be9fd, inactive = #44475a)
- Named workspaces: 1=browser, 2=tmux, 3=teams, 4=rdesk

## Known Uncertainties in Lua API (verify if broken)

These Lua API calls are reasonable translations but are not shown in the official example file — check the wiki if they fail:

- `hl.dsp.submap("name")` / `hl.submap("name")` — submap support
- `hl.dsp.workspace.move_to_monitor("r")` — movecurrentworkspacetomonitor
- `hl.dsp.window.fullscreen(0)` — fullscreen mode argument
- `hl.dsp.window.move({ direction = "left" })` — directional window move
- `hl.workspace_rule({ workspace = "1", name = "browser" })` — named workspaces via workspace_rule

## Synergy / XWayland

Synergy uses XTest via XWayland (`:0`), not the EI/InputCapture portal (broken on this stack). See `~/.config/systemd/user/synergy.service.d/wayland-env.conf` — sets `XDG_SESSION_TYPE=x11` and `DISPLAY=:0`.

## Session / Autostart

- `hyprland-session.target` activates `synergy.service`
- XDG portals started explicitly in autostart (xdg-desktop-portal-hyprland, xdg-desktop-portal)
- `dex --autostart` handles XDG autostart entries
