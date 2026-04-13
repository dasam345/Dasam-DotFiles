#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║         Dasam DotFiles – Installer dla Arch Linux            ║
# ║         Sprzęt: R9 7900X3D + RX 9060 XT + 1440p 165Hz       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
header()  { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN} $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ────────────────────────────────────────────────────────────────
header "1. Aktualizacja systemu"
sudo pacman -Syu --noconfirm
success "System zaktualizowany"

# ────────────────────────────────────────────────────────────────
header "2. Instalacja yay (AUR helper)"
if ! command -v yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    success "yay zainstalowany"
else
    success "yay już zainstalowany"
fi

# ────────────────────────────────────────────────────────────────
header "3. Włączanie multilib (wymagane dla lib32-*)"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    info "Włączanie multilib..."
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    success "multilib włączony"
else
    success "multilib już włączony"
fi

# ────────────────────────────────────────────────────────────────
header "4. Hyprland core"
sudo pacman -S --noconfirm --needed \
    hyprland \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    polkit-gnome \
    qt5-wayland \
    qt6-wayland
success "Hyprland core OK"

# ────────────────────────────────────────────────────────────────
header "5. Terminal i shell"
sudo pacman -S --noconfirm --needed \
    kitty \
    zsh \
    zsh-completions \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    starship

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Ustawianie zsh jako domyślny shell..."
    chsh -s "$(which zsh)"
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Instalacja Oh My Zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
fi

success "Terminal/shell OK"

# ────────────────────────────────────────────────────────────────
header "6. Audio (Pipewire)"
sudo pacman -S --noconfirm --needed \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    wireplumber \
    pamixer \
    playerctl \
    pavucontrol

systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
success "Audio OK"

# ────────────────────────────────────────────────────────────────
header "7. Screenshot / nagrywanie"
sudo pacman -S --noconfirm --needed \
    grim \
    slurp \
    wl-clipboard \
    wf-recorder
success "Capture tools OK"

# ────────────────────────────────────────────────────────────────
header "8. AMD GPU sterowniki (RX 9060 XT)"
# UWAGA: mesa-vdpau NIE jest osobnym pakietem – jest częścią mesa
# lib32-libva-mesa-driver dostarcza VA-API dla 32bit (Steam)
sudo pacman -S --noconfirm --needed \
    mesa \
    vulkan-radeon \
    libva-mesa-driver \
    lib32-mesa \
    lib32-vulkan-radeon \
    lib32-libva-mesa-driver \
    vulkan-tools
success "AMD GPU OK"

# ────────────────────────────────────────────────────────────────
header "9. Waybar"
sudo pacman -S --noconfirm --needed waybar
success "Waybar OK"

# ────────────────────────────────────────────────────────────────
header "10. Czcionki"
sudo pacman -S --noconfirm --needed \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    ttf-font-awesome
success "Czcionki OK"

# ────────────────────────────────────────────────────────────────
header "11. Narzędzia systemowe"
sudo pacman -S --noconfirm --needed \
    nautilus \
    firefox \
    steam \
    brightnessctl \
    network-manager-applet \
    blueman \
    fastfetch \
    qt5ct \
    qt6ct \
    xdg-utils \
    udiskie \
    ntfs-3g \
    htop \
    imagemagick \
    pulsemixer \
    pavucontrol \
    dconf \
    go
success "Narzędzia systemowe OK"

# ────────────────────────────────────────────────────────────────
header "12. greetd – autologin (zastępuje SDDM/GDM)"
sudo pacman -S --noconfirm --needed greetd

CURRENT_USER=$(whoami)
info "Konfigurowanie autologin dla: $CURRENT_USER"

# Tworzymy konfig
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null << EOF
[terminal]
vt = 1

[default_session]
command = "agreety --cmd Hyprland"
user = "greeter"

[initial_session]
command = "Hyprland"
user = "$CURRENT_USER"
EOF

# KLUCZOWA ZMIANA: Najpierw wywalamy stare managery, potem wymuszamy greetd
info "Usuwanie konfliktów display managerów..."
sudo systemctl disable sddm gdm lightdm ly 2>/dev/null || true

# Używamy --force, żeby nadpisać symlink /etc/systemd/system/display-manager.service
sudo systemctl enable --force greetd

