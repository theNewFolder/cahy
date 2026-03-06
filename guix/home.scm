;; Guix Home Configuration — Full Desktop Environment
;; Transfers CachyOS dotfiles setup into declarative Guix Home format
;; Hardware: ASUS TUF A15, Ryzen 7 7435HS, RTX 3050, 16GB DDR5
;;
;; Usage: guix home reconfigure ~/cahy/guix/home.scm

(use-modules
 (gnu home)
 (gnu home services)
 (gnu home services shells)
 (gnu home services shepherd)
 (gnu home services mcron)
 (gnu home services dotfiles)
 (gnu home services xdg)
 (gnu home services fontutils)
 (gnu packages)
 (gnu packages admin)
 (gnu packages base)
 (gnu packages compression)
 (gnu packages curl)
 (gnu packages emacs)
 (gnu packages fonts)
 (gnu packages freedesktop)
 (gnu packages gnome)
 (gnu packages image)
 (gnu packages linux)
 (gnu packages man)
 (gnu packages node)
 (gnu packages package-management)
 (gnu packages python)
 (gnu packages rust-apps)
 (gnu packages shells)
 (gnu packages terminals)
 (gnu packages version-control)
 (gnu packages wm)
 (gnu packages xdisorg)
 (gnu services)
 (guix gexp))

;; ────────────────────────────────────────────────────────────
;; Paths
;; ────────────────────────────────────────────────────────────
(define %dotfiles-dir
  (string-append (getenv "HOME") "/cahy/dotfiles"))

(define %cahy-dir
  (string-append (getenv "HOME") "/cahy"))

(define (dotfile path)
  (local-file (string-append %dotfiles-dir "/" path)
              (basename path)))

