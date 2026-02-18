#!/usr/bin/env bash
# CachyOS Setup - Full desktop environment bootstrap
# Clone this repo and run: chmod +x install.sh && ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; exit 1; }

# ===== 1. System Packages (pacman) =====
install_system_packages() {
    info "Installing system packages via pacman..."
    sudo pacman -Syu --noconfirm

    local pkgs=(
        # Wayland / SwayFX
        swayfx waybar wofi mako foot kitty
        swaylock swayidle swaybg kanshi
        xdg-desktop-portal-wlr

        # Polkit & auth
        polkit-gnome

        # Networking
        networkmanager network-manager-applet

        # Audio
        pipewire pipewire-pulse wireplumber pavucontrol playerctl

        # Display / GPU
        brightnessctl mesa intel-media-driver libva-utils

        # Clipboard & screenshots
        wl-clipboard grim slurp swappy wf-recorder cliphist

        # Night light
        wlsunset

        # Notifications
        libnotify

        # File manager
        thunar

        # Bluetooth
        bluez bluez-utils

        # Shell
        zsh zsh-completions

        # Git
        git git-lfs

        # Build tools (for Emacs native comp, etc)
        base-devel gcc

        # Misc
        curl wget unzip
    )

    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    info "System packages installed."
}

# ===== 2. AUR packages (yay) =====
install_aur_packages() {
    if ! command -v yay &>/dev/null; then
        warn "yay not found. CachyOS should have it pre-installed."
        warn "If not: git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
        return
    fi

    info "Installing AUR packages via yay..."
    local aur_pkgs=(
        swappy
    )
    yay -S --needed --noconfirm "${aur_pkgs[@]}" || true
    info "AUR packages done."
}

# ===== 3. Set zsh as default shell =====
set_default_shell() {
    if [[ "$SHELL" != */zsh ]]; then
        info "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        info "Shell changed to zsh. Will take effect on next login."
    else
        info "zsh is already the default shell."
    fi
}

# ===== 4. Install Determinate Nix =====
install_nix() {
    if command -v nix &>/dev/null; then
        info "Nix already installed."
        return
    fi

    info "Installing Determinate Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    info "Nix installed. Sourcing environment..."

    # Source nix for this session
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
}

# ===== 5. Install home-manager and apply config =====
apply_home_manager() {
    info "Applying home-manager configuration..."
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"

    # Run home-manager switch
    nix run home-manager -- switch --flake "$REPO_DIR#dev" -b backup
    info "Home-manager applied successfully."
}

# ===== 6. Deploy Sway config =====
deploy_sway_config() {
    info "Deploying SwayFX config..."
    mkdir -p ~/.config/sway
    cp "$REPO_DIR/dotfiles/sway/config" ~/.config/sway/config
    info "Sway config deployed to ~/.config/sway/config"
}

# ===== 7. Deploy wallpapers =====
deploy_wallpapers() {
    info "Deploying wallpapers..."
    mkdir -p ~/Pictures/Wallpapers ~/Pictures/Screenshots
    cp "$REPO_DIR"/wallpapers/* ~/Pictures/Wallpapers/

    # Create convenience symlink
    ln -sf ~/Pictures/Wallpapers/canyon.jpg ~/Pictures/Wallpapers/gruvbox-current.png
    info "Wallpapers deployed to ~/Pictures/Wallpapers/"
}

# ===== 8. Install DankMono Nerd Font =====
install_fonts() {
    info "Installing DankMono Nerd Font..."
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    if ls "$font_dir"/DankMono* &>/dev/null; then
        info "DankMono already installed."
        return
    fi

    # Clone from user's font repo
    local tmp_dir
    tmp_dir=$(mktemp -d)
    if git clone --depth 1 https://github.com/theNewFolder/my-fontsDank.git "$tmp_dir" 2>/dev/null; then
        cp "$tmp_dir"/*.ttf "$font_dir/" 2>/dev/null || cp "$tmp_dir"/**/*.ttf "$font_dir/" 2>/dev/null || true
        rm -rf "$tmp_dir"
        fc-cache -fv
        info "DankMono Nerd Font installed."
    else
        warn "Could not clone font repo. Install DankMono manually to $font_dir"
    fi
}

# ===== 9. Setup secrets directory =====
setup_secrets() {
    info "Setting up secrets directory..."
    mkdir -p ~/.secrets
    chmod 700 ~/.secrets

    if [[ ! -f ~/.secrets/gemini_api_key ]]; then
        warn "Remember to add your API keys:"
        warn "  echo 'YOUR_KEY' > ~/.secrets/gemini_api_key"
        warn "  echo 'YOUR_KEY' > ~/.secrets/anthropic_api_key"
        warn "  echo 'YOUR_KEY' > ~/.secrets/openai_api_key"
        warn "  chmod 600 ~/.secrets/*_api_key"
    fi
    info "Secrets directory ready at ~/.secrets/"
}

