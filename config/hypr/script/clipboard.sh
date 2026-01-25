#!/bin/bash

THEME="$HOME/.config/rofi/launchers/type-2/style-2.rasi"

LIST=$(cliphist list | awk '
{
  id=$1
  $1=""
  content=substr($0,2)

  if (content ~ /^\[image/) {
    print "<b>"id"</b>    <i>Image</i>"
  } else {
    print "<b>"id"</b>    "content
  }
}')

CHOICE=$(echo "$LIST" | rofi -dmenu \
    -i \
    -markup-rows \
    -p " Clipboard" \
    -theme "$THEME")

[[ -z "$CHOICE" ]] && exit 0

ID=$(echo "$CHOICE" | sed -E 's/<[^>]*>//g' | awk '{print $1}')

cliphist decode "$ID" | wl-copy

