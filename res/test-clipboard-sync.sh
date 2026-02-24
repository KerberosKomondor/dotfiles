#!/bin/bash
# Test suite for ~/res/x11-clip-sync.sh
#
# Covers all clipboard copy/paste paths between local apps and FreeRDP:
#   - Wayland CLIPBOARD  → X11 CLIPBOARD  (local Wayland app → FreeRDP)
#   - Wayland CLIPBOARD  → X11/Wayland PRIMARY  (middle-click paste)
#   - Clipboard persistence  (Chrome async clipboard API releases ownership after ~3s)
#   - X11 deadlock safety  (script uses timeout so it can't block indefinitely)
#   - Interactive: Teams Ctrl+C  → FreeRDP paste
#   - Interactive: Teams right-click copy  → FreeRDP paste (incl. 4s persistence check)
#   - Interactive: FreeRDP copy  → local Wayland app paste
#
# Usage:
#   bash ~/res/test-clipboard-sync.sh           # run all tests
#   bash ~/res/test-clipboard-sync.sh --auto    # skip interactive tests

# ── colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

PASS=0; FAIL=0; SKIP=0
# Use arithmetic assignment (not (( )) ) to avoid bash exiting on zero result
# when set -e is active — and don't use set -e in test scripts anyway.
pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS=$(( PASS + 1 )); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$(( FAIL + 1 )); }
skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; SKIP=$(( SKIP + 1 )); }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
section() { echo; echo -e "${BOLD}=== $1 ===${NC}"; }

INTERACTIVE=true
[[ "${1:-}" == "--auto" ]] && INTERACTIVE=false

# ── helpers ───────────────────────────────────────────────────────────────────
unique() { echo "CLIP_TEST_$$_$(date +%s%N)"; }

wl_get()  { timeout 1 wl-paste 2>/dev/null || true; }
x11_get() { DISPLAY=:0 timeout 0.6 xclip -o -selection clipboard -target UTF8_STRING 2>/dev/null || true; }
x11_primary_get() { DISPLAY=:0 timeout 0.6 xclip -o -selection primary -target UTF8_STRING 2>/dev/null || true; }
wl_primary_get()  { timeout 1 wl-paste --primary 2>/dev/null || true; }

# Save clipboard state and restore on exit
_saved_wl=$(wl_get)
_saved_x11=$(x11_get)
cleanup() {
    # Restore previous clipboard if it had content
    [[ -n "$_saved_wl" ]] && printf '%s' "$_saved_wl" | wl-copy 2>/dev/null || true
}
trap cleanup EXIT

# ── 1. Environment ────────────────────────────────────────────────────────────
section "Environment"

[[ -n "${DISPLAY:-}" ]]          && pass "DISPLAY set ($DISPLAY)"          || fail "DISPLAY not set"
[[ -n "${WAYLAND_DISPLAY:-}" ]]  && pass "WAYLAND_DISPLAY set ($WAYLAND_DISPLAY)" || fail "WAYLAND_DISPLAY not set"
for t in wl-copy wl-paste xclip; do
    command -v "$t" &>/dev/null  && pass "$t available" || fail "$t not found"
done

# ── 2. Script health ──────────────────────────────────────────────────────────
section "Script health"

script_pid=$(pgrep -f x11-clip-sync.sh | head -1 || true)
if [[ -n "$script_pid" ]]; then
    pass "x11-clip-sync.sh running (PID $script_pid)"
else
    fail "x11-clip-sync.sh NOT running — start it before testing"
    echo -e "${RED}Cannot run propagation tests without the sync script. Exiting.${NC}"
    echo
    echo "════════════════════════════════════════"
    echo -e "  ${GREEN}Passed${NC}: $PASS   ${RED}Failed${NC}: $FAIL   ${YELLOW}Skipped${NC}: $SKIP"
    echo "════════════════════════════════════════"
    exit 1
fi

# Check for stuck xclip -o processes (our script uses timeout 0.5s, so any
# xclip -o that's been running > 2s is leftover from the old script version)
stuck=""
while IFS= read -r pid; do
    [[ -z "$pid" ]] && continue
    # /proc/<pid>/stat field 22 is start time in clock ticks since boot
    ticks_per_sec=$(getconf CLK_TCK 2>/dev/null || echo 100)
    start_ticks=$(awk '{print $22}' /proc/"$pid"/stat 2>/dev/null || echo 0)
    uptime_ticks=$(awk '{print int($1 * '"$ticks_per_sec"')}' /proc/uptime 2>/dev/null || echo 0)
    age_sec=$(( (uptime_ticks - start_ticks) / ticks_per_sec ))
    (( age_sec > 2 )) && stuck+="PID $pid (${age_sec}s) "
done < <(pgrep -f "xclip.*-o.*clipboard" 2>/dev/null || true)

