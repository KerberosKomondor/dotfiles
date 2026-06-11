# AGS Bar

Custom AGS 3.x bar replacing HyprPanel on DP-1 (all monitors via app.get_monitors().map(Bar)).

## Config location
`~/.config/ags/`

## Run / restart
```bash
ags quit && ags run ~/.config/ags/app.ts
```

## AGS version
AGS 3.1.2 with gnim reactive library. Uses `createState`/`createBinding`/`createPoll` (not the older `Variable`/`bind` API).

## Monitor targeting
Bar runs on all monitors via `app.get_monitors().map(Bar)`. Popups target `monitors[0]`. If the wrong monitor gets the bar or a popup, adjust the index in `app.ts` and check with `ags inspect`.

## Weather
Open-Meteo, ZIP 80921 (Colorado Springs). Coordinates: 39.02°N, 104.77°W.
Update interval: 10 min. No API key required. To change location, edit `service/weather.ts`.

### Hourly Weather

The weather popup fetches 12 hours of hourly data from Open-Meteo alongside current conditions and the 5-day forecast.

- Fields: `temperature_2m`, `weather_code`, `precipitation_probability`
- Displayed as a timeline between current conditions and the daily forecast
- Bar color: cyan (dry), purple (precip ≥ 20%)
- Bar width: relative to min/max temp across the 12-hour window
- Time labels: "Now" for current hour, then 12-hour format (e.g. "3 PM")
- API `startIdx` fallback: when the current hour is not found in the hourly array, falls back to the last 12 available hours (not the first 12)

## Dashboard
Opens via the 󰣇 button at far left of bar. Escape or button click to close.
- Power: systemctl poweroff/reboot, hyprctl dispatch exit
- Toggles: wifi (AstalNetwork), bluetooth (AstalBluetooth bt.toggle()), notifications DnD (AstalNotifd), volume/mic mute (AstalWirePlumber)

## Todo list

Button at far left (after DashboardButton). Click to open a per-day checklist popup.

### Storage
- `~/.local/share/ags/todos/YYYY-MM-DD.txt` — daily items (`[ ] text` / `[x] text`)
- `~/.local/share/ags/todos/recurring.txt` — recurring items (`MTWRF [ ] text`)

### Adding items
Click `＋` in the popup. Toggle One-off (pick days this week) or Recurring (pick day-of-week letters). Press Enter or click Add.

### Recurring items
Injected into a day's file when that tab is first opened. Checking a recurring item marks it done only in that day's file — `recurring.txt` always stays `[ ]`.

### Checkbox/text colors
- Checkbox box outline (`󰄱`): always purple (`#bd93f9`), checked or not.
- Checkmark overlay (`󰄬`, shown only when done): teal (`#8be9fd`), layered via `<overlay>`/`$type="overlay"` on top of the box icon.
- Completed item text: teal (`#8be9fd`) with strikethrough (was green `#50fa7b`).

### Deleting recurring items
Edit `~/.local/share/ags/todos/recurring.txt` directly.

## Clock

Stacked button widget in bar (far right). Top line: time (`2:30 PM`), bottom line: date (`Mon Jun 8`). Click toggles the calendar popup open/closed.

## Calendar popup

Toggled by clock click. Fullscreen overlay, content top-right corner. Monday-first month grid with today highlighted in pink.

- `◀` / `▶` navigate months
- Today only highlighted when viewing current month
- Escape, click-outside, or clicking the clock again closes it
- Month always resets to current on open (`calendarVisible.subscribe` in `CalendarPopup.tsx`)

State: `calendarVisible` in `app.ts`. Widget: `widget/CalendarPopup.tsx`.

## Popup behavior

All popups (Dashboard, Weather, Todo, Calendar) are mutually exclusive: opening one closes any other that's open. Each toggle button calls `togglePopup(visible, setVisible)` from `app.ts`, which closes all popup states then opens the target if it wasn't already open. Clicking a popup's own toggle button again closes it.

## Cmus / MPRIS widget

`widget/Cmus.tsx` shows `artist - title [pos/len]` for the active MPRIS player (browsers excluded via `BROWSER_IDS`).

- `position` doesn't fire `notify::position` — AstalMpris/cmus don't push position updates, so a plain `createBinding(player, "position")` never updates during playback.
- Fix: `createPoll(player.position ?? 0, 1000, () => player.position ?? 0)` polls position every second; combined with `title`/`artist`/`length` bindings via `createMemo`.

## Tray (system tray icons)

`widget/Tray.tsx` — left-click calls `item.activate(x,y)` (primary action), right-click opens the dbusmenu context menu via a manually-built `Gtk.PopoverMenu`.

- Each tray item gets its own `Gtk.PopoverMenu.new_from_model(item.menuModel)`, parented to the icon's `<button>` via `set_parent()`. Rebuilt whenever `menuModel`/`actionGroup` change.
- Two `Gtk.GestureClick` controllers (button = `Gdk.BUTTON_PRIMARY` / `Gdk.BUTTON_SECONDARY`) are added as JSX children of the `<button>` — `<menubutton>` only triggers on left-click in GTK4, so right-click needs its own gesture.
- **Must call `item.about_to_show()` before `popover.popup()`** — the dbusmenu protocol requires this to populate fresh item state/labels (e.g. battery %); skipping it doesn't break things visually but the app won't refresh menu contents.

### Styling the right-click menu (`style.scss`, `.tray-menu` block)
- `Gtk.PopoverMenu.new_from_model()` renders items as `modelbutton.flat` (CSS node `modelbutton`, class `.flat`) — **not** `button.model` as GTK4 docs for `GtkPopoverMenu` claim. Style selectors must target `popover.tray-menu modelbutton.flat` (and its `label` child) or text color falls back to the light-theme default `.background { color: #2e3436 }`, which is nearly invisible on the dark `#282a36` popover background.
- `popover.tray-menu` class is added via `popover.add_css_class("tray-menu")` in `Tray.tsx`.
- `!important` is **not valid in GTK CSS** — causes a silent parse error (`CSS Error: Junk at end of value for color`) that drops the whole declaration. Rely on `Gtk.STYLE_PROVIDER_PRIORITY_USER` (used by ags's `apply_css`) + selector specificity instead.

## Known limitations
- Dashboard popup doesn't close on click-outside (use Escape or the button)
- Audio device capture is static at launch; switching default sink requires restart

## Cleanup (after confirming stable)
```bash
cp -r ~/.config/hyprpanel ~/.config/hyprpanel.bak
paru -Rns ags-hyprpanel-git
```
