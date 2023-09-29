;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(load-file "$HOME/.config/doom/custom.el")

(setq user-full-name "chaoky"
      user-mail-address "levimanga@gmail.com"
      org-directory "~/org/"
      doom-theme 'doom-ephemeral
      doom-font (font-spec :family "Iosevka" :size 16)
      save-interprogram-paste-before-kill t
      enable-local-variables t
      default-directory "~/Projects/"
      )

;;show wrapped text right bellow
(setq +word-wrap-extra-indent 0)
(other-window 0)
;;line wrap on `=`
(setq word-wrap-by-category t)
(modify-category-entry ?= ?| (standard-category-table))

(use-package! boon
  :init
  (require 'switch-window)
  (require 'boon-colemak)
  (require 'vterm)
  (boon-mode)
  :config
  (defadvice! +vterm-update-cursor-boon (orig-fn &rest args) :before #'boon-insert (vterm-goto-char (point)))
  (fset 'boon-special-mode-p #'(lambda () nil)) ;;special mode sucks I can just press Q and change context
  (setq boon-insert-conditions '((cl-search "emacs-everywhere" (buffer-name))))
  :general
  (:keymaps 'boon-command-map
            "M-1" '+workspace/switch-to-0
            "M-2" '+workspace/switch-to-1
            "M-3" '+workspace/switch-to-2
            "M-4" '+workspace/switch-to-3
            "C-w" 'switch-window-mvborder-up
            "C-r" 'switch-window-mvborder-down
            "C-a" 'switch-window-mvborder-left
            "C-s" 'switch-window-mvborder-right
            "C-b" 'balance-windows
            "C-e" 'doom/escape
            "c" (general-simulate-key "C-c")
            "p" (general-simulate-key "C-c s b")
            "D" 'lsp-describe-thing-at-point
            "O" 'forward-sexp
            "N" 'backward-sexp
            "L" 'beginning-of-visual-line
            ":" 'end-of-visual-line
            )

  (:keymaps 'boon-x-map
            "s" 'save-buffer
            "C-s" 'save-some-buffers
            "f" 'find-file
            "l" '+fold/toggle
            )

  (:keymaps 'global-map
            "C-e" 'boon-set-command-state
            )
  )

;; (use-package! elcord
;;   :config
;;   (setq
;;    elcord-use-major-mode-as-main-icon t)
;;   (elcord-mode t))

(use-package! ob-sql-mode :defer t)

(use-package! wakatime-mode :config (global-wakatime-mode))

(use-package! tsx-mode
  :hook (tsx-mode . rainbow-delimiters-mode)
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-mode))
  (after! all-the-icons
    (add-to-list 'all-the-icons-mode-icon-alist
                 '(tsx-mode all-the-icons-fileicon "tsx" :v-adjust -0.1 :face all-the-icons-cyan-alt)))
  (setq-hook! 'tsx-mode-hook +format-with-lsp nil)
  (after! format-all
    (format-all--pushhash
     'tsx-mode
     '(prettier closure
       (t)
       nil "typescript")
     format-all--mode-table)))

(after! typescript-mode
  (setq +format-with-lsp nil))

(use-package! protobuf-mode)

(after! flycheck
  (set-face-attribute 'flycheck-warning nil :underline nil))

(after! (:and rustic lsp-mode)
  (setq
   lsp-disabled-clients '(rls)
   ;; lsp-rust-analyzer-diagnostics-disabled ["unresolved-proc-macro"]
   lsp-rust-analyzer-cargo-watch-command "clippy"
   lsp-rust-analyzer-cargo-watch-args "-Zunstable-options"
   lsp-rust-analyzer-server-display-inlay-hints nil
   +format-with-lsp t
   ))

(after! switch-window
  (setq
   switch-window-shortcut-style 'qwerty
   switch-window-qwerty-shortcuts '("n" "e" "i" "o" "'")
   switch-window-extra-map nil
   switch-window-threshold 2
   )
  ;;don't ignore `no-other-window'
  (fset 'switch-window--other-window-or-frame
        #'(lambda ()
            (if switch-window-multiple-frames
                (switch-window--select-window (next-window nil nil 'visible))
              (next-window-any-frame))))
  )

(after! projectile
  (setq
   projectile-project-search-path '(("~/Projects" . 3))
   projectile-project-root-files-bottom-up (delete ".git" projectile-project-root-files-bottom-up)
   projectile-project-root-files (cons ".git" projectile-project-root-files)
   ;; projectile-globally-ignored-directories (append '("*node_modules" "node_modules" "*/node_modules") projectile-globally-ignored-directories)
   ;; projectile-ignored-project-function '(lambda (project-name) (cl-search "node_modules" project-name))
   ))

(after! web-mode
  (setq web-mode-enable-auto-indentation nil))

(after! vterm
  (setq
   vterm-buffer-name "vterm"
   vterm-shell "fish"))

(after! treemacs
  (setq treemacs-read-string-input 'from-minibuffer)
  (treemacs-project-follow-mode t))

(after! lsp-mode
  (advice-add 'json-parse-buffer :around
              (lambda (orig &rest rest)
                (save-excursion
                  (while (re-search-forward "\\\\u0000" nil t)
                    (replace-match "")))
                (apply orig rest))))
