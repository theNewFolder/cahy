# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Context
- **Hardware**: ASUS TUF A15 — Ryzen 7 7435HS, RTX 3050 (4GB), 16GB DDR5
- **OS**: GNU Guix System (migrating from CachyOS)
- **WM**: Hyprland (Wayland) with hyprpaper, hypridle, hyprlock
- **Editor**: Guix-native Emacs (emacs-next-pgtk) — no Doom, no straight.el
- **Shell**: zsh + starship + fzf + zoxide + direnv
- **Theme**: Catppuccin Mocha across all apps (Emacs, Waybar, Mako, Foot, Kitty, Hyprlock)
- **Font**: DankMono Nerd Font

## Repository Structure
```
dotfiles/                    # All configuration files (symlinked via Guix Home)
  hypr/                      # Hyprland WM + hyprpaper/idle/lock
  waybar/                    # Status bar: emacs, git, AI, guix-health, gpu, system
  mako/                      # Notification daemon (Catppuccin Mocha)
  zsh/                       # Shell config
  foot/                      # Terminal (Catppuccin Mocha)
  kitty/                     # Terminal (Catppuccin Mocha)
  mbsync/                    # Gmail IMAP sync for mu4e
  bin/                       # Scripts: ai-*, guix-menu, guix-snapshot, guix-health-status, git-waybar-status
  starship.toml              # Prompt
guix/                        # Guix System + Home configs
  system.scm                 # OS config (NVIDIA, greetd, TLP, btrfs, substitutes)
  home.scm                   # User env (80+ packages, dotfiles, services, mcron)
  emacs/                     # Guix-native Emacs config (init.el, early-init.el, banner.txt)
  learning/                  # Guile Scheme exercises
  partition-samsung.sh       # Btrfs partitioning script
  post-install.sh            # Post-boot setup (Claude Code, npm, snapper, mu4e)
  snapper-configs/           # Btrfs snapshot config
scripts/                     # MCP servers (gemini-mcp)
```

## Build / Deploy (Guix)
```bash
# Apply system config (as root)
sudo guix system reconfigure ~/cahy/guix/system.scm

# Apply user environment
guix home reconfigure ~/cahy/guix/home.scm

# Pull latest channels
guix pull --substitute-urls="https://bordeaux.guix.gnu.org https://ci.guix.gnu.org https://substitutes.nonguix.org"
```

## Emacs Keybindings (SPC leader via general.el)
| Prefix | Domain | Key examples |
|--------|--------|-------------|
| SPC f | Files | ff=find, fr=recent, fs=save, fd=dired |
| SPC b | Buffers | bb=switch, bk=kill |
| SPC w | Windows | wv=vsplit, ws=split, whjkl=move |
| SPC s | Search | ss=buffer, sp=project, si=imenu |
| SPC g | Git | gg=magit, gb=blame, gt=timemachine |
| SPC a | AI | aa=send, ab=buffer, as=switch model |
| SPC o | Org | oa=agenda, oc=capture, or=roam, od=today |
| SPC c | Code/LSP | ca=actions, cr=rename, cd=definition |
| SPC G | Guix | Gs=system.scm, Gh=home.scm, Gr=reconfigure |
| SPC C | Chat | Cc=Matrix connect, Cr=rooms |
| SPC l | Scheme | le=eval, lb=buffer, ls=REPL |
| SPC m | Mail | mm=mu4e, mc=compose |
| SPC h | Help | hg=Guix manual, hr=Guile ref, he=Emacs |

## Hyprland Keybindings
| Key | Action |
|-----|--------|
| Super+Return | foot terminal |
| Super+D / Space | wofi launcher |
| Super+B | Firefox |
| Super+E | Emacs |
| Super+G | lazygit |
| Super+Shift+G | guix-menu (wofi) |
| Super+1-9 | workspaces |
| Print | screenshot (full → file + clipboard) |
| Shift+Print | screenshot (region → clipboard) |
| Super+Print | screenshot (region → swappy annotate) |

## AI Integration
- **gptel (Emacs)**: Claude (default) + Gemini backends, SPC a s to switch
- **Claude Code**: MCP servers: context7 + gemini-mcp
- **AI scripts**: ai-commit, ai-review, ai-explain, ai-fix, etc. (in dotfiles/bin/)
- **API keys**: ~/.secrets/{anthropic,gemini,github}_api_key (NOT in Guix store)

## DO NOT
- Commit API keys or secrets (they live in ~/.secrets/)
- Use X11-only tools (Wayland-only setup)
- Use `git add -A` (may include secrets)
- Use straight.el or package.el (Guix manages all Emacs packages)
- Use `guix build` without `--substitute-urls` (always use substitutes)
- Set WLR_DRM_NO_ATOMIC (causes issues with NVIDIA)
