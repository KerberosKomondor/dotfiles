#!/bin/bash
# Auto-restart AGS when source files change.
# Usage: ./watch.sh  (run from any directory)
set -euo pipefail

AGS_DIR="$HOME/.config/ags"

restart() {
    echo "[watch] restarting AGS..."
    ags quit 2>/dev/null || true
    sleep 0.5
    ags run "$AGS_DIR" &>/tmp/ags-watch.log &
    echo "[watch] started (pid $!)"
}

restart

inotifywait -m -r -e modify,close_write,create,delete \
    --include '.*\.(tsx?|scss)$' \
    "$AGS_DIR" 2>/dev/null |
while read -r _dir _event _file; do
    echo "[watch] $_file changed"
    restart
done