if [[ -z "$stuck" ]]; then
    pass "No stuck xclip -o processes"
else
    fail "Stuck xclip -o processes detected: $stuck"
fi

grep -q 'timeout.*xclip' ~/res/x11-clip-sync.sh \
    && pass "Script uses timeout on xclip -o (XWayland deadlock protection)" \
    || fail "Script does NOT use timeout on xclip -o"

grep -q 'saved_content' ~/res/x11-clip-sync.sh \
    && pass "Script has clipboard persistence (saved_content restore logic)" \
    || fail "Script missing clipboard persistence logic"

# ── 3. Wayland → X11 propagation ─────────────────────────────────────────────
section "Wayland → X11 propagation"

T=$(unique)
printf '%s' "$T" | wl-copy
sleep 0.6   # 6 poll cycles at 100ms (generous to avoid races)

got=$(x11_get)
[[ "$got" == "$T" ]] \
    && pass "Wayland CLIPBOARD → X11 CLIPBOARD" \
    || fail "Wayland CLIPBOARD → X11 CLIPBOARD  (expected '${T:0:30}', got '${got:0:30}')"

got=$(x11_primary_get)
[[ "$got" == "$T" ]] \
    && pass "Wayland CLIPBOARD → X11 PRIMARY" \
    || fail "Wayland CLIPBOARD → X11 PRIMARY  (expected '${T:0:30}', got '${got:0:30}')"

got=$(wl_primary_get)
if [[ "$got" == "$T" ]]; then
    pass "Wayland CLIPBOARD → Wayland PRIMARY"
elif [[ -z "$got" || "$got" == "Nothing is copied" ]]; then
    skip "Wayland PRIMARY not supported by compositor (zwp_primary_selection_device_manager_v1 missing)"
else
    fail "Wayland CLIPBOARD → Wayland PRIMARY  (expected '${T:0:30}', got '${got:0:30}')"
fi

# ── 4. Clipboard persistence ──────────────────────────────────────────────────
section "Clipboard persistence (Chrome async clipboard expiry simulation)"

T=$(unique)
printf '%s' "$T" | wl-copy
sleep 0.4   # let script detect and save

info "Simulating clipboard owner exit (pkill wl-copy) ..."
pkill -f wl-copy 2>/dev/null || true
sleep 0.5   # 5 poll cycles for script to detect empty and restore

got_wl=$(wl_get)
got_x11=$(x11_get)

[[ "$got_wl" == "$T" ]] \
    && pass "Wayland CLIPBOARD restored after owner exit" \
    || fail "Wayland CLIPBOARD not restored  (expected '${T:0:30}', got '${got_wl:0:30}')"

[[ "$got_x11" == "$T" ]] \
    && pass "X11 CLIPBOARD restored after owner exit" \
    || fail "X11 CLIPBOARD not restored  (expected '${T:0:30}', got '${got_x11:0:30}')"

# ── 5. Persistence duration ───────────────────────────────────────────────────
section "Persistence duration (clipboard survives 5 seconds)"

T=$(unique)
printf '%s' "$T" | wl-copy
sleep 0.3
pkill -f wl-copy 2>/dev/null || true   # simulate Chrome releasing clipboard
sleep 5                                  # wait well past Chrome's ~3s expiry

got_wl=$(wl_get)
got_x11=$(x11_get)

[[ "$got_wl" == "$T" ]] \
    && pass "Wayland CLIPBOARD still present after 5s" \
    || fail "Wayland CLIPBOARD expired after 5s  (got '${got_wl:0:30}')"

[[ "$got_x11" == "$T" ]] \
    && pass "X11 CLIPBOARD still present after 5s" \
    || fail "X11 CLIPBOARD expired after 5s  (got '${got_x11:0:30}')"

# ── 6. Interactive tests ──────────────────────────────────────────────────────
section "Interactive tests"

if ! $INTERACTIVE; then
    skip "Interactive tests skipped (--auto flag)"
