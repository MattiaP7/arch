# Pirazzi's Dotfiles | Tokyo Night Edition

Benvenuto nei miei dotfiles! Questa è una configurazione completa per **Hyprland** basata sulla palette cromatica **Tokyo Night**. È pensata per essere minimale, veloce e produttiva.

---

## 🚀 Cosa include questo setup?

Il cuore del sistema è un mix di strumenti moderni e performanti:

| Componente | Strumento |
|---|---|
| Window Manager | Hyprland (Wayland) |
| Barra di stato | Waybar (Tokyo Night Theme) |
| Terminale | Kitty |
| Editor | Neovim (configurazione LazyVim style) |
| Launcher | Walker / Rofi |
| Notifiche | SwayNC |
| Shell | Zsh (con supporto alle icone Nerd Font) |

**Utility incluse:** Fastfetch, Btop, Yazi (file manager), Zoxide, Eza.

---

## 🛠️ Requisiti

Prima di lanciare lo script, assicurati di avere:

1. Arch Linux installato e funzionante.
2. Un utente con privilegi `sudo`.
3. Una connessione internet attiva.

> [!IMPORTANT]
> Lo script **non installa driver grafici**. Assicurati di aver installato i driver corretti per la tua GPU (Mesa per AMD/Intel, proprietari per NVIDIA) prima di avviare Hyprland.

---

## 📦 Installazione

È semplicissimo. Clona la cartella ed esegui lo script di installazione:

```bash
git clone https://github.com/tuo-username/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

### Cosa fa lo script?

1. **Network Check** — Abilita NetworkManager e `iwd` per il Wi-Fi.
2. **AUR Helper** — Installa `yay` se non presente.
3. **Pacchetti** — Scarica tutti i pacchetti necessari da Pacman e AUR.
4. **Symlink** — Collega le cartelle in `config/` alla tua `~/.config/` reale.
5. **Backup** — Se hai già delle configurazioni, crea un backup con estensione `.bak.[timestamp]`.
6. **Script** — Rende eseguibili automaticamente tutti gli script in `hypr/script/`.

---

## ⌨️ Shortcut Rapide (Keybinds)

| Shortcut | Azione |
|---|---|
| `SUPER + Q` | Apri Kitty (Terminale) |
| `SUPER + E` | Apri Dolphin/Nautilus (File Manager) |
| `SUPER + R` | App Launcher (Walker/Rofi) |
| `ALT + SHIFT` | Cambia layout tastiera (IT/US) |
| `SUPER + C` | Chiudi finestra attiva |

---

## ❓ Risoluzione Problemi (FAQ)

### 1. La password di `sudo` non viene accettata

Controlla il modulo **Language** sulla Waybar. Se vedi `US` e hai una tastiera italiana, i caratteri speciali potrebbero essere invertiti. Clicca sul modulo o usa `ALT+SHIFT` per tornare su `IT`.

### 2. Le icone non si vedono correttamente

Assicurati che i font siano stati installati. Lo script installa `ttf-jetbrains-mono-nerd`. Se persistono problemi, prova a pulire la cache dei font:

```bash
fc-cache -fv
```

### 3. Hyprland non parte o si blocca

Se hai una scheda **NVIDIA**, devi aggiungere i parametri del kernel necessari (`nvidia_drm.modeset=1`). Consulta la [Arch Wiki su Hyprland](https://wiki.archlinux.org/title/Hyprland) per i dettagli specifici.

### 4. Errore "target not found" durante l'installazione

Aggiorna i database di pacman e riprova:

```bash
sudo pacman -Syu
```

---

Spero che queste config ti piacciano! Se hai dubbi, apri una **Issue** o chiedimi direttamente. 🐧✨
