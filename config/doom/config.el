;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(load-file "$HOME/.config/doom/custom.el")

(setq user-full-name "chaoky"
      user-mail-address "levimanga@gmail.com"
      org-directory "~/org/"
      doom-theme 'doom-ephemeral
      doom-font (font-spec :family "Iosevka" :size 15)
      save-interprogram-paste-before-kill t
      enable-local-variables t
      default-directory "~/Projects/"
      )

(use-package! boon
  :init
  (require 'switch-window)
  (require 'boon-colemak)
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
            )

  (:keymaps 'boon-x-map
            "s" 'save-buffer
            "C-s" 'save-some-buffers
            "f" 'find-file
            "l" '+fold/toggle
            )

  (:keymaps 'global-map
            "C-e" 'boon-set-command-state)
  )

(use-package! elcord
  :config
  (setq
   elcord-use-major-mode-as-main-icon t)
  (elcord-mode t))

(use-package! org-projectile
  :config
  (org-projectile-per-project)
  (setq org-projectile-per-project-filepath "/docs/todo.org")
  (setq org-agenda-files (append org-agenda-files (org-projectile-todo-files))))

(use-package! ob-sql-mode :defer t)

(use-package! wakatime-mode :config (global-wakatime-mode))

(after! flycheck
  (set-face-attribute 'flycheck-warning nil :underline nil))

(after! tramp
  (setq tramp-inline-compress-start-size 1000)
  (setq tramp-copy-size-limit 10000)
  (setq vc-handled-backends '(Git))
  (setq tramp-verbose 1)
  (setq tramp-default-method "rpc")
  (setq tramp-use-ssh-controlmaster-options nil)
  (setq projectile--mode-line "Projectile")
  (setq tramp-verbose 1))


(after! lsp-mode
  (advice-add 'json-parse-string :around
              (lambda (orig string &rest rest)
                (apply orig (s-replace "\\u0000" "" string)
                       rest)))
  (advice-add 'json-parse-buffer :around
              (lambda (orig &rest rest)
                (while (re-search-forward "\\u0000" nil t)
                  (replace-match ""))
                (apply orig rest)))
  ;; (advice-add #'lsp-hover :after (lambda () (setq lsp--hover-saved-bounds nil)))
  (setq lsp-ui-doc-use-childframe nil)
  )

(after! switch-window
  (setq
   switch-window-shortcut-style 'qwerty
   switch-window-qwerty-shortcuts '("n" "e" "i" "o" "'")
   switch-window-extra-map nil))

(after! projectile
  (setq
   projectile-project-search-path '(("~/Projects" . 3))
   projectile-project-root-files-bottom-up (delete ".git" projectile-project-root-files-bottom-up)
   projectile-project-root-files (cons ".git" projectile-project-root-files)
   ;; projectile-globally-ignored-directories (append '("*node_modules" "node_modules" "*/node_modules") projectile-globally-ignored-directories)
   projectile-ignored-project-function '(lambda (project-name) (cl-search "node_modules" project-name))))

(setq-hook! '(typescript-mode-hook typescript-tsx-mode-hook js2-mode-hook) +format-with-lsp nil)

(after! web-mode (setq web-mode-enable-auto-indentation nil))

(after! vterm
  (setq
   vterm-buffer-name "vterm"
   vterm-buffer-name-string "%s"
   vterm-shell "fish"))

(after! eshell (setq eshell-buffer-name "eshell"))

(after! treemacs (setq treemacs-read-string-input 'from-minibuffer))

(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

(after! rustic
  (setq
   lsp-disabled-clients '(rls)
   lsp-rust-analyzer-diagnostics-disabled ["unresolved-proc-macro"]
   lsp-rust-analyzer-cargo-watch-command "clippy"
   lsp-rust-analyzer-server-display-inlay-hints nil
   lsp-rust-analyzer-max-inlay-hint-length 9)
  )
