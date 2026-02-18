# Memory

## User Preferences
- Minimize confirmation questions. Act decisively, only confirm for truly irreversible/high-risk actions
- Sudo password is "o" (use `echo 'o' | sudo -S`)
- GitHub username: theNewFolder
- Timezone: Asia/Dubai
- Theme: Gruvbox Dark Vibrant
- Font: DankMono Nerd Font (from github.com/theNewFolder/my-fontsDank)
- WM: Hyprland (Wayland)
- Editor: Doom Emacs daemon (emacsclient), config in ~/.config/doom/ (symlinked from ~/cahy/dotfiles/doom)
- Shell: zsh (default)
- Terminal: foot

## Environment
- CachyOS (Arch-based), ASUS TUF A15, Ryzen 7 7435HS, RTX 3050, 16GB DDR5
- Node.js via fnm at ~/.local/share/fnm
- gh, lazygit, gemini-cli, claude-code all installed
- Dotfiles at ~/cahy/dotfiles/
- Doom Emacs at ~/.config/emacs, config at ~/.config/doom/

## Project Structure
- ~/cahy/ — dotfiles repo (standard config, no Nix)
- ~/org/ — Org-mode PKM (GitHub private: theNewFolder/org-pkm)
- ~/ai-knowledge/ — AI learning notes and knowledge base
- ~/.config/doom/ — Doom Emacs config (init.el, config.org, packages.el)
- ~/.config/hypr/ — Hyprland config (symlinked from dotfiles/hypr)

## Hyprland / Waybar
- Bar: Waybar with Gruvbox gradient pills, GPU/AI/system modules
- Hyprland config: managed in dotfiles/hypr/hyprland.conf
- Autostart: nm-applet, polkit-gnome, wlsunset, hyprpaper, hypridle, mako
- GTK CSS caveat: gnome-themes-extra has no GTK4 CSS — don't set `theme.package`; GTK4 dark mode uses `prefer-dark-theme` only
- Waybar CSS caveat: GTK CSS parser doesn't support comma-separated `%` in `@keyframes`

## Key Configs
- AI scripts: ~/.local/bin/ai-{commit,review,explain,fix,summarize,test,pr,doc} (symlinked from dotfiles/bin)
- MCP servers: gemini, filesystem, git, github, memory (in ~/.config/claude/settings.json)
- Firefox: userChrome.css (minimal Gruvbox), user.js (NVIDIA HW accel), tridactylrc
- Doom Emacs: gptel (Claude + Gemini), claude-code.el, org-roam, SPC a = AI leader

## Management Commands
- `./install.sh` (links configs)
- `doom sync` (after changing doom config)
- System update: `sudo pacman -Syu`