(define (dotfile-dir path)
  (local-file (string-append %dotfiles-dir "/" path)
              (basename path)
              #:recursive? #t))

;; ────────────────────────────────────────────────────────────
;; Packages
;; ────────────────────────────────────────────────────────────
(define %user-packages
  (specifications->packages
   (list
    ;; ── Emacs (Guix-native, no Doom) ──
    "emacs-next-pgtk"
    ;; Evil (vim keybindings)
    "emacs-evil" "emacs-evil-collection"
    "emacs-evil-surround" "emacs-evil-commentary"
    ;; Completion (VCO stack)
    "emacs-vertico" "emacs-consult" "emacs-orderless"
    "emacs-marginalia" "emacs-embark" "emacs-corfu"
    ;; Keybindings
    "emacs-general" "emacs-which-key"
    ;; Git
    "emacs-magit" "emacs-forge" "emacs-diff-hl"
    ;; Org-mode + Roam
    "emacs-org-roam"
    ;; AI
    "emacs-gptel"
    ;; LSP + tree-sitter
    "emacs-treesit-auto"
    ;; Languages
    "emacs-geiser" "emacs-geiser-guile"  ;Guile Scheme
    "emacs-rust-mode"
    "emacs-markdown-mode" "emacs-yaml-mode"
    ;; Terminal
    "emacs-vterm" "emacs-vterm-toggle"
    ;; UI
    "emacs-doom-modeline" "emacs-nerd-icons"
    "emacs-catppuccin-theme" "emacs-dashboard"
    "emacs-writeroom-mode" "emacs-rainbow-delimiters"
    ;; Email
    "emacs-mu4e-alert"
    "mu" "isync"                        ;mail indexer + IMAP sync
    ;; Utils
    "emacs-direnv"
    ;; Guix integration
    "emacs-guix"                        ;browse Guix packages from Emacs

    ;; ── Terminals ──
    "foot" "kitty"

    ;; ── Shell tools ──
    "zsh" "starship" "fzf" "zoxide" "direnv"
    "bat" "eza" "fd" "ripgrep"
    "htop" "btop"

    ;; ── Version control ──
    "git"

    ;; ── Web ──
    "curl" "wget"

    ;; ── Wayland tools ──
    "wofi" "wl-clipboard" "grim" "slurp"
    "wlsunset" "brightnessctl" "playerctl"
    "mako"

    ;; ── Development ──
    "node"                              ;Claude Code + MCP servers
    "python" "python-wrapper"           ;python3 + pip
    "make" "gcc-toolchain"              ;native compilation
    "rust" "rust-cargo"                 ;Rust toolchain
    "guile"                             ;for Guix development

    ;; ── LSP servers ──
    "python-lsp-server"                 ;Python LSP
    "rust-analyzer"                     ;Rust LSP

    ;; ── Fonts ──
    "font-fira-code"
    "font-google-noto"
    "font-google-noto-emoji"

    ;; ── System ──
    "man-pages" "file" "tree" "unzip" "zip"
    "nss-certs")))

;; ────────────────────────────────────────────────────────────
;; Environment variables
;; ────────────────────────────────────────────────────────────
(define %environment-variables
  '(;; Wayland / NVIDIA
    ("XDG_SESSION_TYPE" . "wayland")
    ("XDG_CURRENT_DESKTOP" . "Hyprland")
    ("XDG_SESSION_DESKTOP" . "Hyprland")
    ("LIBVA_DRIVER_NAME" . "nvidia")
    ("__GLX_VENDOR_LIBRARY_NAME" . "nvidia")
    ("GBM_BACKEND" . "nvidia-drm")
    ("NVD_BACKEND" . "direct")
    ("QT_QPA_PLATFORM" . "wayland;xcb")
    ("QT_WAYLAND_DISABLE_WINDOWDECORATION" . "1")
    ("MOZ_ENABLE_WAYLAND" . "1")
    ("ELECTRON_OZONE_PLATFORM_HINT" . "auto")
    ("SDL_VIDEODRIVER" . "wayland")
    ("GDK_BACKEND" . "wayland,x11,*")
    ;; Gemini CLI auth
    ("GOOGLE_GENAI_USE_GCA" . "true")
    ;; FZF theming (Gruvbox)
    ("FZF_DEFAULT_COMMAND" . "fd --type f --hidden --follow --exclude .git")
    ("FZF_DEFAULT_OPTS" . "--height 40% --layout=reverse --border --color=bg+:#3c3836,bg:#1d2021,spinner:#ffd040,hl:#ff60d0,fg:#fbf1c7,header:#60c0ff,info:#ffd040,pointer:#ffd040,marker:#ff9030,fg+:#fbf1c7,prompt:#ffd040,hl+:#ff60d0")
    ;; Editor
    ("EDITOR" . "emacsclient -c -a emacs")
    ("VISUAL" . "emacsclient -c -a emacs")
    ;; npm global packages (NOT in /gnu/store)
    ("NPM_CONFIG_PREFIX" . "$HOME/.npm-global")
    ;; Emacs (Guix-native, no Doom)
    ("EMACSDIR" . "$HOME/.config/emacs")))

;; ────────────────────────────────────────────────────────────
;; Zsh — use the existing zshrc from dotfiles
;; ────────────────────────────────────────────────────────────
(define %zsh-config
  (home-zsh-configuration
   (environment-variables %environment-variables)
   (zshrc
    (list (dotfile "zsh/zshrc")))
   (zprofile
    (list
     (plain-file "zprofile-guix" "\
# Guix Home profile paths
export PATH=\"$HOME/.config/emacs/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$PATH\"

# Guix zsh plugins
for p in $HOME/.guix-home/profile/share/zsh/plugins/*/; do
  [[ -d \"$p\" ]] && source \"${p}\"*.zsh 2>/dev/null
done

# Guix zsh completions
fpath+=($HOME/.guix-home/profile/share/zsh/site-functions)

# Claude Code (native installer)
[[ -f $HOME/.claude/claude ]] && export PATH=\"$HOME/.claude:$PATH\"
")))))

;; ────────────────────────────────────────────────────────────
;; Dotfiles — bulk import via home-dotfiles-service-type
;; Symlinks entire dotfiles directory structure into ~/.config/
;; ────────────────────────────────────────────────────────────

;; XDG config files — individual entries for precise control
(define %xdg-config-files
  (list
   `("hypr"          ,(dotfile-dir "hypr"))
   `("waybar"        ,(dotfile-dir "waybar"))
   `("mako"          ,(dotfile-dir "mako"))
   `("foot"          ,(dotfile-dir "foot"))
   `("kitty"         ,(dotfile-dir "kitty"))
   `("starship.toml" ,(dotfile "starship.toml"))
   `("mimeapps.list" ,(dotfile "mimeapps.list"))
   ;; Guix-native Emacs config (replaces Doom)
   `("emacs/early-init.el"
     ,(local-file (string-append %cahy-dir "/guix/emacs/early-init.el")))
   `("emacs/init.el"
     ,(local-file (string-append %cahy-dir "/guix/emacs/init.el")))
   `("guix/channels.scm"
     ,(local-file (string-append (getenv "HOME")
                                 "/.config/guix/channels.scm")))))

;; ────────────────────────────────────────────────────────────
;; Home files (~/.*)
;; ────────────────────────────────────────────────────────────

;; Scripts — map all bin/* to ~/.local/bin/
(define %bin-scripts
  (map (lambda (name)
         (list (string-append ".local/bin/" name)
               (local-file (string-append %dotfiles-dir "/bin/" name))))
       '("agent-team" "ai-ask" "ai-commit" "ai-doc" "ai-explain"
         "ai-fix" "ai-learn" "ai-learn-quick" "ai-note" "ai-pr"
         "ai-review" "ai-screenshot" "ai-summarize" "ai-test"
         "ai-waybar-status" "asus-boost-toggle" "asus-gpu-switch"
         "asus-power-auto" "asus-waybar-status" "gpu-stats"
         "power-menu" "wallpaper-rotate" "yubikey-lock.sh")))

(define %home-files
  (append
   ;; Gemini MCP server for Claude Code
   (list `(".local/share/gemini-mcp/server.js"
           ,(local-file (string-append %cahy-dir
                                       "/scripts/gemini-mcp/server.js"))))
   ;; Claude Code global memory
   (list `(".claude/CLAUDE.md"
           ,(local-file (string-append (getenv "HOME")
                                       "/.claude/CLAUDE.md"))))
   ;; Claude Code project memory
   (list `(".claude/projects/-home-dev/memory/MEMORY.md"
           ,(local-file (string-append %cahy-dir "/claude/MEMORY.md"))))
   ;; Scripts
   %bin-scripts))

;; ────────────────────────────────────────────────────────────
;; Shepherd user services
;; ────────────────────────────────────────────────────────────
(define %user-shepherd-services
  (list
   ;; Emacs daemon
   (shepherd-service
    (provision '(emacs))
    (documentation "Emacs daemon for emacsclient.")
    (start #~(make-forkexec-constructor
              (list (string-append #$(specification->package "emacs-next-pgtk")
                                   "/bin/emacs")
                    "--fg-daemon")
              #:log-file
              (string-append (or (getenv "XDG_STATE_HOME")
                                 (string-append (getenv "HOME")
                                                "/.local/state"))
                             "/emacs-daemon.log")))
    (stop #~(make-kill-destructor))
    (respawn? #t))))

;; ────────────────────────────────────────────────────────────
;; Mcron — scheduled maintenance
;; ────────────────────────────────────────────────────────────
(define %mcron-jobs
  (list
   ;; Weekly guix gc (Sunday 3am) — keep 10GB free, prune old generations
   #~(job '(next-day-from (next-hour '(3)) 0)
          (string-append #$guix "/bin/guix gc -F 10G")
          "guix-gc-weekly")
   ;; Monthly store optimization
   #~(job '(next-day-from (next-hour '(4)) 1)
          (string-append #$guix "/bin/guix gc --optimize")
          "guix-optimize-monthly")))

;; ────────────────────────────────────────────────────────────
;; SECRETS STRATEGY
;; ────────────────────────────────────────────────────────────
;; ~/.secrets/ is NOT managed by Guix Home (world-readable in /gnu/store)
;; Loaded at shell startup via _load_secrets in zshrc
;; On fresh install: manually copy ~/.secrets/ from backup
;; Contains: anthropic_api_key, gemini_api_key, github_api_key
;; Safe env vars (GOOGLE_GENAI_USE_GCA) are in %environment-variables

;; ────────────────────────────────────────────────────────────
;; Home environment — putting it all together
;; ────────────────────────────────────────────────────────────
(home-environment
 (packages %user-packages)

 (services
  (list
   ;; Zsh shell with full config
   (service home-zsh-service-type %zsh-config)

   ;; XDG base directories
   (service home-xdg-base-directories-service-type
            (home-xdg-base-directories-configuration
             (cache-home "$HOME/.cache")
             (config-home "$HOME/.config")
             (data-home "$HOME/.local/share")
             (state-home "$HOME/.local/state")))

   ;; XDG config files (~/.config/*)
   (service home-xdg-configuration-files-service-type
            %xdg-config-files)

   ;; Home files (~/.*)
   (service home-files-service-type %home-files)

   ;; Environment variables
   (service home-environment-variables-service-type
            %environment-variables)

   ;; Fontconfig
   (service home-fontconfig-service-type
            (home-fontconfig-configuration))

   ;; Shepherd user services (emacs daemon)
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (services %user-shepherd-services)))

   ;; Mcron scheduled tasks (gc, optimization)
   (service home-mcron-service-type
            (home-mcron-configuration
             (jobs %mcron-jobs))))))
