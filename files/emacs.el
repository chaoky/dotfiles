;;(setq my-global-map (make-sparse-keymap))
;;(substitute-key-definition 'self-insert-command 'self-insert-command my-global-map global-map)
;;(use-global-map my-global-map)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package) 
  (package-refresh-contents) 
  (package-install 'use-package))

(setq custom-file (make-temp-file "emacs-custom"))

(setq default-frame-alist '((font . "Fira Code 11") 
			    (width . 0.93) 
			    (height . 0.95) 
			    (left . 0.52) 
			    (top . 0.55)))

(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(global-display-line-numbers-mode t)
(global-prettify-symbols-mode t)

(defun fira-code-mode--make-alist (list) 
  "Generate prettify-symbols alist from LIST."
  (let ((idx -1)) 
    (mapcar 
     (lambda (s) 
       (setq idx (1+ idx)) 
       (let* ((code (+ #Xe100 idx)) 
	      (width (string-width s)) 
	      (prefix ()) 
	      (suffix '(?\s (Br . Br))) 
	      (n 1)) 
	 (while (< n width) 
	   (setq prefix (append prefix '(?\s (Br . Bl)))) 
	   (setq n (1+ n))) 
	 (cons s (append prefix suffix (list (decode-char 'ucs code))))))
     list)))

(defconst fira-code-mode--ligatures 
  '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "[]" "::" ":::" ":=" "!!" "!=" "!==" "-}"
    "--" "---" "-->" "->" "->>" "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_" "#_("
    ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**" "/=" "/==" "/>" "//" "///" "&&" "||" "||="
    "|=" "|>" "^=" "$>" "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-" ">="
    ">=>" ">>" ">>-" ">>=" ">>>" "<*" "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+" "<+>"
    "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~" "<~~" "</" "</>" "~@" "~-" "~=" "~>"
    "~~" "~~>" "%%" "x" ":" "+" "+" "*"))

(defvar fira-code-mode--old-prettify-alist)

(defun fira-code-mode--enable () 
  "Enable Fira Code ligatures in current buffer."
  (setq-local fira-code-mode--old-prettify-alist prettify-symbols-alist) 
  (setq-local prettify-symbols-alist (append (fira-code-mode--make-alist fira-code-mode--ligatures)
					     fira-code-mode--old-prettify-alist)) 
  (prettify-symbols-mode t))

(defun fira-code-mode--disable () 
  "Disable Fira Code ligatures in current buffer."
  (setq-local prettify-symbols-alist fira-code-mode--old-prettify-alist) 
  (prettify-symbols-mode -1))

(define-minor-mode fira-code-mode "Fira Code ligatures minor mode" 
  :lighter " Fira Code"
  (setq-local prettify-symbols-unprettify-at-point 'right-edge) 
  (if fira-code-mode (fira-code-mode--enable) 
    (fira-code-mode--disable)))

(defun fira-code-mode--setup () 
  "Setup Fira Code Symbols"
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol"))

(provide 'fira-code-mode)

(add-hook 'prog-mode-hook 'fira-code-mode)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist '(("." . "~/.emacs.d/backup")) backup-by-copying t	; Don't delink hardlinks
      version-control t	     ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      )


(put 'dired-find-alternate-file 'disabled nil)

(use-package 
  dashboard 
  :ensure t 
  :config (dashboard-setup-startup-hook) 
  (setq dashboard-banner-logo-title "\"I dont know everything, I just know what I know\"") 
  (setq dashboard-startup-banner "~/Pictures/edit/tsubasaFace.png") 
  (setq dashboard-set-file-icons t) 
  (setq dashboard-set-heading-icons t) 
  (setq dashboard-items '((recents  . 6) 
			  (projects . 11))))
(use-package 
  helm 
  :ensure t 
  :bind ("M-x" . helm-M-x) 
  ("C-x C-f" . helm-find-files) 
  ("C-x f" . helm-recentf) 
  ("M-y" . helm-show-kill-ring) 
  :config (helm-autoresize-mode) 
  (setq helm-autoresize-max-height 20) 
  (helm-mode 1) 
  (helm-adaptive-mode 1) 
  (helm-adaptive-save-history 1) 
  (define-key boon-x-map "x" 'helm-M-x))

(use-package 
  boon 
  :ensure t 
  :config (require 'boon-colemak) 
  (boon-mode 1))

(use-package 
  exec-path-from-shell 
  :ensure t 
  :config (exec-path-from-shell-initialize))

(use-package 
  dracula-theme 
  :ensure t 
  :config (load-theme 'dracula t))

(use-package 
  swiper 
  :ensure t 
  :config (define-key boon-command-map "p" '("pinpoint" . swiper)))

(use-package 
  which-key 
  :ensure t 
  :diminish which-key-mode 
  :config (add-hook 'after-init-hook 'which-key-mode))

(use-package 
  undo-tree 
  :ensure t 
  :diminish undo-tree-mode: 
  :config (global-undo-tree-mode 1))

(use-package 
  projectile 
  :ensure t 
  :config (projectile-mode) 
  (setq projectile-completion-system 'ivy) 
  (setq projectile-project-search-path '("~/Projects")) 
  (setq projectile-sort-order 'access-time) 
  (setq projectile-git-submodule-command nil))

(use-package 
  rainbow-mode 
  :ensure t 
  :config (add-hook 'prog-mode-hook 'rainbow-mode))

(use-package 
  exec-path-from-shell 
  :ensure t 
  :config (exec-path-from-shell-initialize))

(use-package 
  helm-spotify-plus 
  :ensure t)

(use-package 
  elcord 
  :ensure t 
  :config (elcord-mode 1))

(use-package 
  eyebrowse 
  :ensure t 
  :config (eyebrowse-setup-opinionated-keys) 
  (eyebrowse-mode 1))

(use-package 
  frog-jump-buffer 
  :ensure t 
  :config (setq frog-jump-buffer-sort 'string<) 
  (setq frog-jump-buffer-current-filter-function 'frog-jump-buffer-filter-file-buffers) 
  :bind ("C-x '" . frog-jump-buffer))

;;Programming

(use-package 
  lsp-mode 
  :ensure t 
  :config (add-hook 'prog-mode-hook #'lsp))

(use-package 
  company-lsp 
  :ensure t 
  :config (push 'company-lsp company-backends))

(use-package 
  company 
  :ensure t 
  :config (global-company-mode))

(use-package 
  elisp-format 
  :ensure t 
  :config (add-hook 'emacs-lisp-mode-hook 
		    (lambda () 
		      (add-hook 'before-save-hook 'elisp-format-buffer))))

(use-package 
  smartparens 
  :ensure t 
  :diminish smartparens-mode 
  :config (add-hook 'prog-mode-hook 'smartparens-mode))

(use-package 
  rainbow-delimiters 
  :ensure t 
  :config (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package 
  aggressive-indent 
  :ensure t 
  :config (global-aggressive-indent-mode 1))

(use-package 
  elm-mode 
  :ensure t 
  :config (setq elm-format-on-save t))

(use-package 
  web-mode 
  :ensure t)

(use-package 
  js2-mode 
  :ensure t 
  :mode "\\.js\\'")

(use-package 
  rjsx-mode 
  :ensure t)

(use-package 
  prettier-js 
  :ensure t 
  :config (add-hook 'js2-mode-hook 'prettier-js-mode) 
  (add-hook 'web-mode-hook 'prettier-js-mode))

(use-package 
  yaml-mode 
  :ensure t)
