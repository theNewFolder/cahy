# CLAUDE.md — Project Rules for Claude Code

## System Context
- **Hardware**: ASUS TUF A15 — Ryzen 7 7435HS, RTX 3050 (4GB), 16GB DDR5
- **OS**: CachyOS (Arch-based), kernel 6.x
- **WM**: Hyprland (Wayland) with hyprpaper, hypridle, hyprlock
- **Editor**: Doom Emacs (emacs30-pgtk) with gptel AI integration
- **Shell**: zsh + starship + fzf + zoxide + direnv
- **Theme**: Gruvbox Dark Vibrant across all apps
- **Font**: DankMono Nerd Font

## Repository Structure
```
dotfiles/                    # All configuration files
  hypr/                      # Hyprland WM config + hyprpaper/idle/lock
  waybar/                    # Status bar with GPU/AI/system modules
  mako/                      # Notification daemon config
  zsh/                       # Shell configuration (zshrc, aliases)
  foot/                      # Terminal config
  kitty/                     # Terminal config
  starship.toml              # Prompt configuration
  doom/                      # Doom Emacs config (symlinked to ~/.doom.d)
  bin/                       # Custom scripts (ai-commit, etc.)
install.sh                   # Script to link dotfiles to ~/.config
README.md                    # Project documentation
scripts/                     # Additional project scripts (e.g. gemini-mcp)
```

## Build / Deploy
```bash
# Link configurations
chmod +x install.sh && ./install.sh

# Install system packages (Arch/CachyOS)
sudo pacman -S hyprland hyprpaper hypridle hyprlock waybar mako zsh starship fzf zoxide direnv foot kitty emacs-wayland

# After changing doom/ files
doom sync
```

## AI Integration
- **Claude Code**: MCP servers in ~/.config/claude/settings.json
- **Gemini MCP**: gemini_ask tool via scripts/gemini-mcp/server.js
- **gptel (Emacs)**: Claude + Gemini backends, SPC a for AI leader
- **AI scripts**: ai-commit, ai-review, ai-explain, ai-fix, ai-summarize, ai-test, ai-pr, ai-doc (in dotfiles/bin/)
- **API keys**: ~/.secrets/{anthropic,gemini,github}_api_key

## Key Keybindings (Hyprland)
| Key | Action |
|-----|--------|
| Super+Return | foot terminal |
| Super+D / Space | wofi launcher |
| Super+B | Firefox |
| Super+E | Emacs |
| Super+I | Gemini chat |
| Super+Shift+I | Claude Code |
| Super+G | lazygit |
| Super+C | org-capture |
| Super+A | org-agenda |
| Super+N | org-roam find |
| Super+HJKL | focus vim-style |
| Super+1-9 | workspaces |

## DO NOT
- Commit API keys or secrets (they live in ~/.secrets/)
- Edit doom/config.el directly (edit config.org, then doom sync)
- Use X11-only tools (this is a Wayland-only setup)
- Set WLR_DRM_NO_ATOMIC (causes issues with NVIDIA)
- Add gnome-themes-extra as theme.package (no GTK4 CSS)
- Use `git add -A` (may include secrets)
