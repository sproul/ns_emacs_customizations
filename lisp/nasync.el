(provide 'nasync)
(defun nasync-timer( interval func &optional arg)
  "asynchronously delay INTERVAL seconds, then execute FUNC"
  (let(
       (timer-process	(apply 'n-start-process
                               "nasync-timer"
                               "*Messages*"
                               "sh"
                               "$NELSON_BIN/n_timer.sh"
                               (format "%d" interval)
                               "T"
                               (symbol-name func)
                               (if arg
                                   (list arg))
                               )
                        )
       )
    (process-kill-without-query timer-process)
    (set-process-filter   timer-process 'nasync-filter-parser)
    (set-process-sentinel timer-process 'n-sentinel-silent)
    )
  )
(defun nasync-timer-signal( funcStuff)
  (let(
       funcName
       arg
       )
    (cond
     ((string-match "\\([^ ]+\\) \\([^ ]+\\)" funcStuff)
      (setq
       funcName	(n--pat 1 funcStuff)
       arg		(n--pat 2 funcStuff)
       )
      (funcall (intern-soft funcName) arg)
      )
     ((not (string= "" funcStuff))
      (setq funcName funcStuff)
      (funcall (intern-soft funcName))
      )
     (t nil)
     )
    )
  )
(defun nasync-filter-parser( proc msg )
  "splits msg into \n-delimited strings, and passes them on to nasync-filter"
  (let( newline )
    (while (setq newline (string-match "\n" msg))
      (nasync-filter (substring msg 0 newline))
      (setq msg (substring msg (1+ newline)))
      )
    )
  )
(defun nasync-filter( msg )
  (n-trace "(nasync-filter \"%s\" )\n" msg)
  (if (n-proc-cmd "NRT" msg)
      (let(
           (cmd (substring msg 0 1))
           (rest	(if (< 3 (length msg))
                            (substring msg 2)
                          ""))
           )
        (cond
         ((equal cmd "N") (progn
                            (batch-log "n-gen-tags finished")
                            (ntags-reinit)
                            )
          )
         ((equal cmd "R") (message "ntags: %s" rest)) ; also saved to report.emacs
         ((equal cmd "T") (nasync-timer-signal rest))
         (t (error "Malformed command string '%s' received from emacs server" msg))
         )
        )
    )
  )
(defun nasync-wait-for(regexp callback &optional count interval)
  (if n-win
      (y-or-n-p "nt386 in nasync-timer ")
    (if (not count)
        (setq count 60))
    (if (not interval)
        (setq interval 1))
    (setq
     nasync-wait-for-buffer	(current-buffer)
     nasync-wait-for-callback	callback
     nasync-wait-for-char		(point)
     nasync-wait-for-count	count
     nasync-wait-for-interval	interval
     nasync-wait-for-regexp	regexp
     )
    (nasync-wait-for-loop)
    )
  )
(defun nasync-wait-for-loop()
  (setq nasync-wait-for-count	(1- nasync-wait-for-count))
  (if (> 0 nasync-wait-for-count)
      (error "nasync-wait-for-loop: never saw '%s'" nasync-wait-for-regexp))
  (save-window-excursion
    (set-buffer	nasync-wait-for-buffer)
    (goto-char	nasync-wait-for-char)
    (if (n-s nasync-wait-for-regexp)
        (funcall nasync-wait-for-callback)
      (nasync-timer nasync-wait-for-interval 'nasync-wait-for-loop)
      )
    )
  )
(defun nasync-wait-for-test-callback()
  (message "nasync-wait-for-test-callback executed")
  )
(defun nasync-wait-for-test()
  (nshell)
  (n-host-shell-cmd "sleep 3; echo hello")
  (goto-char (point-max))
  (nasync-wait-for "hello" 'nasync-wait-for-test-callback)
  )
(defun n-x7()
  (interactive)
  (nasync-wait-for-test)
  )
(defun n-x7()
  (interactive)
  (nasync-timer 1 'message "hello")
  )
