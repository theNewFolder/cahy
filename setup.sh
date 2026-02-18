#!/usr/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  CachyOS Post-Nix Master Setup Script                       ║
# ║  Run: bash ~/cahy/setup.sh                                  ║
# ╚══════════════════════════════════════════════════════════════╝
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[-]${NC} $1"; }
step()  { echo -e "\n${YELLOW}══════ $1 ══════${NC}"; }

# ──────────────────────────────────────────────────────────────
step "1/8: Complete Nix Removal"
# ──────────────────────────────────────────────────────────────

# Stop nix services
info "Stopping nix services..."
sudo systemctl stop nix-daemon.service 2>/dev/null || true
sudo systemctl stop nix-daemon.socket 2>/dev/null || true
sudo systemctl stop determinate-nixd.socket 2>/dev/null || true
sudo systemctl disable nix-daemon.service 2>/dev/null || true
sudo systemctl disable nix-daemon.socket 2>/dev/null || true
sudo systemctl disable determinate-nixd.socket 2>/dev/null || true

# Remove systemd units
info "Removing systemd service files..."
sudo rm -f /etc/systemd/system/nix-daemon.service
sudo rm -f /etc/systemd/system/nix-daemon.socket
sudo rm -f /etc/systemd/system/determinate-nixd.socket
sudo systemctl daemon-reload

# Remove shell integration
info "Removing nix shell hooks..."
sudo rm -f /etc/fish/conf.d/nix.fish
sudo rm -f /etc/profile.d/nix.sh

# Clean /etc/bashrc nix lines
if grep -q 'nix-daemon.sh' /etc/bashrc 2>/dev/null; then
    info "Cleaning /etc/bashrc..."
    sudo sed -i '/# Nix/,/# End Nix/d' /etc/bashrc
fi

# Remove nix config
info "Removing /etc/nix/..."
sudo rm -rf /etc/nix

# Remove determinate-nixd binary
sudo rm -f /usr/local/bin/determinate-nixd

# Remove the entire nix store (THIS IS THE BIG ONE)
info "Removing /nix/ (this may take a while)..."
sudo rm -rf /nix

# Remove user nix artifacts
info "Cleaning user nix files..."
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
rm -rf ~/.local/state/nix
rm -rf ~/.config/nix
rm -rf ~/.config/direnv/lib/hm-nix-direnv.sh
rm -rf ~/.config/environment.d/10-home-manager.conf

# Remove nixbld users and group
info "Removing nixbld users..."
for i in $(seq 1 32); do
    sudo userdel "nixbld${i}" 2>/dev/null || true
done
sudo groupdel nixbld 2>/dev/null || true

info "Nix completely removed!"

# ──────────────────────────────────────────────────────────────
step "2/8: Install System Packages"
# ──────────────────────────────────────────────────────────────

info "Installing packages from official repos..."
sudo pacman -S --needed --noconfirm \
    zoxide starship direnv \
    wdisplays bluetui \
    zsa-udev \
    imagemagick \
    asusctl rog-control-center power-profiles-daemon \
    nvidia-utils lib32-nvidia-utils \
    fontconfig freetype2 \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    ttf-jetbrains-mono-nerd

# AUR packages
info "Installing AUR packages..."
if command -v yay &>/dev/null; then
    AUR=yay
elif command -v paru &>/dev/null; then
    AUR=paru
else
    warn "No AUR helper found! Install yay or paru first."
    AUR=""
fi

if [[ -n "$AUR" ]]; then
    $AUR -S --needed --noconfirm \
        google-chrome \
        zsa-keymapp-bin
fi

# Enable ASUS services
info "Enabling ASUS services..."
sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
sudo systemctl enable --now asusd.service 2>/dev/null || true

# ZSA keyboard udev
info "Setting up ZSA keyboard access..."
sudo groupadd plugdev 2>/dev/null || true
sudo usermod -aG plugdev "$USER"

info "Packages installed!"

# ──────────────────────────────────────────────────────────────
step "3/8: Fix Shell"
# ──────────────────────────────────────────────────────────────

info "Changing login shell to system zsh..."
sudo chsh -s /usr/bin/zsh "$USER"

# Remove the fake nix-profile wrapper
rm -rf ~/.nix-profile

# Ensure the fish fix config is clean
mkdir -p ~/.config/fish/conf.d
cat > ~/.config/fish/conf.d/00-fix-path.fish << 'FISHEOF'
# Post-nix cleanup: ensure system paths
set -gx SHELL /usr/bin/zsh
set -e __ETC_PROFILE_NIX_SOURCED 2>/dev/null
set -e NIX_PROFILES 2>/dev/null
set -e NIX_SSL_CERT_FILE 2>/dev/null
FISHEOF

info "Shell fixed!"

# ──────────────────────────────────────────────────────────────
step "4/8: Clean Home Directory"
# ──────────────────────────────────────────────────────────────

