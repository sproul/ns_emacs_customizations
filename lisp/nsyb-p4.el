(provide 'nsyb-p4)
(setq nsyb-p4-root (n-host-to-canonical (getenv "P4ROOT")))
(if (not (n-file-exists-p nsyb-p4-root))
    (progn
      (setq nsyb-p4-root nil)
      )
  )

(defun nsyb-p4-add-or-edit(files)
  (apply 'nsyb-p4-call-process "add" files)
  (apply 'nsyb-p4-call-process "edit" files)
  )

(defun nsyb-p4-add()
  (nsyb-p4-call-process "add")
  (n-file-refresh-from-disk)
  )

(defun nsyb-p4-get()
  (nsyb-p4-call-process "sync" "-f")
  (n-file-refresh-from-disk)
  )

(defun nsyb-p4-lock()
  (nsyb-p4-call-process "edit")
  (n-file-chmod "+w")
  (n-file-refresh-from-disk)
  )

(defun nsyb-p4-rm()
  (nsyb-p4-call-process "delete")
  (nbuf-kill-current)
  )

(defun nsyb-p4-unlock()
  (nsyb-p4-call-process "revert")
  (n-file-chmod "-w")
  (n-file-refresh-from-disk)
  )
(defun nsyb-p4-call-process(op &rest leftover)
  (let(
       (fn (n-host-to-canonical (buffer-file-name)))
       )
    (if n-win
        (setq fn (nstr-replace-regexp fn ".*/p4/" "//")))

    (delete-other-windows)
    (nsimple-split-window-vertically)
    (switch-to-buffer (get-buffer-create "*Messages*"))
    (delete-region (point-min) (point-max))
    (message "calling 4 %s %s" op fn)
    (if (not leftover)
	(setq leftover (list fn))
      (setq leftover (append leftover (list fn)))
      )
    (apply 'call-process
	   "bash"
	   nil
	   "*Messages*"
	   t
           "4"
	   op
	   leftover
	   )
    )
  (other-window 1)
  (if (not (string= op "delete"))
      (n-file-refresh-from-disk))
  )
(defun nsyb-p4-near-command()
  (save-restriction
    (save-excursion
      (widen)
      (n-narrow-to-line)
      (goto-char (point-min))
      (n-s "\\bp4\\b")
      )
    )
  )

(defun nsyb-p4-maybe-grab(fn)
  "see if FN is a p4 file, syncing if needed.  Return the file system name of the file, or just return FN unchanged if it can't be found"
  (let(
       p4fn
       )
    (if fn
        (progn
          (if (not (null nsyb-p4-root))
              (progn
                (setq p4fn  (nstr-replace-regexp fn "^//?" (concat nsyb-p4-root "/")))
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
