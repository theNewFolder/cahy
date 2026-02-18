# Memory

## User Preferences
- Minimize confirmation questions. Act decisively, only confirm for truly irreversible/high-risk actions
- Sudo password is "o" (use `echo 'o' | sudo -S`)
- GitHub username: theNewFolder
- Timezone: Asia/Dubai
- Theme: Gruvbox Dark Vibrant
- Font: DankMono Nerd Font (from github.com/theNewFolder/my-fontsDank)
- WM: SwayFX (Wayland)
- Editor: Emacs daemon (emacsclient)
- Shell: zsh (default), bash also configured
- Terminal: foot (server mode)

## Environment
- CachyOS (Arch-based), Intel i5-8365U, UHD 620, 16GB RAM
- Determinate Nix installed at /nix/var/nix/profiles/default/bin
- Node.js via fnm at ~/.local/share/fnm
- gh, lazygit, gemini-cli, claude-code all installed
- Home-manager via Nix flake at ~/cahy

## Project Structure
- ~/cahy/ — flake.nix + home.nix + modules/ (CachyOS setup repo)
- ~/org/ — Org-mode PKM (GitHub private: theNewFolder/org-pkm)
- ~/.config/sway/ — SwayFX config (Gruvbox)
- ~/.config/emacs/ — Emacs config (straight.el + use-package)

## Sway / Waybar
- Bar: Waybar with Gruvbox theme (~/.config/waybar/style.css)
- Sway config: ~/.config/sway/config
- Autostart: nm-applet, polkit-gnome, wlsunset, kanshi, swayidle
- GTK CSS caveat: gnome-themes-extra has no GTK4 CSS — don't set `theme.package` in home.nix gtk section; GTK4 dark mode uses `prefer-dark-theme` setting only
- Waybar CSS caveat: GTK CSS parser doesn't support comma-separated `%` in `@keyframes` — use separate stops

## Key Configs
- Home-manager modules: modules/secrets.nix, modules/github.nix, modules/emacs.nix
- AI scripts: ~/.local/bin/ai-commit, ai-review, ai-explain, ai-fix
- Firefox: userChrome.css (minimal Gruvbox), user.js (perf tweaks), tridactylrc
- Emacs vterm requires libvterm (pacman: libvterm) for module compilation

## Rebuild Commands
- `home-manager switch --flake ~/cahy#dev -b backup`
- Nix path: `export PATH="/nix/var/nix/profiles/default/bin:$PATH"`
