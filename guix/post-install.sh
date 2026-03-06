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

# Step 2: Emacs config (Guix-native, no Doom)
echo ">>> Emacs config managed by Guix Home (init.el + early-init.el)"
echo "    Config at ~/.config/emacs/ (symlinked by guix home)"

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

# Step 6: Set up snapper for btrfs snapshots
echo ""
echo ">>> Setting up snapper..."
if command -v snapper &>/dev/null; then
  if ! sudo snapper -c root get-config &>/dev/null 2>&1; then
    sudo snapper -c root create-config /
    sudo cp ~/cahy/guix/snapper-configs/root /etc/snapper/configs/root
    sudo snapper -c root set-config ALLOW_USERS=dev
    echo "Snapper configured for root subvolume"
  else
    echo "Snapper root config already exists"
  fi
else
  echo "Snapper not installed — install with: guix install snapper"
fi

# Step 7: Set up mu4e email (after app password is created)
echo ""
if [ -f "$HOME/.secrets/gmail_app_password" ]; then
  echo ">>> Setting up mu4e..."
  mkdir -p ~/Mail/Gmail
  mu init --maildir=~/Mail --my-address=omranaltunaiji@gmail.com 2>/dev/null || true
  mbsync -a
  mu index
  echo "mu4e ready — open with SPC m m in Emacs"
else
  echo ">>> Skipping mu4e setup (no Gmail app password yet)"
  echo "    Create at: https://myaccount.google.com/apppasswords"
  echo "    Save to: ~/.secrets/gmail_app_password"
  echo "    Then run: mbsync -a && mu init --maildir=~/Mail --my-address=omranaltunaiji@gmail.com && mu index"
fi

echo ""
echo "=== Post-install complete! ==="
echo "Restart your session for all changes to take effect."
echo ""
echo "Quick start:"
echo "  SPC m m    — Email (mu4e)"
echo "  SPC f d    — File manager (dirvish)"
echo "  SPC C c    — Chat (Matrix/Ement)"
echo "  SPC G s    — Edit system.scm"
echo "  SPC a a    — AI chat (gptel)"
