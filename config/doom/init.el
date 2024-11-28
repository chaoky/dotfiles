;;; init.el -*- lexical-binding: t; -*-
(setenv "LSP_USE_PLISTS" "1")


(doom!
 :os 
  tty

 :completion
 (corfu +orderless) 
 (vertico +icons)

 :ui
 doom
 hl-todo
 indent-guides
 (ligatures +extra)
 modeline
 nav-flash
 ophints
 (popup +defaults)
 (treemacs +lsp)
 vi-tilde-fringe
 (window-select +switch-window)
 workspaces

 :editor
 file-templates
 fold
 format
 multiple-cursors
 snippets
 word-wrap

 :emacs
 (dired +icons)
 (undo +tree)
 ;; vc

 :term
 vterm

 :checkers
 syntax
 (spell +everywhere +aspell)

 :tools
 direnv
 (docker +lsp)
 editorconfig
 lookup
 lsp
 magit
 pdf
 rgb
 tree-sitter

 :lang
 (json +lsp +tree-sitter)
 (javascript +lsp +tree-sitter)
 (rust +lsp +tree-sitter)
 (scala +lsp +tree-sitter)
 (web +lsp +tree-sitter)
 (yaml +lsp +tree-sitter)
 (sh +fish +powershell +lsp +tree-sitter)
 (graphql +lsp)
 (org +present)
 (markdown +grip)
 (rest +jq)
 emacs-lisp
 data

 :app
 irc

 :config
 (default +bindings +smartparens))
