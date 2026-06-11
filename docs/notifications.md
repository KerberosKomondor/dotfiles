# Notifications

AGS-rendered notifications via AstalNotifd, replacing mako and HyprPanel's built-in notifications (HyprPanel itself was later replaced by Waybar — see `~/docs/hyprland.md`).

## Why

mako's body text wrapping was fixed (`width`/`height` only). HyprPanel's built-in notifications hardcoded body text to 2 lines / 35 chars in the compiled bundle with no config option to change it. AGS gives full control over layout, styling, and behavior.

## Architecture

- `~/.config/ags/service/notifications.ts` — AstalNotifd-backed service. Exports:
  - `popupStack: PopupGroup[]`, `overflowCount`, `history` — reactive state (`createState`)
  - `dismissPopup`, `clearHistory`, `removeFromHistory`, `invokeAction`
  - `urgencyClass(notif)` → `"low" | "normal" | "critical"`
  - `notifIcon(notif)` → `{ file? }` or `{ iconName? }`
  - `notifImagePixbuf(notif)` → `GdkPixbuf.Pixbuf | null` — inline image preview (see below)
  - `pauseTimer` / `resumeTimer` / `getTimerFraction` — auto-dismiss timer control
  - Listens to `notifd` `"notified"`/`"resolved"` signals to keep `popupStack` and `history` in sync
- `~/.config/ags/widget/NotificationPopups.tsx` — popup window, top-right (DP-1, `monitors[0]`). Window `visible` is bound to `popupStack.length > 0` so it fully hides (no ghost empty window) when the stack empties. Click a popup row to dismiss; click an action button to invoke it instead. "Clear all" button dismisses every visible group; "+N more" row appears when overflow occurs.
- `~/.config/ags/widget/NotificationHistory.tsx` — full-screen overlay history panel, opened via the bar badge. Click outside the panel or press Escape to close. "Clear all" empties history. Notifications are grouped per-app into collapsible sections.
- `~/.config/ags/widget/Notifications.tsx` — bar badge (`󰂚 N`), only visible when history is non-empty. Toggles `notifHistoryVisible`.
- Wired into `~/.config/ags/app.ts` (instantiated on `monitors[0]`, i.e. DP-1) and styled in `~/.config/ags/style.scss` under `.NotificationPopups` / `.NotificationHistory`.

## Do Not Disturb

The Dashboard's "Notifications (DnD)" toggle flips `notifd.dontDisturb`. The
`notified` handler checks this flag: when DND is on, new notifications are
still recorded in `history`, but no popup/timer is started. Popups already
showing when DND is toggled on are left alone (no retroactive hiding).

## Popup grouping, dismiss-all, overflow

`popupStack` is `PopupGroup[]` (`{ appName, notif, count }`) instead of a flat
notification list. A burst of notifications from the same app folds into one
popup row, showing the latest notification's content plus a `×N` count badge.

- Max 5 distinct-app groups shown at once (`MAX_VISIBLE`). A 6th app's
  notification evicts the oldest group; its folded count is added to
  `overflowCount`, surfaced as a "+N more" row at the bottom of the popup
  stack. Clicking it opens the history panel. `overflowCount` resets to 0
  once the popup stack empties.
- "Clear all" button at the top of the popup stack dismisses every visible
  group.
- When a group is updated in place (new notif from an already-grouped app),
  the old notif's auto-dismiss timer is cleared but the old notification
  object itself is not explicitly dismissed — it just stops being displayed.

## History grouping

`NotificationHistory.tsx` groups the flat `history` list by `app_name`
(`Map<string, Notifd.Notification[]>`, built by iterating `history`
top-down — `history` is newest-first, so each app's section appears at the
position of its newest member).

- A single notification from an app renders as a normal row.
- Multiple notifications from the same app render as a collapsible section:
  header `{appName} ×{count} · {relativeTime}` with a `▸`/`▾` chevron,
  **default collapsed**. Click to expand/collapse (local `expandedApps: Set`
  state, not persisted).

## Image previews

`notifImagePixbuf(notif)` decodes a notification's attached image into a
`GdkPixbuf.Pixbuf`, rendered as `<image class="notif-preview-image">` below
the title/body in both popups and history.

- Tries raw-bytes hints first (`image-data`, `image_data`, `icon_data` —
  GVariant `(iiibiiay)`, decoded via `GdkPixbuf.Pixbuf.new_from_bytes`).
- Falls back to `image-path`/`image_path` (loaded via
  `GdkPixbuf.Pixbuf.new_from_file`) — **this is the path that actually fires
  in practice** (see Known issues).
- Result is scaled down to fit `MAX_PREVIEW_PX = 128` on the longer side
  (aspect ratio preserved), and cached in-memory per `notif.id`
  (`imagePreviewCache`), since both popup and history call
  `notifImagePixbuf` and history re-renders its whole list on every change.
  The cache is invalidated in `removeFromHistory`/`clearHistory`.

## Known issues / notes

- **`image-data` hint is normalized by astal-notifd before `notified`
  fires.** astal-notifd decodes the raw `image-data`/`image_data`/`icon_data`
  hints itself, writes the result to a cached PNG under
  `~/.cache/astal/notifd/`, and exposes that file via the `image-path` hint
  (stripping the raw-bytes hints). So `notifImagePixbuf`'s raw-bytes branch is
  effectively dead in practice for this notifd; the `image-path` fallback is
  what actually renders previews. The raw-bytes branch is kept as a defensive
  fallback in case a future notifd/sender populates those hints directly.
- **Preview can duplicate the small icon.** `notifIcon()` also resolves
  `image-path` (via `notif.get_image()`) for the small icon shown next to the
  title. For notifications whose only image is their app icon (set via
  `image-path` rather than an icon-theme name), the same image now renders
  twice — once small (icon) and once larger (preview). This is accepted as a
  reasonable tradeoff for now (apps that send a genuinely distinct inline
  photo, e.g. Teams screenshots, get a useful larger preview); revisit if it
  proves visually noisy for common senders in daily use.
- Teams-specific verification was not performed (Teams was not running during
  implementation) — the `image-path` fallback was validated with a synthetic
  `gdbus`-sent `image-data` hint (1×1 pixel), which astal-notifd normalized to
  `image-path` as expected.

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