success "greetd autologin skonfigurowany"
# ────────────────────────────────────────────────────────────────
header "13. Pakiety AUR"
# nwg-look, swww, swaync, swayosd, rofi-wayland, wlogout, matugen, discord – wszystkie AUR
yay -S --noconfirm --needed \
    swww \
    swaync \
    swayosd \
    rofi-wayland \
    wlogout \
    matugen \
    nwg-look \
    discord
success "AUR OK"

# ────────────────────────────────────────────────────────────────
header "14. Kopiowanie dotfiles"
info "Kopiowanie konfiguracji..."

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$HOME/.config/hypr" ]; then
    warn "Backup istniejącego .config → $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for dir in hypr waybar rofi swaync kitty; do
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/" 2>/dev/null || true
    done
fi

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/.local/share/rofi/themes"

cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
cp -r "$DOTFILES_DIR/.local/"*  "$HOME/.local/"

[ -f "$DOTFILES_DIR/.zshrc" ]  && cp "$DOTFILES_DIR/.zshrc"  "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.rec.sh" ] && cp "$DOTFILES_DIR/.rec.sh" "$HOME/.rec.sh"

# Utwórz katalog na tapety
mkdir -p "$HOME/Wallpapers"

success "Dotfiles skopiowane"

# ────────────────────────────────────────────────────────────────
header "15. chmod +x dla wszystkich skryptów .sh"
info "Nadawanie uprawnień wykonywalnych..."

# Globalnie – każdy .sh w .config i .local
find "$HOME/.config" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.local"  -name "*.sh" -exec chmod +x {} \;
[ -f "$HOME/.rec.sh" ] && chmod +x "$HOME/.rec.sh"

# Dodatkowo explicite każdy znany skrypt
SCRIPTS=(
    "$HOME/.config/hypr/scripts/osd.sh"
    "$HOME/.config/hypr/scripts/screenshot.sh"
    "$HOME/.config/hypr/scripts/colorpick.sh"
    "$HOME/.config/hypr/scripts/screenrec.sh"
    "$HOME/.config/hypr/scripts/mpris_osd.sh"
    "$HOME/.config/hypr/lockscripts/mpris.sh"
    "$HOME/.config/waybar/scripts/reloadwb.sh"
    "$HOME/.config/rofi/scripts/wallpaper.sh"
    "$HOME/.config/rofi/scripts/wbswitcher.sh"
    "$HOME/.config/rofi/scripts/emoji-picker.sh"
    "$HOME/.config/rofi/scripts/icon-picker.sh"
    "$HOME/.config/rofi/scripts/menu.sh"
    "$HOME/.config/rofi/scripts/about.sh"
    "$HOME/.config/rofi/scripts/genrate-icons.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        success "chmod +x $(basename "$script")"
    else
        warn "Nie znaleziono: $script"
    fi
done

# ────────────────────────────────────────────────────────────────
header "16. Odświeżanie cache czcionek"
fc-cache -fv &>/dev/null
success "Cache czcionek odświeżony"

# ────────────────────────────────────────────────────────────────
header "17. Info o montowaniu NTFS"
warn "Jeśli chcesz auto-mount dysku NTFS, dodaj do /etc/fstab:"
echo "  UUID=<twoje_UUID>  /mnt/windows  ntfs-3g  uid=$(id -u),gid=$(id -g),defaults  0  0"
echo "  Znajdź UUID: sudo blkid | grep ntfs"

# ────────────────────────────────────────────────────────────────
header "✅ Gotowe!"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Dotfiles zainstalowane pomyślnie!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Następne kroki:${NC}"
echo "  1. reboot"
echo "  2. Hyprland wystartuje automatycznie"
echo "  3. hyprlock pojawi się od razu (wpisz hasło)"
echo "  4. CTRL+SPACE → wybierz tapetę"
echo "  5. matugen image ~/tapeta.jpg → wygeneruj kolory"
echo "  6. SUPER+SHIFT+W → zmień motyw Waybar"
echo ""
echo -e "${YELLOW}Skróty:${NC}"
echo "  SUPER+ENTER  → kitty"
echo "  SUPER+SPACE  → rofi"
echo "  SUPER+Q      → zamknij okno"
echo "  SUPER+L      → hyprlock"
echo "  SUPER+X      → wlogout"
echo "  SUPER+PRINT  → screenshot"
echo "  CTRL+SPACE   → tapeta"
echo ""
