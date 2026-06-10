# Notifications

AGS-rendered notifications via AstalNotifd, replacing mako and HyprPanel's built-in notifications (HyprPanel itself was later replaced by Waybar — see `~/docs/hyprland.md`).

## Why

mako's body text wrapping was fixed (`width`/`height` only). HyprPanel's built-in notifications hardcoded body text to 2 lines / 35 chars in the compiled bundle with no config option to change it. AGS gives full control over layout, styling, and behavior.

## Architecture

- `~/.config/ags/service/notifications.ts` — AstalNotifd-backed service. Exports:
  - `popupStack`, `history` — reactive state (`createState`)
  - `dismissPopup`, `clearHistory`, `removeFromHistory`, `invokeAction`
  - `urgencyClass(notif)` → `"low" | "normal" | "critical"`
  - `notifIcon(notif)` → `{ file? }` or `{ iconName? }`
  - `pauseTimer` / `resumeTimer` / `getTimerFraction` — auto-dismiss timer control
  - Listens to `notifd` `"notified"`/`"resolved"` signals to keep `popupStack` and `history` in sync
- `~/.config/ags/widget/NotificationPopups.tsx` — popup window, top-right (DP-1, `monitors[0]`). Window `visible` is bound to `popupStack.length > 0` so it fully hides (no ghost empty window) when the stack empties. Click a popup row to dismiss; click an action button to invoke it instead.
- `~/.config/ags/widget/NotificationHistory.tsx` — full-screen overlay history panel, opened via the bar badge. Click outside the panel or press Escape to close. "Clear all" empties history.
- `~/.config/ags/widget/Notifications.tsx` — bar badge (`󰂚 N`), only visible when history is non-empty. Toggles `notifHistoryVisible`.
- Wired into `~/.config/ags/app.ts` (instantiated on `monitors[0]`, i.e. DP-1) and styled in `~/.config/ags/style.scss` under `.NotificationPopups` / `.NotificationHistory`.

## Auto-dismiss timers

`service/notifications.ts` runs per-notification auto-dismiss timers keyed off `URGENCY_TIMEOUT_MS`:
- `low` → 8000ms, `normal` → 10000ms, `critical` → `null` (never auto-expires, matches old mako `default-timeout=0` behavior)
- `getTimerFraction(id)` returns `null` for never-expiring notifications, so the popup progress bar is hidden for critical urgency
- Hovering a popup pauses its timer (`pauseTimer`/`resumeTimer`), preserving remaining time across pause/resume

**Fixed bug**: `startTimer` originally used `URGENCY_TIMEOUT_MS[urgency] ?? 10000`, but `??` only falls back on `null`/`undefined` and can't distinguish "key present with value `null`" (critical) from "key absent". This caused critical notifications to get a 10s timer and show a progress bar instead of persisting. Fixed by checking `urgency in URGENCY_TIMEOUT_MS` first (commit `b44fd0f`).

## Theme

Dracula palette:
- Background: `#282a36`
- Text: `#f8f8f2`
- Urgency colors (popup border + history app-name label):
  - `low` → `#bd93f9` (purple)
  - `normal` → `#8be9fd` (cyan, matches `col.active_border`)
  - `critical` → `#ff79c6` (pink)
- History divider / progress track: `#44475a`
- Progress bar fill: `#8be9fd`

## mako removal

mako autostart removed from `~/.config/hypr/hyprland.lua` (commit `5f9e385`). AstalNotifd is now the sole `org.freedesktop.Notifications` DBus owner.

Remaining cleanup (manual, requires `doas`):
```
doas pacman -R mako
```
After uninstalling, also remove `~/.config/mako/` (config dir, no longer used).

## Known issues / notes

- None currently open.
