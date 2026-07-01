# Compact Clock + Calendar Popup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single-line clock label with a stacked compact widget (time + date), and add a clickable calendar popup with month navigation.

**Architecture:** Clock becomes a `<button>` wrapping a vertical box of two labels. A new `CalendarPopup` widget follows the exact `WeatherPopup` pattern — fullscreen `OVERLAY` window, click-outside/Escape to close, content anchored top-right. Month state is a `createState(0)` offset; pure JS `Date` math builds the grid.

**Tech Stack:** AGS 3.1.2, GTK4, TypeScript/TSX, gnim reactivity (`createState`, `createPoll`, `With`)

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `style.scss` | Modify | Replace `.clock` rule; add `.CalendarPopup` block |
| `app.ts` | Modify | Add `calendarVisible`/`setCalendarVisible` state; import+instantiate `CalendarPopup` |
| `widget/Clock.tsx` | Rewrite | Two polls, button wrapper, stacked labels, opens calendar on click |
| `widget/CalendarPopup.tsx` | Create | Fullscreen overlay popup, month grid with Mon-first week, prev/next nav |

---

### Task 1: Update styles

**Files:**
- Modify: `~/.config/ags/style.scss`

- [ ] **Step 1: Replace the `.clock` rule and add calendar styles**

Find and replace the `/* Clock */` block (lines 101–104):

```scss
/* Clock widget (stacked button) */
.clock-widget {
  background: transparent;
  border-radius: 4px;
  padding: 2px 5px;

  &:hover { background: rgba(255, 121, 198, 0.12); }
}

.clock-time {
  color: #ff79c6;
  font-size: 12px;
}

.clock-date {
  color: #bd93f9;
  font-size: 9px;
}
```

Then append the calendar popup block at the end of the file (before the final newline):

```scss
/* Calendar popup */
.CalendarPopup {
  background: transparent;

  .calendar-box {
    background: #282a36;
    border: 1px solid #44475a;
    border-radius: 8px;
    padding: 10px;
    min-width: 176px;
    margin: 6px;
  }

  .calendar-nav-arrow {
    background: transparent;
    border: none;
    color: #6272a4;
    padding: 1px 6px;
    border-radius: 3px;

    &:hover { background: #44475a; color: #f8f8f2; }
  }

  .calendar-nav-label {
    color: #bd93f9;
    font-weight: bold;
    font-size: 11px;
  }

  .calendar-dow {
    color: #6272a4;
    font-size: 9px;
    min-width: 22px;
  }

  .calendar-day {
    color: #f8f8f2;
    font-size: 10px;
    min-width: 22px;
    border-radius: 3px;

    &.today {
      background: #ff79c6;
      color: #282a36;
      font-weight: bold;
    }
  }

  .calendar-empty {
    min-width: 22px;
    color: transparent;
  }
}
```

- [ ] **Step 2: Verify compile-check passes**

```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

Expected: exits 0, no errors (style changes don't affect TS compilation).

- [ ] **Step 3: Commit**

```bash
config add ~/.config/ags/style.scss
config commit -m "feat(ags): add stacked clock and calendar popup styles"
```

---

### Task 2: Add calendarVisible state to app.ts

**Files:**
- Modify: `~/.config/ags/app.ts`

`Clock.tsx` imports `setCalendarVisible` from `app.ts`. This state must exist before Clock.tsx is rewritten.

- [ ] **Step 1: Add the state export**

Add one line after the existing state exports:

```typescript
// ~/.config/ags/app.ts
import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import WeatherPopup from "./widget/WeatherPopup"
import Dashboard from "./widget/Dashboard"
import TodoPopup from "./widget/TodoPopup"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)
export const [todoVisible, setTodoVisible] = createState(false)
export const [calendarVisible, setCalendarVisible] = createState(false)

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.filter((m: any) => m.get_geometry().x > 0).map(Bar)
    Dashboard(monitors[0])
    WeatherPopup(monitors[0])
    TodoPopup(monitors[0])
  },
})
```

- [ ] **Step 2: Verify compile-check passes**

```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

Expected: exits 0, no errors.

- [ ] **Step 3: Commit**

