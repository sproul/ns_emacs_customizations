(provide 'nsrc)

(defvar nsrc-mv-destination nil "file destination for marked code, if it is moved/copied")

;; utilities to manipulate code (e.g., moving it between modules)
(defun nsrc()
  (interactive)
  (let(
       (cmd (progn
	      (message "c-opy marked, d-el marked, m-v marked, r-outine mark, R-outine and deps mark, u-nmark routine, U-nmark all")
	      (read-char)
	      )
	    )
       )
    (cond
     ((eq cmd ?c)
      (nsrc-copy-marked)
      )
     ((eq cmd ?d)
      (nsrc-delete-marked)
      )
     ((eq cmd ?m)
      (nsrc-mv-marked)
      )
     ((eq cmd ?r)
      (nsrc-mark-routine)
      )
     ((eq cmd ?R)
      (nsrc-mark-routine-and-deps)
      )
     ((eq cmd ?u)
      (nsrc-unmark-routine)
      )
     ((eq cmd ?U)
      (nsrc-unmark-all)
      )
     )
    )
  )
(defun nsrc-delete-marked()
  (require 'n-prune-buf)
  (n-prune-buf "^\\|")
  (nsrc-unmark-all) ;; rm marks for dangling refs
  )

(defun nsrc-mv--set-destination()
  (if (not nsrc-mv-destination)
      (setq nsrc-mv-destination default-directory))
  (setq nsrc-mv-destination (nfly-read-fn "mv marked code to: " nsrc-mv-destination))
  )

(defun nsrc-mv-marked()
  (save-window-excursion
    (nsrc-copy-marked)
    (n-loc-push)
    )
  (nsrc-delete-marked)
  (n-loc-pop)
  )
(defun nsrc-copy-marked()
  (nsrc-mv--set-destination)
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       )
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data)
      (require 'n-prune-buf)
      (n-prune-buf-v "^|")
      (nsrc-unmark-all)
      (setq data (buffer-substring-no-properties (point-min) (point-max)))
      (delete-region (point-min) (point-max))
      )
    (nelisp-bp "nsrc-copy-marked" (concat "about to go to " nsrc-mv-destination) 69);;;;;;;;;;;;;;;;;
    (find-file nsrc-mv-destination)
    (nelisp-bp "nsrc-copy-marked" "in dest file, hopefully" 71);;;;;;;;;;;;;;;;;
    (if (n-s "^sub new")
	(forward-line 0)
      (goto-char (point-max))
      )
    (n-loc-push)
    (nelisp-bp "nsrc-copy-marked" "about to insert" 78);;;;;;;;;;;;;;;;;
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data)
      (goto-char (point-min))
      (replace-regexp "^sub" "\nsub")
      )
    (nelisp-bp "nsrc-copy-marked" "done" 80);;;;;;;;;;;;;;;;;
    )
  )
(defun nsrc-mark-routine(&optional searchForGlobalsUsedAndRoutinesCalled)
  (save-restriction
    (save-excursion
      (nc-beginning-of-defun t)
      (if (not (looking-at "|"))	;; guard against routine already having been marked
	  (progn
	    (narrow-to-region (point)
			      (progn
				(n-s "{" t)
				(nc-end-of-defun) 
				(point)
				)
			      )
	    (goto-char (point-min))
	    (replace-regexp "^" "|")
	    
	    (if searchForGlobalsUsedAndRoutinesCalled
		(let(
		     token
		     )
		  ;; update listOfGlobalsUsed
		  (goto-char (point-min))
		  ;; assume globals start w/ "__":
		  (while (n-s "[%\\$@]\\(__[0-9a-zA-Z_]+\\)")
		    (setq token (n--pat 1))
		    (n-trace "glob used: %s" token)
		    (if (not (assoc token listOfGlobalsUsed))
			(setq listOfGlobalsUsedChanged t
			      listOfGlobalsUsed (cons (cons token nil) 
						      listOfGlobalsUsed)))
		    )
		  
		  ;; update listOfRoutinesCalled
		  (goto-char (point-min))
		  ;; assume routines are capitalized:
		  (while (n-s "\\(\\$self->\\|[^:a-zA-Z0-9_]\\)\\([A-Z][0-9a-zA-Z_]*\\)(") 
		    (setq x (n--pat 1))
		    (setq token (n--pat 2))
		    (n-trace "routine called: %s (%s)" token x)
		    (if (not (assoc token listOfRoutinesCalled))
			(setq listOfRoutinesCalledChanged t
			      listOfRoutinesCalled (cons (cons token nil) 
							 listOfRoutinesCalled)))
		    )
		  )
	      )
	    )
	)
      )
    )
  )

