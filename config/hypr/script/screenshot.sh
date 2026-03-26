#!/bin/bash
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

# 'copysave' fa entrambe le cose in un colpo solo
grimblast copysave area "$FILE"

notify-send "Screenshot" "Salvato e copiato negli appunti" -i "$FILE"
