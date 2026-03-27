#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

CACHE_DIR="$HOME/.cache/pkg-fzf-remove"
CACHE_FILE="$CACHE_DIR/installed_packages.txt"
CACHE_MAX_AGE=60 # Cache più breve (60s) perché le installazioni cambiano spesso

mkdir -p "$CACHE_DIR"

# --- Funzione cache valida ---
is_cache_valid() {
    [ -f "$CACHE_FILE" ] && \
    [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt $CACHE_MAX_AGE ]
}

# --- Aggiorna cache (Solo pacchetti installati) ---
update_cache() {
    echo -e "${CYAN}Scansione pacchetti installati...${NC}"
    # pacman -Qe elenca i pacchetti installati esplicitamente (non come dipendenze)
    pacman -Qe | awk '{print $1}' > "$CACHE_FILE"
}

if ! is_cache_valid; then
    update_cache
fi

# --- FZF UI ---
selection=$(cat "$CACHE_FILE" | fzf \
    --multi \
    --ansi \
    --header "DISINSTALLATORE ARCH" \
    --prompt "Cerca pacchetto da rimuovere: " \
    --pointer "➜" \
    --marker "✗" \
    --preview 'pacman -Qi {1} | grep -E "Name|Description|Version|Install Date|Size" --color=always' \
    --preview-window=right:60%:wrap \
    --bind "ctrl-a:select-all,ctrl-d:deselect-all"
)

[ -z "$selection" ] && echo -e "${YELLOW}Annullato.${NC}" && exit 0

# --- Conferma e Rimozione ---
clear
echo -e "${YELLOW}Stai per rimuovere i seguenti pacchetti:${NC}"
echo "$selection"
echo -e "------------------------------------------"

# Usiamo -Rs per rimuovere anche le dipendenze inutilizzate (pulizia profonda)
# Se preferisci una rimozione semplice, usa solo -R
read -p "Confermi la disinstallazione? (s/N): " confirm
if [[ $confirm == [sS] ]]; then
    sudo pacman -Rs $selection
    
    if [ $? -eq 0 ]; then
        echo -e "\n${CYAN}✅ Pacchetti rimossi con successo!${NC}"
        # Svuota la cache per forzare l'aggiornamento al prossimo avvio
        rm "$CACHE_FILE"
    else
        echo -e "\n${YELLOW}⚠️ Si è verificato un errore durante la rimozione.${NC}"
    fi
else
    echo -e "${YELLOW}Operazione annullata.${NC}"
fi

echo -e "${CYAN}Premi un tasto per chiudere...${NC}"
read -n 1 -s -r
exit 0
