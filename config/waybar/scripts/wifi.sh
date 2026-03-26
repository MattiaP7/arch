#!/bin/bash

if nmcli radio wifi | grep -q "enabled"; then
    if ssid=$(nmcli -t -f active,ssid dev wifi | grep "^yes" | cut -d: -f2); then
        echo "{\"text\":\"󰤨 $ssid\", \"class\":\"connected\", \"tooltip\":\"Connesso a $ssid\"}"
    else
        echo "{\"text\":\"󰤯\", \"class\":\"disconnected\", \"tooltip\":\"Nessuna connessione WiFi\"}"
    fi
else
    echo "{\"text\":\"󰤮\", \"class\":\"disabled\", \"tooltip\":\"WiFi disabilitato\"}"
fi
