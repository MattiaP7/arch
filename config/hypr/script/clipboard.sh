#!/bin/bash
# =============================================================================
# CLIPBOARD MANAGER — cliphist + walker
# Menu pulito, preview intelligente, senza confusione visiva
# =============================================================================

MAX_TEXT_LEN=80   # caratteri massimi per la preview del testo

# ---------------------------------------------------------------------------
# Recupera lista clipboard
# ---------------------------------------------------------------------------
raw_list=$(cliphist list 2>/dev/null)

if [ -z "$raw_list" ]; then
    notify-send "Clipboard" "La cronologia è vuota" --icon=edit-paste -t 2000
    exit 0
fi

# ---------------------------------------------------------------------------
# Formatta lista: una riga pulita per ogni entry
# Formato output:  ID\tPREVIEW
# ---------------------------------------------------------------------------
formatted_list=$(echo "$raw_list" | while IFS=$'\t' read -r id content; do
    # Immagine / dato binario
    if [[ "$content" == *"<< binary data >>"* ]]; then
        printf "%s\t󰋩  [immagine]\n" "$id"
        continue
    fi

    # Rimuove spazi/newline in eccesso, tronca
    preview=$(echo "$content" \
        | tr '\n\t' '  ' \
        | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
        | cut -c "1-$MAX_TEXT_LEN")

    # Aggiunge "…" se troncato
    original_len=${#content}
    [ "$original_len" -gt "$MAX_TEXT_LEN" ] && preview="$preview…"

    # Salta righe vuote
    [ -z "$preview" ] && continue

    printf "%s\t󰆒  %s\n" "$id" "$preview"
done)

# ---------------------------------------------------------------------------
# Walker — mostra solo la preview (colonna 2), nasconde l'ID
# ---------------------------------------------------------------------------
selected_preview=$(echo "$formatted_list" | cut -f2 | walker \
    --dmenu \
    --placeholder "󱘝  Cerca nella clipboard..." \
    --width 700 \
    --height 480 \
    )

[ -z "$selected_preview" ] && exit 0

# ---------------------------------------------------------------------------
# Ritrova l'ID originale dalla preview selezionata
# ---------------------------------------------------------------------------
clip_id=$(echo "$formatted_list" \
    | grep -F "$(printf '\t')${selected_preview}" \
    | head -n1 \
    | cut -f1)

# Fallback: prova match parziale
if [ -z "$clip_id" ]; then
    clip_id=$(echo "$formatted_list" \
        | awk -F'\t' -v sel="$selected_preview" '$2 == sel {print $1; exit}')
fi

# ---------------------------------------------------------------------------
# Copia negli appunti Wayland
# ---------------------------------------------------------------------------
if [ -n "$clip_id" ]; then
    cliphist decode "$clip_id" | wl-copy
    notify-send "Clipboard" "Copiato negli appunti" \
        --icon=edit-copy \
        --expire-time=1500
else
    notify-send "Clipboard" "Errore: elemento non trovato" \
        --icon=dialog-error \
        --expire-time=2000
fi
