# 🏔️ Dasam DotFiles

Personal Hyprland rice for Arch Linux — interactive installer, dynamic theming (Matugen), resource monitor, and a clean Waybar layout.

> Based on [anom-dots](https://github.com/atif-1402/anom-dots) with heavy modifications.

---

## 📦 Installation

```bash
git clone https://github.com/dasam345/Dasam-DotFiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The installer offers **3 modes** (Minimal / Standard / Full), 14 interactive prompts, automatic config generation, and saves your choices to `~/.config/dotfiles-setup.conf` for reuse.

---

## 🖥️ Hardware

| Component | Model |
|-----------|-------|
| CPU | AMD Ryzen 9 7900X3D |
| GPU | AMD RX 9060 XT 16GB |
| Monitor | 1440p @ 165Hz |
| Storage | 2TB (ext4) |

---

## 🧩 Components

| Component | Description |
|-----------|-------------|
| **Hyprland** | Wayland compositor |
| **Waybar** | Status bar (3 themes: default, Material Pills, Minimal Bar) |
| **SwayNC** | Notification center |
| **SwayOSD** | Volume OSD |
| **Oh My Zsh** | Shell with Powerlevel10k |
| **Fastfetch** | Terminal system info |
| **Kitty** | GPU-accelerated terminal |
| **Rofi** | Launcher + wallpaper picker + emoji/icon picker |
| **Matugen** | Dynamic color generation from wallpaper |
| **swww** | Animated wallpapers (GIF support) |
| **hyprlock** | Lock screen |
| **hypridle** | Auto-lock on idle |
| **btop** | Resource monitor (SUPER+R) |

---

## ⌨️ Keybinds

**SUPER** = <kbd>⊞ Win</kbd>

<details open>
<summary><b>🚀 Launchers & Apps</b></summary>

| Shortcut | Action |
|----------|--------|
| `SUPER + ENTER` | Terminal (kitty) |
| `SUPER + SPACE` | App launcher (rofi) |
| `SUPER + B` | Browser (configurable) |
| `SUPER + E` | File manager (Dolphin) |
| `SUPER + D` | Discord |
| `SUPER + R` | Resource monitor (btop) |
| `SUPER + H` | Keybind helper (rofi) |
</details>

<details open>
<summary><b>🪟 Window Management</b></summary>

| Shortcut | Action |
|----------|--------|
| `SUPER + Q` | Close window |
| `SUPER + T` | Toggle floating |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + V` | Toggle split |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + ALT + S` | Move to scratchpad |
| `SUPER + SHIFT + ←/→` | Move window left/right |
</details>

<details open>
<summary><b>🎨 UI & Appearance</b></summary>

| Shortcut | Action |
|----------|--------|
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + X` | Logout / power menu |
| `SUPER + SHIFT + S` | Screenshot |
| `SUPER + SHIFT + W` | Switch Waybar theme |
| `SUPER + SHIFT + E` | Emoji picker |
| `SUPER + SHIFT + I` | Icon picker |
| `CTRL + SPACE` | Wallpaper picker |
</details>

<details open>
<summary><b>🔊 Media & Hardware</b></summary>

| Shortcut | Action |
|----------|--------|
| `XF86AudioRaiseVolume` | Volume up (OSD) |
| `XF86AudioLowerVolume` | Volume down (OSD) |
| `XF86AudioMute` | Mute toggle |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
</details>

---

## 📊 Waybar Layout

```
┌──────────┬──────────────────────────────────────┬──────────────────────────────┐
│  Left    │              Center                  │          Right               │
├──────────┼──────────────────────────────────────┼──────────────────────────────┤
│   ☀️   │  14:30  [1] [2] [3]         │     45%   75%  󰤨    │
│ arch wea  │ clock   workspaces    notification  │ tray  res  audio  network     │
└──────────┴──────────────────────────────────────┴──────────────────────────────┘
```

**Features:**
- **Dynamic resource monitor** — CPU, RAM, GPU (bash-only, no `bc`/`fzf`/`eza`)
- **Weather** — auto-location via `wttr.in`, 30-min cache, Unicode emoji (`☀️ ⛅ ☁️ 🌧️`)
- **WiFi menu** — rofi-based `nmcli` frontend (connect + password prompt)
- **Keybind helper** — `SUPER+H` shows all keybinds parsed from `bindings.conf`
- **Mpris** — media player controls (Spotify, Firefox, mpv, etc.)

---

## 🛠️ Troubleshooting

<details>
<summary><b>Oh My Zsh not loaded</b></summary>

```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
```
</details>

<details>
<summary><b>Volume OSD not showing</b></summary>

Check if `swayosd-server` is running:
```bash
ps aux | grep swayosd
```
</details>

<details>
<summary><b>Notifications not working</b></summary>

Ensure `swaync` is running and `XDG_DATA_DIRS` includes the right paths. Restart with:
```bash
swaync --quit && swaync
```
</details>

<details>
<summary><b>Wallpaper picker fails</b></summary>

Make sure you have wallpapers in `~/Wallpapers` and `imagemagick` is installed.
</details>

<details>
<summary><b>Waybar doesn't match wallpaper colors</b></summary>

Run `matugen image ~/Wallpapers/your-wallpaper.jpg` to regenerate the color scheme, then `pkill -SIGUSR2 waybar`.
</details>

---

## 🙏 Credits

- [atif-1402/anom-dots](https://github.com/atif-1402/anom-dots) — base configuration
- [matugen](https://github.com/InioX/matugen) — dynamic color theming
- [wttr.in](https://wttr.in) — weather data
