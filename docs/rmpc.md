# rmpc

Config: `~/.config/rmpc/config.ron` (RON format). Theme: `~/.config/rmpc/themes/main.ron`, referenced via `theme: Some("main")` in config.ron. Hot reload on (`enable_config_hot_reload: true`), edits apply live, no restart.

## What was configured

Custom header layout: album art pinned top-left (spanning the header + tab-bar rows), song info/playing state/volume/toggles consolidated into one box beside it, and a Cava audio visualizer strip above the status line. Queue tab has Lyrics on the right, Queue on the left.

## Layout overview (top to bottom)

1. **Header row** (`theme.layout`, size `10`):
   - Left: `Pane(AlbumArt)`, fixed width `18`, full height of the header+tabs block (18×10 cells, roughly square once cell aspect ratio is applied).
   - Right: a vertical split —
     - `header_center` component (height `8`): title, artist/album, play state, elapsed/bitrate, volume slider, and repeat/random/consume/single (`z`/`x`/`c`/`v`) toggles — all stacked in one box.
     - `Pane(Tabs)` (height `2`): the tab bar, sitting under the text box only (not under the art column).
   - `header_right` / the old separate volume+toggles column was removed; everything lives in `header_center` now.
2. `Pane(TabContent)` — the active tab's content, sized `100%`.
3. `Pane(Cava)` — visualizer strip, height `8`, sits above the status line.
4. Status line (height `3`): input-mode indicator + progress bar, unchanged from default.

### Queue tab (`config.ron` → `tabs`)

- Left (65%): queue header row + song queue table.
- Right (35%): Lyrics pane, bordered, titled " Lyrics ".

(Originally AlbumArt lived in this tab's left column — moved out because rmpc forbids the same pane type appearing in both the global theme `layout` and a per-tab `pane` config; since AlbumArt is now global (header), it had to be removed from here.)

## Album art position

`album_art` block in `config.ron` controls in-pane alignment (used by the header's AlbumArt pane, and by any future per-tab AlbumArt pane):

```
album_art: (
    method: Auto,
    max_size_px: (width: 1200, height: 1200),
    disabled_protocols: ["http://", "https://"],
    vertical_align: Top,
    horizontal_align: Left,
),
```

## Cava visualizer

### Packages

- `cava` (extra repo) — `doas pacman -S cava`

### MPD side (`~/.config/mpd/mpd.conf`)

Second `audio_output` block, a raw PCM fifo mpd writes to alongside the normal PipeWire output:

```
audio_output {
    type   "fifo"
    name   "cava"
    path   "/run/user/1000/mpd-cava.fifo"
    format "44100:16:2"
}
```

Requires `systemctl --user restart mpd.service` after adding (not a config-only reload). Verify with `mpc outputs` — should list both `PipeWire` and `cava` as enabled, and the fifo should exist at that path once mpd is running.

### rmpc side (`config.ron`)

```
cava: (
    framerate: 60,
    autosens: true,
    sensitivity: 100,
    lower_cutoff_freq: 50,
    higher_cutoff_freq: 10000,
    input: (
        method: Fifo,
        source: "/run/user/1000/mpd-cava.fifo",
        sample_rate: 44100,
        channels: 2,
        sample_bits: 16,
    ),
    smoothing: (
        noise_reduction: 77,
        monstercat: false,
        waves: false,
    ),
    eq: []
),
```

`input.source` must match mpd's fifo `path` exactly.

### Theme appearance (`themes/main.ron`)

```
cava: (
    bar_symbols: ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
    inverted_bar_symbols: ['▔', '🮂', '🮃', '▀', '🮄', '🮅', '🮆', '█'],
    inverted_bar_as_mask: false,
    bar_width: 1,
    bar_spacing: 1,
    orientation: Bottom,
    bar_color: Gradient({
          0: "rgb(189, 147, 249)",
         50: "rgb(222, 134, 224)",
        100: "rgb(255, 121, 198)",
    }),
),
```

Dracula purple (`#bd93f9`) at the bar base, shading to pink (`#ff79c6`) at the tips — purple dominant since bars spend more time near the base than the peak.

Pane placed in `theme.layout` (see layout overview above) rather than inside a tab, so it's visible on every tab, not just Queue.

## Known issues / gotchas

- **AlbumArt/Cava/any global-layout pane type can't also appear in a per-tab `pane` config** — rmpc errors at startup: `Panes cannot be in layout and tabs at the same time`. If a pane type is used in `theme.layout`, remove it from `tabs[*].pane` (this is why the Queue tab's own AlbumArt pane was deleted).
- **Header row height math**: art column height (currently `10`, split into `8` for the text box + `2` for the tab bar) must equal the sum of what the right-side vertical split adds up to, or the art column will over/undershoot the tab bar.
- **`/run/user/1000` is hardcoded** in both `mpd.conf` (fifo path) and `config.ron` (mpd socket, cava fifo source) — matches this system's UID (1000), not portable as-is to another user.
- Adding/changing `audio_output` blocks in `mpd.conf` needs an actual `mpd.service` restart — `enable_config_hot_reload` in rmpc only reloads rmpc's own config, not mpd's.

## See also

mpd/rmpc/mpd-mpris backend setup: `~/docs/mpd.md`.
