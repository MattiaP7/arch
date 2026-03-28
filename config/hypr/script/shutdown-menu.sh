#!/bin/bash

choice=$(printf "⏻ Shutdown\n🔁 Reboot\n🚪 Logout\n❌ Cancel" | fzf)

case "$choice" in
  "⏻ Shutdown") systemctl poweroff ;;
  "🔁 Reboot") systemctl reboot ;;
  "🚪 Logout") hyprctl dispatch exit ;;
  *) exit ;;
esac
