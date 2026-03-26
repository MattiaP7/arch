#!/bin/bash

if command -v swaync-client &> /dev/null; then
    count=$(swaync-client -c 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        echo "{\"text\":\"$count\", \"class\":\"has-notifications\", \"tooltip\":\"$count notifiche non lette\"}"
    else
        echo "{\"text\":\"0\", \"class\":\"no-notifications\", \"tooltip\":\"Nessuna notifica\"}"
    fi
else
    echo "{\"text\":\"0\", \"class\":\"no-notifications\"}"
fi
