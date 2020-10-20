;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! boon)
(package! key-chord)
(package! fish-mode)
(package! ivy-hoogle :recipe ( :host github
                               :repo "sjsch/ivy-hoogle"))

(package! tsc :recipe (:host github
                       :repo "ubolonton/emacs-tree-sitter"
                       :files ("core/*.el")))

(package! tree-sitter :recipe ( :host github
                                :repo "ubolonton/emacs-tree-sitter"
                                :files ("lisp/*.el")))

(package! tree-sitter-langs :recipe ( :host github
                                      :repo "ubolonton/emacs-tree-sitter"
                                      :files ("langs/*.el" "langs/queries")))
