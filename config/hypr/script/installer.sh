#!/bin/bash

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

CACHE_DIR="$HOME/.cache/pkg-fzf"
CACHE_FILE="$CACHE_DIR/packages.txt"
CACHE_MAX_AGE=1800  # 30 minuti (in secondi)

mkdir -p "$CACHE_DIR"

# --- Funzione cache valida ---
is_cache_valid() {
    [ -f "$CACHE_FILE" ] && \
    [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt $CACHE_MAX_AGE ]
}

# --- Aggiorna cache ---
update_cache() {
    echo -e "${CYAN}Aggiorno cache pacchetti...${NC}"

    repo_pkgs=$(pacman -Slq | sed 's/^/[REPO] /')
    aur_pkgs=$(yay -Slq --aur | sed 's/^/[AUR] /')

    (echo "$repo_pkgs"; echo "$aur_pkgs") | sort -u > "$CACHE_FILE"
}

# --- Usa cache o aggiorna ---
if is_cache_valid; then
    echo -e "${CYAN}Uso cache pacchetti...${NC}"
else
    update_cache
fi

# --- FZF ---
selection=$(cat "$CACHE_FILE" | fzf \
    --multi \
    --ansi \
    --header "📦 INSTALLATORE ARCH (cached)" \
    --prompt "Filtra: " \
    --pointer "➜" \
    --marker "✔" \
    --preview '
        pkg=$(echo {} | sed "s/\[.*\] //")
        if echo {} | grep -q "\[REPO\]"; then
            pacman -Si "$pkg"
        else
            yay -Si "$pkg"
        fi | grep -E "Name|Description|Version|Installed Size|Depends On" --color=always
    ' \
    --preview-window=right:60%:wrap \
    --bind "ctrl-a:select-all,ctrl-d:deselect-all"
)

[ -z "$selection" ] && echo -e "${YELLOW}Annullato.${NC}" && exit 0

# --- Separazione ---
repo_to_install=()
aur_to_install=()

while read -r line; do
    pkg=$(echo "$line" | sed 's/\[.*\] //')
    if [[ "$line" == *"[REPO]"* ]]; then
        repo_to_install+=("$pkg")
    else
        aur_to_install+=("$pkg")
    fi
done <<< "$selection"
# ... (sopra resta tutto uguale)

clear
echo -e "${CYAN}Installazione...${NC}"

# Variabile per monitorare se qualcosa va storto
ERRORE=0

# --- Installazione REPO ---
if [ ${#repo_to_install[@]} -gt 0 ]; then
    echo -e "${CYAN}📦 Installazione pacchetti ufficiali...${NC}"
    # Ho aggiunto --needed così non reinstalla ciò che hai già
    sudo pacman -S --needed "${repo_to_install[@]}" || ERRORE=1
fi

# --- Installazione AUR ---
if [ ${#aur_to_install[@]} -gt 0 ]; then
    echo -e "${CYAN}📦 Installazione pacchetti AUR...${NC}"
    yay -S --needed "${aur_to_install[@]}" || ERRORE=1
fi

# --- MESSAGGIO FINALE ---
echo -e "\n------------------------------------------"

if [ $ERRORE -eq 0 ]; then
    echo -e "${CYAN}✅ Operazione completata con successo!${NC}"
else
    echo -e "${YELLOW}⚠️  L'installazione è terminata con degli errori.${NC}"
    echo -e "${YELLOW}Controlla i messaggi sopra per i dettagli.${NC}"
fi

echo -e "------------------------------------------"
echo -e "${CYAN}Premi un tasto qualsiasi per chiudere questa finestra...${NC}"

# Blocca lo script finché non premi un tasto
read -n 1 -s -r

exit 0
