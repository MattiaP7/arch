#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/bind.conf"

mapfile -t BINDINGS < <(
  grep '^[[:space:]]*bind[[:space:]]*=' "$HYPR_CONF" |
  sed -e 's/^[[:space:]]*bind[[:space:]]*=[[:space:]]*//' \
      -e 's/  */ /g' \
      -e 's/, /,/g' |
  awk -F, -v q="'" '{
    cmd=""
    for(i=3;i<NF;i++) cmd=cmd $i " "
    print "<b>"$1" + "$2"</b>  <i>"$NF",</i><span color="q"gray"q">"cmd"</span>"
  }'
)

CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | \
  rofi -dmenu \
     -i \
     -markup-rows \
     -icons \
     -p "󱂬 Keybinds" \
     -theme "$HOME/.config/rofi/launchers/type-2/style-2.rasi")


CMD=$(echo "$CHOICE" | sed -n "s/.*<span color='gray'>\(.*\)<\/span>.*/\1/p")

[[ -z $CMD ]] && exit 0

if [[ $CMD == exec* ]]; then
    eval "$CMD"
else
    hyprctl dispatch "$CMD"
fi

