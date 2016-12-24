(provide 'n5)
(setq n-narrowed nil)
(make-variable-buffer-local 'n-narrowed)
(defun n-narrow-to-region(&optional p1 p2)
  (interactive)
  (setq n-narrowed t)
  (if (not p1)
      (call-interactively 'narrow-to-region)
    (narrow-to-region p1 p2)
    )
  )

(defun n-widen( &optional arg p1 p2)
  "if the region is not currently narrowed, then narrow to REGION.
  if the region IS currently narrowed, then stop narrowing, unless optional ARGUMENT is non-nil, in which case, narrow to REGION."
  (interactive "P")
  (let(
       (cmd (if (not arg)
                ?n


              ?1

              ;;(progn
              ;;(message "1-no-matter-what")
              ;;(read-char)
              ;;)
              )
            )
       )
    (cond
     ((or (= cmd ?1) (not n-narrowed))
      (setq n-narrowed t)
      (if p2
          (narrow-to-region p1 p2)
        (condition-case nil
            (call-interactively 'narrow-to-region)
          (error (progn
                   (widen)
                   (message "No mark, so widened insteaded of narrowing...")
                   )
                 )
          )
        )
      )
     (t
      (setq n-narrowed nil)
      (call-interactively 'widen)
      )
     )
    )
  )

(defun n-makefile-p()
  (or (string-match "^Makefile" (buffer-name))
      (string-match "^makefile" (buffer-name)))
  )

(defun n-zip-cat( l1 l2)
  (let(
       l3
       )
    (while (and l1 l2)
      (setq	l3 (append (list (concat (car l1) (car l2))) l3)
                l1 (cdr l1)
                l2 (cdr l2)
                )
      )
    l3
    )
  )
;;(n-zip-cat (list "a" "b") (list "1" "2")) -> (list "b2" "a1")
(setq n-exit-hook nil
      n-exit-hook-pending nil
      )

(defun n-post-for-exit-push()
  "push a new node onto posted actions-at-exit stack"
  (setq n-exit-hook		(cons n-exit-hook-pending n-exit-hook)
        n-exit-hook-pending	nil
        )
  )

(defun n-post-for-exit-pop()
  "pop the topmost node off of the posted actions-at-exit stack"
  (if n-exit-hook
      (let(
           (actions	(car n-exit-hook))
           )
        (while actions
          (apply (caar actions) (cdar actions))
          (setq actions (cdr actions))
          )
        (setq n-exit-hook (cdr n-exit-hook))
        )
    )
  )
  
(defun n-post-for-exit( func &rest args)
  "request that when the current edit level is exited 
    (FUNC &rest ARGS) be executed"
  (setq n-exit-hook-pending (cons (append (list func) args)
                                  n-exit-hook-pending
                                  )
        )
  )

(defun n-grab-recursive()
  "go into a recursive edit; mark some text; return; insert it"
  (interactive)
  (n-post-for-exit 'call-interactively 'nsimple-copy-region-as-kill)
  (save-window-excursion
    (recursive-edit)
    )
  (yank)
  )

(setq n-grab-token-recursive-tmp nil)

(defun n-grab-token-recursive(&optional badChars)
  "go into a recursive edit; user goes to a token; routine returns this token"
  (interactive)
  (if (not badChars)
      (setq badChars (n-grab-token-badChars)))
  (let(
       )
    (n-post-for-exit '(lambda()
			(setq n-grab-token-recursive-tmp
			      (buffer-substring-no-properties
			       (progn
				 (if (n-r (concat "[" badChars "]"))
				     (forward-char 1)
				   (goto-char (point-min))
				   )
				 (point)
				 )
			       (progn
				 (if (n-s (concat "[" badChars "]"))
				     (forward-char -1)
				   (goto-char (point-max))
				   )
				 (point)
				 )
			       )
			      )
			)
		     )
    (save-window-excursion
      (recursive-edit)
      )
    n-grab-token-recursive-tmp
    )
  )

(defun n-scratch-compile()
  (interactive)
  (n-loc-push)
  (goto-char (point-min))
  (n-s "^@@" t)
  (forward-line 0)
  (eval-last-sexp nil)
  (n-loc-pop)
  (message "*scratch* n-x7 compiled")
  )
(defun n-enlarge-window()
  "increase the size of the current buffer's window"
  (interactive)
  (enlarge-window 4)
  )

(defun n-personal-file( fn findDate)
  "get FN, post save for when it quits; if DATE, enter date on line, and return t if month-day updated"
  (n-file-find fn)
  (goto-char (point-min))
  (n-s "^>")
  (forward-line 1)
  (nbuf-post-for-kill 'save-buffer)
  (if findDate
      (let(
           (monthDay	(n-month-day t t))
           )
        (if (or (looking-at monthDay)
                (save-excursion
                  (n-r (concat "^" monthDay))
                  )
                )
            nil		;; date already there
          (progn
            (forward-line -1)
            (insert     monthDay "\n")
            (forward-line 1)
            t		;; return t if month-day updated
            )
          )
        (setq fill-prefix "\t")
        (auto-fill-mode 1)
        )
    )
  )

(defun n-month-day( &optional arg addYr)
  "(n-month-day)==('Jun' . '5')
  (n-month-day 0)==(6 . 5)
  (n-month-day 1)=='Mon'
  (n-month-day 2)=='Jun-97'
  (n-month-day t)=='Jun 5'
  (n-month-day t t)=='Jun 5-97'"

  (let(
       (timeStr (current-time-string))
       )
    (let(
         (month	(progn
                  (if (not
		       ;; Tue Apr 10 14:45:10 2001
                       (string-match "^\\([A-Za-z]+\\) \\([A-Za-z]+\\) +\\([0-9]+\\) \\([0-9:]+\\) \\([0-9][0-9]\\([0-9][0-9]\\)\\)"
                                     timeStr)
                       )
                      (error (format "cannot parse time string %s" timeStr))
		    )
                  (n--pat 2 timeStr))
                )
         (dayOfWeek	(n--pat 1 timeStr))
         (day		(n--pat 3 timeStr))
         (time		(n--pat 4 timeStr))
	 (year4		(n--pat 5 timeStr))
	 (year 		(n--pat 6 timeStr))
         monthAsNumber
         )
      (setq monthAsNumber (cond
			   ((string= month "Jan") 1)
			   ((string= month "Feb") 2)
			   ((string= month "Mar") 3)
			   ((string= month "Apr") 4)
			   ((string= month "May") 5)
			   ((string= month "Jun") 6)
			   ((string= month "Jul") 7)
			   ((string= month "Aug") 8)
			   ((string= month "Sep") 9)
			   ((string= month "Oct") 10)
			   ((string= month "Nov") 11)
			   ((string= month "Dec") 12)
			   )
            )
      (cond
       ((equal arg t)
        (format "%s %s%s" month day
                (if addYr
                    (concat "-" year)
                  ""
                  )
                )
        )
       ((equal arg 0)
        (cons monthAsNumber
              (string-to-int day))
        )
       ((equal arg 1)
        dayOfWeek
        )
       ((equal arg 2)
        (format "%s-%s" month year)
        )
       ((and (stringp arg)
	     (string= arg "sql")
	     )
	(format "%02d-%2s-%s %s"
		monthAsNumber
		day
		year4
		time
		)
        )
       (t
        (cons month day)
        )
       )
      )
    )
  )
(defun n-year(fourDigits)
  (let(
       (timeStr (current-time-string))
       )
    (let(
         (year	(progn
                  (if (not
		       ;; Tue Apr 10 14:45:10 2001
                       (string-match "^\\([A-Za-z]+\\) \\([A-Za-z]+\\) +\\([0-9]+\\) \\([0-9:]+\\) \\([0-9][0-9]\\([0-9][0-9]\\)\\)"
                                     timeStr)
                       )
                      (error (format "cannot parse time string %s" timeStr))
		    )
                  (n--pat 6 timeStr))
                )
	 year4
         )
      (setq year4 (n--pat 5 timeStr))

      (if fourDigits
	  year4
	year
	)
      )
    )
  )
(defun n-make-marker( j)
  (let(
       (marker	(make-marker))
       )
    (set-marker marker j (current-buffer))
    )
  )

(defun n-next-line( &optional arg )
  "go to the next line"
  (interactive "p")
  (if (eobp)
      (error "End of buffer."))
  (next-line arg)
  )

(defun n-prev-line( &optional arg )
  " go to the previous line"
  (interactive "p")
  (if (bobp)
      (error "Beginning of buffer."))
  (previous-line arg)
  )
(defun n-next-line-safe()
  (interactive)
  (condition-case nil
      (call-interactively 'next-line)
    (error nil)
    )
  )

(defun n-note()
  "record the current token, point and fn (to *n-output*)"
  (interactive)
  (n-print "%s" (n-grab-token))
  (save-excursion
    (set-buffer "*n-output*")
    (indent-to-column 30)
    )
  (n-print "%s:%d\n" (buffer-file-name) (n-what-line))
  )

(defun n-name-prefix()
  "based on the current buf name, give the LISP name prefix according to my conventions"
  (let(
       (bufPrefix	(nfn-prefix))
       )
    (if (string-match "n[0-9]+" bufPrefix)
        "n-"
      (concat bufPrefix "-")
      )
    )
  )
(defun n-q( prompt )
  (save-excursion
    (forward-line 0)
    (setq overlay-arrow-position (point-marker))
    (recenter nil)
    (prog1
        (y-or-n-p prompt)
      (setq overlay-arrow-position nil)
      )
    )
  )
(defun n-nuke-pdf-bs()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "—" "--")
    )
  )
(defun n-math-percentage(denominator numerator)
  ;; computer percentage to one decimal point
  (/
   (/ (* 1000 denominator) numerator)
   10.0
   )
  )
