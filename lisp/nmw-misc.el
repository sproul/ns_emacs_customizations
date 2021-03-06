(defun nmw-misc-add-trailer(lang trailer)
  (require 'xcursion
	   (n-s (concat "'" lang "' => '") t)
	   (if (not trailer)
	       (setq trailer (read-string (concat "new trailer for " lang ": "))))
	   (end-of-line)
	   (n-r "'" t)
	   (forward-char -1)
	   (insert trailer)
	   )
  trailer
  )

(defun nmw-misc-add-trailers()
  (let(
       English-trailer
       German-trailer
       French-trailer
       Italian-trailer
       Spanish-trailer
       )
    (while (and (n-s "{")
		(y-or-n-p "go? ")
		)
      (setq English-trailer	(nmw-misc-add-trailer	"English"	English-trailer)
	    German-trailer	(nmw-misc-add-trailer	"German"	German-trailer)
	    French-trailer	(nmw-misc-add-trailer	"French"	French-trailer)
	    ;;Italian-trailer	(nmw-misc-add-trailer	"Italian"	Italian-trailer)
	    ;;Spanish-trailer	(nmw-misc-add-trailer	"Spanish"	Spanish-trailer)
	    )
      )
    )
  )
(defun nmw-misc-switch-imperfect-English-from-ing()
  (let(
       (verb	(save-excursion
 		  (n-s "'English' => '.*I was \\([a-z]+\\)ing" t)
		  (n--pat 1)
		  )
		)
       )
    (setq verb (nstr-replace-regexp verb "tt$" "t")
	  verb (read-string "ok? " verb)
	  )
    (while (and (n-s "'English' => '")
		(y-or-n-p "go? ")
		)
      (save-restriction
	(n-narrow-to-line)
	(n-s "ing " t)
	(forward-char -1)
	(narrow-to-region (point)
			  (progn
			    (forward-line 0)
			    (point)
			    )
			  )
	(end-of-line)
	(n-r "\\(\\\\'\\)?\\b[a-z]+ [a-z]+ing" t)
	(narrow-to-region (point)
			  (progn
			    (end-of-line)
			    (point)
			    )
			  )
	(delete-region (point-min) (point-max))
	(insert verb)
	)
      )
    )
  )

(defun nmw-misc-switch-present-English-to-ing()
  (let(
       contract
       (verb-ing	(save-excursion
			  (n-s "'English' => 'I " t)
			  (concat (n-grab-token) "ing")
			  )
			)
       x
       )
    (setq verb-ing (nstr-replace-regexp verb-ing "e$" "")
	  verb-ing (read-string "ok? " verb-ing)
	  )
    (while (and (n-s "'English' => '")
		(y-or-n-p "go? ")
		)
      (setq contract (nsimple-coin-flip))
      (cond
       ((looking-at "You")	(setq x (if contract "\\'re" " are")))
       ((looking-at "I")	(setq x (if contract "\\'m" " am")))
       ((looking-at "They")	(setq x (if contract "\\'re" " are")))
       ((looking-at "We")	(setq x (if contract "\\'re" " are")))
       ((looking-at "One")	(setq x (if contract "\\'s" " is")))
       ((looking-at "She")	(setq x (if contract "\\'s" " is")))
       ((looking-at "He")	(setq x (if contract "\\'s" " is")))
       )
      (forward-word 1)
      (insert x)
      (forward-char 1)
      (delete-region (point) (progn
			       (n-s " ")
			       (forward-char -1)
			       (point)
			       )
		     )
      (insert verb-ing)
      )
    )
  )
(defun nmw-misc-delete-xlation(lang)
  (save-excursion
    (if (n-s (concat "'" lang "' =>"))
	(nsimple-delete-line 1)
      )
    )
  )

(defun nmw-misc-delete-xlations()
  (while (and (n-s "{")
	      (y-or-n-p "go? ")
	      )
    (nmw-misc-delete-xlation "German")
    (nmw-misc-delete-xlation "French")
    (nmw-misc-delete-xlation "Italian")
    (nmw-misc-delete-xlation "Spanish")
    )
  )

(defun nmw-misc-narrow-to-current-tense()
  (let(
       (firstPersonEnglishRegexp "English' => '.*\\bI\\b")
       )
    (narrow-to-region 
     (progn
       (n-s "}" t)
       (n-r firstPersonEnglishRegexp t)
       (n-r "{" t)
       (point)
       )
     (progn
       (n-s firstPersonEnglishRegexp t)
       (n-s firstPersonEnglishRegexp t)
       (n-r "}" t)
       (point)
       )
     )
    )
  (goto-char (point-min))
  )

(defun nmw-misc()
    (interactive)
  (let(
       (cmd (progn
	      (message "d-elete xlations, i-English-present-to-ing, I-English-imperfect-from-ing, t-railer addition")
	      (read-char)
	      )
	    )
       )
    (cond
     ((eq cmd ?d) (nmw-misc-delete-xlations))
     ((eq cmd ?i) (nmw-misc-switch-present-English-to-ing))
     ((eq cmd ?I) (nmw-misc-switch-imperfect-English-from-ing))
     ((eq cmd ?n) (nmw-misc-narrow-to-current-tense))
     ((eq cmd ?t) (nmw-misc-add-trailers))
     ) 
    )
  )
