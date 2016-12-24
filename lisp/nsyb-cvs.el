(provide 'nsyb-cvs)

(defun nsyb-cvs-add-or-edit(files)
  (error "nsyb-cvs-add-or-edit: http://www.loria.fr/~molli/cvs/doc/cvs_toc.html: fill in the blanks here.  Watch out for 'put'.")
  (apply 'nsyb-cvs-call-process "add" files)
  (apply 'nsyb-cvs-call-process "edit" files)
  )

(defun nsyb-cvs-add()
  (nsyb-cvs-call-process "add")
  (n-file-refresh-from-disk)
  )

(defun nsyb-cvs-get()
  (nsyb-cvs-call-process "checkout")
  (n-file-refresh-from-disk)
  )

(defun nsyb-cvs-lock()
  (nsyb-cvs-call-process "admin -l")
  (n-file-refresh-from-disk)
  )

(defun nsyb-cvs-rm()
  (nsyb-cvs-call-process "remove -f")
  (nsyb-cvs-call-process "ci -m")
  )

(defun nsyb-cvs-unlock()
  (nsyb-cvs-call-process "revert")
  )
(defun nsyb-cvs-call-process(op &rest leftover)
  (let(
       (fn (buffer-file-name))
       )
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (switch-to-buffer (get-buffer-create "*Messages*"))
    (delete-region (point-min) (point-max))
    (message "calling cvs %s" op)
    (if (not leftover)
	(setq leftover (list fn))
      (setq leftover (append leftover (list fn)))
      )
    (apply 'call-process
	   "cvs"
	   nil
	   "*Messages*"
	   t
	   op
	   leftover
	   )
    )
  (other-window 1)
  (if (not (string= op "delete"))
      (n-file-refresh-from-disk))
  )
