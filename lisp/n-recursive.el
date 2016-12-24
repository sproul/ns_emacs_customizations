(provide 'n-recursive)
(if (not (boundp 'n-exit-recursive-edit-old))
    (setq n-exit-recursive-edit-old	(symbol-function 'exit-recursive-edit))
  )
(if (not (boundp 'n-recursive-edit-old))
    (setq n-recursive-edit-old	(symbol-function 'recursive-edit))
  )
(setq n-recursive-edit-cnt 0)

(defun exit-recursive-edit( &optional arg)
  "exit the outermost recursive-edit, or if there is none, exit EMACS itself"
  (interactive "P")
  (cond
   (arg
    (if (y-or-n-p "drop to xterm? ")
        (let(
             (fn (n-host-to-canonical "$TMP/e.drop_to_xterm"))
             )
          (n-file-touch fn)
          (save-buffers-kill-emacs t)
          )
      )
    )
   ((get-buffer "*Backtrace*")
    (kill-buffer "*Backtrace*")
    (setq n-recursive-edit-cnt	0
          n-exit-hook nil
          n-exit-hook-pending nil
          )
    (top-level)
    )
   (t
    (n-post-for-exit-pop)
    (if (< 0 n-recursive-edit-cnt)
        (progn
          (setq n-recursive-edit-cnt (1- n-recursive-edit-cnt))
          (condition-case nil
              (funcall n-exit-recursive-edit-old)
            (error (save-buffers-kill-emacs t))
            )
          )
      (save-buffers-kill-emacs t)
      )
    )
   )
  )

(defun recursive-edit()
  "like recursive-edit, but updates my internal count"
  (setq n-recursive-edit-cnt (1+ n-recursive-edit-cnt))
  (n-post-for-exit-push)
  (funcall n-recursive-edit-old)
  )

(defun n-recursive-kill-emacs-maybe()
  "kill emacs (after confirming that the user really wants to)"
  (interactive)
  (if (y-or-n-p "kill emacs? ")
      (kill-emacs))
  )
