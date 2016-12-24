(provide 'nscm-ade)

(defun nscm-ade-add-or-edit(files)
  (apply 'nscm-ade-call-process "add" files)
  (apply 'nscm-ade-call-process "edit" files)
  )

(defun nscm-ade-add()
  (nscm-ade-call-process "nscm-ade.el:NOT_IMPL")
  (n-file-refresh-from-disk)
  )

(defun nscm-ade-get()
  (nscm-ade-call-process "nscm-ade.el:NOT_IMPL" "-f")
  (n-file-refresh-from-disk)
  )

(defun nscm-ade-lock()
  (nscm-ade-call-process "cho")
  (n-file-chmod "+w")
  (n-file-refresh-from-disk)
  )

(defun nscm-ade-rm()
  (nscm-ade-call-process "nscm-ade.el:NOT_IMPL")
  (nbuf-kill-current)
  )

(defun nscm-ade-unlock()
  (nscm-ade-call-process "nscm-ade.el:NOT_IMPL")
  (n-file-chmod "-w")
  (n-file-refresh-from-disk)
  )
(defun nscm-ade-call-process(op &rest leftover)
  (let(
       (fn (n-host-to-canonical (buffer-file-name)))
       )
    (apply 'nscm-call-process (concat "ade." op) fn "4" leftover)
    )
  )
(defun nscm-ade-get-view-name()
  (if (not (n-file-exists-p "$dp/data/vn"))
      (error "nscm-ade-get-view-name: no current view (i.e., $dp/data/vn doesn't exist"))
  (nstr-chomp (n-file-contents "$dp/data/vn"))
  )

(defun nscm-ade-get-root()
  (if (not (getenv "ADE_VIEW_ROOT"))
      (let(
           (view        (nscm-ade-get-view-name))
           )
        (setenv "ADE_VIEW_ROOT" (concat (getenv "ADE_DEFAULT_VIEW_STORAGE_LOC")
                                        "/nsproul_"
                                        view
                                        "/"
                                        )
                )
        )
    )
  (getenv "ADE_VIEW_ROOT")
  )

