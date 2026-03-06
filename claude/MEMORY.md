# Memory

## User Preferences
- Minimize confirmation questions. Act decisively, only confirm for truly irreversible/high-risk actions
- Always ask finetuning/optimization questions — as many as useful
- User types fast and informal — interpret intent, don't nitpick typos
- Sudo password is "o" (use `echo 'o' | sudo -S`)
- GitHub username: theNewFolder
- Email: omranaltunaiji@gmail.com
- Timezone: Asia/Dubai
- Theme: Gruvbox Dark Vibrant
- Font: DankMono Nerd Font (from github.com/theNewFolder/my-fontsDank)
- WM: Hyprland (Wayland)
- Editor: Doom Emacs daemon (emacsclient), config in ~/.config/doom/ (symlinked from ~/cahy/dotfiles/doom)
- Shell: zsh (default), fish also configured
- Terminal: foot (primary), kitty (backup)
- AUR helper: paru

## Hardware
- ASUS TUF A15 — Ryzen 7 7435HS (8C/16T, Zen 3+), RTX 3050 Mobile (4GB), 16GB DDR5
- NVMe 1: ~954GB (boot + home, btrfs), NVMe 2: ~1.8TB (LVM2)
- Wifi: RTL8852BE (rtw89 driver)

## Environment
- CachyOS (Arch-based), kernel 6.19.x-cachyos (PREEMPT_DYNAMIC)
- Node.js v25.6.1 via fnm (~/.local/share/fnm)
- Python via uv/uvx (0.10.8)
- gh, lazygit, gemini-cli, kimi, kiro-cli, claude-code all installed

## AI Tools
| Tool | Version | Auth |
|------|---------|------|
| Claude Code | 2.1.70 | Authenticated |
| Gemini CLI | 0.32.1 | GCA (GOOGLE_GENAI_USE_GCA=true) |
| Kimi CLI | 1.17.0 | OAuth |
| Kiro CLI | 1.27.1 | Google login |
| GitHub CLI | — | theNewFolder |

## MCP Servers (7 total, in ~/.claude.json)
| Server | Command | Package |
|--------|---------|---------|
| github | npx | @modelcontextprotocol/server-github |
| memory | npx | @modelcontextprotocol/server-memory |
| fetch | uvx | mcp-server-fetch |
| filesystem | npx | @modelcontextprotocol/server-filesystem |
| git | uvx | mcp-server-git |
| context7 | npx | @upstash/context7-mcp |
| gemini-mcp | node | ~/cahy/scripts/gemini-mcp/server.js |

## Project Structure
- ~/cahy/ — dotfiles repo (standard config, no Nix)
- ~/cachycraft/ — CachyOS optimization guide
- ~/org/ — Org-mode PKM (GitHub private: theNewFolder/org-pkm)
- ~/ai-knowledge/ — AI learning notes and knowledge base
- ~/.config/doom/ — Doom Emacs config (init.el, config.org, packages.el)
- ~/.config/hypr/ — Hyprland config (symlinked from dotfiles/hypr)

## Hyprland / Waybar
- Bar: Waybar with Gruvbox gradient pills, GPU/AI/system modules
- Hyprland config: managed in dotfiles/hypr/hyprland.conf
- Autostart: nm-applet, polkit-gnome, wlsunset, hyprpaper, hypridle, mako
- GTK CSS caveat: gnome-themes-extra has no GTK4 CSS — don't set `theme.package`
- Waybar CSS caveat: GTK CSS parser doesn't support comma-separated `%` in `@keyframes`

## Key Configs
- AI scripts: ~/.local/bin/ai-{commit,review,explain,fix,summarize,test,pr,doc,screenshot,learn,note,ask}
- MCP servers: 7 servers in ~/.claude.json (user scope)
- Secrets: ~/.secrets/ dir, auto-loaded by zsh (_load_secrets) and fish (conf.d/secrets.fish)
- Firefox: userChrome.css (minimal Gruvbox), user.js (NVIDIA HW accel), tridactylrc
- Doom Emacs: gptel (Claude + Gemini), claude-code.el, org-roam, SPC a = AI leader

## Management Commands
- `./install.sh` (links configs)
- `doom sync` (after changing doom config)
- System update: `sudo pacman -Syu`