info "Cleaning caches and logs..."
rm -rf ~/.npm/_logs
rm -rf ~/.npm-cache/_logs
rm -rf ~/.config/emacs/.local/state/logs/*.log
rm -rf ~/.config/emacs/.local/state/logs/*.error
rm -rf ~/.config/mozilla/firefox/Crash\ Reports 2>/dev/null || true
rm -rf ~/.cache/fish/generated_completions
rm -rf ~/.cache/paru/clone/swayfx-*
rm -rf ~/.cache/paru/clone/scenefx-git
rm -rf ~/.cache/paru/clone/linutil-git
rm -rf ~/.cache/fastfetch
rm -rf ~/cahy-nix-backup

# Clean npm cache
npm cache clean --force 2>/dev/null || true

info "Home cleaned!"

# ──────────────────────────────────────────────────────────────
step "5/8: Setup Secrets"
# ──────────────────────────────────────────────────────────────

mkdir -p ~/.secrets
chmod 700 ~/.secrets

for keyfile in anthropic_api_key gemini_api_key github_api_key; do
    if [[ ! -f ~/.secrets/$keyfile ]]; then
        echo ""
        read -rp "Enter ${keyfile} (or press Enter to skip): " keyval
        if [[ -n "$keyval" ]]; then
            echo -n "$keyval" > ~/.secrets/$keyfile
            chmod 600 ~/.secrets/$keyfile
            info "Saved ~/.secrets/$keyfile"
        else
            warn "Skipped $keyfile"
        fi
    else
        info "~/.secrets/$keyfile already exists"
    fi
done

# ──────────────────────────────────────────────────────────────
step "6/8: Font Rendering"
# ──────────────────────────────────────────────────────────────

info "Configuring optimal font rendering..."
mkdir -p ~/.config/fontconfig

cat > ~/.config/fontconfig/fonts.conf << 'FONTEOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Subpixel rendering for LCD -->
  <match target="font">
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    <edit name="autohint" mode="assign"><bool>false</bool></edit>
  </match>

  <!-- Default fonts -->
  <alias>
    <family>monospace</family>
    <prefer>
      <family>DankMono Nerd Font</family>
      <family>JetBrainsMono Nerd Font</family>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>

  <!-- Emoji fallback -->
  <match>
    <test name="family"><string>emoji</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
</fontconfig>
FONTEOF

# Enable Freetype env for better rendering
if ! grep -q 'FREETYPE_PROPERTIES' /etc/environment 2>/dev/null; then
    echo 'FREETYPE_PROPERTIES="truetype:interpreter-version=40"' | sudo tee -a /etc/environment > /dev/null
fi

# Rebuild font cache
fc-cache -fv 2>/dev/null || true

info "Font rendering configured!"

# ──────────────────────────────────────────────────────────────
step "7/8: Generate Gruvbox Wallpaper"
# ──────────────────────────────────────────────────────────────

mkdir -p ~/Pictures/Wallpapers ~/Pictures/Screenshots

# Copy wallpapers from dotfiles repo
if [[ -d ~/cahy/wallpapers ]]; then
    cp -n ~/cahy/wallpapers/* ~/Pictures/Wallpapers/ 2>/dev/null || true
    info "Copied wallpapers from dotfiles repo"
fi

# Generate a dark vibrant gruvbox wallpaper if ImageMagick is available
if command -v magick &>/dev/null; then
    info "Generating gruvbox-dark.png..."
    magick -size 1920x1080 xc:'#1d2021' \
        \( -size 1920x1080 plasma:'#282828-#1d2021' -blur 0x50 \) -compose overlay -composite \
        \( -size 600x600 xc:none -draw "circle 300,300 300,0" -fill '#ffd04020' -opaque white -blur 0x100 \) \
            -gravity NorthEast -geometry +80+60 -compose screen -composite \
        \( -size 500x500 xc:none -draw "circle 250,250 250,0" -fill '#60c0ff15' -opaque white -blur 0x120 \) \
            -gravity SouthWest -geometry +120+60 -compose screen -composite \
        \( -size 400x400 xc:none -draw "circle 200,200 200,0" -fill '#ff60d012' -opaque white -blur 0x80 \) \
            -gravity Center -geometry +200-100 -compose screen -composite \
        \( -size 350x350 xc:none -draw "circle 175,175 175,0" -fill '#60ff900e' -opaque white -blur 0x70 \) \
            -gravity SouthEast -geometry +250+150 -compose screen -composite \
        -attenuate 0.03 +noise Gaussian \
        ~/Pictures/Wallpapers/gruvbox-dark.png
    info "Wallpaper generated!"
else
    warn "ImageMagick not found. Using existing wallpapers."
fi

# ──────────────────────────────────────────────────────────────
step "8/8: Link Dotfiles"
# ──────────────────────────────────────────────────────────────

info "Running install.sh to link dotfiles..."
cd ~/cahy
chmod +x install.sh
./install.sh

info "Dotfiles linked!"

# ──────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup complete! Please:                                     ║${NC}"
echo -e "${GREEN}║  1. Log out and back in (shell change takes effect)          ║${NC}"
echo -e "${GREEN}║  2. Run: hyprctl reload                                      ║${NC}"
echo -e "${GREEN}║  3. Run: doom sync (to update Emacs)                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
