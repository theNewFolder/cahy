;;; init.el — Guix-native Emacs configuration -*- lexical-binding: t; -*-
;;
;; ARCHITECTURE: All packages installed by Guix (no straight.el, no package.el).
;; This file only configures packages using use-package (built into Emacs 29+).
;; Guix handles dependencies, versions, and native compilation.
;;
;; LEARNING: use-package with :ensure nil tells Emacs not to try installing
;; the package — Guix already did that. We only configure behavior here.

;;;; ──────────────────────────────────────────────────────────
;;;; Core Settings
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: These are Emacs built-in settings that don't need any package.
(use-package emacs
  :ensure nil
  :init
  ;; User info
  (setq user-full-name "dev"
        user-mail-address "omranaltunaiji@gmail.com")

  ;; UTF-8 everywhere
  (set-default-coding-systems 'utf-8)
  (prefer-coding-system 'utf-8)

  ;; UI cleanup
  (setq inhibit-startup-screen t
        inhibit-startup-message t
        initial-scratch-message nil
        ring-bell-function 'ignore
        use-short-answers t)            ; y/n instead of yes/no

  ;; Line numbers in programming modes
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (setq display-line-numbers-type 'relative) ; vim-style relative numbers

  ;; Smooth scrolling
  (setq scroll-margin 5
        scroll-conservatively 101
        scroll-up-aggressively 0.01
        scroll-down-aggressively 0.01)
  (pixel-scroll-precision-mode 1)

  ;; Files and saving
  (setq make-backup-files nil           ; no backup~ files
        auto-save-default t
        create-lockfiles nil
        require-final-newline t)

  ;; Indentation
  (setq-default indent-tabs-mode nil    ; spaces, not tabs
                tab-width 4)

  ;; Parens
  (electric-pair-mode 1)
  (show-paren-mode 1)
  (setq show-paren-delay 0)

  ;; Recent files
  (recentf-mode 1)
  (setq recentf-max-saved-items 100)

  ;; Save place in files
  (save-place-mode 1)

  ;; Remember minibuffer history
  (savehist-mode 1)

  ;; Auto-revert buffers when files change on disk
  (global-auto-revert-mode 1)

  ;; Column number in modeline
  (column-number-mode 1)

  ;; Highlight current line
  (global-hl-line-mode 1))

;;;; ──────────────────────────────────────────────────────────
;;;; Theme — Catppuccin Mocha
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: Catppuccin is a community theme with pastel colors.
;; "Mocha" is the darkest variant. Guix package: emacs-catppuccin-theme
(use-package catppuccin-theme
  :ensure nil
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin t))

;;;; ──────────────────────────────────────────────────────────
;;;; Evil Mode — Vim keybindings
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: Evil provides full Vim emulation in Emacs.
;; evil-collection extends it to work in all Emacs modes (magit, dired, etc).
(use-package evil
  :ensure nil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil        ; let evil-collection handle this
        evil-want-C-u-scroll t          ; C-u scrolls like vim
        evil-want-C-d-scroll t
        evil-undo-system 'undo-redo     ; native Emacs 28+ undo
        evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)
  ;; Use jk to escape insert mode (common vim pattern)
  (define-key evil-insert-state-map (kbd "j k") 'evil-normal-state))

(use-package evil-collection
  :ensure nil
  :after evil
  :config
  (evil-collection-init))

;; LEARNING: evil-surround adds vim-surround commands (cs, ds, ys)
(use-package evil-surround
  :ensure nil
  :after evil
  :config
  (global-evil-surround-mode 1))

;; LEARNING: evil-commentary adds gc for commenting (like vim-commentary)
(use-package evil-commentary
  :ensure nil
  :after evil
  :config
  (evil-commentary-mode 1))

;;;; ──────────────────────────────────────────────────────────
;;;; Keybindings — SPC leader via general.el
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: general.el lets you define leader-key based keybindings
;; like Doom Emacs / Spacemacs. SPC is the leader in normal/visual mode.
;; which-key shows a popup of available keys after pressing leader.

(use-package general
  :ensure nil
  :config
  (general-create-definer my/leader
    :keymaps 'override
    :states '(normal visual motion)
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Top-level shortcuts
  (my/leader
    "SPC" '(execute-extended-command :which-key "M-x")
    "."   '(find-file :which-key "find file")
    ","   '(consult-buffer :which-key "switch buffer")
    ";"   '(eval-expression :which-key "eval")
    "'"   '(vterm-toggle :which-key "terminal")
    "TAB" '(evil-switch-to-windows-last-buffer :which-key "last buffer")
    "u"   '(universal-argument :which-key "universal arg"))

  ;; Files
  (my/leader
    "f"   '(:ignore t :which-key "files")
    "f f" '(find-file :which-key "find file")
    "f r" '(consult-recent-file :which-key "recent files")
    "f s" '(save-buffer :which-key "save")
    "f S" '(write-file :which-key "save as")
    "f d" '(dired-jump :which-key "dired here"))

  ;; Buffers
  (my/leader
    "b"   '(:ignore t :which-key "buffers")
    "b b" '(consult-buffer :which-key "switch")
    "b k" '(kill-current-buffer :which-key "kill")
    "b n" '(next-buffer :which-key "next")
    "b p" '(previous-buffer :which-key "prev")
    "b s" '(scratch-buffer :which-key "scratch"))

  ;; Windows
  (my/leader
    "w"   '(:ignore t :which-key "windows")
    "w v" '(split-window-right :which-key "vsplit")
    "w s" '(split-window-below :which-key "split")
    "w d" '(delete-window :which-key "delete")
    "w o" '(delete-other-windows :which-key "only this")
    "w h" '(windmove-left :which-key "left")
    "w j" '(windmove-down :which-key "down")
    "w k" '(windmove-up :which-key "up")
    "w l" '(windmove-right :which-key "right"))

  ;; Search
  (my/leader
    "s"   '(:ignore t :which-key "search")
    "s s" '(consult-line :which-key "search buffer")
    "s p" '(consult-ripgrep :which-key "search project")
    "s f" '(consult-find :which-key "find file")
    "s i" '(consult-imenu :which-key "imenu")
    "s r" '(query-replace :which-key "replace"))

  ;; Git
  (my/leader
    "g"   '(:ignore t :which-key "git")
    "g g" '(magit-status :which-key "status")
    "g b" '(magit-blame :which-key "blame")
    "g l" '(magit-log-current :which-key "log")
    "g d" '(magit-diff :which-key "diff")
    "g f" '(magit-fetch :which-key "fetch")
    "g F" '(forge-pull :which-key "forge pull")
    "g t" '(git-timemachine :which-key "timemachine"))

  ;; AI
  (my/leader
    "a"   '(:ignore t :which-key "AI")
    "a a" '(gptel-send :which-key "send to AI")
    "a c" '(gptel-menu :which-key "AI menu")
    "a b" '(gptel :which-key "AI buffer")
    "a r" '(gptel-rewrite :which-key "AI rewrite")
    "a s" '(my/gptel-switch-backend :which-key "switch model"))

  ;; Org
  (my/leader
    "o"   '(:ignore t :which-key "org")
    "o a" '(org-agenda :which-key "agenda")
    "o c" '(org-capture :which-key "capture")
    "o r" '(org-roam-node-find :which-key "roam find")
    "o i" '(org-roam-node-insert :which-key "roam insert")
    "o d" '(org-roam-dailies-goto-today :which-key "today")
    "o t" '(org-todo :which-key "toggle todo")
    "o l" '(org-store-link :which-key "store link"))

  ;; Project
  (my/leader
    "p"   '(:ignore t :which-key "project")
    "p f" '(project-find-file :which-key "find file")
    "p p" '(project-switch-project :which-key "switch project")
    "p b" '(project-switch-to-buffer :which-key "buffer")
    "p s" '(consult-ripgrep :which-key "search")
    "p t" '(vterm-toggle :which-key "terminal"))

  ;; Code / LSP
  (my/leader
    "c"   '(:ignore t :which-key "code")
    "c a" '(eglot-code-actions :which-key "code action")
    "c r" '(eglot-rename :which-key "rename")
    "c d" '(xref-find-definitions :which-key "definition")
    "c D" '(xref-find-references :which-key "references")
    "c f" '(eglot-format :which-key "format")
    "c e" '(consult-flymake :which-key "errors"))

  ;; Help
  (my/leader
    "h"   '(:ignore t :which-key "help")
    "h f" '(describe-function :which-key "function")
    "h v" '(describe-variable :which-key "variable")
    "h k" '(describe-key :which-key "key")
    "h m" '(describe-mode :which-key "mode")
    "h i" '(info :which-key "info"))

  ;; Toggle
  (my/leader
    "t"   '(:ignore t :which-key "toggle")
    "t l" '(display-line-numbers-mode :which-key "line numbers")
    "t w" '(whitespace-mode :which-key "whitespace")
    "t z" '(writeroom-mode :which-key "zen mode")
    "t t" '(consult-theme :which-key "theme"))

  ;; Quit
  (my/leader
    "q"   '(:ignore t :which-key "quit")
    "q q" '(save-buffers-kill-terminal :which-key "quit")))

(use-package which-key
  :ensure nil
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.3
        which-key-sort-order 'which-key-key-order-alpha))

;;;; ──────────────────────────────────────────────────────────
;;;; Completion — Vertico + Consult + Orderless + Marginalia
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: This is the "VCO stack" — modern Emacs completion framework.
;; Vertico = vertical minibuffer UI
;; Consult = enhanced commands (search, buffer switch, etc)
;; Orderless = fuzzy matching
;; Marginalia = annotations in completion candidates
;; Corfu = in-buffer completion (like company-mode but lighter)

(use-package vertico
  :ensure nil
  :init (vertico-mode 1)
  :config
  (setq vertico-count 15
        vertico-cycle t))

(use-package orderless
  :ensure nil
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure nil
  :init (marginalia-mode 1))

(use-package consult
  :ensure nil
  :config
  (setq consult-narrow-key "<"))

(use-package embark
  :ensure nil
  :bind ("C-." . embark-act))

(use-package embark-consult
  :ensure nil
  :after (embark consult))

(use-package corfu
  :ensure nil
  :init (global-corfu-mode 1)
  :config
  (setq corfu-auto t                   ; auto-popup completions
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-quit-no-match 'separator))

;; LEARNING: cape adds more completion-at-point functions to corfu.
;; file paths, dabbrev (buffer words), elisp symbols, etc.
(use-package cape
  :ensure nil
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Better help buffers (from gunix manifest)
(use-package helpful
  :ensure nil
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

;;;; ──────────────────────────────────────────────────────────
;;;; Git — Magit + Forge
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: Magit is the best Git interface in any editor, period.
;; Forge adds GitHub/GitLab integration (PRs, issues, reviews).
(use-package magit
  :ensure nil
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :ensure nil
  :after magit)

;; LEARNING: git-timemachine lets you walk through a file's git history.
;; Press n/p to move between commits, q to quit.
(use-package git-timemachine
  :ensure nil)

;; Show git changes in the fringe
(use-package diff-hl
  :ensure nil
  :config
  (global-diff-hl-mode 1)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;;;; ──────────────────────────────────────────────────────────
;;;; AI — gptel (Claude + Gemini)
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: gptel is a lightweight AI client for Emacs.
;; It supports multiple backends (Claude, Gemini, OpenAI, local).
;; Secrets are loaded from ~/.secrets/ at shell startup.

(use-package gptel
  :ensure nil
  :config
  ;; Claude backend (default)
  (setq gptel-model 'claude-sonnet-4-20250514
        gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key (lambda () (getenv "ANTHROPIC_API_KEY"))))

  ;; Gemini backend
  (gptel-make-gemini "Gemini"
    :stream t
    :key (lambda () (getenv "GEMINI_API_KEY"))
    :models '(gemini-2.0-flash
              gemini-2.0-pro))

  ;; Quick model switcher
  (defun my/gptel-switch-backend ()
    "Toggle between Claude and Gemini backends."
    (interactive)
    (if (string= (gptel-backend-name gptel-backend) "Claude")
        (progn
          (setq gptel-backend (gptel-get-backend "Gemini")
                gptel-model 'gemini-2.0-flash)
          (message "Switched to Gemini"))
      (setq gptel-backend (gptel-get-backend "Claude")
            gptel-model 'claude-sonnet-4-20250514)
      (message "Switched to Claude"))))

;;;; ──────────────────────────────────────────────────────────
;;;; Org-mode + Org-roam (Zettelkasten)
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: Org-roam implements a Zettelkasten (slip-box) system.
;; Each note is a node in a graph. Links between notes build knowledge.
;; Flat structure — no folders, use tags and links for organization.

(use-package org
  :ensure nil
  :config
  (setq org-directory "~/org"
        org-default-notes-file "~/org/inbox.org"
        org-return-follows-link t
        org-hide-emphasis-markers t
        org-startup-indented t
        org-ellipsis " ..."
        org-log-done 'time
        org-agenda-files '("~/org"))

  ;; Capture templates — extended for learning + AI + code + bookmarks
  (setq org-capture-templates
        '(("t" "Todo" entry (file "~/org/inbox.org")
           "* TODO %?\n%U\n%a" :empty-lines 1)
          ("n" "Note" entry (file "~/org/inbox.org")
           "* %?\n%U" :empty-lines 1)
          ("j" "Journal" entry (file+datetree "~/org/journal.org")
           "* %?\n%U" :empty-lines 1)
          ("l" "Learning" entry (file "~/org/learning.org")
           "* %? :learning:\n%U\n** Topic: \n** Key Insight: \n** Source: " :empty-lines 1)
          ("c" "Code Snippet" entry (file "~/org/snippets.org")
           "* %? :code:\n%U\n#+begin_src %^{Language}\n%i\n#+end_src\n** Context: %a" :empty-lines 1)
          ("a" "AI Conversation" entry (file "~/org/ai-notes.org")
           "* %? :ai:\n%U\n** Model: %^{Model|Claude|Gemini}\n** Prompt: \n** Response:\n%i" :empty-lines 1)
          ("b" "Bookmark" entry (file "~/org/bookmarks.org")
           "* %? :bookmark:\n%U\n%a\n** Notes: " :empty-lines 1))))

;; Org beautification (from gunix + doom config)
(use-package org-modern
  :ensure nil
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "◈" "◇" "▸")))

(use-package org-appear
  :ensure nil
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t))

(use-package org-superstar
  :ensure nil
  :hook (org-mode . org-superstar-mode))

;; LEARNING: org-roam-ui gives you a web-based graph visualization
;; of your knowledge network. Run M-x org-roam-ui-mode to open it.
(use-package org-roam-ui
  :ensure nil
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t))

(use-package org-roam
  :ensure nil
  :config
  (setq org-roam-directory "~/org/roam"
        org-roam-db-location "~/org/roam/org-roam.db"
        ;; Zettelkasten: flat structure, no subdirectories
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: \n")
           :unnarrowed t)
          ("r" "reference" plain "%?"
           :target (file+head "ref/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :reference:\n")
           :unnarrowed t))
        org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        '(("d" "daily" entry "* %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n"))))
  (org-roam-db-autosync-mode 1))

;;;; ──────────────────────────────────────────────────────────
;;;; LSP — Eglot + Tree-sitter
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: Eglot is built into Emacs 29+ — it's the lightweight LSP client.
;; Tree-sitter provides fast, incremental syntax highlighting.
;; Both are part of core Emacs now, Guix provides the grammar packages.

;; Snippets (from gunix manifest)
(use-package yasnippet
  :ensure nil
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure nil
  :after yasnippet)

;; Syntax checking
(use-package flycheck
  :ensure nil
  :hook (prog-mode . flycheck-mode))

;; Highlight TODOs in code
(use-package hl-todo
  :ensure nil
  :hook (prog-mode . hl-todo-mode))

(use-package eglot
  :ensure nil
  :hook ((python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (scheme-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t           ; shutdown LSP when buffer closed
        eglot-events-buffer-size 0))   ; less memory for logs

(use-package treesit-auto
  :ensure nil
  :config
  (setq treesit-auto-install nil)      ; Guix manages grammars
  (global-treesit-auto-mode 1))

;;;; ──────────────────────────────────────────────────────────
;;;; Language-specific
;;;; ──────────────────────────────────────────────────────────

;; Guile Scheme — for Guix configs
;; LEARNING: geiser provides a Scheme REPL in Emacs. geiser-guile
;; connects to Guile specifically. Essential for Guix development.
(use-package geiser
  :ensure nil)
(use-package geiser-guile
  :ensure nil
  :config
  (setq geiser-guile-binary "guile"
        geiser-default-implementation 'guile))

;; Rust
(use-package rust-mode
  :ensure nil
  :config
  (setq rust-format-on-save t))

;; Python
;; LEARNING: python-mode is built-in. We just configure it to use eglot.

;; Markdown
(use-package markdown-mode
  :ensure nil)

;; YAML
(use-package yaml-mode
  :ensure nil)

;;;; ──────────────────────────────────────────────────────────
;;;; Terminal — vterm
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: vterm is the best terminal emulator inside Emacs.
;; It's a compiled C library (libvterm) — very fast and compatible.
(use-package vterm
  :ensure nil
  :config
  (setq vterm-max-scrollback 10000
        vterm-shell "/bin/zsh"))

(use-package vterm-toggle
  :ensure nil
  :config
  (setq vterm-toggle-scope 'project))

;;;; ──────────────────────────────────────────────────────────
;;;; Project management
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: project.el is built into Emacs — manages project roots.
;; No need for projectile with modern Emacs.

;;;; ──────────────────────────────────────────────────────────
;;;; UI enhancements
;;;; ──────────────────────────────────────────────────────────

;; Modeline
(use-package doom-modeline
  :ensure nil
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 30
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-buffer-encoding nil))

;; Icons
(use-package nerd-icons
  :ensure nil)

;; Dashboard
(use-package dashboard
  :ensure nil
  :config
  (setq dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-items '((recents . 10)
                          (projects . 5)
                          (agenda . 5))
        dashboard-set-heading-icons t
        dashboard-set-file-icons t)
  (dashboard-setup-startup-hook))

;; Zen mode for focused writing
(use-package writeroom-mode
  :ensure nil)

;; Direnv integration
(use-package direnv
  :ensure nil
  :config
  (direnv-mode 1))

;; Rainbow delimiters for Lisp
(use-package rainbow-delimiters
  :ensure nil
  :hook (prog-mode . rainbow-delimiters-mode))

;;;; ──────────────────────────────────────────────────────────
;;;; Guile Scheme helpers (for learning Guix)
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: These help you work with Guix config files.
;; guix-mode provides Guix-specific features in Scheme buffers.

(defun my/guix-edit-system ()
  "Open the Guix system configuration."
  (interactive)
  (find-file "~/cahy/guix/system.scm"))

(defun my/guix-edit-home ()
  "Open the Guix Home configuration."
  (interactive)
  (find-file "~/cahy/guix/home.scm"))

;; Add to leader keys
(with-eval-after-load 'general
  (my/leader
    "G"   '(:ignore t :which-key "Guix")
    "G s" '(my/guix-edit-system :which-key "system.scm")
    "G h" '(my/guix-edit-home :which-key "home.scm")
    "G r" '((lambda () (interactive)
              (async-shell-command
               "guix home reconfigure ~/cahy/guix/home.scm"))
            :which-key "home reconfigure")
    "G p" '((lambda () (interactive)
              (async-shell-command "guix pull"))
            :which-key "guix pull")
    "G e" '(geiser :which-key "Guile REPL")
    "G g" '(guix :which-key "Guix interface")
    "G i" '(guix-packages-by-name :which-key "search packages")))

;; LEARNING: emacs-guix lets you browse, search, and manage Guix packages
;; entirely from within Emacs. SPC G g opens the main interface.
(use-package guix
  :ensure nil)

;;;; ──────────────────────────────────────────────────────────
;;;; Waybar integration — Emacs status in status bar
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: This function is called by Waybar's custom/emacs module.
;; It returns a status string showing what you're doing in Emacs.
(defun my/waybar-status ()
  "Return a status string for Waybar."
  (let ((clock (when (bound-and-true-p org-clock-current-task)
                 (format "[%s] %s"
                         (org-duration-from-minutes
                          (org-clock-get-clocked-time))
                         (substring-no-properties org-clock-current-task
                                                  0 (min 30 (length org-clock-current-task))))))
        (ai (when (bound-and-true-p gptel-backend)
              (gptel-backend-name gptel-backend)))
        (buf (buffer-name (current-buffer))))
    (cond
     (clock (format "%s" clock))
     (ai (format "%s | %s" ai (truncate-string-to-width buf 20)))
     (t (truncate-string-to-width buf 25)))))

;;;; ──────────────────────────────────────────────────────────
;;;; Auto-open daily note on startup
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: This opens today's org-roam daily note when Emacs starts.
;; Great for building a daily journaling habit.
(add-hook 'emacs-startup-hook
          (lambda ()
            (when (and (not (daemonp))
                       (file-directory-p "~/org/roam"))
              (org-roam-dailies-goto-today))))

;;;; ──────────────────────────────────────────────────────────
;;;; Email — mu4e + Gmail
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: mu4e is an Emacs email client backed by the `mu` indexer.
;; It reads Maildir format. Use `mbsync` (isync) to sync Gmail via IMAP.
;; Setup requires: 1) mbsync config 2) mu init 3) mu4e config below.
;;
;; First-time setup (run in terminal):
;;   mu init --maildir=~/Mail --my-address=omranaltunaiji@gmail.com
;;   mu index

(use-package mu4e
  :ensure nil
  :config
  (setq mu4e-maildir "~/Mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300        ; check every 5 min
        mu4e-compose-signature-auto-include nil
        mu4e-view-show-images t
        mu4e-view-show-addresses t
        mu4e-change-filenames-when-moving t ; required for mbsync

        ;; Gmail-specific
        mu4e-sent-folder "/Gmail/[Gmail]/Sent Mail"
        mu4e-drafts-folder "/Gmail/[Gmail]/Drafts"
        mu4e-trash-folder "/Gmail/[Gmail]/Trash"
        mu4e-refile-folder "/Gmail/[Gmail]/All Mail"

        ;; Sending (via Gmail SMTP)
        message-send-mail-function 'smtpmail-send-it
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        smtpmail-stream-type 'starttls
        smtpmail-smtp-user "omranaltunaiji@gmail.com")

  ;; Bookmarks for quick access
  (setq mu4e-bookmarks
        '((:name "Unread" :query "flag:unread AND NOT flag:trashed" :key ?u)
          (:name "Today" :query "date:today.." :key ?t)
          (:name "Week" :query "date:7d.." :key ?w)
          (:name "Flagged" :query "flag:flagged" :key ?f))))

;; Add email to leader keys
(with-eval-after-load 'general
  (my/leader
    "m"   '(:ignore t :which-key "mail")
    "m m" '(mu4e :which-key "open mail")
    "m c" '(mu4e-compose-new :which-key "compose")
    "m u" '(mu4e-update-mail-and-index :which-key "update")))

;;;; ──────────────────────────────────────────────────────────
;;;; Guile Scheme learning enhancements
;;;; ──────────────────────────────────────────────────────────

;; LEARNING: eldoc shows function signatures in the minibuffer as you type.
;; Built into Emacs, works with geiser for Scheme.
(add-hook 'scheme-mode-hook #'eldoc-mode)

;; Auto-indent Scheme on save
;; LEARNING: This ensures consistent formatting in .scm files.
(defun my/scheme-format-on-save ()
  "Indent the entire buffer on save for Scheme files."
  (when (derived-mode-p 'scheme-mode)
    (indent-region (point-min) (point-max))))
(add-hook 'before-save-hook #'my/scheme-format-on-save)

;; Scheme-specific keybindings
(with-eval-after-load 'general
  (general-define-key
   :states '(normal visual)
   :keymaps 'scheme-mode-map
   :prefix "SPC l"
   "" '(:ignore t :which-key "Scheme")
   "e" '(geiser-eval-definition :which-key "eval defn")
   "b" '(geiser-eval-buffer :which-key "eval buffer")
   "r" '(geiser-eval-region :which-key "eval region")
   "d" '(geiser-doc-symbol-at-point :which-key "docs")
   "s" '(geiser :which-key "REPL")
   "c" '(geiser-connect :which-key "connect")))

;; LEARNING: org-protocol lets you capture URLs from Firefox.
;; Install the org-protocol Firefox extension, then clicking the
;; bookmarklet sends the URL to Emacs org-capture.
(use-package org-protocol
  :ensure nil
  :config
  (setq org-protocol-default-template-key "b"))

;;; init.el ends here
