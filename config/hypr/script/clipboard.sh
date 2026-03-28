#!/bin/bash

# Cartella per le anteprime delle immagini
PREVIEW_DIR="/tmp/cliphist_previews"
mkdir -p "$PREVIEW_DIR"

# Recupera la lista da cliphist
selection=$(cliphist list | gawk -v dir="$PREVIEW_DIR" '{
    id = $1
    # Se la riga contiene dati binari (immagini)
    if ($0 ~ /\[\[ binary data/) {
        icon_path = dir "/" id ".png"
        # Estrae l immagine solo se l anteprima non esiste già
        if (system("test -f " icon_path) != 0) {
            system("cliphist decode " id " > " icon_path " 2>/dev/null")
        }
        # Formatta per Fuzzel: ID\tTesto \0icon\x1f percorso
        print $0 "\0icon\x1f" icon_path
    } else {
        # Se è testo, usa un icona generica e tronca per pulizia
        split($0, arr, "\t")
        text = arr[2]
        if (length(text) > 80) text = substr(text, 1, 80) "…"
        print id "\t󰆒  " text "\0icon\x1fedit-paste"
    }
}' | fuzzel --dmenu --placeholder "📋 Clipboard History...")

# Se l utente ha selezionato qualcosa, copia negli appunti
if [ -n "$selection" ]; then
    id=$(echo "$selection" | cut -f1)
    cliphist decode "$id" | wl-copy
    notify-send "Clipboard" "Elemento ripristinato" -i edit-paste -t 1000
fi
