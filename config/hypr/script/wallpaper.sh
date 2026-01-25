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
for i in "${!WALLPAPERS[@]}"; do
  if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
    NEXT="${WALLPAPERS[$(( (i + 1) % ${#WALLPAPERS[@]} ))]}"
    break
  fi
done

# se non trovato, usa il primo
[ -z "$NEXT" ] && NEXT="${WALLPAPERS[0]}"

# applica wallpaper
swww img "$NEXT" \
  --transition-type "$TRANSITION" \
  --transition-duration "$DURATION"

# salva stato
echo "$NEXT" > "$STATE_FILE"

