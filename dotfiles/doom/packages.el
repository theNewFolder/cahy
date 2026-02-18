;;; packages.el -*- lexical-binding: t; -*-
;; Extra packages beyond what Doom modules provide

;; AI integration
(package! gptel)                    ; LLM chat (Claude + Gemini backends)
(package! claude-code               ; Claude Code Emacs integration
  :recipe (:host github :repo "stevemolitor/claude-code.el"))

;; Org extensions
(package! org-roam-ui)              ; Graph visualization for org-roam
(package! org-superstar)            ; Better heading bullets

;; Theme
(package! gruvbox-theme)            ; Gruvbox color theme
