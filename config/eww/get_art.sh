#!/bin/bash
URL=$(playerctl metadata mpris:artUrl 2>/dev/null)
if echo "$URL" | grep -q "^https\?://"; then
    DEST="/tmp/eww_art.jpg"
    curl -s -o "$DEST" "$URL" && echo "$DEST" || echo ""
elif echo "$URL" | grep -q "^file://"; then
    echo "${URL#file://}"
else
    echo ""
fi
