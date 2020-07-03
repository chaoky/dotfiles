;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "lordie"
      user-mail-address "levimanga@gmail.com"
      doom-theme 'doom-one
      doom-font (font-spec :family "UZURA_FONT" :size 16)
      org-directory "~/org/"
      display-line-numbers-type t)

(use-package! boon
  :config (require 'boon-colemak)
  (boon-mode)
  (general-define-key :keymaps 'boon-command-map
      "p" 'swiper
      "C-e" 'doom/escape
      "c" (general-simulate-key "C-c"))
  (general-define-key :keymaps 'global-map
      "C-e" 'boon-set-command-state)
  (general-define-key :keymaps 'boon-x-map
      "f" 'find-file))

(use-package! rainbow-mode
  :config (add-to-list 'minor-mode-list 'rainbow-mode))
