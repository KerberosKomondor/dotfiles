# AGS Bar Todo List — Design Spec

Date: 2026-06-08

## Overview

A todo button added to the AGS bar (immediately right of the DashboardButton) that opens a popup with a per-day checklist. Items are stored as plain text files by date. Both one-off multi-day items and recurring-by-day-of-week items are supported.

---

## File Format & Storage

```
~/.local/share/ags/todos/
  YYYY-MM-DD.txt    ← one file per day
  recurring.txt     ← recurring items config
```

**Daily file format:**
```
[ ] Fix the shower
[x] Buy groceries
[ ] Call dentist
```

**Recurring file format:**
```
MTWRF [ ] Exercise
M [ ] Weekly review
U [ ] Meal prep
```
Day letters: `M`=Mon `T`=Tue `W`=Wed `R`=Thu `F`=Fri `S`=Sat `U`=Sun

When a day's tab is first opened and no file exists for that date, `initDayIfNeeded` creates the file and injects any recurring items whose day-of-week letter matches. Checking off a recurring item marks it done only in that day's file — `recurring.txt` always stays `[ ]` as the source of truth for future days.

---

## Architecture

### New files

**`service/todos.ts`**
All file I/O and parsing. Exports:
- `getTodosForDate(date: string): TodoItem[]` — reads and parses `YYYY-MM-DD.txt`
- `saveTodosForDate(date: string, items: TodoItem[])` — writes `YYYY-MM-DD.txt`
- `getRecurring(): RecurringItem[]` — reads and parses `recurring.txt`
- `saveRecurring(items: RecurringItem[])` — writes `recurring.txt`
- `initDayIfNeeded(date: string)` — creates day file from recurring if missing
- `todayCount` — `createPoll`-based binding, polls today's file every 5s, returns unchecked item count

Types:
```typescript
interface TodoItem { text: string; done: boolean }
interface RecurringItem { text: string; days: string[]; }
```

**`widget/TodoButton.tsx`**
Bar button. Reads `todayCount` binding. Renders checklist icon (`󰄬`) with a pink badge overlay when count > 0. Toggles `todoVisible` on click.

**`widget/TodoPopup.tsx`**
Popup window. Uses `createState` for the selected day tab. On tab change: calls `initDayIfNeeded`, reads that day's file, re-renders item list. On any mutation (toggle, delete, add): writes file immediately, re-reads to sync UI.

### Modified files

**`app.ts`**
- Add `export const [todoVisible, setTodoVisible] = createState(false)`
- Instantiate `TodoPopup(monitors[0])` in `main()`

**`widget/Bar.tsx`**
- Import and insert `<TodoButton />` after `<DashboardButton />` in the left box

**`style.scss`**
- Add styles: `.todo-button`, `.TodoPopup`, `.todo-tab`, `.todo-item`, `.todo-badge`, `.todo-add-row`

---

## Popup UX

**Day tabs row** — Mon–Sun for the current calendar week. Today highlighted pink (`#ff79c6`). Days with items in purple (`#bd93f9`). Empty days dim (`#44475a`).

**Item rows** — checkbox + text. Click anywhere to toggle done (rewrites file). Hover reveals a `✕` delete button on the right (removes item, rewrites file). Checked items: strikethrough, muted green color.

**Add flow** — `+` button at bottom reveals inline input:
1. Text field (Enter or save button commits)
2. Mode toggle: **One-off** vs **Recurring**
3. **One-off mode**: day checkboxes for the current week, pre-selected to the active tab's day. Item written to each selected day's file.
4. **Recurring mode**: day-of-week letter buttons (`M T W R F S U`). Item appended to `recurring.txt` and immediately injected into any matching day files that already exist this week.

**Dismiss** — Escape key or clicking the bar button again closes the popup (same pattern as Dashboard).

**Week scope** — always the current calendar week (Mon–Sun). No next-week navigation.

---

## Bar Button

- Position: left box, between `DashboardButton` and `Workspaces`
- Icon: `󰄬` (Nerd Font checklist)
- Badge: pink pill overlaid top-right, shows count of unchecked items in today's file; hidden at 0
- Styling: matches `dashboard-button` — transparent background, right border divider, dims to `#6272a4`, brightens to `#f8f8f2` on hover

---

## Out of Scope

- Next-week navigation (YAGNI)
- Deleting recurring items from the UI (edit `recurring.txt` directly)
- Due times or priorities
- Syncing across machines