(defun nsrc-unmark-all()
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "^[!|]" "")	      
    )
  )
(defun nsrc-mark-routine-and-deps()
  (let(
       ;; these are hashes, to prevent double-counting.  Since assoc, ELISP's hash access routine,
       ;; expects a list of cons, we have to append meaningless t's to make it happy:
       listOfGlobalsUsed
       (listOfRoutinesCalled (list (cons (n-defun-name) t)
				   )
			     ) 
       
       listOfGlobalsUsedChanged
       listOfRoutinesCalledChanged
       L
       )
    (nsrc-mark-routine t)      
    (while (or listOfGlobalsUsedChanged
	       listOfRoutinesCalledChanged
	       )
      (if listOfGlobalsUsedChanged
	  (progn
	    (setq L listOfGlobalsUsed
		  listOfGlobalsUsedChanged nil
		  )
	    (while L
	      (goto-char (point-min))
	      (replace-regexp (concat "^my \\(.\\)" (caar L) " ")
			      (concat "|my \\1"     (caar L) " ")
			      )
	      (setq L (cdr L))
	      )
	    )  
	)
      (if listOfRoutinesCalledChanged
	  (progn
	    (setq L listOfRoutinesCalled
		  listOfRoutinesCalledChanged nil
		  )
	    (while L
	      (goto-char (point-min))
	      (if (not (n-s (concat "^sub " (caar L) "$")))
		  ;;(n-trace "nsrc-mark-routine-and-deps: could not find %s" (caar L))
		  nil
		(n-s "{" t)
		(nsrc-mark-routine t)      
		)
	      (setq L (cdr L))
	      )
	    )  
	)
      )
    (nsrc-mark-potentially-dangling-refs listOfGlobalsUsed listOfRoutinesCalled)
    )
  )
(defun nsrc-unmark-routine()
  (save-restriction
    (narrow-to-region (progn
			(nc-beginning-of-defun t)
			(point)
			)
		      (progn
			(n-s "^.?}" t)	; .? for the possibility of marking
			(point)
			)
		      )
    (goto-char (point-min))
    (replace-regexp "^|" "")
    )
  )
(defun nsrc-mark-potentially-dangling-ref()
  (forward-line 0)
  (n-loc-push)
  (insert "!")
  )
(defun nsrc-mark-potentially-dangling-refs(listOfGlobalsUsed listOfRoutinesCalled)
  (while listOfGlobalsUsed
    (goto-char (point-min))
    (while (n-s (concat "^[^|!].*[%\\$@]" (caar listOfGlobalsUsed) "\\b"))
      (nsrc-mark-potentially-dangling-ref)
      )
    (setq listOfGlobalsUsed (cdr listOfGlobalsUsed))
    )
  (while listOfRoutinesCalled
    (goto-char (point-min))
    (while (n-s (concat "^[^|!].*\\b" (caar listOfRoutinesCalled) "("))
      (nsrc-mark-potentially-dangling-ref)
      )
    (setq listOfRoutinesCalled (cdr listOfRoutinesCalled))
    )
  (n-loc-pop)	;; pop last one since that's where pt ends up anyway
  )
