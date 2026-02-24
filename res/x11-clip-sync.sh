#!/bin/bash
# Bidirectional clipboard bridge: X11 CLIPBOARD ↔ Wayland clipboard
#
# X11 → Wayland: FreeRDP (XWayland) uses lazy clipboard ownership;
#   Hyprland's built-in sync fails on the RDP server round-trip, so we
#   poll X11 every 100ms and push to Wayland + PRIMARY when it changes.
#   Uses UTF8_STRING — FreeRDP doesn't offer STRING. xclip outputs
#   errors to stdout with exit 0, so we filter "Error:" lines.
#
# Wayland → X11: handled automatically by XWayland's clipboard bridge.
#   Do NOT add wl-paste --watch here — it creates an infinite loop:
#   wl-copy → XWayland mirrors to X11 → wl-paste fires → xclip sets X11
#   → XWayland re-announces Wayland → wl-paste fires → ... forever.
#   Teams (XWayland, --ozone-platform=x11) would get a moving target
#   and fail to paste.

# X11 → Wayland CLIPBOARD + PRIMARY (so local apps see RDP copies)
last=""
while true; do
    current=$(xclip -o -selection clipboard -target UTF8_STRING 2>/dev/null)
    if [[ -n "$current" && "$current" != Error:* && "$current" != "$last" ]]; then
        printf '%s' "$current" | wl-copy
        printf '%s' "$current" | wl-copy --primary
        printf '%s' "$current" | xclip -i -selection clipboard
        printf '%s' "$current" | xclip -i -selection primary
        last="$current"
    fi
    sleep 0.1
done
