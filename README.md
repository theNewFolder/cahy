# CachyOS Desktop Setup

Gruvbox Dark Vibrant desktop with SwayFX, Emacs, and AI tools. Managed by Nix home-manager.

## Quick Start

```bash
git clone https://github.com/theNewFolder/cahy.git ~/cahy
cd ~/cahy
chmod +x install.sh
./install.sh
```

## What's Included

- **WM**: SwayFX with blur, rounded corners, shadows
- **Bar**: Waybar (Gruvbox gradient theme)
- **Terminal**: foot (primary), kitty (backup)
- **Editor**: Emacs daemon with org-mode, org-roam, Evil, Magit
- **Browser**: Firefox with vertical tabs, Tridactyl, Gruvbox userChrome
- **Shell**: zsh + starship prompt + modern CLI (eza, bat, fd, ripgrep, etc.)
- **AI**: Claude Code, Gemini CLI, helper scripts (ai-commit, ai-review, etc.)
- **Theme**: Gruvbox Dark Vibrant everywhere
- **Font**: DankMono Nerd Font

## Structure

```
flake.nix          # Nix flake entry point
home.nix           # Main home-manager config
modules/           # Modular configs (ai, apps, emacs, firefox, github, secrets, waybar)
dotfiles/sway/     # SwayFX window manager config
wallpapers/        # Gruvbox-themed wallpapers
claude/            # Claude Code AI memories and settings
secrets/           # API key setup instructions
```

## Rebuild

```bash
home-manager switch --flake ~/cahy#dev -b backup
```

## Key Bindings

| Key | Action |
|-----|--------|
| `mod+Return` | foot terminal |
| `mod+d` | wofi launcher |
| `mod+b` | Firefox |
| `mod+e` | Emacs |
| `mod+i` | Gemini (floating) |
| `mod+Shift+i` | Claude (floating) |
| `mod+g` | lazygit (floating) |
| `mod+hjkl` | Focus (vim-style) |
| `mod+1-9` | Workspaces |
