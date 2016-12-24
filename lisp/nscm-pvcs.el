(provide 'nscm-pvcs)
(defun nscm-pvcs-add()
  (error "nscm-pvcs-add: n.a.: just do a put when you're done with the file")
  )

(defun nscm-pvcs-get()
  (nscm-pvcs-get-file (buffer-file-name) "" "interactive")
  )

(defun nscm-pvcs-lock()
  (nscm-pvcs-get-file (buffer-file-name) "-l" "interactive")
  )

(defun nscm-pvcs-unlock()
  (let(
       (user (read-string "break lock owned by " n-local-user))
       )
    (n-host-shell-cmd-visible (format "pushd %s; vcs -u:%s %s" 
				      (file-name-directory (buffer-file-name))
				      user
				      (file-name-nondirectory (buffer-file-name))
				      )
			      )
    (nscm-pvcs-y (string= user n-local-user))
    (if (string= user n-local-user)
	(progn
	  (rename-file (buffer-file-name)
		       (concat (buffer-file-name) "." n-local-user)
		       )
	  (nscm-get (buffer-file-name))
	  )
      (n-host-shell-cmd-visible
       (format
	"echo I needed it to complete a check in - I hope it was no inconvenience|/usr/ucb/Mail -s'I broke your lock on %s' %s"
	(file-name-nondirectory (buffer-file-name))
	user
	)
       )
      )
    (n-host-shell-cmd-visible "popd")
    )
  )


(defun nscm-pvcs-get-file(fn &optional lock interactive)
  (n-loc-push)
  
  (let(
       (oldFileExisted	(file-exists-p fn))
       (oldReadOnly	(not (file-writable-p fn)))
       (oldFile (concat fn ".old"))
       (lockOption (if (not lock)
                       ""
                     lock
                     )
                   )
       )
    (n-host-shell-cmd-visible (format "cd %s" (file-name-directory fn)))
    (if oldFileExisted
        (progn
          (n-loc-push)
          (nfly-write-file oldFile)
          (nbuf-kill-current)
          (n-host-shell-cmd-visible (format "chmod 555 %s"
                                            (file-name-nondirectory fn)
                                            ) 
                                    )   
          (if (and (boundp 'alien-file-locker)
                   (not (string= alien-file-locker ""))
                   (y-or-n-p (format "break %s's lock? " alien-file-locker))
                   )
              (progn
                (n-host-shell-cmd-visible (format "echo I needed it for a checkin|/usr/ucb/Mail -s'I broke your lock on %s' %s %s"
                                                  (file-name-nondirectory fn)
                                                  alien-file-locker
						  "/var/mail/$USER"
                                                  )
                                          )
                (n-host-shell-cmd-visible (format "vcs -u:%s %s"
                                                  alien-file-locker
                                                  (file-name-nondirectory fn)
                                                  )
                                          )
                (nscm-pvcs-y)
                )
            )
          )
      )
    (n-host-shell-cmd-visible (format "get -T %s %s" 
                                      lockOption
                                      (file-name-nondirectory fn)
                                      )
                              )
    (n-loc-pop)
    (sleep-for 2)
    (n-file-refresh-from-disk)
    (if oldFileExisted
        (progn
          (if (not (ndiff-files fn oldFile))
              (n-file-delete oldFile)
            (cond
             ((and
               interactive
               (y-or-n-p "difference: merge ")
               )
              ;; kill off this buffer to avoid containing nmerge
              (n-host-shell-cmd-visible (format "chmod +w %s" fn))
              (nbuf-kill (file-name-nondirectory fn))
              (nmerge-go oldFile
                         nil
                         fn
                         1
                         )
              )
             ((or (not interactive)
                  (y-or-n-p "overwrite codeline version ")
                  )
              (n-host-shell-cmd-visible (format "chmod +w %s" fn))
              (n-host-shell-cmd-visible (format "rm %s; mv %s.old %s" fn fn fn))
              (sleep-for 2)
              (n-file-refresh-from-disk)
              ;;(find-file fn)
              )
             )
            )
          )
      )
    )
  )

(defun nscm-pvcs-y(&optional noWait)
  (if (not noWait)
      (progn
        (message "wait for pvcs to get its head out of its ass")
        (sleep-for 1)
        (n-host-shell-cmd-visible "y")
        )
    )
  )

