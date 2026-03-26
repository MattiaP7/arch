#!/bin/bash

# fermo in caso di errore
set -e

# resolving network error like dns, dhcp, ...
# connect to wifi/ethernet before...
sudo systemctl enable --now systemd-resolved
sudo systemctl enable --now NetworkManager

# create symbolick link for dns
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# i personally use iwd...
sudo mkdir -p /etc/NetworkManager/conf.d/
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf
sudo systemctl restart NetworkManager

# aggiorno
# sudo pacman -Syu

# installo yay
if ! command -v yay &> /dev/null; then
  echo "Yay not found. Installing yay..."
  git clone https://aur.archlinux.org/yay.git ~/yay
  cd yay
  makepkg -si
  cd ..
  rm -rf yay
else
  echo "Yay already installed..."
fi

# useful package
PKGS=(
  "hyprland"
  "waybar"
  "kitty"
  "rofi"
  "wofi"
  "swww"
  "ttf-jetbrains-mono-nerd"
  "git"
  "base-devel"
  "gcc"
  "clang"
  "unzip"
  "nodejs"
  "npm"
  "neovim"
  "networkmanager"
  "kitty"
  "zsh"
  "brightnessctl"
  "greetd"
  "greetd-tuigreet"
)

sudo pacman -S --needed "${PKGS[@]}"
yay -S xdg-user-dirs nwg-look ags-hyprpanel-git
xdg-user-dirs-update

swww-daemon & disown

