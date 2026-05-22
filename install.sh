#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║         Dasam DotFiles – Interactive Installer               ║
# ║         for Arch Linux (Hyprland rice)                       ║
# ╚══════════════════════════════════════════════════════════════╝

set -o pipefail

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

LOG_FILE="/tmp/dotfiles-install-$(date +%Y%m%d-%H%M%S).log"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }
info()    { local m="$1"; echo -e "${BLUE}[INFO]${NC} $m"; log "INFO  $m"; }
success() { local m="$1"; echo -e "${GREEN}[OK]${NC}   $m"; log "OK    $m"; }
warn()    { local m="$1"; echo -e "${YELLOW}[WARN]${NC} $m"; log "WARN  $m"; }
header()  { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN} $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; log "===== $1 ====="; }
banner()  { echo -e "${CYAN}$1${NC}"; log "$1"; }

# ── Read input with default ───────────────────────────────────
prompt_with_default() {
    local prompt="$1" default="$2"
    local input
    read -p "$(echo -e "${BOLD}${prompt}${NC} [${default}]: ")" input
    echo "${input:-$default}"
}

prompt_yes_no() {
    local prompt="$1" default="${2:-y}"
    local input
    read -p "$(echo -e "${BOLD}${prompt}${NC} (Y/n): ")" input
    input="${input:-$default}"
    [[ "$input" =~ ^[Yy]$ ]]
}

prompt_choice() {
    local prompt="$1" default="$2" min="$3" max="$4"
    local input
    read -p "$(echo -e "${BOLD}${prompt}${NC} [${default}]: ")" input
    input="${input:-$default}"
    if [[ "$input" -ge "$min" ]] && [[ "$input" -le "$max" ]] 2>/dev/null; then
        echo "$input"
    else
        echo "$default"
    fi
}

# ── Config file ───────────────────────────────────────────────
CONFIG_FILE="$HOME/.config/dotfiles-setup.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    info "Loading existing configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
    HAS_EXISTING_CONFIG=true
else
    HAS_EXISTING_CONFIG=false
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ═══════════════════════════════════════════════════════════════
header "WELCOME TO DASAM DOTFILES"
header "Interactive Hyprland installer for Arch Linux"
echo ""
banner "This installer will guide you through setting up:"
banner "  • Hyprland (Wayland compositor)"
banner "  • Waybar (status bar) with system resource monitor"
banner "  • Rofi (app launcher & wallpaper picker)"
banner "  • Kitty terminal, SwayNC notifications, and more"
echo ""
banner "3 installation modes available:"
banner "  MINIMAL  – Core Hyprland + essentials (quick setup)"
banner "  STANDARD – Interactive, most features (recommended)"
banner "  FULL     – Everything: gaming, dev tools, security"
echo ""

# ══════════════════════════════════════════════════════════════
header "INSTALLATION MODE"
# ══════════════════════════════════════════════════════════════
echo ""
info "MINIMAL  – Hyprland, waybar, kitty, rofi, basic tools"
info "           Good for quick setup or minimal systems."
echo ""
info "STANDARD – Interactive prompts for most features."
info "           Extra apps, browser choice, resource monitor."
echo ""
info "FULL     – Everything from Standard plus:"
info "           Gaming (lutris, gamemode, mangohud)"
info "           Dev tools (neovim, docker, github-cli)"
info "           Security (ufw, keepassxc, syncthing)"
echo ""

if [[ -z "$INSTALL_MODE" ]]; then
    echo "  1) Minimal"
    echo "  2) Standard"
    echo "  3) Full"
    INSTALL_MODE=$(prompt_choice "Select installation mode" 2 1 3)
fi

header "GPU SELECTION"
echo ""
info "Select your graphics card brand."
info "NVIDIA is excluded – known issues with Hyprland."
echo ""
echo "  1) AMD (recommended)"
echo "  2) Intel"
if [[ -z "$GPU" ]]; then
    GPU=$(prompt_choice "Select GPU" 1 1 2)
fi
case $GPU in
    1) GPU_VAR="amd"; GPU_PACKAGES="mesa vulkan-radeon libva-mesa-driver lib32-mesa lib32-vulkan-radeon lib32-libva-mesa-driver vulkan-tools";;
    2) GPU_VAR="intel"; GPU_PACKAGES="mesa vulkan-intel intel-media-driver lib32-mesa lib32-vulkan-intel";;
esac

