(provide 'n7)
(defun n-kill-process(&optional proc )
  "like kill-process, except no complaint if it doesn't exist"
  (if (not proc)
      (setq proc (get-buffer-process (current-buffer))))
  (if (and proc
           (or (processp proc)
               (setq proc (get-process proc))
               )
           proc
           )
      (kill-process proc))
  )

(defun n-get-process(procName program filter &optional report startAlways &rest args)
  "return the process object named by PROCESS; if it doesn't exist,
assume that a like-named program exists in $NELSON_BIN, and start it.  Set
the process filter to be FILTER.
If optional REPORT
is non-nil, don't signal an error if there's trouble - just call n-report
with the msg

If optional START_ALWAYS is non-nil, don't bother seeing if a copy of the
program is already running; just go ahead and start up a new copy.  If START_ALWAYS
is a string, then the new process will be the concatenation of PROCESS '-' and START_ALWAYS.

Additional args are passed on to the process"

  (let(
       (proc	(get-process procName))
       )
    (if (and (not startAlways) proc)
        proc
      (let(
           (pgmFile	(n-host-to-canonical (concat "$NELSON_BIN/" procName)))
	   )
	(if (file-exists-p pgmFile)
	    (progn
	      (setq proc (apply 'n-start-process
				(if (stringp startAlways)
				    (concat procName "-" startAlways)
				  procName
				  )
				nil
				pgmFile
				args
				)
		    )
	      (process-kill-without-query proc)
	      (set-process-filter   proc filter)
	      (set-process-sentinel proc 'n-sentinel)
	      (n-process-catch-up-maybe)
	      proc
	      )
	  (if report
	      (n-report (format  "n7.n-get-process cannot find %s" pgmFile))
	    (error "n7.n-get-process cannot find %s" pgmFile)
	    )
	  )
	)
      )
    )
  )
(defun n-process-catch-up-maybe()
  ;;(if (string= n-local-situation "whitelight")
  ;;(sleep-for 1))
  )

(defun n-process-at-pt-kill()
  "n7: kill the process named under point"
  (interactive)
  (let(
       (procName	(n-grab-token "-.<>0-9a-zA-Z_"))
       )
    (kill-process procName)
    )
  (if (equal (buffer-name) "*Process List*")
      (progn
        (n-loc-push)
        (n-list-processes)
        (n-loc-pop)
        (forward-line -1)
        )
    )
  )
(defun n-process-kill-em-all()
  (goto-char (point-min))
  (forward-line 2)

  (if (nbuf-read-only-p)
      (toggle-read-only))
  (n-prune-buf "Killed")

  (while (not (eobp))
    (condition-case nil
        (n-process-at-pt-kill)
      (error nil)
      )
    (forward-line 1)
    )
  (n-list-processes)
  )

(defun n-list-processes()
  "like list-processes, but 'normal' processes aren't listed"
  (interactive)
  (list-processes)
  (set-buffer "*Process List*")
  (delete-region (point-min) (progn
                               (forward-line 2)
                               (point)
                               )
                 )
  (if (n-s "^compilation")
      (nsimple-delete-line))
  (goto-char (point-min))

  (if (n-s "^shell")
      (nsimple-delete-line))
  (goto-char (point-min))

  (if (n-s "^Tags-db-process")
      (nsimple-delete-line))
  (goto-char (point-min))
  )

(setq n-svr-posted-funcs nil)

(defun n-post-for-svr( key func &rest args)
  (if (assoc key  n-svr-posted-funcs)
      (progn
        (n-unpost-for-svr key)
        (n-trace "svr posting for %s overruled" key)
        )
    )
  (setq  n-svr-posted-funcs (cons
                             (cons key (cons func args))
                             n-svr-posted-funcs
                             )
         )
  )

(defun n-unpost-for-svr( key)
  (let(
       (elt	 (assoc key  n-svr-posted-funcs))
       )
    (if elt
        (setq n-svr-posted-funcs	(delq elt n-svr-posted-funcs))
      )
    )
  )

(defun n-svr-misc( cmd)
  "given STR, a one-char string, use it to index into an alist for a posted func and args"
  (let(
       (posted	(assoc cmd n-svr-posted-funcs))
       func
       args
       )
    (if (not posted)
        (error "nothing posted to svr for %s" cmd))
    (setq func			(cadr posted)
          args			(cddr posted)
          )
    (apply func args)
    )
  )


(defun n-for( func seq )
  "apply FUNC to each node of LIST"
  (while seq
    (funcall func (car seq))
    (setq seq (cdr seq))
    )
  )

(defun n-sentinel( proc msg )
  (n-trace (concat "Sentinel-Rcv: " msg))
  )

(defun n-sentinel-silent( proc msg )
  )



(setq n-history-pending nil)
(setq n-history-ordinal 1)

(defun n-history-prompted-cmd-p()
  "return t if the current line is a cmd entered at the shell in response to
a prompt (in contrast to a line of input to a running program, like mail)"
  (save-excursion
    (let(
         (maybePrompt	(n-get-line))
         )
      (equal 0 (string-match (n-host-current) maybePrompt))
      )
    )
  )


(defun n-delete-window()
  "delete the current window"
  (interactive)
  (if (= 1 (count-windows))
      (n-flip)
    (delete-window)
    )
  )


(defun n-flip()
  "move the most recent buffer into the current window"
  (n-split-and-flip)
  (delete-other-windows)
  )

(defun n-split-and-flip()
  "split the current window and display the second most recent buffer one half of the newly divided window"
  (interactive)
  (delete-other-windows)
  (split-window-vertically)
  (other-window 1)
  (switch-to-buffer (other-buffer))
  )

(defun n-other-window()
  "go to the next window"
  (interactive)
  (let(
       (old-major-mode major-mode)
       (buf	(current-buffer))
       (fn	(buffer-file-name))
       )
    (other-window 1)
    (cond
     ((and fn (eq major-mode 'shell-mode))
      (switch-to-buffer buf)
      (if (eq old-major-mode 'nsh-mode)
          (n-file-chmod  "a+x")
        )
      (nshell-meat)
      )
     ((and fn
           (or
            (eq major-mode 'gdb-mode)
            (eq major-mode 'gud-mode)
            )
           )
      (set-buffer buf)
      (save-buffer)
      )
     )
    )
  )

(defun n-rv( patts &optional errS lines )
  "given PATTERNS, a list structured as follows:
;;	(list
;;		(list patt func arg1 arg2...)
;;		(list patt func arg1 arg2...)
;;		...
;;	)
;;n-v will go to the first occurrence of the patt's, and then,
;;if func is a function, execute
;;the corresponding func (passing it the attendant arg1... list).
;;If func isn't supplied, n-v just returns the text pattern that
;;was the hit.
;;If func is not executable, the list func, arg1... is returned.
;;
;;If the optional string arg ERR_STRING is passed and no patterns
;;are found, error is called and passed the error string.
;;
;;If the optional integer arg  LINES is passed, the search takes
;;place only within that number of lines following point.
  "
  (n-v nil patts errS lines ))

(defun n-sv( patts &optional errS lines )
  "given PATTERNS, a list structured as follows:
;;	(list
;;		(list patt func arg1 arg2...)
;;		(list patt func arg1 arg2...)
;;		...
;;	)
;;n-v will go to the first occurrence of the patt's, and then,
;;if func is a function, execute
;;the corresponding func (passing it the attendant arg1... list).
;;If func isn't supplied, n-v just returns the text pattern that
;;was the hit.
;;If func is not executable, the list func, arg1... is returned.
;;
;;If the optional string arg ERR_STRING is passed and no patterns
;;are found, error is called and passed the error string.
;;
;;If the optional integer arg  LINES is passed, the search takes
;;place only within that number of lines following point.
  "
  (n-v t patts errS lines ))

(defun n-v( forward patts &optional errS lines)
  "given FORWARD, a bool giving the search direction,
;;and PATTERNS, a list structured as follows:
;;(
;; (
;;	(list
;;		(list patt func arg1 arg2...)
;;		(list patt func arg1 arg2...)
;;		...
;;	)
;;n-v will go to the first occurrence of the patt's, and then,
;;if func is a function, execute
;;the corresponding func (passing it the attendant arg1... list).
;;If func isn't supplied, n-v just returns the text pattern that
;;was the hit.
;;If func is not executable, the list func, arg1... is returned.
;;
;;If the optional string arg ERR_STRING is passed and no patterns
;;are found, error is called and passed the error string.
;;
;;If the optional integer arg  LINES is passed, the search takes
;;place only within that number of lines following point.
"
  (save-restriction
    (if lines
        (narrow-to-region (point) (progn
                                    (forward-line lines)
                                    (point))
                          )
      )
    
    (let(
         (func	(if forward 'n-s 'n-r))
         (ptCmp	(if forward '<   '>))
         (start	(point))
         (hitPt	(if forward
                    (1+ (point-max))
                  0))
         hit
         maybeHit
         )
      (if lines
          (widen))
      (while patts
        (setq maybeHit (car patts)
              patts (cdr patts))
        
                                        ;(n-trace "n-v: trying %s at %d"  (n-v-text maybeHit) (point))
        
        (if (and (funcall func (n-v-text maybeHit))
                 (funcall ptCmp (point) hitPt))
            (progn
              
                                        ;(n-trace "hit %s at %d"  (n-v-text maybeHit) (point))
              
              (setq hit maybeHit
                    hitPt (point))
              )
          )
        (goto-char start)
        )
      (if hit
          (progn
            (goto-char hitPt)
            (if (n-v-func hit)
                (apply (n-v-func hit) (n-v-args hit))
              (if (n-v-rest hit)
                  (n-v-rest hit)
                (n-v-text hit)
                )
              )
            )
        (if errS
            (error "n-v: %s" errS)
          nil
          )
        )
      )
    )
  )

(defun n-v-text( hit)
  (car hit))

(defun n-v-rest( hit)
  (cadr hit))

(defun n-v-func( hit)
  (if (and (symbolp (n-v-rest hit)) (fboundp (n-v-rest hit)))
      (n-v-rest hit)))

(defun n-v-args( hit)
  (cddr hit))

(defun n-proc-cmd( cmds msg)
  (and (< 0 (length msg))
       (string-match (concat "[" cmds  "]")
                     (substring msg 0 1))
       )
  )




(defun n-skip-str()
  (if (looking-at "\"")
      (n-s "[^\\]\""))
  )




(defun n-cyclic-inc( jj len)
  (setq jj (1+ jj))
  (if (= jj len)
      0
    jj
    )
  )

(defun n-mode-line-buffer-name()
  (cond
   ((eq major-mode 'dired-mode)
    "")
   (t
    (buffer-name))
   )
  )
(defun n-reboot()
  (interactive)
  (if (y-or-n-p "reboot?")
      (progn
        (if (not (equal "drone" (system-name)))
            (error "n-reboot: "))
        (if (get-buffer "*shell*")
            (kill-buffer "*shell*"))
        (shell)
        (n-sleep-for 2)
        (process-send-string nil "su\n")
        (n-sleep-for 2)
        (process-send-string nil (concat (n-host-pw) "\n"))
        (n-sleep-for 2)
        (process-send-string nil "reboot\n")
        )
    )
  )

(defun n-oop(&rest x)
  "no op"
  )
(defun n-start-process(name buffer pgm &rest arguments)
  (n-trace (apply 'concat name arguments))
  (let(
       expandedArguments
       )
    (while arguments
      (setq expandedArguments (cons (nsimple-env-expand (car arguments))
				    expandedArguments
				    )
	    arguments (cdr arguments)
	    )
      )
    (setq expandedArguments (nreverse expandedArguments))

    (if (and n-win
             (string= "perl" pgm)
             )
        (setq pgm "perl.exe")
      )

    (get-buffer-create buffer)
    (let(
	 (process	(apply 'start-process name buffer pgm expandedArguments))
	 )
      (n-process-catch-up-maybe)
      process
      )
    )
  )

