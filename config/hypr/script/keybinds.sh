#!/bin/bash

hyprkeys -b -r -l -c ~/.config/hypr/bind.conf \
| sed -e 's/bind = //' \
      -e 's/, exec, / → /' \
| awk -F',' '{
    key=$1" + "$2
    cmd=$3

    gsub(/^ +| +$/, "", key)
    gsub(/^ +| +$/, "", cmd)

    icon=""
    if(cmd ~ /firefox|chrome/) icon=""
    else if(cmd ~ /thunar|nautilus/) icon=""
    else if(cmd ~ /code|nvim/) icon=""

    printf "%s  <b>%-18s</b>  <span color=\"#888\">%s</span>\n", icon, key, cmd
}' \
| rofi -dmenu -i -markup-rows -p "󱂬 Keybinds" \
  -theme "$HOME/.config/rofi/launchers/type-5/style-4.rasi"
