#!/bin/bash

if ! command -v bluetoothctl &> /dev/null; then
    echo "{\"text\":\"󰂲\", \"class\":\"error\", \"tooltip\":\"Bluetoothctl non trovato\"}"
    exit 1
fi

# Controlla se bluetooth è acceso
if bluetoothctl show | grep -q "Powered: yes"; then
    # Conta dispositivi connessi
    connected=$(bluetoothctl devices Connected | wc -l)
    
    if [ "$connected" -gt 0 ]; then
        # Prendi il nome del primo dispositivo connesso
        device_name=$(bluetoothctl devices Connected | head -n1 | cut -d' ' -f3-)
        echo "{\"text\":\" $connected\", \"class\":\"connected\", \"tooltip\":\"Connesso a: $device_name\"}"
    else
        echo "{\"text\":\"󰂯\", \"class\":\"disconnected\", \"tooltip\":\"Bluetooth acceso, nessun dispositivo\"}"
    fi
else
    echo "{\"text\":\"󰂲\", \"class\":\"disabled\", \"tooltip\":\"Bluetooth disabilitato\"}"
fi

