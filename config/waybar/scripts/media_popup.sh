#!/bin/bash
# ~/.config/waybar/scripts/media_popup.sh
# Popup media player con immagine, usa playerctl + imagemagick + kitty o una finestra GTK
# Alternativa: usa rofi o un semplice script dunst

PLAYER=$(playerctl -l 2>/dev/null | grep -i spotify | head -1)
if [ -z "$PLAYER" ]; then
    PLAYER=$(playerctl -l 2>/dev/null | head -1)
fi

if [ -z "$PLAYER" ]; then exit 0; fi

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
TITLE=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
ARTIST=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
ALBUM=$(playerctl -p "$PLAYER" metadata album 2>/dev/null)
ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)
POSITION=$(playerctl -p "$PLAYER" position 2>/dev/null | cut -d. -f1)
DURATION=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)

# Converti durata da microsec a secondi
if [ -n "$DURATION" ]; then
    DUR_SEC=$((DURATION / 1000000))
    DUR_MIN=$((DUR_SEC / 60))
    DUR_SECC=$((DUR_SEC % 60))
    POS_MIN=$((POSITION / 60))
    POS_SEC=$((POSITION % 60))
    TIME_STR=$(printf "%d:%02d / %d:%02d" $POS_MIN $POS_SEC $DUR_MIN $DUR_SECC)
fi

# Scarica art se è un URL http
ART_PATH=""
if echo "$ART_URL" | grep -q "^https\?://"; then
    ART_PATH="/tmp/waybar_media_art.jpg"
    curl -s -o "$ART_PATH" "$ART_URL" 2>/dev/null
elif echo "$ART_URL" | grep -q "^file://"; then
    ART_PATH="${ART_URL#file://}"
fi

# Mostra notifica con dunstify (con immagine se disponibile)
BODY=""
[ -n "$ARTIST" ] && BODY+="<b>$ARTIST</b>"
[ -n "$ALBUM" ] && BODY+="\n<i>$ALBUM</i>"
[ -n "$TIME_STR" ] && BODY+="\n⏱ $TIME_STR"

ICON_ARG=""
if [ -n "$ART_PATH" ] && [ -f "$ART_PATH" ]; then
    ICON_ARG="--icon=$ART_PATH"
fi

dunstify \
    --replace=9999 \
    --urgency=low \
    --timeout=5000 \
    $ICON_ARG \
    --appname="Media Player" \
    "$([ "$STATUS" = "Playing" ] && echo "▶" || echo "⏸") $TITLE" \
    "$BODY" \
    --action="default,Apri" \
    --action="prev,⏮ Precedente" \
    --action="next,⏭ Successivo" \
    --action="toggle,⏯ Play/Pausa" 2>/dev/null &

# Gestisci l'azione scelta
ACTION=$?
