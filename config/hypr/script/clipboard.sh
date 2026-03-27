#!/bin/bash

# --- CONFIGURAZIONE ---
# Icone Tokyo Night style
ICON_TEXT="󰦨 "
ICON_IMAGE="󰋩 "
ICON_CLIP="󱘝 "

# Funzione per pulire il testo da caratteri strani o newline per la lista
clean_text() {
    echo "$1" | tr '\n' ' ' | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -c 1-100
}

# --- GENERAZIONE LISTA PER WALKER ---
# Recuperiamo la lista da cliphist
# Formato: "ID  CONTENUTO"
raw_list=$(cliphist list)

if [ -z "$raw_list" ]; then
    notify-send "Clipboard" "La cronologia è vuota" -t 2000
    exit 0
fi

# Formattiamo la lista per Walker: "Icona  Testo [ID]"
formatted_list=$(echo "$raw_list" | while read -r line; do
    id=$(echo "$line" | cut -f1)
    content=$(echo "$line" | cut -f2-)
    
    # Determiniamo se è un'immagine o testo per l'icona
    if [[ "$content" == "<< binary data >>" ]]; then
        icon="$ICON_IMAGE"
        label="Immagine / Screenshot"
    else
        icon="$ICON_TEXT"
        label=$(clean_text "$content")
    fi
    
    printf "%s  %s  [ID: %s]\n" "$icon" "$label" "$id"
done)

# --- UI WALKER ---
selected=$(echo "$formatted_list" | walker \
    --dmenu \
    --placeholder "󱘝 Cerca nella Clipboard..." \
    --width 800 \
    --height 500)

# Se l'utente preme ESC o chiude
[ -z "$selected" ] && exit 0

# --- ESTRAZIONE ID E COPIA ---
# Estraiamo l'ID contenuto tra le parentesi quadre [ID: XXX]
clip_id=$(echo "$selected" | grep -oP '\[ID: \K[0-9]+(?=\])')

if [ -n "$clip_id" ]; then
    # Decodifica e copia negli appunti di sistema (Wayland)
    cliphist decode "$clip_id" | wl-copy
    notify-send "Clipboard" "Elemento copiato negli appunti" -i "edit-copy" -t 1500
fi
