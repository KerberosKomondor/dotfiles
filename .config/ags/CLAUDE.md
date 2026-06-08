# AGS Config — Developer Notes

AGS 3.1.2 with gnim reactive library. TypeScript/TSX targeting GTK3.

## Run / restart

```bash
ags quit && ags run ~/.config/ags
```

Compile-check without running:
```bash
ags bundle ~/.config/ags/app.ts /tmp/check.js
```

## File map

| File | Responsibility |
|------|----------------|
| `app.ts` | Entry point, global state (`todoVisible`, `dashboardVisible`, `weatherVisible`), popup instantiation |
| `style.scss` | All styles — Dracula theme throughout |
| `service/weather.ts` | Weather polling, Open-Meteo API |
| `service/todos.ts` | Todo file I/O, badge count state |
| `widget/Bar.tsx` | Bar window, left/right clusters |
| `widget/TodoPopup.tsx` | Todo popup — day tabs, item list, add flow |
| `widget/Dashboard.tsx` | Dashboard popup — power, toggles |

## Multi-monitor

`app.get_monitors()` returns all `Gdk.Monitor` instances. To target a specific output:

- **Do NOT use `get_connector()`** — not exposed in this GJS binding (throws `TypeError: not a function`)
- **Do NOT use `is_primary()`** — always returns false on Wayland/Hyprland
- **Use geometry**: filter by `m.get_geometry().x` based on Hyprland monitor positions

DP-1 (right, x=1920) vs DP-2 (left, x=0):
```typescript
monitors.filter(m => m.get_geometry().x > 0).map(Bar)  // DP-1 only
```

## Reactive primitives (gnim)

```typescript
import { createState, With, createBinding } from "ags"
import { interval } from "ags/time"

// Local state
const [value, setValue] = createState(0)
value()           // read
setValue(1)       // write
value.as(n => n * 2)  // derived binding (use on JSX props directly)

// GObject property binding
const binding = createBinding(gobject, "property")

// Reactive child rendering
<With value={signal}>{(val) => <label label={String(val)} />}</With>

// Polling
interval(5000, callback)  // every 5s, no immediate call
```

**Use `.as()` on props directly instead of `<With>` when you don't need conditional rendering** — it's simpler and avoids a Fragment wrapper.

## GTK3 layout gotchas

### Box children always expand

`Gtk.Box.add()` packs children with `expand=true, fill=true` by default. Setting `halign`, `valign`, or `hexpand={false}` on a child **does not fix this** — the packing expand is set at the container level and overrides widget properties.

**Consequence:** a label with `background` CSS inside a `<box>` will stretch to fill available space, regardless of alignment props.

**Fix for inline styled text** (e.g. a count badge next to an icon): use **Pango markup on a single label** instead of separate sibling widgets:

```tsx
<label
  use_markup={true}
  label={count.as(n => n > 0
    ? `icon <span foreground="#282a36" background="#ff79c6" size="small" weight="bold"> ${n} </span>`
    : "icon"
  )}
/>
```

Pango `background` only covers the span text, not the widget allocation.

### Overlay JSX

`<overlay>` uses `overlays={[...]}` for overlay children — JSX children set the base widget only:

```tsx
<overlay overlays={[<label halign={Gtk.Align.END} valign={Gtk.Align.START} />]}>
  <label label="base" />
</overlay>
```

Do NOT put reactive `.as()` bindings inside the `overlays={[]}` array — causes a `Cannot convert non-null JS value to G_POINTER` crash at runtime.

## Popup pattern

All popups (Dashboard, WeatherPopup, TodoPopup) follow the same pattern:

```typescript
// app.ts
export const [fooVisible, setFooVisible] = createState(false)

// FooPopup.tsx
<window
  layer={Astal.Layer.OVERLAY}
  keymode={Astal.Keymode.ON_DEMAND}
  anchor={TOP | LEFT}
  visible={fooVisible.as(v => v)}
  onKeyPressEvent={(_self, event) => {
    if (event.get_keyval()[1] === Gdk.KEY_Escape) setFooVisible(false)
  }}
>
```

Use `visible={signal.as(v => v)}` — not `visible={signal as unknown as boolean}` (the `.as()` form is type-safe).

## File I/O (Gio/GLib)

```typescript
import Gio from "gi://Gio"
import GLib from "gi://GLib"

function readFileSync(path: string): string | null {
  try {
    const file = Gio.File.new_for_path(path)
    const [ok, contents] = file.load_contents(null)
    if (!ok || !contents) return null
    return new TextDecoder().decode(contents as Uint8Array)
  } catch { return null }
}

function writeFileSync(path: string, content: string): void {
  try {
    const file = Gio.File.new_for_path(path)
    const parent = file.get_parent()
    if (parent) try { parent.make_directory_with_parents(null) } catch (_) {}
    file.replace_contents(
      new TextEncoder().encode(content),
      null, false, Gio.FileCreateFlags.REPLACE_DESTINATION, null
    )
  } catch (e) { console.error("writeFileSync:", e) }
}
```

**Always use local date methods** (`getFullYear`/`getMonth`/`getDate`) — `toISOString()` returns UTC and is wrong for 6-7h after midnight in Colorado (UTC-6/7).

## Dotfiles

Use `config` (bare git repo alias), not `git`:
```bash
config add ~/.config/ags/widget/Foo.tsx
config commit -m "feat(ags): ..."
```
