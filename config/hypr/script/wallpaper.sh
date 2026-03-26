#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper"
TRANSITION="wipe"
DURATION=1

# crea cache se non esiste
mkdir -p "$(dirname "$STATE_FILE")"

# lista wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f | sort)

# esci se cartella vuota
[ ${#WALLPAPERS[@]} -eq 0 ] && exit 1

# wallpaper corrente
if [ -f "$STATE_FILE" ]; then
  CURRENT=$(cat "$STATE_FILE")
else
  CURRENT=""
fi

# trova il prossimo
NEXT=""
# Sostituisci la parte del ciclo FOR nel tuo script con:
SELECTED=$(find "$WALLPAPER_DIR" -type f | walker --dmenu --placeholder "Scegli sfondo...")

[ -z "$SELECTED" ] && exit 0

swww img "$SELECTED" --transition-type "$TRANSITION"
echo "$SELECTED" > "$STATE_FILE"

# se non trovato, usa il primo
[ -z "$NEXT" ] && NEXT="${WALLPAPERS[0]}"

# applica wallpaper
swww img "$NEXT" \
  --transition-type "$TRANSITION" \
  --transition-duration "$DURATION"

# salva stato
echo "$NEXT" > "$STATE_FILE"

