;;; init.el -*- lexical-binding: t; -*-
(setenv "LSP_USE_PLISTS" "1")


(doom!
 :completion
 company
 (vertico +icons)

 :ui
 doom
 doom-quit
 hl-todo
 indent-guides
 (ligatures +extra)
 modeline
 nav-flash
 ophints
 (popup +all)
 treemacs
 unicode
 (vc-gutter +pretty)
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
 undo
 vc

 :term
 eshell
 vterm

 :checkers
 syntax
 (spell +everywhere +aspell)

 :tools
 (debugger +lsp)
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
 nix
 (clojure +lsp)
 (csharp +lsp +tree-sitter)
 data
 (elixir +lsp +tree-sitter)
 emacs-lisp
 graphql
 (haskell +dante +lsp)
 (json +lsp +tree-sitter)
 (javascript +lsp +tree-sitter)
 (markdown +grip)
 nim
 (org +pretty +present +pandoc +noter)
 plantuml
 (purescript +lsp)
 (python +lsp +tree-sitter)
 rest
 (rust +lsp)
 (scala +lsp +tree-sitter)
 (sh +lsp +fish +powershell +tree-sitter)
 (web +lsp +tree-sitter)
 (yaml +lsp)

 :app
 irc
 everywhere

 :config
 (default +bindings +smartparens)

 :os
 tty
 )
