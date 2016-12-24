(provide 'nsyb-svn)
(defun nsyb-svn-add-or-edit(files)
  (apply 'nsyb-svn-call-process "add" files)
  (apply 'nsyb-svn-call-process "edit" files)
  )

(defun nsyb-svn-add()
  (nsyb-svn-call-process "a")
  (n-file-refresh-from-disk)
  )

(defun nsyb-svn-get()
  (nsyb-svn-call-process "g")
  (n-file-refresh-from-disk)
  )

(defun nsyb-svn-lock()
  (message "no-op for optimistic locking systems")
  )

(defun nsyb-svn-rm()
  (nsyb-svn-call-process "d")
  (nbuf-kill-current)
  )

(defun nsyb-svn-unlock()
  (nsyb-svn-call-process "revert")
  )
(defun nsyb-svn-call-process(op &rest leftover)
  (let(
       (fn (buffer-file-name))
       )
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (switch-to-buffer (get-buffer-create "*Messages*"))
    (delete-region (point-min) (point-max))
    (message "calling sv %s %s" op fn)
    (if (not leftover)
	(setq leftover (list fn))
      (setq leftover (append leftover (list fn)))
      )
    (apply 'call-process
	   "bash"
	   nil
	   "*Messages*"
	   t
           "sv"
	   op
	   leftover
	   )
    )
  (other-window 1)
  (if (not (string= op "delete"))
      (n-file-refresh-from-disk))
  )
(defun nsyb-svn-near-command()
  (save-restriction
    (save-excursion
      (widen)
      (n-narrow-to-line)
      (goto-char (point-min))
      (n-s "\\bsvn\\b")
      )
    )
  )
