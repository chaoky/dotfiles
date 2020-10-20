;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "lordie"
      user-mail-address "levimanga@gmail.com"
      doom-theme 'doom-one
      doom-font (font-spec :family "DaddyTimeMono Nerd Font" :size 14)
      org-directory "~/org/"
      display-line-numbers-type t
      projectile-project-search-path (doom-files-in '("~/Projects/" "~/Projects/Learn/" "~/Projects/CTF/")  :depth 0 :type 'dirs)
      counsel-projectile-remove-current-buffer t
      counsel-projectile-preview-buffers t
      counsel-switch-buffer-preview-virtual-buffers t)

(set-fontset-font t 'symbol "Twemoji")

(projectile-discover-projects-in-search-path)

(defun dante-doc (ident)
  "Get the haddock about IDENT at point."
  (interactive (list (dante-ident-at-point)))
  (lcr-cps-let ((info (dante-async-call (format ":doc %s" ident))))
               (with-help-window (help-buffer)
                 (with-current-buffer (help-buffer)
                   (insert  (dante-fontify-expression info))))))


(defun counsel-projectile-switch-to-buffer-other-window ()
  "Switch to another buffer in another window.
Display a preview of the selected ivy completion candidate buffer
in the current window."
  (interactive)
  (let ((ivy-update-fns-alist
         '((ivy-switch-buffer-other-window . counsel--switch-buffer-update-fn)))
        (ivy-unwind-fns-alist
         '((ivy-switch-buffer-other-window . counsel--switch-buffer-unwind))))
    (ivy-read (projectile-prepend-project-name "Switch to other project buffer: ")
              ;; We use a collection function so that it is called each
              ;; time the `ivy-state' is reset. This is needed for the
              ;; "kill buffer" action.
              #'counsel-projectile--project-buffers
              :matcher #'ivy--switch-buffer-matcher
              :require-match t
              :preselect (buffer-name (other-buffer (current-buffer)))
              :sort counsel-projectile-sort-buffers
              :action #'ivy--switch-buffer-other-window-action
              :keymap counsel-projectile-switch-to-buffer-map
              :caller 'ivy-switch-buffer-other-window)))

(use-package! boon
  :config (require 'boon-colemak)
  (boon-mode)
  (general-define-key :keymaps 'boon-command-map
                      "p" 'swiper
                      "C-e" 'doom/escape
                      "c" (general-simulate-key "C-c")
                      "1" '+workspace/switch-to-0
                      "2" '+workspace/switch-to-1
                      "3" '+workspace/switch-to-2)
  (general-define-key :keymaps 'global-map
                      "C-e" 'boon-set-command-state)
  (general-define-key :keymaps 'boon-x-map
                      "s" 'save-buffer
                      "C-s" 'save-some-buffers
                      "f" 'find-file
                      "b" 'counsel-projectile-switch-to-buffer
                      "C-b" 'counsel-projectile-switch-to-buffer-other-window
                      "B" 'counsel-switch-buffer
                      ))

(use-package! rainbow-mode
  :config (add-to-list 'minor-mode-list 'rainbow-mode))

(use-package! tree-sitter-langs)
(use-package! tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
