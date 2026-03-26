#!/bin/bash

# Percorso della batteria (cambia se necessario)
BAT_PATH="/sys/class/power_supply/BAT0"

if [ ! -d "$BAT_PATH" ]; then
    echo "{\"text\":\"󰂑\", \"class\":\"not-found\", \"tooltip\":\"Batteria non trovata\"}"
    exit 1
fi

# Leggi i valori
capacity=$(cat "$BAT_PATH/capacity")
status=$(cat "$BAT_PATH/status")

# Calcola tempo rimanente
if [ -f "$BAT_PATH/energy_now" ] && [ -f "$BAT_PATH/energy_full" ]; then
    energy_now=$(cat "$BAT_PATH/energy_now")
    energy_full=$(cat "$BAT_PATH/energy_full")
    power_now=$(cat "$BAT_PATH/power_now" 2>/dev/null || echo "0")
    
    if [ "$power_now" -gt 0 ] && [ "$status" = "Discharging" ]; then
        hours=$((energy_now / power_now))
        minutes=$(( (energy_now * 60 / power_now) % 60 ))
        time_remaining="${hours}h ${minutes}m"
    else
        time_remaining="in carica"
    fi
else
    time_remaining="n/a"
fi

# Icone in base alla percentuale e stato
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    icon="󰂄"
    class="charging"
elif [ "$capacity" -le 10 ]; then
    icon="󰂎"
    class="critical"
elif [ "$capacity" -le 20 ]; then
    icon="󰂎"
    class="warning"
elif [ "$capacity" -le 30 ]; then
    icon="󰁻"
    class="low"
elif [ "$capacity" -le 50 ]; then
    icon="󰁽"
    class="medium"
elif [ "$capacity" -le 80 ]; then
    icon="󰁿"
    class="high"
else
    icon="󰁹"
    class="full"
fi

# Output JSON
echo "{\"text\":\"$icon $capacity%\", \"class\":\"$class\", \"tooltip\":\"Batteria: $capacity%\\nStato: $status\\nTempo rimanente: $time_remaining\"}"