header "BROWSER SELECTION"
echo ""
info "Choose your default web browser."
info "Opens with SUPER+B keybind."
echo ""
echo "  1)  firefox       – Mozilla Firefox, most compatible"
echo "  2)  zen-browser   – Firefox-based, privacy-focused"
echo "  3)  google-chrome – Google Chrome (AUR)"
echo "  4)  chromium      – Open-source Chrome"
echo "  5)  brave-browser – Built-in adblocker (AUR)"
echo "  6)  librewolf     – Hardened Firefox (AUR)"
echo "  7)  vivaldi       – Highly customizable (AUR)"
echo "  8)  floorp        – Firefox-based, Japanese (AUR)"
echo "  9)  waterfox      – Firefox-based, 64-bit only (AUR)"
echo "  10) tor-browser   – Anonymous browsing (AUR)"
echo ""
if [[ -z "$BROWSER" ]]; then
    BROWSER=$(prompt_choice "Select browser" 1 1 10)
fi
BROWSER_NAMES=("firefox" "zen-browser" "google-chrome" "chromium" "brave-browser" "librewolf" "vivaldi" "floorp" "waterfox" "tor-browser")
BROWSER_AUR=(false true true false true true true true true true)
BROWSER_PKG=${BROWSER_NAMES[$((BROWSER-1))]}
BROWSER_BIN=$BROWSER_PKG
BROWSER_IS_AUR=${BROWSER_AUR[$((BROWSER-1))]}
[[ "$BROWSER_IS_AUR" == "true" ]] && BROWSER_PKG="${BROWSER_PKG}-bin"
[[ "$BROWSER_PKG" == "firefox" ]] && BROWSER_PKG="firefox"

# ── Auto-detect monitor ────────────────────────────────────
if [[ -z "$RES_STR" ]] && [[ -z "$MONITOR_REFRESH" ]]; then
    for d in /sys/class/drm/card*-*; do
        [[ ! -f "$d/status" ]] && continue
        [[ "$(< "$d/status")" != "connected" ]] && continue
        mode=$(head -1 "$d/modes" 2>/dev/null)
        [[ -z "$mode" ]] && continue
        RES_STR="${mode%@*}"
        if command -v edid-decode &>/dev/null && [[ -s "$d/edid" ]]; then
            MONITOR_REFRESH=$(cat "$d/edid" | edid-decode 2>/dev/null | sed -n '/Vert frequency/s/[^0-9]//gp' | head -1)
        fi
        break
    done
fi

header "MONITOR SETUP"
echo ""
if [[ -n "$RES_STR" ]] && [[ -z "$MONITOR_RES" ]]; then
    info "Detected monitor: ${RES_STR} @ ${MONITOR_REFRESH:-?} Hz"
    if ! prompt_yes_no "Is this correct?"; then
        RES_STR=""
        MONITOR_REFRESH=""
    fi
fi
if [[ -z "$RES_STR" ]]; then
    info "Select your monitor's native resolution."
    echo ""
    if [[ -z "$MONITOR_RES" ]]; then
        echo "  1) 1920x1080  (Full HD)"
        echo "  2) 2560x1440  (QHD, recommended)"
        echo "  3) 3840x2160  (4K UHD)"
        echo "  4) 1920x1200  (WUXGA, common on laptops)"
        echo "  5) 2560x1600  (WQXGA, common on laptops)"
        echo "  6) Custom"
        MONITOR_RES=$(prompt_choice "Select resolution" 2 1 6)
    fi
    case $MONITOR_RES in
        1) RES_STR="1920x1080";;
        2) RES_STR="2560x1440";;
        3) RES_STR="3840x2160";;
        4) RES_STR="1920x1200";;
        5) RES_STR="2560x1600";;
        6) RES_STR=$(prompt_with_default "Enter custom resolution (e.g. 3440x1440)" "2560x1440");;
    esac
fi

if [[ -z "$MONITOR_REFRESH" ]]; then
    MONITOR_REFRESH=$(prompt_with_default "Enter your monitor refresh rate in Hz" "60")
fi

header "KEYBOARD & LANGUAGE"
echo ""
info "Select your keyboard layout."
echo ""
if [[ -z "$KB_LAYOUT" ]]; then
    echo "  1) pl  (Polish)"
    echo "  2) us  (US English)"
    echo "  3) de  (German)"
    echo "  4) fr  (French)"
    echo "  5) es  (Spanish)"
    echo "  6) Custom"
    KB_LAYOUT=$(prompt_choice "Select layout" 1 1 6)
