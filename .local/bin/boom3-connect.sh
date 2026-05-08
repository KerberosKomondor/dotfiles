#!/bin/bash
set -e

MAC=EC:81:93:6A:B7:74
VOL_FILE="$HOME/.local/state/boom3-volume"

sleep 10

for i in 1 2 3 4 5; do
    echo "info $MAC" | bluetoothctl | grep -q "Connected: yes" && break
    bluetoothctl connect "$MAC"
    sleep 5
done

# Wait for PipeWire sink to become available
for i in $(seq 1 10); do
    pactl get-sink-volume "bluez_output.${MAC//:/_}.1" > /dev/null 2>&1 && break
    sleep 1
done

VOL=$([ -f "$VOL_FILE" ] && cat "$VOL_FILE" || echo "45%")
pactl set-sink-volume "bluez_output.${MAC//:/_}.1" "$VOL"
