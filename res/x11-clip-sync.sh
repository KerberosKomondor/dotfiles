#!/bin/bash
# Bidirectional clipboard bridge: local apps ↔ FreeRDP (XWayland) + Synergy
#
# Root cause: XWayland creates an X11 CLIPBOARD deadlock when an X11 app (Teams,
# ozone-platform=x11) copies — XWayland bridges X11→Wayland, then immediately
# reclaims X11 CLIPBOARD as a Wayland→X11 proxy. The proxy deadlocks because
# XWayland is asking itself (XWayland-Wayland-client) for the content.
#
# Fix for local→remote (Teams → FreeRDP):
#   XWayland DOES bridge X11→Wayland *before* deadlocking, so Wayland CLIPBOARD
#   gets the content. We poll Wayland CLIPBOARD, then call wl-copy to re-assert
#   ownership. This changes XWayland's X11 CLIPBOARD proxy source from the
#   deadlocked XWayland-Wayland-client to wl-copy (a real process that can respond),
#   breaking the deadlock. FreeRDP can then read X11 CLIPBOARD via XWayland→wl-copy.
#
# Fix for remote→local (FreeRDP → local apps):
#   FreeRDP uses lazy clipboard (fetches from RDP server on SelectionRequest), which
#   causes XWayland's X11→Wayland bridge to fail (timeout on the RDP round-trip).
#   We poll X11 CLIPBOARD with timeout, forcing the RDP round-trip locally, then
#   push the result to wl-copy (Wayland CLIPBOARD) and X11 PRIMARY.
#
# Fix for images (screenshot → Teams and Synergy):
#   Satty copies images as application/octet-stream (PNG bytes) to Wayland CLIPBOARD.
#   Synergy (XWindowsClipboardBMPConverter) needs image/bmp in X11 CLIPBOARD.
#   Teams/XWayland needs image/png. xclip can only serve one target, so we use
#   x11-image-clipboard.py: a Python X11 clipboard server that serves BOTH image/png
#   and image/bmp from the same X11 CLIPBOARD owner, converting PNG→BMP via magick.
#   Change detection uses md5sum; restore logic is gated on fully empty clipboard
#   to avoid clobbering an image clipboard with saved text content.
#
# Do NOT use xclip -i -selection clipboard: taking X11 CLIPBOARD ownership from a
# local app triggers XWayland to re-bridge and re-deadlock X11 CLIPBOARD.
# Do NOT add wl-paste --watch: creates infinite loop (wl-copy → XWayland mirrors
# to X11 → wl-paste fires → xclip → XWayland re-announces → repeat).
# Timeouts on xclip -o prevent the script from blocking on XWayland deadlock.

x11_last=""
wl_last=""
saved_content=""      # last known text content, for restoring when clipboard goes empty
wl_last_img_hash=""   # md5 of last image bridged from Wayland → X11
img_clipboard_pid=""  # PID of running x11-image-clipboard.py (multi-target image server)
img_stable=""         # stable copy of image passed to Python server (not subject to overwrites)
empty_count=0         # consecutive empty wl_current_types reads (debounce for text restore)

img_tmp=$(mktemp)
trap 'rm -f "$img_tmp" "${img_stable:-}"; [[ -n "$img_clipboard_pid" ]] && kill "$img_clipboard_pid" 2>/dev/null' EXIT