fi
KB_LAYOUTS=("pl" "us" "de" "fr" "es")
[[ "$KB_LAYOUT" -le 5 ]] && KB_STR="${KB_LAYOUTS[$((KB_LAYOUT-1))]}" || KB_STR=$(prompt_with_default "Enter custom layout code" "us")

if [[ -z "$TIMEZONE" ]]; then
    header "TIMEZONE"
    echo ""
    info "Select your timezone for correct clock display."
    echo ""
    echo "  1) Europe/Warsaw"
    echo "  2) Europe/Berlin"
    echo "  3) Europe/London"
    echo "  4) US/Eastern"
    echo "  5) US/Pacific"
    echo "  6) Custom"
    echo ""
    TZ_CHOICE=$(prompt_choice "Select timezone" 1 1 6)
    TZ_NAMES=("Europe/Warsaw" "Europe/Berlin" "Europe/London" "US/Eastern" "US/Pacific")
    [[ "$TZ_CHOICE" -le 5 ]] && TZ_STR="${TZ_NAMES[$((TZ_CHOICE-1))]}" || TZ_STR=$(prompt_with_default "Enter your timezone (e.g. Asia/Tokyo)" "Europe/Warsaw")
else
    TZ_STR="$TIMEZONE"
fi

header "WAYBAR CUSTOMIZATION"
echo ""
info "Waybar shows a pill with your name/alias at the top-left."
info "This is purely cosmetic and can be changed later."
echo ""
if [[ -z "$WAYBAR_NICKNAME" ]]; then
    WAYBAR_NICKNAME=$(prompt_with_default "Enter your Waybar nickname" "Dasam")
fi

echo ""
info "Choose how time is displayed in Waybar."
echo ""
if [[ -z "$TIME_FORMAT" ]]; then
    echo "  1) 24-hour format  (e.g. 14:30)"
    echo "  2) 12-hour format  (e.g. 02:30 PM)"
    TIME_FORMAT=$(prompt_choice "Select time format" 1 1 2)
fi

header "RESOURCE MONITOR"
echo ""
info "Choose a system monitor app (opens with SUPER+R)."
echo ""
echo "  1) btop           – Modern TUI, C++, lightweight"
echo "  2) htop           – Classic process viewer"
echo "  3) mission-center – GTK4 graphical (AUR)"
echo ""
if [[ -z "$RESOURCE_MONITOR" ]]; then
    RESOURCE_MONITOR=$(prompt_choice "Select resource monitor" 1 1 3)
fi
case $RESOURCE_MONITOR in
    1) RM_PKG="btop"; RM_CMD="btop";;
    2) RM_PKG="htop"; RM_CMD="htop";;
    3) RM_PKG="mission-center"; RM_CMD="mission-center";;
esac

# ── Standard / Full only sections ─────────────────────────────
EXTRA_APPS=()
GAMING_APPS=()
DEV_APPS=()
SEC_APPS=()

if [[ "$INSTALL_MODE" -ge 2 ]]; then
    header "EXTRA APPLICATIONS"
    echo ""
    info="Select additional apps to install."
    info="Use Y/n for each."
    echo ""
    banner "Media & Daily Use:"
    prompt_add_app() {
        local pkg="$1" desc="$2" var_name="$3"
        if prompt_yes_no "  Install $pkg? ($desc)" n; then
            eval "$var_name+=('$pkg')"
        fi
    }
    prompt_add_app "mpv" "Video player (used by celluloid)" EXTRA_APPS
    prompt_add_app "vlc" "Media player" EXTRA_APPS
    prompt_add_app "telegram-desktop" "Messenger" EXTRA_APPS
    prompt_add_app "obs-studio" "Screen recording / streaming" EXTRA_APPS
    prompt_add_app "gimp" "Image editor" EXTRA_APPS
    prompt_add_app "libreoffice-fresh" "Office suite" EXTRA_APPS
    prompt_add_app "thunderbird" "Email client" EXTRA_APPS
    prompt_add_app "handbrake" "Video converter" EXTRA_APPS
    prompt_add_app "virt-manager" "Virtual machine manager" EXTRA_APPS
    echo ""
    banner "AUR Apps (require yay):"
    prompt_add_app_aur() {
        local pkg="$1" desc="$2" var_name="$3"
        if prompt_yes_no "  Install $pkg? ($desc)" n; then
            eval "$var_name+=('AUR:$pkg')"
        fi
    }
    prompt_add_app_aur "visual-studio-code-bin" "VS Code editor" EXTRA_APPS
    prompt_add_app_aur "spotify" "Music streaming" EXTRA_APPS
    prompt_add_app_aur "localsend" "Local file sharing" EXTRA_APPS
    prompt_add_app_aur "bitwarden" "Password manager" EXTRA_APPS
    prompt_add_app_aur "stremio" "Streaming app" EXTRA_APPS
