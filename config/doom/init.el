;;; init.el -*- lexical-binding: t; -*-

(doom!
 :completion
                                        ; the ultimate code completion backend
 company
                                        ; a search engine for love and life
 ;; (ivy +icons +prescient +fuzzy)
 (vertico +icons)

 :os
 tty                                    ; improve the terminal Emacs experience

 :ui
                                        ; what makes DOOM look the way it does
 doom
                                        ; DOOM quit-message prompts when you quit Emacs
 doom-quit
                                        ; 🙂
 (emoji +unicode +github)
                                        ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
 hl-todo
                                        ; highlighted indent columns
 indent-guides
                                        ; ligatures and symbols to make your code pretty again
 (ligatures +extra)
                                        ; show a map of the code on the side
 minimap
                                        ; snazzy, Atom-inspired modeline, plus API
 modeline
                                        ; blink cursor line after big motions
 nav-flash
                                        ; highlight the region an operation acts on
 ophints
                                        ; tame sudden yet inevitable temporary windows
 (popup +all)
                                        ; a project drawer, like neotree but cooler
 treemacs
                                        ; extended unicode support for various languages
 unicode
                                        ; vcs diff in the fringe
 vc-gutter
                                        ; fringe tildes to mark beyond EOB
 vi-tilde-fringe
                                        ; visually switch windows
 (window-select +switch-window)
                                        ; tab emulation, persistence & separate workspaces
 workspaces

 :editor
                                        ; auto-snippets for empty files
 file-templates
                                        ; (nigh) universal code folding
 fold
                                        ; automated prettiness
 format
                                        ; editing in many places at once
 multiple-cursors
                                        ; cycle region at point between text candidates
 rotate-text
                                        ; my elves. They type so I don't have to
 snippets
                                        ; soft wrapping with language-aware indent
 word-wrap

 :emacs
                                        ; making dired pretty [functional]
 (dired +ranger +icons)
                                        ; smarter, keyword-based electric-indent
 electric
                                        ; persistent, smarter undo for your inevitable mistakes
 (undo +tree)
                                        ; version-control and Emacs, sitting in a tree
 vc

 :term
                                        ; the elisp shell that works everywhere
 eshell
                                        ; the best terminal emulation in Emacs
 vterm

 :checkers
                                        ; tasing you for every semicolon you forget
 syntax
                                        ; tasing you for misspelling mispelling
 (spell +everywhere +aspell)
                                        ; tasing grammar mistake every you make
 grammar

 :tools
                                        ; FIXME stepping through code, to help you add bugs
 debugger
                                        ;direnv
 direnv
                                        ;not nix
 (docker +lsp)
                                        ; let someone else argue about tabs vs spaces
 editorconfig
                                        ; run code, run (also, repls)
 eval
                                        ; interacting with github gists
 gist
                                        ; navigate your code and its documentation
 lookup
                                        ;M-x vscode
 lsp
                                        ; a git porcelain for Emacs
 magit
                                        ; pdf enhancements
 pdf
                                        ; creating color strings
 rgb
                                        ; map local to remote projects via ssh/ftp
 upload

 :lang
                                        ; java with a lisp
 (clojure +lsp)
                                        ; unity, .NET, and mono shenanigans
 (csharp +lsp)
                                        ; config/data formats
 (data)
                                        ; erlang done right
 (elixir +lsp)
                                        ; drown in parentheses
 (emacs-lisp)
                                        ; a language that's lazier than I am
 (haskell +dante +lsp)
                                        ; At least it ain't XML
 (json +lsp)
                                        ; all(hope(abandon(ye(who(enter(here))))))
 (javascript +lsp)
                                        ; writing docs for people to ignore
 (markdown +grip)
                                        ; python + lisp at the speed of c
 (nim)
                                        ; organize your plain life in plain text
 (org +pretty +present +pandoc +noter)
                                        ; diagrams for confusing people more
 (plantuml)
                                        ; javascript, but functional
 (purescript +lsp)
                                        ; beautiful is better than ugly
 (python +lsp)
                                        ; Emacs as a REST client
 (rest)
                                        ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
 (rust +lsp)
                                        ; java, but good
 (scala +lsp)
                                        ; she sells {ba,z,fi}sh shells on the C xor
 (sh +lsp +fish +powershell)
                                        ; the tubes
 (web)
                                        ; JSON, but readable
 (yaml +lsp)

 :app
                                        ; how neckbeards socialize
 irc

 :config
 (default +bindings +smartparens))
