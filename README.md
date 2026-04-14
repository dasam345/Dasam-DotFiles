# Dasam DotFiles

Personal Hyprland rice for Arch Linux.

> Oparte na [anom-dots](https://github.com/atif-1402/anom-dots) z własnymi modyfikacjami.

## Sprzęt

| Komponent | Model |
|-----------|-------|
| CPU | AMD Ryzen 9 7900X3D |
| GPU | AMD RX 9060 XT 16GB |
| Monitor | 1440p @ 165Hz |
| Dysk | 2TB (ext4) |

## Zrzuty ekranu

> _TODO: dodaj screenshoty_

## Instalacja

```bash
git clone https://github.com/dasam345/Dasam-DotFiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Co zawiera

| Komponent | Opis |
|-----------|------|
| **Hyprland** | Wayland compositor |
| **Waybar** | Pasek stanu (2 motywy: Material Pills / Minimal Bar) |
| **SwayNC** | Centrum powiadomień |
| **SwayOSD** | OSD dla głośności |
| **Oh My Zsh** | Shell z Powerlevel10k |
| **Fastfetch** | System info w terminalu |
| **Kitty** | Terminal GPU-accelerated |
| **Rofi** | Launcher + wallpaper picker + emoji/icon picker |
| **Matugen** | Generowanie kolorów z tapety |
| **swww** | Animowane tapety (GIF support) |
| **hyprlock** | Ekran blokady |
| **hypridle** | Auto-blokada po czasie nieaktywności |

## Skróty klawiszowe

**SUPER** = klawisz Windows

| Skrót | Akcja |
|-------|-------|
| `SUPER + ENTER` | Terminal (kitty) |
| `SUPER + SPACE` | Launcher (rofi) |
| `SUPER + Q` | Zamknij okno |
| `SUPER + T` | Floating toggle |
| `SUPER + L` | Zablokuj ekran |
| `SUPER + X` | Wyloguj / wyłącz |
| `SUPER + E` | Menedżer plików (Dolphin) |
| `SUPER + B` | Firefox |
| `SUPER + D` | Discord |
| `SUPER + SHIFT + S` | Screenshot |
| `CTRL + SPACE` | Wybór tapety |
| `SUPER + SHIFT + W` | Zmień motyw Waybar |
| `SUPER + SHIFT + E` | Emoji picker |
| `SUPER + SHIFT + I` | Icon picker |
| `SUPER + 1-9` | Przełącz workspace |
| `SUPER + SHIFT + 1-9` | Przenieś okno do workspace |
| `SUPER + ALT + S` | Przenieś do scratchpad |
| XF86AudioRaiseVolume | Głośność + (OSD) |
| XF86AudioLowerVolume | Głośność - (OSD) |


## Problemy i rozwiązania

Jeśli napotkasz problemy po instalacji:

- **Oh My Zsh błąd**: Uruchom `git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh` i `git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k`
- **OSD głośności nie działa**: Sprawdź czy swayosd-server jest uruchomiony (`ps aux | grep swayosd`)
- **Powiadomienia nie działają**: Sprawdź konfigurację swaync i env XDG_DATA_DIRS
- **Wallpaper skrypt nie działa**: Upewnij się, że masz tapety w ~/Wallpapers i imagemagick zainstalowane
- **Menu dźwięku w Waybar**: Używa pulsemixer, zainstalowane automatycznie


## Kredyty

- [atif-1402/anom-dots](https://github.com/atif-1402/anom-dots) – baza konfiguracji
- [matugen](https://github.com/InioX/matugen) – dynamic color theming