fi

if [[ "$INSTALL_MODE" -eq 3 ]]; then
    header "GAMING PACKAGES"
    echo ""
    info "Install gaming optimization tools?"
    echo ""
    prompt_add_app "lutris" "Game manager" GAMING_APPS
    prompt_add_app "steam" "Valve game store & launcher" GAMING_APPS
    prompt_add_app "gamemode" "CPU/GPU optimization for games" GAMING_APPS
    prompt_add_app "mangohud" "FPS/performance overlay" GAMING_APPS
    prompt_add_app_aur "gamescope" "Micro-compositor for games" GAMING_APPS
    prompt_add_app "wine" "Windows compatibility layer" GAMING_APPS
    prompt_add_app "winetricks" "Wine configuration tool" GAMING_APPS

    header "DEVELOPMENT TOOLS"
    echo ""
    prompt_add_app "neovim" "Modern terminal editor" DEV_APPS
    prompt_add_app "github-cli" "GitHub CLI (gh)" DEV_APPS
    prompt_add_app "nodejs" "JavaScript runtime + npm" DEV_APPS
    prompt_add_app "docker" "Container platform" DEV_APPS
    prompt_add_app "python-pip" "Python package manager" DEV_APPS

    header "SECURITY & BACKUP"
    echo ""
    prompt_add_app "ufw" "Firewall (uncomplicated)" SEC_APPS
    prompt_add_app_aur "keepassxc" "Password database" SEC_APPS
    prompt_add_app "syncthing" "File sync between devices" SEC_APPS
fi

# ══════════════════════════════════════════════════════════════
header "INSTALLATION SUMMARY"
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "  ${BOLD}Install mode:${NC}    $([ $INSTALL_MODE -eq 1 ] && echo "Minimal" || ([ $INSTALL_MODE -eq 2 ] && echo "Standard" || echo "Full"))"
echo -e "  ${BOLD}GPU:${NC}             $GPU_VAR"
echo -e "  ${BOLD}Browser:${NC}         ${BROWSER_PKG}"
echo -e "  ${BOLD}Monitor:${NC}         ${RES_STR} @ ${MONITOR_REFRESH}Hz"
echo -e "  ${BOLD}Keyboard:${NC}        $KB_STR"
echo -e "  ${BOLD}Timezone:${NC}        $TZ_STR"
echo -e "  ${BOLD}Waybar nickname:${NC} $WAYBAR_NICKNAME"
echo -e "  ${BOLD}Time format:${NC}     $([ $TIME_FORMAT -eq 1 ] && echo "24h" || echo "12h")"
echo -e "  ${BOLD}Resource monitor:${NC} $RM_PKG ($RM_CMD)"
echo -e "  ${BOLD}Extra apps:${NC}      ${EXTRA_APPS[*]:-(none selected)}"
echo -e "  ${BOLD}Gaming:${NC}          ${GAMING_APPS[*]:-(none selected)}"
echo -e "  ${BOLD}Dev tools:${NC}       ${DEV_APPS[*]:-(none selected)}"
echo -e "  ${BOLD}Security:${NC}        ${SEC_APPS[*]:-(none selected)}"
echo ""
if ! prompt_yes_no "Proceed with installation?"; then
    warn "Installation cancelled."
    exit 0
fi

# ══════════════════════════════════════════════════════════════
header "1. SAVING CONFIGURATION"
# ══════════════════════════════════════════════════════════════
mkdir -p "$HOME/.config"
cat > "$CONFIG_FILE" << CONFIGEOF
INSTALL_MODE=$INSTALL_MODE
GPU=$GPU
GPU_VAR=$GPU_VAR
BROWSER=$BROWSER
BROWSER_PKG=$BROWSER_PKG
MONITOR_RES=$MONITOR_RES
RES_STR=$RES_STR
MONITOR_REFRESH=$MONITOR_REFRESH
KB_LAYOUT=$KB_LAYOUT
KB_STR=$KB_STR
TIMEZONE=$TZ_STR
WAYBAR_NICKNAME=$WAYBAR_NICKNAME
TIME_FORMAT=$TIME_FORMAT
RESOURCE_MONITOR=$RESOURCE_MONITOR
RM_PKG=$RM_PKG
RM_CMD=$RM_CMD
CONFIGEOF
success "Configuration saved to $CONFIG_FILE"

