#!/bin/bash
# Set BOOM 3 volume to 45% whenever it connects

pactl subscribe 2>/dev/null | while IFS= read -r event; do
    if echo "$event" | grep -q "Event 'new' on sink"; then
        sleep 0.5
        boom_sink=$(pactl list sinks short | awk '/EC_81_93_6A_B7_74/{print $2}')
        if [ -n "$boom_sink" ]; then
            pactl set-sink-volume "$boom_sink" 45%
            exit 0
        fi
    fi
done
