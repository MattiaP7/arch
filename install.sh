#!/bin/bash

# Esci se un comando fallisce
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOT_CONFIG="$SCRIPT_DIR/config"
TARGET_CONFIG="$HOME/.config"

echo "Avvio installazione da: $SCRIPT_DIR"

### ------------------------
### INSTALL YAY (AUR Helper)
### ------------------------
if ! command -v yay &> /dev/null; then
    echo "Installazione yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

### ------------------------
### PACMAN PACKAGES
### ------------------------
# Qui ci sono le utility che usi nelle tue config (waybar, nvim, shell tools)
PKGS=(
    waybar kitty waypaper swaync swww           # UI & Desktop
    pavucontrol libnotify brightnessctl         # System Control
    wl-clipboard cliphist jq fzf ripgrep fd     # Tools & Clipboard
    eza bat zoxide yazi fastfetch btop          # CLI modern tools
    ttf-jetbrains-mono-nerd ttf-dejavu          # Fonts obbligatori
    nodejs npm python-pip neovim                # Dev & Editor
    rsync unzip wget                            # Utility
    papirus-icon-theme                          # Icone (importanti per GTK)
)

echo "Installazione pacchetti Pacman..."
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

### ------------------------
### AUR PACKAGES
### ------------------------
AUR_PKGS=(
    nwg-look ags-hyprpanel-git                  # Personalizzazione estetica
    walker visual-studio-code-bin               # App specifiche
    grimblast-git greetd-tuigreet               # Screenshot e Login
    clipse                                      # Gestore clipboard TUI
)

echo "Installazione pacchetti AUR..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

### ------------------------
### CONFIGURAZIONE SYMLINK
### ------------------------
echo "Creazione Symlink..."

mkdir -p "$TARGET_CONFIG"

# Ciclo sulle cartelle presenti nel tuo repository dotfiles
for dir in "$DOT_CONFIG"/*; do
    name=$(basename "$dir")
    target="$TARGET_CONFIG/$name"

    # Se esiste già una cartella/file (e non è già un link), facciamo backup
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo " Backup di $name..."
        mv "$target" "$target.bak.$(date +%s)"
    elif [ -L "$target" ]; then
        echo "Rimuovo vecchio link: $name"
        rm "$target"
    fi

    ln -s "$dir" "$target"
    echo "Collegato $name"
done

### ------------------------
### SERVIZI E PERMESSI
### ------------------------
echo "Abilitazione Servizi..."
sudo systemctl enable --now bluetooth 2>/dev/null || echo "Bluetooth non presente"

# Rende eseguibili tutti i tuoi script in hypr/script
if [ -d "$TARGET_CONFIG/hypr/script" ]; then
    chmod +x "$TARGET_CONFIG/hypr/script"/*.sh
    echo "Script in hypr/script resi eseguibili"
fi

echo " Setup completato con successo!"
echo " Prossimo passo: configura tuigreet in /etc/greetd/config.toml"