# ══════════════════════════════════════════════════════════════
header "2. APPLYING CONFIGURATION TO DOTFILES"
# ══════════════════════════════════════════════════════════════
# Update hyprland.conf – monitor line
sed -i "s/^monitor = .*/monitor = , ${RES_STR}@${MONITOR_REFRESH}, auto, 1/" "$DOTFILES_DIR/.config/hypr/hyprland.conf"
# Update hyprland.conf – keyboard layout
sed -i "s/^    kb_layout = .*/    kb_layout = $KB_STR/" "$DOTFILES_DIR/.config/hypr/hyprland.conf"
# Update hyprland.conf – browser
sed -i "s|^\\\$browser = .*|\\\$browser = ${BROWSER_BIN}|" "$DOTFILES_DIR/.config/hypr/hyprland.conf"
# Update hyprland.conf – resource monitor
sed -i "s|^\\\$monitor = .*|\\\$monitor = ${RM_CMD}|" "$DOTFILES_DIR/.config/hypr/hyprland.conf"
# Update waybar time format
if [[ "$TIME_FORMAT" -eq 1 ]]; then
    sed -i 's|"format": "  {:%H:%M}"|"format": "  {:%H:%M}"|' "$DOTFILES_DIR/.config/waybar/config.jsonc"
    sed -i 's|"format": " {:%H:%M}"|"format": " {:%H:%M}"|' "$DOTFILES_DIR/.config/waybar/themes/Minimal Bar/config.jsonc" 2>/dev/null || true
else
    sed -i 's|"format": "  {:%H:%M}"|"format": "  {:%I:%M %p}"|' "$DOTFILES_DIR/.config/waybar/config.jsonc"
    sed -i 's|"format": " {:%H:%M}"|"format": " {:%I:%M %p}"|' "$DOTFILES_DIR/.config/waybar/themes/Minimal Bar/config.jsonc" 2>/dev/null || true
    sed -i 's|"format": "  {:%H:%M}"|"format": "  {:%I:%M %p}"|' "$DOTFILES_DIR/.config/waybar/themes/Material Pills/config.jsonc" 2>/dev/null || true
fi
success "Configuration applied to dotfiles"
success "Setting timezone to $TZ_STR..."
sudo timedatectl set-timezone "$TZ_STR" 2>/dev/null || warn "Could not set timezone (try manually: timedatectl set-timezone $TZ_STR)"

# ══════════════════════════════════════════════════════════════
header "3. SYSTEM UPDATE"
# ══════════════════════════════════════════════════════════════
info "Updating mirrorlist..."
sudo pacman -S --noconfirm --needed reflector 2>/dev/null || true
sudo reflector --country Poland --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist 2>/dev/null || true
sudo pacman -Syu --noconfirm || true
success "System updated"

# ══════════════════════════════════════════════════════════════
header "4. YAY (AUR HELPER)"
# ══════════════════════════════════════════════════════════════
if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    success "yay installed"
else
    success "yay already installed"
fi

# ══════════════════════════════════════════════════════════════
header "5. ENABLING MULTILIB"
# ══════════════════════════════════════════════════════════════
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    info "Enabling multilib..."
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
    success "multilib enabled"
else
    success "multilib already enabled"
fi

# ══════════════════════════════════════════════════════════════
header "6. INSTALLING PACKAGES"
# ══════════════════════════════════════════════════════════════

# ── Core Hyprland ──────────────────────────────────────────
info "Installing Hyprland core..."
sudo pacman -S --noconfirm --needed \
    hyprland hyprlock hypridle hyprpicker \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    polkit-gnome qt5-wayland qt6-wayland
success "Hyprland core"

# ── Terminal & Shell ───────────────────────────────────────
info "Installing terminal & shell..."
sudo pacman -S --noconfirm --needed \
    kitty zsh zsh-completions zsh-autosuggestions \
    zsh-syntax-highlighting starship
