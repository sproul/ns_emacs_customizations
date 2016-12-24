(provide 'nscm-p4)
(setq nscm-p4-root (n-host-to-canonical (getenv "P4ROOT")))
(if (not (n-file-exists-p nscm-p4-root))
    (progn
      (setq nscm-p4-root nil)
      )
  )

(defun nscm-p4-add-or-edit(files)
  (apply 'nscm-p4-call-process "add" files)
  (apply 'nscm-p4-call-process "edit" files)
  )

(defun nscm-p4-add()
  (nscm-p4-call-process "add")
  (n-file-refresh-from-disk)
  )

(defun nscm-p4-get()
  (nscm-p4-call-process "sync" "-f")
  (n-file-refresh-from-disk)
  )

(defun nscm-p4-lock()
  (nscm-p4-call-process "edit")
  (n-file-chmod "+w")
  (n-file-refresh-from-disk)
  )

(defun nscm-p4-rm()
  (nscm-p4-call-process "delete")
  (nbuf-kill-current)
  )

(defun nscm-p4-unlock()
  (nscm-p4-call-process "revert")
  (n-file-chmod "-w")
  (n-file-refresh-from-disk)
  )

(defun nscm-p4-call-process(op &rest leftover)
  (let(
       (fn (n-host-to-canonical (buffer-file-name)))
       )
    (if n-win
        (setq fn (nstr-replace-regexp fn ".*/p4/" "//")))

    (apply 'nscm-call-process op fn "4" leftover)
    )
  )

(defun nscm-p4-near-command()
  (save-restriction
    (save-excursion
      (widen)
      (n-narrow-to-line)
      (goto-char (point-min))
      (n-s "\\bp4\\b")
      )
    )
  )

(defun nscm-p4-maybe-grab(fn)
  "see if FN is a p4 file, syncing if needed.  Return the file system name of the file, or just return FN unchanged if it can't be found"
  (let(
       p4fn
       )
    (if fn
        (progn
          (if (not (null nscm-p4-root))
              (progn
                (setq p4fn  (nstr-replace-regexp fn "^//?" (concat nscm-p4-root "/")))
                (if p4fn
                    (progn
                      ;;(if (not (n-file-exists-p p4fn))
                      ;; (call-process "p4" nil nil nil "sync" "-f" fn))
                      (if (n-file-exists-p p4fn)
                          p4fn
                        fn
                        )
                      )
                  )
                )
            )
      )
      )
    )
  )
