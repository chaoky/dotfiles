;;; ../dotfiles/files/doom/custom.el -*- lexical-binding: t; -*-

;; (defun counsel-projectile-switch-to-buffer-other-window ()
;;   "Switch to another buffer in another window.
;; Display a preview of the selected ivy completion candidate buffer
;; in the current window."
;;   (interactive)
;;   (ivy-read (projectile-prepend-project-name "Switch to other project buffer: ")
;;             ;; We use a collection function so that it is called each
;;             ;; time the `ivy-state' is reset. This is needed for the
;;             ;; "kill buffer" action.
;;             #'counsel-projectile--project-buffers
;;             :matcher #'ivy--switch-buffer-matcher
;;             :require-match t
;;             :preselect (buffer-name (other-buffer (current-buffer)))
;;             :sort counsel-projectile-sort-buffers
;;             :action #'ivy--switch-buffer-other-window-action
;;             :keymap counsel-projectile-switch-to-buffer-map
;;             :caller 'ivy-switch-buffer-other-window))

(defun set-window-size ()
  (if (display-graphic-p)
      (setq initial-frame-alist '((top . 40) (left . 100) (width . 230) (height . 55)))
    ))

(defun persp-counsel-switch-buffer ()
  (with-eval-after-load "persp-mode"
    (with-eval-after-load "ivy"
      (add-hook 'ivy-ignore-buffers
                #'(lambda (b)
                    (when persp-mode
                      (let ((persp (get-current-persp)))
                        (if persp
                            (not (persp-contain-buffer-p b persp))
                          nil)))))

      (setq ivy-sort-functions-alist
            (append ivy-sort-functions-alist
                    '((persp-kill-buffer   . nil)
                      (persp-remove-buffer . nil)
                      (persp-add-buffer    . nil)
                      (persp-switch        . nil)
                      (persp-window-switch . nil)
                      (persp-frame-switch  . nil)))))))

(provide 'custom)
