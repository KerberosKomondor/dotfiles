# Rio Terminal Font Configuration

## Problem: emoji and symbols showing as boxes

Rio's renderer (sugarloaf/swash) only supports **COLRv1** and **PNG bitmap** emoji fonts. The
Arch package `noto-fonts-emoji` is CBDT/CBLC bitmap-only (no outlines), which swash cannot
render. All emoji showed as boxes.

## Fix

### 1. Install COLRv1 Noto Color Emoji

The official Arch package has no COLRv1 version. Download manually from Google's noto-emoji repo:

```bash
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/googlefonts/noto-emoji/raw/main/fonts/Noto-COLRv1.ttf" \
  -o ~/.local/share/fonts/Noto-COLRv1.ttf
fc-cache ~/.local/share/fonts
```

This registers as "Noto Color Emoji" and shadows the system CBDT version. The COLRv1 version
is picked up by Rio's `colr_raster.rs` pipeline.

### 2. Rio font config (`~/.config/rio/config.toml`)

```toml
[fonts]
family = "FiraCode Nerd Font"
size = 13
extras = [
  { family = "Noto Color Emoji" },
  { family = "Noto Sans" },
  { family = "Noto Sans Symbols" },
  { family = "Noto Sans CJK SC" },
  { family = "JetBrainsMono NFP" },
]
symbol-map = [
  { start = "1F300", end = "1FAFF", font-family = "Noto Color Emoji" },
  { start = "23F0", end = "23FA", font-family = "Noto Color Emoji" },
  { start = "2614", end = "276B", font-family = "Noto Color Emoji" },
  { start = "2B50", end = "2B55", font-family = "Noto Color Emoji" },
  { start = "23BE", end = "23BF", font-family = "Noto Sans Symbols" },
  { start = "2717", end = "2718", font-family = "JetBrains Mono" },
]
```

## Why `extras` alone doesn't work

Rio's `extras` fallback is unreliable for many codepoints. `symbol-map` provides a direct
per-range font assignment that bypasses the broken fallback chain.

## Symbol-map ranges explained

| Range | Chars | Font | Why |
|-------|-------|------|-----|
| 1F300–1FAFF | Main emoji block | Noto Color Emoji (COLRv1) | All standard emoji |
| 23F0–23FA | ⏰⏳⏺ clocks/timers | Noto Color Emoji (COLRv1) | Not in FiraCode |
| 2614–276B | ✨ sparkles + emoji symbols | Noto Color Emoji (COLRv1) | Avoids ✓ 2713 (FiraCode) and ❯ 276F+ (shell prompt) |
| 2B50–2B55 | ⭐ stars | Noto Color Emoji (COLRv1) | Not in FiraCode |
| 23BE–23BF | ⎾⎿ Claude Code result indicators | Noto Sans Symbols | Not in FiraCode or Noto COLRv1 |
| 2717–2718 | ✗✘ ballot X | JetBrains Mono | Not in FiraCode or Noto COLRv1 |

## Known remaining gaps

- ✓ U+2713 CHECK MARK: renders from FiraCode (text, not color)
- ✗ U+2717 BALLOT X: not in FiraCode or Noto COLRv1 → JetBrains Mono fallback
- `twitter-color-emoji` (`ttf-twemoji-color`) uses SVG-in-OpenType which Rio cannot render
