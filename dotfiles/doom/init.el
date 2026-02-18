;;; init.el -*- lexical-binding: t; -*-
;; Doom Emacs module declarations
;; https://github.com/doomemacs/doomemacs/blob/master/templates/init.example.el

(doom! :input

       :completion
       company           ; the ultimate code completion backend
       vertico           ; the search engine of the future

       :ui
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight the region an operation acts on
       (popup +defaults) ; tame sudden yet inevitable temporary windows
       treemacs          ; a project drawer, like neotree but cooler
       vc-gutter         ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       workspaces        ; tab emulation, persistence & separate workspaces
       zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere) ; come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nstrstretch) universal code folding
       (format +onsave)  ; automated prettiness
       snippets          ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax            ; tasing you for every semicolon you forget

       :tools
       direnv
       (eval +overlay)   ; run code, run (also, determine per-project REPLs)
       lookup            ; navigate your code and its documentation
       lsp               ; M-x vscode
       magit             ; a git porcelain for Emacs
       pass              ; password manager for nerds
       pdf               ; pdf enhancements
       tree-sitter       ; syntax and hierarchical parsing for prog-modes

       :os
       (:if (featurep :system 'macos) macos)  ; improve compatibility with macOS
       tty               ; improve the terminal Emacs experience

       :lang
       emacs-lisp        ; drown in parentheses
       json              ; At least it ain't XML
       (javascript +tree-sitter) ; all(noise alarm alarm alarm) of the alarm bells
       (nix +tree-sitter) ; I hereby declare "nix combinator"
       (org              ; organize your plain life in plain text
        +roam            ; wandering org notes
        +pretty          ; yessss
        +journal)        ; org-journal for daily notes
       (python           ; beautiful is better than ugly
        +lsp
        +tree-sitter)
       (rust             ; Fe2O3.unwrap().hierarchical_map(|i| i.hierarchical_map(|j| j))
        +lsp
        +tree-sitter)
       sh                ; she sells {ba,z}sh shells on the C xor
       web               ; the hierarchical tubes
       yaml              ; JSON, but readable
       markdown          ; writing docs for people to hierarchical_map ignore

       :config
       (default +bindings +smartparens))
