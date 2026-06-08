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

### Deleting recurring items
Edit `~/.local/share/ags/todos/recurring.txt` directly.

## Known limitations
- MPRIS position counter refreshes on song change only, not live
- Dashboard popup doesn't close on click-outside (use Escape or the button)
- Audio device capture is static at launch; switching default sink requires restart

## Cleanup (after confirming stable)
```bash
cp -r ~/.config/hyprpanel ~/.config/hyprpanel.bak
paru -Rns ags-hyprpanel-git
```
