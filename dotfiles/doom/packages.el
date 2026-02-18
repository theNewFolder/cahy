;;; packages.el -*- lexical-binding: t; -*-
;; Extra packages beyond what Doom modules provide

;; AI integration
(package! gptel)                    ; LLM chat (Claude + Gemini backends)
(package! claude-code               ; Claude Code Emacs integration
  :recipe (:host github :repo "stevemolitor/claude-code.el"))

;; Org extensions
(package! org-roam-ui)              ; Graph visualization for org-roam
(package! org-modern)               ; Modern org-mode styling (replaces org-superstar)
(package! org-superstar :disable t) ; Replaced by org-modern
(package! toc-org)                  ; Auto-generate TOC in org files (from DistroTube)
(package! org-appear)               ; Show emphasis markers when cursor is on them

;; Productivity (inspired by SystemCrafters)
(package! olivetti)                 ; Centered writing mode
(package! git-timemachine)          ; Walk through file git history (from DistroTube)

;; Theme
(package! gruvbox-theme)            ; Gruvbox color theme