```bash
config add ~/.config/ags/app.ts
config commit -m "feat(ags): add calendarVisible state"
```

---

### Task 3: Rewrite Clock.tsx

**Files:**
- Modify: `~/.config/ags/widget/Clock.tsx`

- [ ] **Step 1: Replace the file contents**

```typescript
// ~/.config/ags/widget/Clock.tsx
import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { setCalendarVisible } from "../app"

export default function Clock() {
  const time = createPoll("", 60000, ["date", "+%I:%M %p"])
  const date = createPoll("", 60000, ["date", "+%a %b %d"])

  return (
    <button class="clock-widget" onClicked={() => setCalendarVisible(true)}>
      <box orientation={1} valign={Gtk.Align.CENTER} spacing={0}>
        <label class="clock-time" label={time} halign={Gtk.Align.CENTER} />
        <label class="clock-date" label={date} halign={Gtk.Align.CENTER} />
      </box>
    </button>
  )
}
```

- [ ] **Step 2: Verify compile-check passes**

```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

Expected: exits 0, no errors.

- [ ] **Step 3: Commit**

```bash
config add ~/.config/ags/widget/Clock.tsx
config commit -m "feat(ags): rewrite Clock as stacked button widget"
```

---

### Task 4: Create CalendarPopup.tsx

**Files:**
- Create: `~/.config/ags/widget/CalendarPopup.tsx`

- [ ] **Step 1: Create the file**

```typescript
// ~/.config/ags/widget/CalendarPopup.tsx
import { Astal, Gtk, Gdk } from "ags/gtk4"
import app from "ags/gtk4/app"
import { createState, With } from "ags"
import { calendarVisible, setCalendarVisible } from "../app"

const MONTH_NAMES = [
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December",
]

const DOW_LABELS = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

function getMonthYear(offset: number): { month: number; year: number } {
  const now = new Date()
  const d = new Date(now.getFullYear(), now.getMonth() + offset, 1)
  return { month: d.getMonth(), year: d.getFullYear() }
}

function getMonthLabel(offset: number): string {
  const { month, year } = getMonthYear(offset)
  return `${MONTH_NAMES[month]} ${year}`
}

function getCalendarWeeks(
  offset: number,
): { day: number | null; isToday: boolean }[][] {
  const now = new Date()
  const { month, year } = getMonthYear(offset)
  // Monday-first: shift getDay() so Mon=0, Tue=1, ..., Sun=6
  const firstDow = (new Date(year, month, 1).getDay() + 6) % 7
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const todayDate = now.getDate()
  const isCurrentMonth = offset === 0

  const cells: { day: number | null; isToday: boolean }[] = []
  for (let i = 0; i < firstDow; i++) cells.push({ day: null, isToday: false })
  for (let d = 1; d <= daysInMonth; d++) {
    cells.push({ day: d, isToday: isCurrentMonth && d === todayDate })
  }
  while (cells.length % 7 !== 0) cells.push({ day: null, isToday: false })

  const weeks: { day: number | null; isToday: boolean }[][] = []
  for (let i = 0; i < cells.length; i += 7) weeks.push(cells.slice(i, i + 7))
  return weeks
}

