#!/usr/bin/env bash
# Post-install script for Guix System
# Run after guix system init + first boot + guix home reconfigure
set -euo pipefail

echo "=== Guix Post-Install ==="

# Step 1: Install Claude Code (native installer via FHS container)
echo ">>> Installing Claude Code..."
if ! command -v claude &>/dev/null; then
  guix shell --container --network --emulate-fhs \
    nss-certs bash coreutils curl -- \
    bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  echo "Claude Code installed to ~/.claude/"
else
  echo "Claude Code already installed"
fi

# Step 2: Install Doom Emacs
echo ">>> Installing Doom Emacs..."
if [ ! -d "$HOME/.config/emacs" ]; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install --no-env
  echo "Doom Emacs installed"
else
  echo "Doom Emacs already installed, syncing..."
  ~/.config/emacs/bin/doom sync
fi

# Step 3: Install AI CLIs via npm-global
echo ">>> Setting up npm-global..."
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_CONFIG_PREFIX"
# Gemini CLI
npm install -g @anthropic-ai/context7-mcp 2>/dev/null || true

# Step 4: Copy secrets (reminder)
echo ""
if [ ! -d "$HOME/.secrets" ]; then
  echo "WARNING: ~/.secrets/ not found!"
  echo "Copy your API keys from backup:"
  echo "  scp backup:~/.secrets/ ~/.secrets/"
  echo "  chmod 600 ~/.secrets/*"
else
  echo "Secrets directory found"
fi

# Step 5: Set up Guix Home
echo ""
echo ">>> Running guix home reconfigure..."
guix home reconfigure ~/cahy/guix/home.scm \
  --substitute-urls="https://bordeaux.guix.gnu.org https://ci.guix.gnu.org https://substitutes.nonguix.org"

echo ""
echo "=== Post-install complete! ==="
echo "Restart your session for all changes to take effect."
