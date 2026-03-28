#!/bin/bash

# Prende la lunghezza totale (in microsecondi) e la posizione (in secondi)
LEN=$(playerctl metadata mpris:length 2>/dev/null)
POS=$(playerctl position 2>/dev/null)

# Se non c'è una canzone o è una radio in diretta (senza lunghezza), restituisci 0
if [ -z "$LEN" ] || [ -z "$POS" ] || [ "$LEN" -eq 0 ]; then
    echo 0
    exit 0
fi

# Calcola la percentuale matematica
awk -v pos="$POS" -v len="$LEN" 'BEGIN { printf "%.0f\n", (pos / (len / 1000000)) * 100 }'