export default function CalendarPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, BOTTOM, RIGHT } = Astal.WindowAnchor
  const [monthOffset, setMonthOffset] = createState(0)

  function close() {
    setCalendarVisible(false)
    setMonthOffset(0)
  }

  return (
    <window
      class="CalendarPopup"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | LEFT | BOTTOM | RIGHT}
      visible={calendarVisible.as((v) => v)}
      application={app}
      $={(self: any) => {
        const ctrl = new Gtk.EventControllerKey()
        ctrl.connect("key-pressed", (_c: any, keyval: number) => {
          if (keyval === Gdk.KEY_Escape) close()
        })
        self.add_controller(ctrl)
        const click = new Gtk.GestureClick()
        click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        click.connect(
          "pressed",
          (gesture: any, _n: number, x: number, y: number) => {
            const child = self.get_child()
            if (!child) return
            const a = child.get_allocation()
            if (
              x >= a.x &&
              x <= a.x + a.width &&
              y >= a.y &&
              y <= a.y + a.height
            ) {
              gesture.set_state(Gtk.EventSequenceState.DENIED)
            } else {
              close()
            }
          },
        )
        self.add_controller(click)
      }}
    >
      <box
        class="calendar-box"
        orientation={1}
        halign={Gtk.Align.END}
        valign={Gtk.Align.START}
        spacing={4}
      >
        {/* Month navigation row */}
        <box spacing={0}>
          <button
            class="calendar-nav-arrow"
            onClicked={() => setMonthOffset(monthOffset() - 1)}
          >
            <label label="◀" />
          </button>
          <label
            class="calendar-nav-label"
            label={monthOffset.as((o) => getMonthLabel(o))}
            hexpand={true}
            halign={Gtk.Align.CENTER}
          />
          <button
            class="calendar-nav-arrow"
            onClicked={() => setMonthOffset(monthOffset() + 1)}
          >
            <label label="▶" />
          </button>
        </box>

        {/* Day-of-week headers (static) */}
        <box spacing={0} homogeneous={true}>
          {DOW_LABELS.map((d) => (
            <label class="calendar-dow" label={d} halign={Gtk.Align.CENTER} />
          ))}
        </box>

        {/* Week rows (reactive on monthOffset) */}
        <With value={monthOffset}>
          {(offset) => {
            const weeks = getCalendarWeeks(offset)
            return (
              <box orientation={1} spacing={0}>
                {weeks.map((week) => (
                  <box spacing={0} homogeneous={true}>
                    {week.map((cell) =>
                      cell.day === null ? (
                        <label
                          class="calendar-empty"
                          label=" "
                          halign={Gtk.Align.CENTER}
                        />
                      ) : (
                        <label
                          class={
                            cell.isToday ? "calendar-day today" : "calendar-day"
                          }
                          label={String(cell.day)}
                          halign={Gtk.Align.CENTER}
                        />
                      ),
                    )}
                  </box>
                ))}
              </box>
            )
          }}
        </With>
      </box>
    </window>
  )
}
```

- [ ] **Step 2: Verify compile-check passes**

```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

Expected: exits 0, no errors.

- [ ] **Step 3: Commit**

```bash
config add ~/.config/ags/widget/CalendarPopup.tsx
config commit -m "feat(ags): add CalendarPopup widget"
```

---

### Task 5: Wire CalendarPopup into app.ts

**Files:**
- Modify: `~/.config/ags/app.ts`

- [ ] **Step 1: Add CalendarPopup import and instantiation**

```typescript
// ~/.config/ags/app.ts
import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import WeatherPopup from "./widget/WeatherPopup"
import Dashboard from "./widget/Dashboard"
import TodoPopup from "./widget/TodoPopup"
import CalendarPopup from "./widget/CalendarPopup"
import { createState } from "ags"

export const [dashboardVisible, setDashboardVisible] = createState(false)
export const [weatherVisible, setWeatherVisible] = createState(false)
export const [todoVisible, setTodoVisible] = createState(false)
export const [calendarVisible, setCalendarVisible] = createState(false)

app.start({
  css: style,
  main() {
    const monitors = app.get_monitors()
    monitors.filter((m: any) => m.get_geometry().x > 0).map(Bar)
    Dashboard(monitors[0])
    WeatherPopup(monitors[0])
    TodoPopup(monitors[0])
    CalendarPopup(monitors[0])
  },
})
```

- [ ] **Step 2: Verify compile-check passes**

```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

Expected: exits 0, no errors.

- [ ] **Step 3: Restart AGS and smoke-test**

```bash
ags quit && ags run ~/.config/ags
```

Verify:
- Clock in bar shows two lines (time + date)
- Clock is visibly narrower than before
- Clicking clock opens calendar popup in top-right corner
- Calendar shows correct current month with today highlighted
- ◀ / ▶ buttons navigate months correctly
- Today highlight disappears when viewing other months
- Escape closes popup
- Clicking outside the calendar box closes popup
- Month offset resets to current month after closing and reopening

- [ ] **Step 4: Commit**

```bash
config add ~/.config/ags/app.ts
config commit -m "feat(ags): wire CalendarPopup into app"
```
