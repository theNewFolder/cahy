;;; early-init.el — Guix-native Emacs early initialization -*- lexical-binding: t; -*-

;; LEARNING: early-init.el runs before the GUI frame is created.
;; Use it for performance settings that must be set very early.

;; Disable package.el — Guix manages all packages
(setq package-enable-at-startup nil)

;; Faster startup: increase GC threshold during init
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Reset GC after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)  ; 16MB
                  gc-cons-percentage 0.1)))

;; Prevent UI flicker during startup
(setq default-frame-alist
      '((menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)
        (font . "DankMono Nerd Font-13")))

;; Native compilation settings (Guix emacs-next-pgtk supports this)
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t))

;; Prevent the glimpse of un-styled Emacs
(setq inhibit-redisplay t
      inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq inhibit-redisplay nil
                  inhibit-message nil)
            (redisplay)))
