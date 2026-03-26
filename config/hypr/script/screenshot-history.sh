#!/bin/bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Seleziona il file
file=$(ls -t "$DIR" 2>/dev/null | fzf \
  --height=100% \
  --layout=reverse \
  --border \
  --info=inline \
  --prompt="  Screenshots > " \
  --preview-window=right:65%:border-left \
  --preview "kitty +kitten icat --clear --stdin no --transfer-mode file --place \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 --scale-up $DIR/{} > /dev/tty"
)

# Se non selezioni nulla (ESC), esci
[ -z "$file" ] && exit

# Azione immediata: Copia nella clipboard
wl-copy < "$DIR/$file"

# Notifica visiva
notify-send " Copiato" "$file" -i "$DIR/$file"
