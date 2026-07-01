# Compact Clock + Calendar Popup — Design Spec

Date: 2026-06-08

## Summary

Replace the single-line clock label in the AGS bar with a compact stacked layout (time on top, date smaller below). Clicking anywhere on the clock opens a calendar popup with month navigation.

## Clock Widget (`widget/Clock.tsx`)

**Current:** Single `<label>` polling `date "+%a %b %d  %I:%M %p"` — ~120px wide.

**New:** A `<button>` wrapping a vertical `<box>` with two labels:
- Top: `<label class="clock-time">` — polls `date "+%I:%M %p"` every 60s
- Bottom: `<label class="clock-date">` — polls `date "+%a %b %d"` every 60s

Clicking anywhere on the button calls `setCalendarVisible(true)`.

Approximate rendered width: ~70px (down from ~120px).

## Calendar Popup (`widget/CalendarPopup.tsx`)

New file. Follows the same pattern as `WeatherPopup`:
- `Astal.Layer.OVERLAY`, `Astal.Keymode.ON_DEMAND`
- `anchor={TOP | LEFT | BOTTOM | RIGHT}` — fullscreen transparent overlay
- Content box: `halign={Gtk.Align.END} valign={Gtk.Align.START}` — appears top-right
- `visible={calendarVisible.as(v => v)}` — type-safe binding per CLAUDE.md
- Escape key: closes popup and resets `monthOffset` to 0 (via `EventControllerKey`)
- Click outside the content box: closes popup and resets `monthOffset` to 0 (via `GestureClick` with `CAPTURE` phase)
- Receives `gdkmonitor` — instantiated once per monitor in `app.ts`

### Month State

```typescript
const [monthOffset, setMonthOffset] = createState(0)
```

`0` = current month, `-1` = previous, `+1` = next. Both close paths (Escape + click-outside) call `setMonthOffset(0)` alongside `setCalendarVisible(false)`.

### Grid Computation

Pure JS `Date` math. Week starts **Monday**.

```typescript
function getMonthLabel(offset: number): string
function getCalendarWeeks(offset: number): ({ day: number | null, isToday: boolean })[][]
```

First-day-of-week offset: `(new Date(year, month, 1).getDay() + 6) % 7`
- Maps Sun(0)→6, Mon(1)→0, Tue(2)→1, … Sat(6)→5

Today highlight: only when `offset === 0` and day matches `new Date().getDate()`.

### Layout

```
[ ◀  June 2026  ▶ ]
[ Mo Tu We Th Fr Sa Su ]
[  1  2  3  4  5  6  7 ]
[  8  9 10 11 12 13 14 ]   ← 8 = today (highlighted)
[ 15 16 17 18 19 20 21 ]
[ 22 23 24 25 26 27 28 ]
[ 29 30                ]
```

Days rendered as `<label>` widgets in a 7-column `<box>` grid (one `<box>` per row, `homogeneous={true}`).

## State (`app.ts`)

Add alongside existing popup states:

```typescript
export const [calendarVisible, setCalendarVisible] = createState(false)
```

Instantiate `CalendarPopup` in the monitor map, same as `WeatherPopup` and `TodoPopup`.

## Styles (`style.scss`)

Replace `.clock` rule with:

```scss
/* Stacked clock button */
.clock-widget {
  background: none;
  border: none;
  box-shadow: none;
  padding: 2px 5px;
  border-radius: 4px;
}

.clock-time {
  color: #ff79c6;
  font-size: 12px;
}

.clock-date {
  color: #bd93f9;
  font-size: 9px;
}

/* Calendar popup */
.CalendarPopup { background: transparent; }

.calendar-box {
  background: #282a36;
  border-radius: 8px;
  padding: 10px;
  min-width: 176px;
  margin: 6px;
}

.calendar-nav-label { color: #bd93f9; font-weight: bold; }
.calendar-nav-arrow { color: #6272a4; }

.calendar-dow { color: #6272a4; font-size: 9px; }
.calendar-day { color: #f8f8f2; font-size: 10px; }
.calendar-day.today {
  background: #ff79c6;
  color: #282a36;
  font-weight: bold;
  border-radius: 3px;
}
.calendar-empty { color: transparent; }
```

## Files Changed

| File | Change |
|------|--------|
| `widget/Clock.tsx` | Rewrite — two polls, button wrapper, stacked box |
| `widget/CalendarPopup.tsx` | New file |
| `app.ts` | Add `calendarVisible`/`setCalendarVisible`; instantiate `CalendarPopup` |
| `style.scss` | Replace `.clock` rule; add calendar popup styles |

## Out of Scope

- Clicking individual days (no selection/event behavior)
- Week numbers
- Multi-monitor: each monitor gets its own popup instance (existing pattern)
