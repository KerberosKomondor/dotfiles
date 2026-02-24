#!/bin/bash
# Bidirectional clipboard bridge: local apps ↔ FreeRDP (XWayland)
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
#   push the result to wl-copy (Wayland CLIPBOARD) and Wayland/X11 PRIMARY.
#
# Do NOT use xclip -i -selection clipboard: taking X11 CLIPBOARD ownership from a
# local app triggers XWayland to re-bridge and re-deadlock X11 CLIPBOARD.
# Do NOT add wl-paste --watch: creates infinite loop (wl-copy → XWayland mirrors
# to X11 → wl-paste fires → xclip → XWayland re-announces → repeat).
# Timeouts on xclip -o prevent the script from blocking on XWayland deadlock.

x11_last=""
wl_last=""
saved_content=""  # last known clipboard content, for restoring when clipboard goes empty

while true; do
    # Poll X11 CLIPBOARD with timeout (avoids blocking on XWayland deadlock)
    x11_current=$(timeout 0.5 xclip -o -selection clipboard -target UTF8_STRING 2>/dev/null)

    # Poll Wayland CLIPBOARD (Teams content arrives here via XWayland bridge before deadlock)
    wl_current=$(timeout 0.5 wl-paste 2>/dev/null)

    # Restore clipboard if it went empty while we have saved content.
    # Chrome's async clipboard API (right-click copy) releases the Wayland clipboard
    # after a few seconds. wl-clip-persist doesn't catch this reliably, so we do it
    # ourselves: detect the empty→restore transition and re-assert wl-copy.
    # saved_content is only set when we write; wl_last/x11_last stay unchanged so
    # on the next poll wl_current==wl_last and the Wayland branch won't re-fire.
    if [[ -z "$wl_current" && -n "$saved_content" ]]; then
        printf '%s' "$saved_content" | wl-copy
    fi

    if [[ -n "$x11_current" && "$x11_current" != Error:* && "$x11_current" != "$x11_last" ]]; then
        # X11 CLIPBOARD changed — e.g. FreeRDP lazy clipboard after RDP round-trip.
        # Push to Wayland CLIPBOARD (wl-copy, for Ctrl+V in Wayland apps),
        # Wayland PRIMARY and X11 PRIMARY (for middle-click).
        printf '%s' "$x11_current" | wl-copy
        printf '%s' "$x11_current" | xclip -i -selection primary
        x11_last="$x11_current"
        wl_last="$x11_current"  # prevent Wayland branch from re-triggering
        saved_content="$x11_current"
    fi

    if [[ -n "$wl_current" && "$wl_current" != "$wl_last" && "$wl_current" != "$x11_last" ]]; then
        # Wayland CLIPBOARD changed — e.g. Teams content arrived via XWayland bridge.
        # Re-assert wl-copy ownership so XWayland's X11 CLIPBOARD proxy serves from
        # wl-copy (real process) instead of the deadlocked XWayland-Wayland-client.
        printf '%s' "$wl_current" | wl-copy
        printf '%s' "$wl_current" | xclip -i -selection primary
        wl_last="$wl_current"
        x11_last="$wl_current"  # prevent X11 branch from re-triggering
        saved_content="$wl_current"
    fi

    sleep 0.1
done