if [[ "$SHELL" != "$(which zsh)" ]]; then
    grep -qx "$(which zsh)" /etc/shells 2>/dev/null || echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null
    sudo chsh -s "$(which zsh)" "$USER" || warn "Could not change shell (run chsh manually)"
fi
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh + Powerlevel10k..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh --depth=1 2>/dev/null || true
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k 2>/dev/null || true
fi
success "Terminal & shell"

# ── GPU Drivers ────────────────────────────────────────────
info "Installing $GPU_VAR GPU drivers..."
sudo pacman -S --noconfirm --needed $GPU_PACKAGES
success "GPU drivers ($GPU_VAR)"

# ── Audio ──────────────────────────────────────────────────
info "Installing Pipewire audio..."
sudo pacman -S --noconfirm --needed \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    wireplumber pamixer playerctl pavucontrol pulsemixer
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
success "Audio"

# ── Capture Tools ─────────────────────────────────────────
sudo pacman -S --noconfirm --needed grim slurp wl-clipboard wf-recorder
success "Capture tools"

# ── Waybar ─────────────────────────────────────────────────
sudo pacman -S --noconfirm --needed waybar
success "Waybar"

# ── Fonts ──────────────────────────────────────────────────
sudo pacman -S --noconfirm --needed \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-font-awesome
success "Fonts"

# ── System Tools ───────────────────────────────────────────
sudo pacman -S --noconfirm --needed \
    dolphin brightnessctl \
    network-manager-applet blueman fastfetch \
    qt5ct qt6ct xdg-utils udiskie ntfs-3g \
    imagemagick dconf-cli go htop
success "System tools"

# ── Browser ────────────────────────────────────────────────
if [[ "$BROWSER_IS_AUR" == "true" ]]; then
    yay -S --noconfirm --needed "${BROWSER_PKG}"
else
    sudo pacman -S --noconfirm --needed "${BROWSER_PKG}"
fi
success "Browser ($BROWSER_PKG)"

# ── Resource Monitor ───────────────────────────────────────
if [[ "$RESOURCE_MONITOR" -eq 3 ]]; then
    yay -S --noconfirm --needed "$RM_PKG"
else
    sudo pacman -S --noconfirm --needed "$RM_PKG"
fi
success "Resource monitor ($RM_PKG)"

# ── Media apps (always installed) ──────────────────────────
sudo pacman -S --noconfirm --needed celluloid imv easyeffects
success "Media apps (celluloid, imv, easyeffects)"

# ── Extra Apps (Standard / Full) ───────────────────────────
PACMAN_APPS=()
AUR_APPS=()
for app in "${EXTRA_APPS[@]}"; do
    if [[ "$app" == AUR:* ]]; then
        AUR_APPS+=("${app#AUR:}")
    else
        PACMAN_APPS+=("$app")
    fi
