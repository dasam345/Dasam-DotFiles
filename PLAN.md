# Dasam-DotFiles — Plan Implementacji

> Generated: 2026-05-21

## A. `install.sh` — Interactive English Installer

Each section has a description explaining what the option does.

| # | Section | Prompt | Options |
|---|---------|--------|---------|
| 1 | Install Mode | "How much do you want to install?" | Minimal / Standard / Full |
| 2 | GPU | "Select your graphics card brand" | AMD / Intel (NVIDIA excluded) |
| 3 | Browser | "Which web browser as default (SUPER+B)?" | firefox, zen-browser, google-chrome, chromium, brave-browser, librewolf, vivaldi, floorp, waterfox, tor-browser |
| 4 | Monitor Resolution | "Your monitor's native resolution" | 1920x1080 / 2560x1440 / 3840x2160 / 1920x1200 / 2560x1600 / Custom |
| 5 | Refresh Rate | "How many Hz does your monitor support?" | Default: 60 |
| 6 | Keyboard Layout | "Which keyboard layout?" | pl / us / de / fr / es / Custom |
| 7 | Timezone | "Pick your timezone for correct time" | Europe/Warsaw / Europe/Berlin / Europe/London / US/Eastern / US/Pacific / Custom |
| 8 | Waybar Nickname | "What name to show in the Waybar pill?" | Default: Dasam |
| 9 | Time Format | "How to display time in Waybar?" | 24h / 12h |
| 10 | Resource Monitor | "Which system monitor (SUPER+R)?" | btop / htop / mission-center |
| 11 | Extra Apps (Std+Full) | "Select additional apps" | checkbox: zen-browser, mpv, vlc, telegram-desktop, obs-studio, gimp, libreoffice, code, virt-manager, thunderbird, handbrake, spotify, localsend, bitwarden |
| 12 | Gaming (Full only) | "Gaming packages" | lutris, gamemode, mangohud, gamescope, wine, winetricks |
| 13 | Dev Tools (Full only) | "Development tools" | neovim, github-cli, nodejs+npm, docker, python-pip |
| 14 | Security (Full only) | "Security & backup" | ufw, keepassxc, syncthing |

## B. Config Generator

- Saves `~/.config/dotfiles-setup.conf` after installation
- Used to generate `hyprland.conf`, `waybar/config.jsonc`, and `bindings.conf`

## C. Waybar Resource Monitor Module

- New: `~/.config/waybar/scripts/resources.sh` (~35 lines)
  - Reads CPU% from /proc/stat
  - Reads RAM from /proc/meminfo
  - Reads GPU% from radeontop (AMD) or nvtop (Intel)
  - Returns JSON: `{"text":" 45%  8.2G","tooltip":"CPU: 45% | RAM: 8.2G/32G | GPU: 38%"}`
- Modified: `waybar/config.jsonc` + custom/resources in modules-right
- Modified: `waybar/style.css` + #custom-resources style
- Modified: Both theme configs

## D. Keybind Helper — SUPER+H

- New: `~/.config/hypr/scripts/keybinds.sh` (~40 lines)
  - Dynamically parses `bindings.conf`
  - Groups into categories (Apps, Workspace, Media, etc.)
  - Displays via rofi -dmenu with icons
- Keybind: `bind = $mainMod, H, exec, ~/.config/hypr/scripts/keybinds.sh`

## E. Post-Install Summary

Shows all keybinds grouped by category so the user knows how to use the system immediately.

## F. Files to Modify

1. `install.sh` — Full rewrite (~550 lines)
2. `.config/waybar/config.jsonc` — + custom/resources module
3. `.config/waybar/style.css` — + #custom-resources style
4. `.config/waybar/scripts/resources.sh` — NEW
5. `.config/waybar/themes/Material Pills/config.jsonc` — + resources
6. `.config/waybar/themes/Minimal Bar/config.jsonc` — + resources
7. `.config/hypr/hyprland.conf` — monitor line generated from config
8. `.config/hypr/bindings.conf` — + SUPER+B (dynamic), SUPER+R, SUPER+H
9. `.config/hypr/scripts/keybinds.sh` — NEW
10. `.config/rofi/wallpaper.rasi` — minor fixes if needed

## G. Already Installed

- celluloid (GTK4 mpv frontend)
- imv (image viewer)
- easyeffects (audio equalizer)

## H. Notes

- install.sh sources `dotfiles-setup.conf` on reinstall
- AUR packages marked; pacman and yay separated
- NVIDIA intentionally excluded
- keybinds.sh auto-updates when bindings.conf changes
