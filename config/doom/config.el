;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(load-file "$HOME/.config/doom/custom.el")

(setq user-full-name "chaoky"
      user-mail-address "levimanga@gmail.com"
      ORG-directory "~/org/"
      doom-theme 'doom-rouge
      doom-font (font-spec :family "Iosevka" :size 16)
      save-interprogram-paste-before-kill t
      enable-local-variables t
      default-directory "~/projects/"
      )

(setq +word-wrap-extra-indent 0) ;;show wrapped text right bellow
(setq word-wrap-by-category t)
(modify-category-entry ?= ?| (standard-category-table)) ;;line wrap on `=`

(use-package! boon
  :init
  (require 'switch-window)
  (require 'boon-colemak)
  (require 'vterm)
  :config
  (boon-mode)
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
            "c" (general-simulate-key "C-c")
            "p" (general-simulate-key "C-c s b")
            "D" 'lsp-ui-doc-glance
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
            "C-e" (general-simulate-key "C-g")
            )

  (:keymaps 'boon-insert-map
            "C-e" 'boon-set-command-state
            )
  )

(use-package! ob-sql-mode)

(use-package! treesit-auto
  :config
  (global-treesit-auto-mode))

(use-package! wakatime-mode :config (global-wakatime-mode))

(use-package! typescript-ts-mode
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode))
  :config
  (add-hook! '(typescript-ts-mode-hook tsx-ts-mode-hook) #'lsp!)
  (add-hook! '(typescript-ts-mode-hook tsx-ts-mode-hook) #'lsp!)
  (setq-hook! '(typescript-ts-mode-hook tsx-ts-mode-hook) +format-with-lsp nil)
  (after! format-all
    (format-all--pushhash
     'tsx-mode
     '(prettier closure
       (t)
       nil "typescript")
     format-all--mode-table))
  )

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
   projectile-project-search-path '(("~/projects" . 3))
   projectile-project-root-files-bottom-up (delete ".git" projectile-project-root-files-bottom-up)
   projectile-project-root-files (cons ".git" projectile-project-root-files)
   projectile-globally-ignored-directories (append '("*node_modules") projectile-globally-ignored-directories)
   ;; projectile-ignored-project-function '(lambda (project-name) (cl-search "node_modules" project-name))
   ))

(after! web-mode
  (setq web-mode-enable-auto-indentation nil))

(after! vterm
  (setq
   vterm-buffer-name "vterm"
   vterm-shell "zsh"))

(after! treemacs
  (setq treemacs-read-string-input 'from-minibuffer))

(after! lsp-mode
  (advice-add 'json-parse-buffer :around
              (lambda (orig &rest rest)
                (save-excursion
                  (while (re-search-forward "\\\\u0000" nil t)
                    (replace-match "")))
                (apply orig rest))))

(after! json-mode
  (setq-hook! 'json-mode-hook
    +format-with-lsp nil
    +format-with 'prettier))
