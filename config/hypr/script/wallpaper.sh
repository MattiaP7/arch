#!/bin/bash

# Cartella dei tuoi wallpaper
WALL_DIR="$HOME/Pictures/wallpapers"

# Verifica swww
pgrep -x swww-daemon > /dev/null || swww-daemon &

# Genera la lista in modo pulito per evitare l'errore "null byte"
# Usiamo un ciclo semplice invece di gawk per massima compatibilità
wall_list=""
while IFS= read -r file; do
    wall_list+="${file}\0icon\x1f${WALL_DIR}/${file}\n"
done < <(ls -1 "$WALL_DIR")

# Lanciamo Fuzzel con i nomi dei flag corretti per la tua versione
selection=$(echo -e "$wall_list" | fuzzel --dmenu \
    --placeholder="Scegli Wallpaper..." \
    --dpi-aware=no \
    --width=60 \
    --lines=4 \
    --background-color="1a1b26f2" \
    --text-color="c0caf5ff" \
    --match-color="bb9af7ff" \
    --selection-color="33467cff" \
    --selection-text-color="ffffffff" \
    --border-color="7aa2f7ff" \
    --border-width=2)

# Se hai selezionato qualcosa
if [ -n "$selection" ]; then
    wallpaper_path="${WALL_DIR}/${selection}"
    
    # Applica con swww
    swww img "$wallpaper_path" --transition-type grow --transition-duration 1.5
    
    # Notifica
    notify-send "Wallpaper" "Sfondo aggiornato" -i "$wallpaper_path"
fi