done
if [[ ${#PACMAN_APPS[@]} -gt 0 ]]; then
    sudo pacman -S --noconfirm --needed "${PACMAN_APPS[@]}"
fi
if [[ ${#AUR_APPS[@]} -gt 0 ]]; then
    yay -S --noconfirm --needed "${AUR_APPS[@]}"
fi
success "Extra apps installed"

# ── Gaming (Full) ──────────────────────────────────────────
if [[ "$INSTALL_MODE" -eq 3 ]]; then
    GAME_PACMAN=()
    GAME_AUR=()
    for app in "${GAMING_APPS[@]}"; do
        [[ "$app" == AUR:* ]] && GAME_AUR+=("${app#AUR:}") || GAME_PACMAN+=("$app")
    done
    [[ ${#GAME_PACMAN[@]} -gt 0 ]] && sudo pacman -S --noconfirm --needed "${GAME_PACMAN[@]}"
    [[ ${#GAME_AUR[@]} -gt 0 ]] && yay -S --noconfirm --needed "${GAME_AUR[@]}"

    DEV_PACMAN=()
    for app in "${DEV_APPS[@]}"; do
        DEV_PACMAN+=("$app")
    done
    [[ ${#DEV_PACMAN[@]} -gt 0 ]] && sudo pacman -S --noconfirm --needed "${DEV_PACMAN[@]}"

    SEC_PACMAN=()
    SEC_AUR=()
    for app in "${SEC_APPS[@]}"; do
        [[ "$app" == AUR:* ]] && SEC_AUR+=("${app#AUR:}") || SEC_PACMAN+=("$app")
    done
    [[ ${#SEC_PACMAN[@]} -gt 0 ]] && sudo pacman -S --noconfirm --needed "${SEC_PACMAN[@]}"
    [[ ${#SEC_AUR[@]} -gt 0 ]] && yay -S --noconfirm --needed "${SEC_AUR[@]}"

    # Enable firewall if installed
    command -v ufw &>/dev/null && sudo systemctl enable --now ufw 2>/dev/null || true
    success "Gaming, Dev & Security packages"
fi

# ── Hyprland AUR extras ────────────────────────────────────
yay -S --noconfirm --needed \
    swaync swayosd rofi-wayland wlogout matugen nwg-look discord
success "AUR extras"

# ── greetd (autologin) ─────────────────────────────────────
sudo pacman -S --noconfirm --needed greetd
CURRENT_USER=$(whoami)
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml > /dev/null << GREETDEOF
[terminal]
vt = 1

[default_session]
command = "agreety --cmd Hyprland"
user = "greeter"

[initial_session]
command = "Hyprland"
user = "$CURRENT_USER"
GREETDEOF
sudo systemctl disable sddm gdm lightdm ly 2>/dev/null || true
sudo systemctl enable --force greetd
success "greetd autologin configured"

# ── swww ───────────────────────────────────────────────────
if command -v swww &>/dev/null; then
    success "swww already installed"
else
    info "Installing swww (wallpaper daemon)..."
    sudo pacman -S --noconfirm --needed \
        git rust wayland wayland-protocols libxkbcommon \
        pkgconf libevdev libdrm lz4
    rm -rf /tmp/swww
    git clone --depth=1 https://github.com/LGFae/swww.git /tmp/swww
    cd /tmp/swww
    cargo build --release
    sudo install -Dm755 target/release/swww /usr/local/bin/swww
    sudo install -Dm755 target/release/swww-daemon /usr/local/bin/swww-daemon
    cd "$DOTFILES_DIR"
    success "swww installed from source"
fi

# ══════════════════════════════════════════════════════════════
header "7. COPYING DOTFILES"
# ══════════════════════════════════════════════════════════════
info "Backing up existing config..."
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
if [[ -d "$HOME/.config/hypr" ]]; then
    warn "Existing config backed up to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for dir in hypr waybar rofi swaync kitty; do
        [[ -d "$HOME/.config/$dir" ]] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/" 2>/dev/null || true
    done
fi

mkdir -p "$HOME/.config" "$HOME/.local/share/fonts" "$HOME/.local/share/rofi/themes" "$HOME/Wallpapers"
cp -r "$DOTFILES_DIR/.config/"* "$HOME/.config/"
cp -r "$DOTFILES_DIR/.local/"*  "$HOME/.local/"
[[ -f "$DOTFILES_DIR/.zshrc" ]]  && cp "$DOTFILES_DIR/.zshrc"  "$HOME/.zshrc"
[[ -f "$DOTFILES_DIR/.rec.sh" ]] && cp "$DOTFILES_DIR/.rec.sh" "$HOME/.rec.sh"

# Set Waybar nickname in .zshrc
if ! grep -q "WAYBAR_NICKNAME" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Waybar nickname" >> "$HOME/.zshrc"
    echo "export WAYBAR_NICKNAME=\"$WAYBAR_NICKNAME\"" >> "$HOME/.zshrc"
fi
success "Dotfiles copied"

# ── Fix hardcoded paths for non-dasam users ─────────────────
if [[ "$USER" != "dasam" ]]; then
    info "Fixing hardcoded paths for user '$USER'..."
    sed -i "s|/home/dasam/|$HOME/|g" "$HOME/.config/rofi/config.rasi" 2>/dev/null || true
    sed -i "s|/home/dasam/|$HOME/|g" "$HOME/.config/matugen/config.toml" 2>/dev/null || true
    sed -i "s|/home/dasam/|$HOME/|g" "$HOME/.zshrc" 2>/dev/null || true
    success "Hardcoded paths updated"
fi

# ══════════════════════════════════════════════════════════════
header "8. SETTING EXECUTABLE PERMISSIONS"
# ══════════════════════════════════════════════════════════════
find "$HOME/.config" -name "*.sh" -exec chmod +x {} \;
find "$HOME/.local"  -name "*.sh" -exec chmod +x {} \;
[[ -f "$HOME/.rec.sh" ]] && chmod +x "$HOME/.rec.sh"

SCRIPTS=(
    "$HOME/.config/hypr/scripts/osd.sh"
    "$HOME/.config/hypr/scripts/screenshot.sh"
    "$HOME/.config/hypr/scripts/colorpick.sh"
    "$HOME/.config/hypr/scripts/screenrec.sh"
    "$HOME/.config/hypr/scripts/mpris_osd.sh"
    "$HOME/.config/hypr/scripts/keybinds.sh"
    "$HOME/.config/hypr/lockscripts/mpris.sh"
    "$HOME/.config/waybar/scripts/reloadwb.sh"
    "$HOME/.config/waybar/scripts/notification-status.sh"
    "$HOME/.config/waybar/scripts/resources.sh"
    "$HOME/.config/waybar/scripts/nickname.sh"
    "$HOME/.config/rofi/scripts/wallpaper.sh"
    "$HOME/.config/rofi/scripts/wbswitcher.sh"
    "$HOME/.config/rofi/scripts/emoji-picker.sh"
    "$HOME/.config/rofi/scripts/icon-picker.sh"
    "$HOME/.config/rofi/scripts/menu.sh"
    "$HOME/.config/rofi/scripts/about.sh"
    "$HOME/.config/rofi/scripts/genrate-icons.sh"
)
for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        chmod +x "$script"
    fi
done
success "Permissions set"

# ══════════════════════════════════════════════════════════════
header "9. FONT CACHE"
# ══════════════════════════════════════════════════════════════
fc-cache -fv &>/dev/null
success "Font cache refreshed"

# ══════════════════════════════════════════════════════════════
header "✅ INSTALLATION COMPLETE"
# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Dotfiles installed successfully!                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── Display keybinds ──────────────────────────────────────
header "📖 KEYBINDS (press SUPER+H anytime in Hyprland)"
echo ""
echo -e "  ${BOLD}Apps & Utils${NC}"
echo "    SUPER+RETURN  → kitty (terminal)"
echo "    SUPER+Q       → close window"
echo "    SUPER+B       → $BROWSER_BIN (browser)"
echo "    SUPER+E       → dolphin (file manager)"
echo "    SUPER+SPACE   → rofi (app launcher)"
echo "    SUPER+T       → toggle floating window"
echo "    SUPER+L       → lock screen"
echo "    SUPER+X       → logout/shutdown menu"
echo "    SUPER+R       → $RM_CMD (resource monitor)"
echo "    SUPER+H       → show this keybind help"
echo "    SUPER+D       → discord"
echo "    SUPER+M       → exit Hyprland"
echo ""
echo -e "  ${BOLD}Window Focus${NC}"
echo "    SUPER+arrows  → move focus"
echo ""
echo -e "  ${BOLD}Workspaces${NC}"
echo "    SUPER+1-9     → switch workspace"
echo "    SUPER+SHIFT+1-9 → move window to workspace"
echo "    SUPER+ALT+S   → move to scratchpad"
echo ""
echo -e "  ${BOLD}Rofi Scripts${NC}"
echo "    SUPER+SHIFT+E → emoji picker"
echo "    SUPER+SHIFT+I → icon picker"
echo "    ALT+SPACE     → wallpaper selector"
echo "    SUPER+SHIFT+W → switch waybar theme"
echo "    SUPER+ALT+SPACE → full menu"
echo ""
echo -e "  ${BOLD}Screenshot${NC}"
echo "    PRINT         → region screenshot (clipboard)"
echo "    SUPER+SHIFT+S → screenshot menu"
echo "    SHIFT+PRINT   → color picker"
echo ""
echo -e "  ${BOLD}Media${NC}"
echo "    XF86AudioPlay/Pause/Next → media controls"
echo "    XF86AudioRaise/Lower     → volume OSD"
echo ""
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. reboot"
echo "  2. Hyprland starts automatically (greetd autologin)"
echo "  3. Set wallpaper: CTRL+SPACE"
echo "  4. Generate colors: matugen image ~/wallpaper.jpg"
echo "  5. Change waybar theme: SUPER+SHIFT+W"
echo ""
echo -e "${YELLOW}Note:${NC} The keybind helper is also saved at:"
echo "       ~/.config/hypr/scripts/keybinds.sh"
echo "       Press SUPER+H in Hyprland to open it anytime."
echo ""
echo ""
echo -e "${YELLOW}Installation log:${NC}"
echo "       $LOG_FILE"
