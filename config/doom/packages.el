;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! boon)
(package! elcord :recipe (:host github
                          :repo "chaoky/elcord"))
(package! ob-sql-mode)
;; (package! activity-watch-mode)
(package! wakatime-mode)
(package! prisma-mode :recipe (:host github :repo "pimeys/emacs-prisma-mode" :branch "main"))

(package! tsi :recipe (:host github :repo "orzechowskid/tsi.el"))
(package! tsx-mode :recipe (:host github :repo "orzechowskid/tsx-mode.el" :branch "emacs28"))

(package! protobuf-mode)
