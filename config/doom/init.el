;;; init.el -*- lexical-binding: t; -*-
(setenv "LSP_USE_PLISTS" "1")


(doom!
 :completion
 company
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
 (vc-gutter +pretty +diff-hl)
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
 electric
 ibuffer
 undo
 vc

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
 (haskell +dante +lsp +tree-sitter)
 (json +lsp +tree-sitter)
 (javascript +lsp +tree-sitter)
 (python +lsp +tree-sitter)
 (rust +lsp +tree-sitter)
 (scala +lsp +tree-sitter)
 (web +lsp +tree-sitter)
 (yaml +lsp +tree-sitter)
 (sh +fish +powershell +lsp +tree-sitter)
 (nix +tree-sitter)
 (graphql +lsp)
 (org +pretty +present +pandoc +noter)
 emacs-lisp
 data
 (markdown +grip)
 rest

 :app
 irc
 everywhere

 :config
 (default +bindings +smartparens))
