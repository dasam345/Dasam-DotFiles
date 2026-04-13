#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║         Dasam DotFiles – Installer dla Arch Linux            ║
# ║         Sprzęt: R9 7900X3D + RX 9060 XT + 1440p 165Hz       ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERR]${NC}  $1"; }
header()  { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN} $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ────────────────────────────────────────────────────────────────
header "1. Aktualizacja systemu"
# ────────────────────────────────────────────────────────────────
info "Aktualizowanie pakietów..."
sudo pacman -Syu --noconfirm
success "System zaktualizowany"

# ────────────────────────────────────────────────────────────────
header "2. Instalacja yay (AUR helper)"
# ────────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    info "Instalowanie yay..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    success "yay zainstalowany"
else
    success "yay już zainstalowany"
fi

# ────────────────────────────────────────────────────────────────
header "3. Pakiety Hyprland (core)"
# ────────────────────────────────────────────────────────────────
PKGS_CORE=(
    hyprland
    hyprlock
    hypridle
    hyprpicker
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-gnome
    qt5-wayland
    qt6-wayland
)

info "Instalowanie: core Hyprland..."
sudo pacman -S --noconfirm --needed "${PKGS_CORE[@]}"
success "Core OK"

# ────────────────────────────────────────────────────────────────
header "4. Pakiety UI / bar / notyfikacje"
# ────────────────────────────────────────────────────────────────
PKGS_UI=(
    waybar
)

info "Instalowanie: UI (pacman)..."
sudo pacman -S --noconfirm --needed "${PKGS_UI[@]}"
success "UI OK"

# ────────────────────────────────────────────────────────────────
header "5. Terminal i shell"
# ────────────────────────────────────────────────────────────────
PKGS_SHELL=(
    kitty
    zsh
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship         # prompt (opcjonalne)
)

info "Instalowanie: terminal/shell..."
sudo pacman -S --noconfirm --needed "${PKGS_SHELL[@]}"

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Ustawianie zsh jako domyślny shell..."
    chsh -s "$(which zsh)"
fi
success "Shell OK"

# ────────────────────────────────────────────────────────────────
header "6. Audio (Pipewire)"
# ────────────────────────────────────────────────────────────────
PKGS_AUDIO=(
    pipewire
    pipewire-pulse
    pipewire-alsa
    pipewire-jack
    wireplumber
    pamixer
    playerctl
    pavucontrol
)

info "Instalowanie: audio..."
sudo pacman -S --noconfirm --needed "${PKGS_AUDIO[@]}"
success "Audio OK"

# ────────────────────────────────────────────────────────────────
header "7. Screenshot / nagrywanie"
# ────────────────────────────────────────────────────────────────
PKGS_CAPTURE=(
    grim
    slurp
    wl-clipboard
    wf-recorder
)

info "Instalowanie: capture tools..."
sudo pacman -S --noconfirm --needed "${PKGS_CAPTURE[@]}"
success "Capture OK"

# ────────────────────────────────────────────────────────────────
header "8. AMD GPU – sterowniki (RX 9060 XT)"
# ────────────────────────────────────────────────────────────────
# Włącz multilib w pacman.conf (potrzebne dla lib32-*)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    info "Włączanie multilib w pacman.conf..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Sy
fi
# ────────────────────────────────────────────────────────────────
PKGS_AMD=(
    mesa
    vulkan-radeon
    libva-mesa-driver
    mesa-vdpau
    lib32-mesa               # dla Steam/Wine
    lib32-vulkan-radeon      # dla Steam/Wine
    vulkan-tools
)

info "Instalowanie: AMD GPU sterowniki..."
sudo pacman -S --noconfirm --needed "${PKGS_AMD[@]}"
success "AMD GPU OK"

# ────────────────────────────────────────────────────────────────
header "9. Czcionki"
# ────────────────────────────────────────────────────────────────
PKGS_FONTS=(
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    ttf-font-awesome
)

info "Instalowanie: czcionki..."
sudo pacman -S --noconfirm --needed "${PKGS_FONTS[@]}"
success "Czcionki OK"

# ────────────────────────────────────────────────────────────────
header "10. Narzędzia systemowe"
# ────────────────────────────────────────────────────────────────
PKGS_SYS=(
    nautilus          # file manager
    firefox
    brightnessctl     # jasność (dla laptopów; bezpieczne też na desktop)
    network-manager-applet
    blueman
    fastfetch
    nwg-look          # GTK theming dla Waylanda
    qt5ct
    qt6ct
    xdg-utils
    udiskie           # auto-mount USB
    ntfs-3g           # NTFS support (ważne dla ciebie!)
)

info "Instalowanie: narzędzia systemowe..."
sudo pacman -S --noconfirm --needed "${PKGS_SYS[@]}"
success "Narzędzia OK"

