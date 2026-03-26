#!/bin/bash

CONF="$HOME/.config/hypr/bind.conf"
CACHE="$HOME/.cache/hypr-binds.txt"
CACHE_TIME=5

mkdir -p ~/.cache

is_cache_valid() {
  [ -f "$CACHE" ] && \
  [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -lt $CACHE_TIME ]
}

build_cache() {
  awk -F',' '
  function trim(s) {
    gsub(/^[ \t]+|[ \t]+$/, "", s)
    return s
  }

  /^bind/ {
    raw=$0

    label=""
    if (match(raw, /#(.*)/, m)) {
      label=trim(m[1])
    }

    sub(/#.*/, "", raw)

    n=split(raw, f, ",")

    mod=trim(f[1])
    key=trim(f[2])
    action=trim(f[3])

    sub(/bind[mel]* *= */, "", mod)

    combo=mod " + " key
    gsub(/ +/, " ", combo)

    if (label == "") {
      label = action
    }

    # --- ICONE ---
    icon=" "
    if (label ~ /Terminal/i) icon=" "
    else if (label ~ /Browser/i) icon=" "
    else if (label ~ /File/i) icon=" "
    else if (label ~ /Workspace/i) icon=" "
    else if (label ~ /Volume|Audio/i) icon=" "
    else if (label ~ /Brightness/i) icon=" "
    else if (label ~ /Lock/i) icon=" "
    else if (label ~ /Screenshot/i) icon=" "

    # --- OUTPUT STILE WALKER ---
    printf "%s  %s  [%s]\n", icon, label, combo
  }
  ' "$CONF" | sort -u > "$CACHE"
}

if ! is_cache_valid; then
  build_cache
fi

# --- UI WALKER ---
if command -v walker >/dev/null; then
  monitor_height=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .height')
  menu_height=$((monitor_height * 40 / 100))


  cat "$CACHE" | walker \
    --dmenu \
    -p "󱂬 Keybinds" \
    --width 700 \
    --height "$menu_height"
else
  cat "$CACHE" | rofi -dmenu -i -p "󱂬 Keybinds"
fi