# ===== 10. Deploy Claude Code config =====
deploy_claude_config() {
    info "Deploying Claude Code config..."
    mkdir -p ~/.claude/projects/-home-dev/memory

    # Deploy memory
    cp "$REPO_DIR/claude/MEMORY.md" ~/.claude/projects/-home-dev/memory/MEMORY.md

    # Deploy settings (global)
    if [[ ! -f ~/.claude/settings.local.json ]]; then
        cp "$REPO_DIR/claude/settings.local.json" ~/.claude/settings.local.json
    else
        warn "~/.claude/settings.local.json already exists, skipping (check claude/ dir for reference)"
    fi

    info "Claude Code config deployed."
}

# ===== 11. Setup Firefox profile configs =====
setup_firefox() {
    info "Setting up Firefox profile..."

    local ff_dir="$HOME/.mozilla/firefox"
    local profile_dir=""

    # If Firefox hasn't been launched yet, do a quick launch to create profile
    if [[ ! -d "$ff_dir" ]]; then
        info "Launching Firefox briefly to create profile..."
        timeout 5 firefox --headless &>/dev/null || true
        sleep 2
    fi

    # Auto-detect profile from profiles.ini
    if [[ -f "$ff_dir/profiles.ini" ]]; then
        local rel_path
        rel_path=$(grep -A5 '\[Install' "$ff_dir/profiles.ini" | grep '^Default=' | head -1 | cut -d= -f2)
        if [[ -n "$rel_path" ]]; then
            profile_dir="$ff_dir/$rel_path"
        fi
    fi

    # Fallback: find any .default-release profile
    if [[ -z "$profile_dir" || ! -d "$profile_dir" ]]; then
        profile_dir=$(find "$ff_dir" -maxdepth 1 -name '*.default-release' -type d 2>/dev/null | head -1)
    fi

    # Fallback: find any .default profile
    if [[ -z "$profile_dir" || ! -d "$profile_dir" ]]; then
        profile_dir=$(find "$ff_dir" -maxdepth 1 -name '*.default' -type d 2>/dev/null | head -1)
    fi

    if [[ -z "$profile_dir" || ! -d "$profile_dir" ]]; then
        warn "Could not detect Firefox profile. Launch Firefox once, then re-run: $0 --firefox-only"
        return
    fi

    info "Detected Firefox profile: $profile_dir"

    # Deploy user.js
    cp "$HOME/.config/firefox/user.js" "$profile_dir/user.js"

    # Deploy chrome styles
    mkdir -p "$profile_dir/chrome"
    cp "$HOME/.config/firefox/userChrome.css" "$profile_dir/chrome/userChrome.css"
    cp "$HOME/.config/firefox/userContent.css" "$profile_dir/chrome/userContent.css"

    info "Firefox profile configured with Gruvbox theme + vertical tabs."
}

# ===== 12. Install AI tools (npm global) =====
install_ai_tools() {
    info "Installing AI CLI tools..."

    # Install fnm if not present
    if [[ ! -f "$HOME/.local/share/fnm/fnm" ]]; then
        info "Installing fnm (Fast Node Manager)..."
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/share/fnm" --skip-shell
    fi

    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$($HOME/.local/share/fnm/fnm env)"

    # Install Node LTS
    "$HOME/.local/share/fnm/fnm" install --lts
    "$HOME/.local/share/fnm/fnm" default lts-latest

    export PATH="$HOME/.local/share/fnm/aliases/default/bin:$PATH"

    # Install global npm tools
    npm install -g @anthropics/claude-code @google/generative-ai-cli 2>/dev/null || {
        warn "Some npm global installs failed. You can install them manually:"
        warn "  npm install -g @anthropics/claude-code"
        warn "  npm install -g @google/generative-ai-cli"
    }

    info "AI tools installed."
}

# ===== 13. Enable services =====
enable_services() {
    info "Enabling system services..."
    sudo systemctl enable --now NetworkManager 2>/dev/null || true
    sudo systemctl enable --now bluetooth 2>/dev/null || true
    info "Services enabled."
}

# ===== Main =====
main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║   CachyOS Desktop Setup - Gruvbox Dark   ║"
    echo "║   SwayFX + Emacs + AI Tools              ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    # Handle --firefox-only flag
    if [[ "${1:-}" == "--firefox-only" ]]; then
        setup_firefox
        exit 0
    fi

    install_system_packages
    install_aur_packages
    set_default_shell
    install_nix
    apply_home_manager
    deploy_sway_config
    deploy_wallpapers
    install_fonts
    setup_secrets
    deploy_claude_config
    setup_firefox
    install_ai_tools
    enable_services

    echo ""
    info "========================================="
    info "Setup complete!"
    info "========================================="
    echo ""
    info "Next steps:"
    info "  1. Log out and back in (or reboot)"
    info "  2. Select 'Sway' at the login screen"
    info "  3. Add your API keys to ~/.secrets/"
    info "  4. Run 'gh auth login' for GitHub CLI"
    info "  5. Launch Emacs: mod+e"
    echo ""
    info "Rebuild home-manager anytime:"
    info "  home-manager switch --flake ~/cahy#dev -b backup"
    echo ""
}

main "$@"