else
    freerdp_pid=$(pgrep -f xfreerdp 2>/dev/null | head -1 || true)
    teams_pid=$(pgrep -f "app-id=cifhbcnohmdccbgoicgdjpfamggdegmo" 2>/dev/null | head -1 || true)

    if [[ -z "$freerdp_pid" ]]; then
        skip "FreeRDP not running — skipping all interactive tests"
    elif [[ -z "$teams_pid" ]]; then
        skip "Teams not running — skipping Teams→FreeRDP interactive tests"
    else
        info "FreeRDP PID: $freerdp_pid  |  Teams PID: $teams_pid"
        echo

        # Helper: poll for clipboard change, up to N seconds
        wait_for_change() {
            local prev="$1" limit="${2:-5}" interval=0.2
            local steps=$(echo "$limit / $interval" | bc)
            for _ in $(seq 1 "$steps"); do
                local cur; cur=$(wl_get)
                if [[ -n "$cur" && "$cur" != "$prev" ]]; then
                    echo "$cur"; return 0
                fi
                sleep "$interval"
            done
            echo ""; return 1
        }

        # ── 6a. Teams Ctrl+C → FreeRDP ────────────────────────────────────────
        echo -e "${BOLD}Test 6a: Teams Ctrl+C → FreeRDP paste${NC}"
        echo "  1. Select and Ctrl+C some text in Teams."
        echo "  2. Then come back here and press Enter."
        read -r -p "  [Enter when done] "

        before=$(wl_get)
        new=$(wait_for_change "$before" 3 || true)
        if [[ -z "$new" ]]; then
            new=$(wl_get)
        fi

        wl_val=$(wl_get); x11_val=$(x11_get)
        if [[ -n "$wl_val" && "$wl_val" == "$x11_val" ]]; then
            pass "6a clipboard synced: Wayland == X11 ('${wl_val:0:40}')"
            echo "  Now paste in FreeRDP (Ctrl+V in the RDP session)."
            read -r -p "  Did it paste correctly? [y/n] " ans
            [[ "$ans" == y* ]] \
                && pass "6a Teams Ctrl+C → FreeRDP paste: confirmed" \
                || fail "6a Teams Ctrl+C → FreeRDP paste: user reported failure"
        else
            fail "6a clipboard not synced  (Wayland='${wl_val:0:30}' X11='${x11_val:0:30}')"
        fi
        echo

        # ── 6b. Teams right-click copy → FreeRDP (with persistence) ───────────
        echo -e "${BOLD}Test 6b: Teams right-click copy → FreeRDP paste${NC}"
        echo "  1. Right-click copy a DIFFERENT piece of text in Teams."
        echo "  2. Then come back here and press Enter."
        read -r -p "  [Enter when done] "

        prev_val="$wl_val"
        wl_after=$(wl_get); x11_after=$(x11_get)

        if [[ -z "$wl_after" || "$wl_after" == "$prev_val" ]]; then
            fail "6b clipboard unchanged after right-click copy  ('${wl_after:0:30}')"
        elif [[ "$wl_after" != "$x11_after" ]]; then
            fail "6b clipboard not synced  (Wayland='${wl_after:0:30}' X11='${x11_after:0:30}')"
        else
            pass "6b clipboard synced immediately ('${wl_after:0:40}')"
            info "Waiting 4s to verify persistence past Chrome's ~3s expiry ..."
            sleep 4
            wl_p=$(wl_get); x11_p=$(x11_get)
            [[ "$wl_p" == "$wl_after" ]] \
                && pass "6b Wayland clipboard persisted after 4s" \
                || fail "6b Wayland clipboard expired  (got '${wl_p:0:30}')"
            [[ "$x11_p" == "$wl_after" ]] \
                && pass "6b X11 clipboard persisted after 4s" \
                || fail "6b X11 clipboard expired  (got '${x11_p:0:30}')"
            echo "  Now paste in FreeRDP (Ctrl+V in the RDP session)."
            read -r -p "  Did it paste correctly? [y/n] " ans
            [[ "$ans" == y* ]] \
                && pass "6b Teams right-click → FreeRDP paste: confirmed" \
                || fail "6b Teams right-click → FreeRDP paste: user reported failure"
        fi
        echo

        # ── 6c. FreeRDP copy → local Wayland app paste ────────────────────────
        echo -e "${BOLD}Test 6c: FreeRDP copy → local Wayland app paste${NC}"
        echo "  1. In the FreeRDP session, select and copy some text (Ctrl+C in a remote app)."
        echo "  2. Then come back here and press Enter."
        read -r -p "  [Enter when done] "

        wl_rdp=$(wl_get); x11_rdp=$(x11_get)
        if [[ -n "$wl_rdp" ]]; then
            pass "6c FreeRDP copy synced to Wayland ('${wl_rdp:0:40}')"
            echo "  Paste in a local Wayland app (e.g. wezterm, gedit) using Ctrl+V."
            read -r -p "  Did it paste correctly? [y/n] " ans
            [[ "$ans" == y* ]] \
                && pass "6c FreeRDP → local Wayland paste: confirmed" \
                || fail "6c FreeRDP → local Wayland paste: user reported failure"
        else
            fail "6c Wayland clipboard empty after FreeRDP copy  (sync may have failed)"
        fi
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo
echo "════════════════════════════════════════"
echo -e "  ${GREEN}Passed${NC}: $PASS   ${RED}Failed${NC}: $FAIL   ${YELLOW}Skipped${NC}: $SKIP"
echo "════════════════════════════════════════"
(( FAIL == 0 )) \
    && echo -e "  ${GREEN}${BOLD}All tests passed.${NC}" \
    || echo -e "  ${RED}${BOLD}Some tests failed.${NC}"
echo
exit $FAIL
