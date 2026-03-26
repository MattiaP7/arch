#!/bin/bash

# Ottieni l'output pulito da wpctl
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | xargs)

# Estrai il volume (es. 0.65) e converti in intero (65)
vol_raw=$(echo "$output" | awk '{print $2}')
volume=$(python3 -c "print(round($vol_raw * 100))" 2>/dev/null || echo "$vol_raw" | cut -d. -f2 | sed 's/^0//')

# Se il volume è 0, lo forziamo a intero
[ -z "$volume" ] && volume=0

# Controllo Mute e Icone
if [[ "$output" == *"[MUTED]"* ]]; then
    icon="󰝟"
    text="Muted"
    class="muted"
else
    if [ "$volume" -lt 33 ]; then
        icon="󰕿"
        class="low"
    elif [ "$volume" -lt 66 ]; then
        icon="󰖀"
        class="medium"
    else
        icon="󰕾"
        class="high"
    fi
    text="$volume%"
fi

echo "{\"text\":\"$icon $text\", \"class\":\"$class\", \"tooltip\":\"Volume: $volume%\"}"
