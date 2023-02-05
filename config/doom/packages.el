;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! boon)
(package! elcord :recipe (:host github
                          :repo "chaoky/elcord"))
(package! org-projectile)
(package! ob-sql-mode)
;; (package! activity-watch-mode)
(package! wakatime-mode)
(package! prisma-mode :recipe (:host github :repo "pimeys/emacs-prisma-mode" :branch "main"))
