#!/usr/bin/env bash
set -e

# Define source directory
DOTFILES="$HOME/cahy/dotfiles"
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"

echo "Starting installation..."

# Create necessary directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$HOME/org"/{roam,roam/daily,archive,templates,attachments}
mkdir -p "$HOME/ai-knowledge"/{claude/{rules,memories,prompts},gemini/{conversations,research},learning/{nix,emacs,hyprland,rust,ai},projects,reference}

# Helper function to link configs
link_config() {
    src="$DOTFILES/$1"
    dest="$CONFIG_DIR/$2"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    
    if [ ! -e "$dest" ]; then
        echo "Linking $src -> $dest"
        ln -sf "$src" "$dest"
    else
        echo "$dest already exists"
    fi
}

# Link standard configs
link_config "hypr" "hypr"
link_config "waybar" "waybar"
link_config "mako" "mako"
link_config "foot" "foot"
link_config "kitty" "kitty"
link_config "starship.toml" "starship.toml"
link_config "mimeapps.list" "mimeapps.list"

# Link Doom Emacs
if [ -d "$DOTFILES/doom" ]; then
    if [ -d "$HOME/.doom.d" ]; then
        echo "Moving existing ~/.doom.d to ~/.doom.d.bak"
        mv "$HOME/.doom.d" "$HOME/.doom.d.bak"
    fi
    # Use standard XDG location
    link_config "doom" "doom"
    # Ensure ~/.doom.d doesn't exist to avoid conflict
    rm -rf "$HOME/.doom.d"
    ln -sf "$CONFIG_DIR/doom" "$HOME/.doom.d" 
fi

# Link Zsh
if [ -f "$DOTFILES/zsh/zshrc" ]; then
    echo "Linking .zshrc"
    ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
fi

# Link Scripts
echo "Linking scripts to $BIN_DIR..."
for script in "$DOTFILES/bin/"*; do
    if [ -f "$script" ]; then
        name=$(basename "$script")
        ln -sf "$script" "$BIN_DIR/$name"
        chmod +x "$script"
    fi
done

# Link Desktop Applications
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
echo "Linking desktop applications..."
for app in "$DOTFILES/applications/"*; do
    if [ -f "$app" ]; then
        name=$(basename "$app")
        ln -sf "$app" "$APP_DIR/$name"
    fi
done

echo "Installation complete! Please restart your shell or log out and back in."
