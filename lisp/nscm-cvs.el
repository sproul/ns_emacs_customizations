(provide 'nscm-cvs)

(defun nscm-cvs-add-or-edit(files)
  (error "nscm-cvs-add-or-edit: http://www.loria.fr/~molli/cvs/doc/cvs_toc.html: fill in the blanks here.  Watch out for 'put'.")
  (apply 'nscm-cvs-call-process "add" files)
  (apply 'nscm-cvs-call-process "edit" files)
  )

(defun nscm-cvs-add()
  (nscm-cvs-call-process "add")
  (n-file-refresh-from-disk)
  )

(defun nscm-cvs-get()
  (nscm-cvs-call-process "checkout")
  (n-file-refresh-from-disk)
  )

(defun nscm-cvs-lock()
  (nscm-cvs-call-process "admin -l")
  (n-file-refresh-from-disk)
  )

(defun nscm-cvs-rm()
  (nscm-cvs-call-process "remove -f")
  (nscm-cvs-call-process "ci -m")
  )

(defun nscm-cvs-unlock()
  (nscm-cvs-call-process "revert")
  )
(defun nscm-cvs-call-process(op &rest leftover)
  (let(
       (fn (buffer-file-name))
       )
    (nscm-call-process op fn "cvs" leftover)
    )
  )
