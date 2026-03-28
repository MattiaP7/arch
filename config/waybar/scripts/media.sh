#!/bin/bash
# ~/.config/waybar/scripts/media.sh
# Richiede: playerctl

# Controlla se playerctl è disponibile
if ! command -v playerctl &> /dev/null; then
    echo '{"text": "", "tooltip": "playerctl non installato", "class": "unavailable"}'
    exit 0
fi

# Prende il player attivo (priorità: spotify > firefox > altri)
PLAYER=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)
if [ -z "$PLAYER" ]; then
    PLAYER=$(playerctl -l 2>/dev/null | head -1)
fi

if [ -z "$PLAYER" ]; then
    echo '{"text": "", "tooltip": "Nessun media in riproduzione", "class": "stopped"}'
    exit 0
fi

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
if [ "$STATUS" = "" ] || [ "$STATUS" = "Stopped" ]; then
    echo '{"text": "", "tooltip": "Nessun media in riproduzione", "class": "stopped"}'
    exit 0
fi

TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null | head -c 35)
ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null | head -c 25)
ALBUM=$(playerctl -p "$PLAYER" metadata album 2>/dev/null | head -c 30)

# Tronca con ellipsis se troppo lungo
if [ ${#TITLE} -ge 35 ]; then TITLE="${TITLE:0:32}..."; fi
if [ ${#ARTIST} -ge 25 ]; then ARTIST="${ARTIST:0:22}..."; fi

# Icona in base allo stato e al player
if echo "$PLAYER" | grep -qi "spotify"; then
    PLAYER_ICON=""
elif echo "$PLAYER" | grep -qi "firefox"; then
    PLAYER_ICON=""
elif echo "$PLAYER" | grep -qi "chromium\|chrome"; then
    PLAYER_ICON=""
else
    PLAYER_ICON="󰝚"
fi

if [ "$STATUS" = "Playing" ]; then
    STATUS_ICON="󰐊"
    CLASS="playing"
else
    STATUS_ICON="󰏤"
    CLASS="paused"
fi

# Testo breve per la barra
if [ -n "$ARTIST" ]; then
    TEXT="$STATUS_ICON $ARTIST - $TITLE"
else
    TEXT="$STATUS_ICON $TITLE"
fi

# Tooltip dettagliato
TOOLTIP="$PLAYER_ICON <b>$TITLE</b>"
if [ -n "$ARTIST" ]; then
    TOOLTIP="$TOOLTIP\n󰠃 $ARTIST"
fi
if [ -n "$ALBUM" ]; then
    TOOLTIP="$TOOLTIP\n󰀥 $ALBUM"
fi
TOOLTIP="$TOOLTIP\n\n󰒮 Prec  |  $STATUS_ICON Play/Pause  |  󰒭 Succ"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\", \"alt\": \"$STATUS\"}"
