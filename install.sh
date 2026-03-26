#!/bin/bash

set -e

echo "🚀 Installing dotfiles..."

### ------------------------
### NETWORK FIX (opzionale)
### ------------------------
sudo systemctl enable --now systemd-resolved
sudo systemctl enable --now NetworkManager

sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

sudo mkdir -p /etc/NetworkManager/conf.d/
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf

sudo systemctl restart NetworkManager

### ------------------------
### INSTALL YAY
### ------------------------
if ! command -v yay &> /dev/null; then
  echo "📦 Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd ~
  rm -rf /tmp/yay
fi

### ------------------------
### PACMAN PACKAGES
### ------------------------
PKGS=(
  hyprland waybar kitty rofi swww
  ttf-jetbrains-mono-nerd
  git base-devel gcc clang unzip
  nodejs npm neovim
  networkmanager zsh brightnessctl
  greetd greetd-tuigreet
  wl-clipboard cliphist
  jq fzf ripgrep fd
)

echo "📦 Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

### ------------------------
### AUR PACKAGES
### ------------------------
AUR_PKGS=(
  nwg-look
  ags-hyprpanel-git
  walker-bin
)

echo "📦 Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

### ------------------------
### XDG DIRS
### ------------------------
xdg-user-dirs-update

### ------------------------
### SYMLINK DOTFILES
### ------------------------
echo "🔗 Linking config files..."

CONFIG_DIR="$HOME/dotfiles/config"

for dir in "$CONFIG_DIR"/*; do
  name=$(basename "$dir")
  target="$HOME/.config/$name"

  if [ -e "$target" ]; then
    echo "⚠️  $name exists, backing up..."
    mv "$target" "$target.bak.$(date +%s)"
  fi

  ln -s "$dir" "$target"
  echo "✅ Linked $name"
done

### ------------------------
### ENABLE SERVICES
### ------------------------
echo "Enabling services..."

systemctl --user enable --now pipewire wireplumber 2>/dev/null || true

### ------------------------
### WALLPAPER DAEMON
### ------------------------
pgrep swww-daemon >/dev/null || swww-daemon & disown

echo "✅ Setup complete!"