while true; do
    # Poll X11 CLIPBOARD TARGETS first. XWayland serves raw bytes for ANY
    # requested target (including UTF8_STRING) even when the clipboard holds an
    # image — causing us to treat 4.4MB BMP bytes as "new text" and evict the
    # image/bmp wl-copy. Only read UTF8_STRING if it's explicitly advertised.
    x11_targets=$(timeout 0.5 xclip -o -selection clipboard -target TARGETS 2>/dev/null || true)
    x11_current=""
    if printf '%s\n' "$x11_targets" | grep -qm1 'UTF8_STRING'; then
        x11_current=$(timeout 0.5 xclip -o -selection clipboard -target UTF8_STRING 2>/dev/null || true)
    fi

    # Poll Wayland CLIPBOARD types (used for image detection and empty-check)
    wl_current_types=$(timeout 0.5 wl-paste --list-types 2>/dev/null || echo "")

    # Poll Wayland CLIPBOARD text (explicit UTF8_STRING — avoids binary image data
    # in text variables when clipboard holds an image)
    wl_current=$(timeout 0.5 wl-paste --type UTF8_STRING 2>/dev/null || true)

    # ── Image bridging: application/octet-stream → X11 CLIPBOARD (for Teams) ──
    # Satty/arboard copies PNG as application/octet-stream (not image/png) to
    # the Wayland clipboard. Teams (XWayland/X11 app) needs image/png or image/bmp
    # in X11 CLIPBOARD. The Python X11 server serves both from the same owner.
    #
    # IMPORTANT: Only trigger on application/octet-stream, NOT on image/* types.
    # When the screenshot keybind puts image/bmp directly in Wayland (via wl-copy),
    # Synergy reads it via wl-paste directly from wl-copy — no X11 bridge needed.
    # If we start the Python server on image/bmp, XWayland bridges X11→Wayland,
    # evicts wl-copy, and wl-paste -t image/bmp then hangs (INCR over XWayland
    # bridge is broken for large binary data). So: leave image/* alone.
    wl_has_octet=$(printf '%s\n' "$wl_current_types" | grep -qm1 '^application/octet-stream' && echo yes || true)
    if [[ -n "$wl_has_octet" ]]; then
        timeout 2 wl-paste --type application/octet-stream > "$img_tmp" 2>/dev/null || true
        if [[ -s "$img_tmp" ]]; then
            img_hash=$(md5sum < "$img_tmp" | cut -d' ' -f1)
            # Start/restart server if: new image (hash changed) OR server died.
            server_alive=false
            [[ -n "$img_clipboard_pid" ]] && kill -0 "$img_clipboard_pid" 2>/dev/null && server_alive=true
            if [[ "$img_hash" != "$wl_last_img_hash" ]] || [[ "$server_alive" == false ]]; then
                # Confirm PNG via magic bytes (satty offers PNG as octet-stream).
                # xxd -l 4 -p reads the first 4 bytes as hex; PNG magic = 89504e47.
                png_sig=$(xxd -l 4 -p "$img_tmp" 2>/dev/null || true)
                if [[ "$png_sig" == "89504e47" ]]; then
                    # Kill previous server if running
                    [[ -n "$img_clipboard_pid" ]] && kill "$img_clipboard_pid" 2>/dev/null
                    # Copy image to a stable file: img_tmp is overwritten every loop
                    # iteration, which would race with magick reading it in the server.
                    [[ -n "$img_stable" ]] && rm -f "$img_stable" 2>/dev/null
                    img_stable=$(mktemp --suffix=.png)
                    cp "$img_tmp" "$img_stable"
                    # Launch Python server: serves image/png AND image/bmp from same X11
                    # owner. Teams needs image/png; the server converts PNG→BMP via magick.
                    DISPLAY=:0 python3 "$(dirname "$0")/x11-image-clipboard.py" "$img_stable" &
                    img_clipboard_pid=$!
                    wl_last_img_hash="$img_hash"
                fi
            fi
        fi
    else
        wl_last_img_hash=""
    fi

    # ── Text persistence: restore if clipboard completely empty ───────────────
    # Chrome's async clipboard API (right-click copy) releases the Wayland clipboard
    # after a few seconds. wl-clip-persist doesn't catch this reliably, so we do it
    # ourselves. Guard on wl_current_types being empty (not just text being empty)
    # so we don't clobber an image clipboard with saved text content.
    # Debounce: require 5 consecutive empty reads (~500ms) before restoring, to avoid
    # a race where wl-copy (e.g. satty-copy.sh) is still registering with the compositor
    # and wl-paste --list-types returns empty for one cycle — which would evict wl-copy.
    if [[ -z "$wl_current_types" ]]; then
        ((empty_count++))
    else
        empty_count=0
    fi
    if [[ "$empty_count" -ge 5 && -n "$saved_content" ]]; then
        printf '%s' "$saved_content" | wl-copy
        empty_count=0
    fi

    # ── X11 → Wayland (FreeRDP lazy clipboard after RDP round-trip) ──────────
    if [[ -n "$x11_current" && "$x11_current" != Error:* && "$x11_current" != "$x11_last" ]]; then
        printf '%s' "$x11_current" | wl-copy
        printf '%s' "$x11_current" | xclip -i -selection primary
        x11_last="$x11_current"
        wl_last="$x11_current"  # prevent Wayland branch from re-triggering
        saved_content="$x11_current"
    fi

    # ── Wayland → X11 (Teams via XWayland bridge, before deadlock) ───────────
    if [[ -n "$wl_current" && "$wl_current" != "$wl_last" && "$wl_current" != "$x11_last" ]]; then
        printf '%s' "$wl_current" | wl-copy
        printf '%s' "$wl_current" | xclip -i -selection primary
        wl_last="$wl_current"
        x11_last="$wl_current"  # prevent X11 branch from re-triggering
        saved_content="$wl_current"
    fi

    sleep 0.1
done
