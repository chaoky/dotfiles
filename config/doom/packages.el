;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! boon)
(package! key-chord)
(package! ivy-hoogle :recipe ( :host github
                               :repo "sjsch/ivy-hoogle"))
(package! org-kanban)
(package! org-projectile)

(package! eaf :recipe (:host github
                       :repo  "manateelazycat/emacs-application-framework"
                       :files ("*")))

(package! graphql-mode)
(package! caddyfile-mode)
(package! elcord)
