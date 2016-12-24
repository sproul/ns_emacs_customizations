(provide 'n-loc)
(defun n-loc-push( &optional arg)
  "push current location onto the location stack"
  (interactive "P")
  (let(
       cmd
       (newLoc (cons (buffer-name) (point-marker)))
       )
    (if arg
	(progn
	  (setq cmd (progn
		      (message "a-ll instances of ^x1, s-tack dump, u-nshift (ie, add to EOL)")
		      (read-char)
		      )
		)
	  (cond
	   ((eq cmd ?a)
	    (n-loc-push-all (nsimple-register-get ?1))
	    )
	   ((eq cmd ?s)
	    (error "n-loc-push: backtrace")
	    )
	   )
	  )
      )
    (setq n-locs (if (eq cmd ?u)
                     (append n-locs (list newLoc))
                   (cons newLoc n-locs)
                   )
          )
    )
  )
(defun n-loc-push-all(x)
  (goto-char (point-min))
  (while (n-s x)
    (n-loc-push)
    )
  )

(defun n-loc-name( locPtr )
  (if locPtr
      (car (car locPtr)))
  )

(defun n-loc-mark( locPtr )
  (if locPtr (cdr (car locPtr)))
  )

(defun n-loc-pop()		;; &optional dontGoToIt?
  "pop a location off of the location stack and go to it"
  (interactive)
  (let(
       (markBuffer  (progn
                      (while (and n-locs
                                  (not (marker-buffer (n-loc-mark n-locs)))
                                  )
                        (setq n-locs (cdr n-locs))
                        )
                      (if n-locs
			  (marker-buffer (n-loc-mark n-locs))
			)
                      )
                    )
       )
    (if (not markBuffer)
	(message "loc stack is empty")
      (if (not (equal markBuffer (current-buffer)))
	  (switch-to-buffer-other-window markBuffer))
      (goto-char (marker-position (n-loc-mark n-locs)))
      (setq n-locs (cdr n-locs))
      )
    )
  )

(defun n-loc-clear()
  (setq n-locs nil)
  )
(defun n-loc-reverse()
  (setq n-locs (nreverse n-locs))
  )
(defun n-loc-on-current-line()
  (and n-locs
       (equal (current-buffer) (marker-buffer (n-loc-mark n-locs)))
       (let(
	    (beginning (save-excursion
			 (forward-line 0)
			 (point)
			 )
		       )
	    (end (save-excursion
		   (end-of-line)
		   (point)
		   )
		 )
	    (position (marker-position (n-loc-mark n-locs))) 
	    )
	 (and
	  (>= position beginning)
	  (<= position end)
	  )
	 )
       )
  )

(defun n-locs-kill( bufName)
  "remove all the nodes in n-locs which refer to the buffer named by
BUFNAME"
  (let(
       newL
       )
    (while n-locs
      (if (not (equal (caar n-locs) bufName))
          (setq newL (append newL (list (car n-locs))))
        )
      (setq n-locs (cdr n-locs))
      )
    (setq n-locs newL)
    )
  )

(defun n-loc-tour-load-files(todo)
  (let(
       file offset pattern
	    )
    (while todo
      (setq
       file (caar todo)
       offset (cadar todo)
       pattern (caddar todo)
       todo (cdr todo)
       )
      (n-file-find file)
      (cond
       ((integerp offset)
	(goto-char offset)
	)
       ((stringp pattern)
	(goto-char (point-min))
	(n-s pattern t)
	)
       )
      (n-loc-push)
      )
    )
  )
(defun n-loc-tour(&rest args)
  (save-some-buffers t)
  (save-window-excursion
    (let(
	 todo
	 )
      (while args
	(let(
	     (arg (car args))
	     )
	  (cond
	   ((stringp arg)
	    (setq todo (cons (list arg 0 nil) todo))
	    )
	   ((listp arg)
	    (setq todo (cons (list arg nil (cadr arg)) todo))
	    )
	   (t
	    (error "n-loc-tour: ")
	    )
	   )
	  )
	)
      (n-loc-tour-possibly-checkout todo)
      (n-loc-tour-load-files todo)
      )
    )
  (n-loc-pop)
  )

(defun n-loc-tour-possibly-checkout(todo)
  (let(
       checkout
       (tmp todo)
       )
    (while tmp
      (if (not (file-writable-p (car tmp)))
	  (progn
	    (setq tmp nil)
	    (setq checkout (y-or-n-p "check out read-only files? "))
	    )
	)
      (setq tmp (cdr tmp))
      )
    (if checkout
	(progn
	  (while todo
	    (let(
		 (file (car todo))
		 )
	      (find-file file)
	      (nbuf-kill-current)
	      
	      (n-host-shell-cmd (concat "p4 edit " file))
	      (setq todo (cdr todo))
	      )
	    )
	  (sleep-for 3)
	  )
      )
    )
  )
