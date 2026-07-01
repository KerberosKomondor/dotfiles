# AGS Notifications — Improvements Design

Follow-up to `2026-06-10-ags-notifications-design.md`. Covers 5 fixes/features
for the existing AGS notification system (`service/notifications.ts`,
`widget/NotificationPopups.tsx`, `widget/NotificationHistory.tsx`).

## 1. Fix DND toggle

**Problem**: Dashboard has a working "Notifications (DnD)" toggle that flips
`notifd.dontDisturb`, but `service/notifications.ts`'s `notified` handler
ignores it — popups show regardless.

**Fix**: in the `notified` handler, check `notifd.dontDisturb`.
- Always: push to `history` (unchanged).
- If `dontDisturb` is `true`: skip popup stack + timer entirely.
- If `false`: proceed as normal (see grouping logic below).

No retroactive hiding — popups already showing when DND is toggled on stay
until dismissed/timed out.

## 2. Popup grouping (group-by-app)

**Problem**: a burst of notifications from one app (e.g. Discord) fills the
5-slot popup stack with near-duplicate rows.

**Data model change** in `service/notifications.ts`:

```ts
export interface PopupGroup {
  appName: string
  notif: Notifd.Notification  // currently displayed (latest)
  count: number               // total notifs folded into this group
}
export const [popupStack, setPopupStack] = createState<PopupGroup[]>([])
export const [overflowCount, setOverflowCount] = createState(0)
```

**`notified` handler** (when `!dontDisturb`):
- Find existing group where `g.appName === notif.app_name`.
  - **Found**: `clearTimer(group.notif.id)` (old displayed notif quietly
    superseded — left "active" in notifd but no longer shown/timed). Replace
    `group.notif = notif`, `group.count += 1`. Start a new timer for the new
    `notif`.
  - **Not found**:
    - If `popupStack.length >= MAX_VISIBLE` (5): drop the oldest group
      (`stack[0]`), `clearTimer(dropped.notif.id)`,
      `overflowCount += dropped.count`.
    - Push new group `{ appName: notif.app_name, notif, count: 1 }`.
    - Start timer.

**`resolved` handler**:
- `clearTimer(id)`.
- `setPopupStack(stack => stack.filter(g => g.notif.id !== id))`. (A resolved
  id that doesn't match any group's displayed `notif` — i.e. an old folded
  notif that was already superseded — is a no-op, which is correct.)
- If the resulting stack is empty, reset `overflowCount` to `0`.

## 3. Popup UI changes (`NotificationPopups.tsx`)

- `<For each={popupStack} id={g => g.notif.id}>` — render `g.notif` exactly as
  today (icon, app name, title, body, actions, progress bar).
- When `g.count > 1`, render a small `×{count}` label next to the app name
  (new class `.notif-popup-count`).
- **Dismiss-all button**: new row/button at the top of `.notif-popups`,
  `onClicked={() => popupStack.get().forEach(g => dismissPopup(g.notif))}`.
  New class `.notif-dismiss-all`.
- **Overflow indicator**: new row at the bottom of `.notif-popups`,
  `visible={overflowCount.as(n => n > 0)}`, label `+{n} more`. Click sets
  `notifHistoryVisible(true)`. New class `.notif-overflow`.

## 4. History grouping (`NotificationHistory.tsx`)

**Problem**: same burst-from-one-app problem in the history list.

- Group the flat `history` array (already newest-first) by `app_name`,
  preserving first-seen order (a `Map<string, Notifd.Notification[]>` built by
  iterating `history` top-down — each app's section appears at the position of
  its newest member).
- `count === 1`: render the row exactly as today (no header).
- `count > 1`: render a collapsible section:
  - Header row: `{appName} ×{count} · {relativeTime(newest)}` + chevron
    (▸ collapsed / ▾ expanded). New class `.notif-history-app-header`.
  - **Default collapsed.** Click header toggles.
  - When expanded, render each notif's row exactly as today (including its
    own remove button).
- New local reactive state in the component:
  `const [expandedApps, setExpandedApps] = createState<Set<string>>(new Set())`
  — tracks apps the user has explicitly expanded. Toggled immutably
  (`new Set(prev)` with add/delete) on header click. An app `count > 1` whose
  name is **not** in `expandedApps` renders collapsed — giving "default
  collapsed" with no special-casing.

## 5. Image preview (image-data hint)

**Goal**: apps that attach an inline image via the standard `image-data` hint
(e.g. Teams message previews/screenshots) show a larger preview, not just the
small app icon.

**New helper** in `service/notifications.ts`:

```ts
import GdkPixbuf from "gi://GdkPixbuf"

export function notifImagePixbuf(notif: Notifd.Notification): GdkPixbuf.Pixbuf | null {
  for (const key of ["image-data", "image_data", "icon_data"]) {
    const v = notif.get_hint(key)
    if (!v) continue
    try {
      const [w, h, rowstride, hasAlpha, bps, _channels, data] = v.deep_unpack() as
        [number, number, number, boolean, number, number, Uint8Array]
      return GdkPixbuf.Pixbuf.new_from_bytes(data, GdkPixbuf.Colorspace.RGB, hasAlpha, bps, w, h, rowstride)
    } catch {
      continue
    }
  }
  return null
}
```

**UI** (both `NotificationPopups.tsx` and `NotificationHistory.tsx`): below
the title/body in each row, conditionally render:

```tsx
{(() => {
  const pb = notifImagePixbuf(notif)
  return pb ? (
    <image class="notif-preview-image" $={(self: any) => self.set_from_pixbuf(pb)} />
  ) : null
})()}
```

New CSS class `.notif-preview-image`: `max-width`/`max-height` constraint
(e.g. 200×120px) + `border-radius`.

**Open risk / verification needed**: `Pixbuf.new_from_bytes` and
`Image.set_from_pixbuf` exist in this binding's typings (`@girs/gdkpixbuf-2.0.d.ts`,
`@girs/gtk-4.0.d.ts`), so the decode path is feasible. But which hint key Teams
actually populates (`image-data` vs `image_data` vs `icon_data`, vs just
`image-path` which is already handled by `notifIcon`) is **unverified**.
During implementation: temporarily log
`notif.get_hints().deep_unpack()` for an inbound Teams notification with an
image attached, confirm the hint name and tuple shape, then adjust the key
list/unpack if needed.

## New CSS classes (style.scss)

- `.notif-popup-count` — small `×N` badge next to app name in popups
- `.notif-dismiss-all` — button at top of popup stack
- `.notif-overflow` — "+N more" row at bottom of popup stack
- `.notif-history-app-header` — collapsible section header (+ chevron) in history
- `.notif-preview-image` — shared by popup + history image previews

## Out of scope

- Live-ticking relative timestamps in history (not selected this round).
- Clickable history rows / re-invoking actions from history (not selected).
- History persistence / cap on history length (not selected).
