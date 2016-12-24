(provide 'n-lpr)
(setq n-lpr-landscape nil)

(setq n-lprinter (n-database-get "printer" nil nil ":lpt1"))

(setq n-lprinters (list
                   ":lpt1"
		   "\\\\corp-bdc\\pso-ns"
		   "\\\\corp-bdc\\pso"
		   "\\\\corp-bdc\\dev-ns"
		   "\\\\corp-bdc\\dev"
		   "\\\\corp-bdc\\eng-ns"
		   "\\\\corp-bdc\\eng"
		   "\\\\corp-bdc\\sales-ns"
		   "\\\\corp-bdc\\sales"
                   )
      )
(setq n-lpr-queue-directory (concat n-local-tmp "print_queue/"))
(setq n-lpr-printed-directory (concat n-local-tmp "print_queue.printed/"))
(setq lpr-command (cond
                   ((file-exists-p "/usr/local/bin/enscript")
                    (setq lpr-switches (list (concat "-P" n-lprinter)
                                             "-2rgGk"
                                             )
                          )
                    "/usr/local/bin/enscript"
                    )
                   ((file-exists-p "/usr/local/bin/mpage")
                    (setq lpr-switches (list "-2"
                                             "-p"
                                             )
                          )
                    (setq n-lprinter "default")
                    "/usr/local/bin/mpage"
                    )
                   (t
		    "n_print.sh"	; NT
                    )
                   )
      )
                                        ; 			   \/ lines per inch
(setq n-lpr-nt386-format (format "%c(8U%c(s0p16.67h8.5v0s0b0T\n%c&l12D\n" 27 27 27))

(defun n-lpr()
  "no arg: print buf
's': select printer
'r': print region"
  (interactive)
  (if (string= (buffer-name) "midnight.price_air")
      (progn
	(goto-char (point-min))
	(replace-regexp "-dollar-sign-" "$")
	(goto-char (point-min))
	(replace-regexp "-at-sign-" "@")
	(save-buffer)
	)
    )
  (let(
       (cmd		(progn
                          (message "b-atch, l-landscape, q-ueue, r-region, s-select lpr")
                          (read-char)
                          )
                        )
       (printing		t)
       )
    (message "...")
    (cond
     ((eq cmd ?b) 		(n-lpr-batch))
      ((eq cmd ?l)		(setq  n-lpr-landscape (not  n-lpr-landscape))
       (setq printing nil))
      ((eq cmd ?p) 		(n-lpr-buf))
      ((eq cmd ?q)		(n-host-shell-cmd (format "lpq -P%s" n-lprinter)))
      ((eq cmd ?r)		(call-interactively 'n-lpr-region))
      ((eq cmd ?s)		(n-lprinter-select)
       (setq printing nil))
      (t				(error "n-lpr: "))
      )
     
     (if (and (not n-win) printing)
	 (n-lpr-lpq n-lprinter t))
     )
   )

(defun n-lpr-buf()
  (if (buffer-file-name)
      (progn
        (save-buffer)
        (n-lpr-file  (buffer-file-name))
        )
    (n-lpr-region (point-min) (point-max))
    )
  )



(defun n-lprinter-select()
  "select a printer"
  (interactive)
  (let(
       (lprList	n-lprinters)
       lprJobs
       lpr
       )
    (n-zap "*lpq-list*")
    (switch-to-buffer-other-window "*lpq-list*")
    (while lprList
      (setq lpr		 (car lprList)
            lprJobs	 (n-lpr-lpq lpr nil))
      (if lprJobs
          (let(
               (line	 (format "%02d jobs: %s\n" lprJobs lpr))
               )
            (set-buffer "*lpq-list*")
            (insert line)
            )
        (error "bad lprJobs")
        )
      (setq lprList (cdr lprList))
      )
    (goto-char (point-min))
    (replace-regexp "^-1 jobs: " "          ")
    (sort-lines nil (point-min) (point-max))
    (goto-char (point-min))
    (n-s n-lprinter)
    (forward-line 0)
    (forward-char 2)
    (message "go to line containing desired printer; kill buffer to select (M-q)")
    (nbuf-post-for-kill 'n-lpr-set-printer)
    )
  )

(defun n-lpr-set-printer(&optional printer)
  (if printer
      (setq n-lprinter printer)
    (end-of-line)
    (setq n-lprinter (buffer-substring-no-properties (point) (progn
						 (n-r "[ \t]" t)
						 (forward-char 1)
						 (point)
						 )
				       )
	  )
    )
  (message "Printer set to %s" n-lprinter)
  )

(defun n-lpr-region( beg end &optional queue)
  "print REGION"
  (interactive "r")
  (let(
       (data	(buffer-substring-no-properties beg end))
       (tmpFn	(concat n-local-tmp "print_region.tmp"))
       (native-unix-printing-enabled nil)	;; at least not at pt
       )
    (find-file tmpFn)
    (erase-buffer)
    (insert data)
    (save-buffer)
    (n-lpr-file tmpFn queue)
    (if (and native-unix-printing-enabled
             (not n-win)
             )
        (delete-file tmpFn)
      )
    (kill-buffer (current-buffer))
    )
  )
(defun n-lpr-queue-file(fn)
  (let(
       (tmpFn	 (concat n-lpr-queue-directory (file-name-nondirectory fn)))
       )
    (n-file-md-p n-lpr-queue-directory)
    (if (file-exists-p tmpFn)
        (progn
          (n-file-push fn)
          (append-to-file (point-min) (point-max) tmpFn)
          (n-file-pop)
          )
      (copy-file fn tmpFn)
      )
    )
  )

(defun n-lpr-file( fn &optional queue)
  (n-database-set "printer" n-lprinter)
  (setenv "printer" n-lprinter)

  (cond
   (queue
    (n-lpr-queue-file fn)
    )
   (t
    (n-start-process "n_print.sh"  "*Messages*" "sh" "-x"
                     (n-host-to-canonical "$NELSON_BIN/n_print.sh")
                     (nfn-to-pc fn t)
                     )
    )
   (t
    (n-trace "printing %s at %s..." fn n-lprinter)
    (let(
         (args  (append lpr-switches
                        (list fn)
                        )
                )
         )
      ( if n-lpr-landscape
          (setq args (append args (list "-l"))))
      (apply 'call-process lpr-command
             nil
             nil
             nil
             args
             )
      )
    )
   )
  )

(defun n-lpr-lpq( printer showMine)
  "lpq PRINTER; if SHOWMINE then print to minibuffer your first job's info; return number of jobs"
  (n-zap "*lpq*")
  (if n-win
      -1
    (call-process "lpq" nil "*lpq*" nil (concat "-P" printer))
    (set-buffer "*lpq*")
    (goto-char (point-min))
    (if showMine
	(message "%s" (if (n-s (user-login-name))
			  (n-get-line)
			"don't see job in the queue"))
      (goto-char (point-max))
      (forward-line -1)
      (let(
	   jobs
	   )
	(cond
	 ((looking-at "no entries")		(setq jobs 0))
	 ((looking-at "^[ \t]*\\([0-9]+\\)")	(setq jobs
                                                      (1+
                                                       (string-to-int
                                                        (buffer-substring-no-properties
                                                         (match-beginning 1)
                                                         (match-end 1))
                                                        )
                                                       )
                                                      )
	  )
	 (t					(setq jobs 1))
	 )
	jobs
	)
      )
    )
  )

(defun n-lpr-dired( &optional arg)
  "from a dired buffer, print one of the files displayed"
  (interactive "p")
  (if (integerp arg)
      (while (> arg 0) (n-lpr-dired) (setq arg (1- arg)))
    (n-lpr-file (dired-get-filename))
    (dired-next-line  1)
    )
  )

(defun n-lpr-batch()
  (message "n-lpr-batch executing")
  (let(
       (fns (directory-files n-lpr-queue-directory t nil))
       fn
       )
    (while fns
      (setq fn (car fns))
      (if (not (file-directory-p fn))
          (progn
            (message "...printing queued file %s" fn)
            (n-lpr-file fn)
            (n-file-md-p n-lpr-printed-directory)
            (setq saved-fn (concat n-lpr-printed-directory
                                   (file-name-nondirectory fn)
                                   )
                  )
            (if (file-exists-p saved-fn)
                (progn
                  (n-file-push fn)
                  (append-to-file (point-min) (point-max) saved-fn)
                  (n-file-pop)
                  (n-file-delete fn)
                  )
              (copy-file fn saved-fn t)
              (delete-file fn)
              )
            )
        )
      (setq fns (cdr fns))
      )
    )
  )

