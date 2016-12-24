(provide 'nscm-svn)
(defun nscm-svn-add-or-edit(files)
  (apply 'nscm-svn-call-process "add" files)
  (apply 'nscm-svn-call-process "edit" files)
  )

(defun nscm-svn-add()
  (nscm-svn-call-process "a")
  (n-file-refresh-from-disk)
  )

(defun nscm-svn-get()
  (nscm-svn-call-process "g")
  (n-file-refresh-from-disk)
  )

(defun nscm-svn-lock()
  (message "no-op for optimistic locking systems")
  )

(defun nscm-svn-rm()
  (nscm-svn-call-process "d")
  (nbuf-kill-current)
  )

(defun nscm-svn-unlock()
  (nscm-svn-call-process "revert")
  )
(defun nscm-svn-call-process(op &rest leftover)
  (let(
       (fn (buffer-file-name))
       )
    (nscm-call-process op fn "svn" leftover)
    )
  )

(defun nscm-svn-near-command()
  (save-restriction
    (save-excursion
      (widen)
      (n-narrow-to-line)
      (goto-char (point-min))
      (n-s "\\bsvn\\b")
      )
    )
  )