# ────────────────────────────────────────────────────────────────
header "11. Pakiety AUR"
# ────────────────────────────────────────────────────────────────
PKGS_AUR=(
    swww           # animowane tapety (AUR)
    swaync         # notification center (AUR)
    swayosd        # OSD głośności (AUR)
    rofi-wayland   # launcher (AUR)
    wlogout        # menu wylogowania (AUR)
    matugen        # generowanie kolorów z tapety (AUR)
    hyprshot       # screenshot tool (AUR)
    nwg-look       # GTK theming (AUR)
)

info "Instalowanie: pakiety AUR..."
yay -S --noconfirm --needed "${PKGS_AUR[@]}" || warn "Niektóre pakiety AUR mogły nie zainstalować się — sprawdź ręcznie"
success "AUR OK"

# ────────────────────────────────────────────────────────────────
header "12. Kopiowanie dotfiles"
# ────────────────────────────────────────────────────────────────
info "Kopiowanie konfiguracji..."

# Backup istniejących configów
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$HOME/.config/hypr" ]; then
    warn "Znaleziono istniejący ~/.config/hypr — backup → $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.config/hypr" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$HOME/.config/waybar" "$BACKUP_DIR/" 2>/dev/null || true
fi

# Kopiowanie .config
cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
success "Pliki .config skopiowane"

# Kopiowanie .local
cp -r "$DOTFILES_DIR/.local/"* "$HOME/.local/"
success "Pliki .local skopiowane"

# Kopiowanie plików z katalogu domowego
[ -f "$DOTFILES_DIR/.zshrc" ]   && cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"   && success ".zshrc"
[ -f "$DOTFILES_DIR/.rec.sh" ]  && cp "$DOTFILES_DIR/.rec.sh" "$HOME/.rec.sh" && success ".rec.sh"

# ────────────────────────────────────────────────────────────────
header "13. Uprawnienia do skryptów"
# ────────────────────────────────────────────────────────────────
info "Nadawanie uprawnień wykonywalnych..."
find "$HOME/.config/hypr/scripts" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/hypr/lockscripts" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/waybar/scripts" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.config/rofi/scripts" -name "*.sh" -exec chmod +x {} \;
[ -f "$HOME/.rec.sh" ] && chmod +x "$HOME/.rec.sh"
success "Uprawnienia nadane"

# ────────────────────────────────────────────────────────────────
header "14. Montowanie NTFS (fstab)"
# ────────────────────────────────────────────────────────────────
warn "Jeśli chcesz auto-mount dysku NTFS, dodaj do /etc/fstab:"
echo -e "  UUID=<twoje_UUID>  /mnt/windows  ntfs-3g  uid=\$(id -u),gid=\$(id -g),defaults  0  0"
echo -e "  Użyj: sudo blkid | grep ntfs   aby znaleźć UUID"

# ────────────────────────────────────────────────────────────────
header "15. greetd – autologin z hyprlock zamiast ekranu logowania"
# ────────────────────────────────────────────────────────────────
# Zamiast SDDM/GDM używamy greetd z autologinem.
# Hyprland startuje automatycznie, hyprlock pojawia się jako "ekran logowania".

if ! command -v greetd &>/dev/null; then
    info "Instalowanie greetd..."
    sudo pacman -S --noconfirm --needed greetd
fi

CURRENT_USER=$(whoami)

info "Konfigurowanie greetd autologin dla użytkownika: $CURRENT_USER"
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

sudo systemctl enable greetd
sudo systemctl disable sddm gdm lightdm ly 2>/dev/null || true

success "greetd skonfigurowany – autologin do Hyprland, hyprlock pojawia się przy starcie"
warn "Jeśli używałeś innego DM – sprawdź czy jest wyłączony: systemctl list-units --type=service | grep dm"
# ────────────────────────────────────────────────────────────────
info "Instalowanie PixelifySans z dotfiles..."
cp -r "$DOTFILES_DIR/.local/share/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null || true
fc-cache -fv &>/dev/null
success "Cache czcionek odświeżony"

# ────────────────────────────────────────────────────────────────
header "✅ Instalacja zakończona!"
# ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Dotfiles zainstalowane pomyślnie!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Następne kroki:${NC}"
echo "  1. Uruchom ponownie: reboot"
echo "  2. Zaloguj się do sesji Hyprland"
echo "  3. Ustaw tapetę: CTRL+SPACE"
echo "  4. Wygeneruj kolory matugenem: matugen image ~/ścieżka/do/tapety.jpg"
echo "  5. Przełącz motyw Waybar: SUPER+SHIFT+W"
echo ""
echo -e "${YELLOW}Skróty klawiszowe:${NC}"
echo "  SUPER+ENTER       → Terminal (kitty)"
echo "  SUPER+SPACE       → Launcher (rofi)"
echo "  SUPER+W           → Zamknij okno"
echo "  SUPER+L           → Zablokuj ekran"
echo "  SUPER+X           → Wyloguj/wyłącz"
echo "  SUPER+PRINT       → Screenshot"
echo "  CTRL+SPACE        → Wybór tapety"
echo ""
