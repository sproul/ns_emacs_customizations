(provide 'nmw-data)

(setq nmw-data-langs (list "French" "German" "Italian" "Spanish"))

(defun nmw-data-mode-meat()
  (let(
       (map  (make-sparse-keymap))
       )
    (define-key map "\C-ck" 'nmw-kill-current-entry)
    ;;(define-key map "\C-cl" 'nmw-goto-current-lang-setting)
    (define-key map "\C-cL" 'nmw-data-set-lang)
    (define-key map "\C-cm" 'nmw-data-misc)
    (define-key map "\C-cM" 'nmw-multiple-verbs-ok)
    (define-key map "\C-cn" 'nmw-narrow-to-current-entry)
    ;;(define-key map "\M-\"" 'nmw-2-lines)

    ;; disable -- screws up nmerge
    ;;(define-key map "\M-\C-f" 'nmw-data-format-for-editing)
    (define-key map "\M-\C-g" 'nmw-data-stop-curlies)
    (define-key map "\M-\C-j" 'nmw-data-edit-map)
    (define-key map "\M-\C-m" 'nmw-data-add-noun-directives)
    (define-key map "\M-\C-n" 'nmw-data-add-noun)
    ;;(define-key map "\M-b" 'nmw-data-backward-word)
    (define-key map "\M-d" 'nmw-data-delete-word)
    ;;(define-key map "\M-f" 'nmw-data-forward-word)
    (define-key map "\M-w" 'nmw-data-find-where)
    (use-local-map map)
    )
  (setq mode-name "teacher data"
        major-mode 'nmw-data-mode
        )

  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list ".*CombinedSeparatedVerb(\".$"	'nmw-complete-replace-with-tense-FormOf)
                 (list ".*CompoundFormOf(\".$"	'nmw-complete-replace-with-tense-CompoundFormOf)
                 (list ".*FormOf(\".$"	'nmw-complete-replace-with-tense-FormOf)
            (list "'tense' => '.$"	'nmw-complete-replace-with-tense)
                 )
                )
	)
  )

(defun nmw-complete-replace-with-tense-FormOf()
  (nmw-complete-replace-with-tense "\", \"@@\")',")
  )

(defun nmw-complete-replace-with-tense-CompoundFormOf()
  (nmw-complete-replace-with-tense "\", \"@@\", \"@@\")',")
  )

(defun nmw-2-lines()
  (interactive)
  (cond
   ((save-excursion
      (forward-line 0)
      (looking-at "[ \t]*'xEnglish' ")
      )
    (forward-line 0)
    (insert "'French' => '{@@',\n")
    (insert "'note/@@French' => '@@',\n")
    (forward-line -2)
    (n-complete-leap)
    )
   (t
    (nmw-2-exercises)
    )
   )
  )

(defun nmw-2-exercises()
  (let(
       (ex (buffer-substring-no-properties (progn
			       (n-r "{" t)
			       (point)
			       )
			     (progn
			       (forward-sexp 1)
			       (point)
			       )
			     )
	   )
       )
    (goto-char (point-max))
    (n-r "}" t)
    (forward-char 1)
    (insert ",\n")
    (save-restriction
      (narrow-to-region (point) (point))
      (insert ex)
      
      (require 'n-prune-buf)
      (n-prune-buf "'German'")
      
      (goto-char (point-min))
      (n-s "'id' =>" t)
      (nsimple-delete-line 1)
      
      (goto-char (point-min))
      (replace-regexp "'French' => '.*'" "'French' => '@@'")
      
      (goto-char (point-min))
      (replace-regexp "'English' => '.*'" "'English' => '@@'")
      )
    (nmw-2-exercises-assign-next-id)
    )
  (goto-char (point-min))
  (n-complete-leap) 
  )
(defun nmw-2-exercises-assign-next-id()
  (let(
       (idNumber (progn
		   (goto-char (point-max))
		   (n-r "'id' => \\([0-9]+\\)" t)
		   (1+ (string-to-int (n--pat 1)))
		   )
		 )
       )
    (n-s "{" t)
    (end-of-line)
    (insert "\n  'id' => " (int-to-string idNumber) ",")
    )
  )

(defun nmw-data-add-trailer(lang trailer)
  (save-excursion
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

(defun nmw-data-add-trailers()
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
      (setq English-trailer	(nmw-data-add-trailer	"English"	English-trailer)
	    German-trailer	(nmw-data-add-trailer	"German"	German-trailer)
	    French-trailer	(nmw-data-add-trailer	"French"	French-trailer)
	    ;;Italian-trailer	(nmw-data-add-trailer	"Italian"	Italian-trailer)
	    ;;Spanish-trailer	(nmw-data-add-trailer	"Spanish"	Spanish-trailer)
	    )
      )
    )
  )
(defun nmw-data-switch-imperfect-English-from-ing()
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

(defun nmw-data-switch-present-English-to-ing()
  (let(
       contract
       (verb-ing	(save-excursion
			  (n-s "'English' => 'I " t)
			  (concat (nmw-grab-token) "ing")
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
(defun nmw-data-delete-xlation(lang)
  (save-excursion
    (if (n-s (concat "'" lang "' =>"))
	(nsimple-delete-line 1)
      )
    )
  )

(defun nmw-append-prop(prop val)
  (save-excursion
    (let(
	 (oldVal (nmw-get-prop prop))
	 )
      (if oldVal
	  (if (not (string-match (concat "|" val "|") oldVal))
	      (progn
		(setq val (concat oldVal val "|"))
		(nmw-set-prop prop val)
		)
	    )
	(nmw-set-prop prop (concat "|" val "|"))
	)
      )
    )
  )

(defun nmw-goto-prop(key)
  (save-restriction
    (narrow-to-region (progn
 			(if (not (n-r "{"))
			    (progn
			      ;; don't be messed up when cursor is sitting on '{', as often happens
			      (forward-char 1)
			      (n-r "{" t)
			      )
			  )
			(forward-line 1)
			(point)
			)
		      (progn
			(n-s "}" t)
			(point)
			)
		      )
    (goto-char (point-min))
    (n-s (concat "'" key "' => "))
    )
  )

(defun nmw-set-prop(key val)
  (if (not key)
      (setq key (nmw-data-get-id)))
  (save-excursion
    (if (not val)
	(if (nmw-goto-prop key)
	    (nsimple-delete-line 1))
      (if (not (nmw-goto-prop key))
	  (progn
	    (insert "'" key "' => \n")
	    (forward-line -1)
	    (end-of-line)
	    )
	)
      (delete-region (point) (progn
			       (end-of-line)
			       (point)
			       )
		     )
      (insert "'" val "',")
      )
    )
  )

(defun nmw-get-prop(&optional key)
  (if (not key)
      (setq key (nmw-data-get-id)))
  (let(
       (val (save-excursion
	      (if (nmw-goto-prop key)
		  (buffer-substring-no-properties (point) (progn
					      (end-of-line)
					      (forward-char -1)
					      (if (not (looking-at ","))
						  (forward-char 1))
					      (point)
					      )
				    )
		)
	      )
	    )
       )
    (setq val (nstr-replace-regexp val ",$" "")
	  val (nstr-replace-regexp val "^'\\(.*\\)'$" "\\1")
	  val (nstr-replace-regexp val "^\"\\(.*\\)\"$" "\\1")
	  )
    )
  )

(defun nmw-data-add-tense-markers-read-tense(dft)
  (save-restriction
    (n-narrow-to-line)
    (prog1
	(nmenu-brief "tense?" "nmw-tenses" dft)
      (widen)
      )
    )
  )

(defun nmw-data-add-tense-markers()
  (let(
       (tense "present")
       (val "present")
       )
    (while (n-s "'French' => '")
      (while (progn
	       (setq val (nmw-data-add-tense-markers-read-tense val))
	       (if (string= "undo" val)
		   (progn
		     (forward-line 0)
		     (n-r "'French' => '" t)
		     (nmw-set-prop "areas" nil)
		     t
		     )
		 )
	       )
	)
      (if (or
	     (string= "add" val)
	     )
	    (progn
	      ;; add tense marker to previous elt
	      (forward-line 0)
	      (n-r "'French' => '" t)
	      (end-of-line)
	      (setq val (nmw-data-add-tense-markers-read-tense val))
	      )
	  )
	(setq tense val)
	(nmw-append-prop "areas" tense)
	(forward-line 1)
      )
    )
  )

(defun nmw-data-delete-xlations()
  (while (and (n-s "{")
	      (y-or-n-p "go? ")
	      )
    (nmw-data-delete-xlation "German")
    (nmw-data-delete-xlation "French")
    (nmw-data-delete-xlation "Italian")
    (nmw-data-delete-xlation "Spanish")
    )
  )

(defun nmw-data-add-exercise()
  (goto-char (point-max))
  (n-r "'id' =>" t)
  (nmw-2-exercises)
  )

(defun nmw-data-misc()
  (interactive)
  (let(
       (action (nmenu "cmd" "nmw-data"))
       )
    (cond
     ((and action (string-match "^(" action))
      (eval (car (read-from-string action)))
      )
     (action
      (nmidnight-ext-run action)
      )
     )
    )
  )
(defun nmw-narrow-to-current-entry()
  (interactive)
  (save-excursion
    (n-widen t
	     (progn
	       (if (not (n-s "^[ \t]*}"))
		   (progn ; for unlikely sit that (point) is at eof, or at least beyond last entry
		     (n-r "^[ \t]*}" t)
		     (forward-char 1)
		     )
		 )
	       (if (looking-at ",")
		   (forward-char 1)
		 (insert ",")			; makes life easier if last entry isn't missing it
		 )
	       (point)
	       )
	     (progn
	       (n-r "^[ \t]*{" t)
	       (point)
	       )
	     )
    )
  (goto-char (point-min))
  )

(defun nmw-goto-current-lang-setting()
  (interactive)
  (if (not nmw-lang)
      (nmw-data-set-lang))
  (save-restriction
    (nmw-narrow-to-current-entry)
    (goto-char (point-min))
    (n-s (concat nmw-lang "' => '") t)
    )
  )
(defun nmw-data-set-lang()
  (interactive)
  (setq nmw-lang (nmw-data-prompt-for-lang))
  )
(defun nmw-data-prompt-for-lang(&optional default)
  (interactive)
  (if default
      (message "e-nglish, f-rench, g-erman, s-panish, i-talian (%s) " default)
    (message "e-nglish, f-rench, g-erman, s-panish, i-talian ")
    )
  (let(
       (cmd (read-char))
       )
    (cond
     ((eq cmd ?e)
      "English"
      )
     ((eq cmd ?f)
      "French"
      )
     ((eq cmd ?g)
      "German"
      )
     ((eq cmd ?s)
      "Spanish"
      )
     ((eq cmd ?i)
      "Italian"
      )
     ((eq cmd 13)	; \n
      default
      )
     )
    )
  )
(defun nmw-kill-current-entry()
  (interactive)
  (save-restriction
    (nmw-narrow-to-current-entry)
    (kill-region (point-min) (point-max))
    (n-widen nil)
    )
  )

(setq nmw-prep-to-generate-this-verb-lang nil)

(defun nmw-prep-to-generate-this-verb( &optional verb-b lang deactivateTest1)
  (interactive "P")
  (if lang
      (setq nmw-prep-to-generate-this-verb-lang lang))
  (cond
   ((save-excursion
      (forward-line 0)
      (looking-at "[^\\\\]+\\\\\\\\\\([A-Z][a-z]+\\).*FormOf[^,]+, \"\\([^\"]+\\)")
      )
    (setq nmw-prep-to-generate-this-verb-lang (n--pat 1)
	  verb-b (n--pat 2)
	  )
    )
   ((and verb-b
	 (not (stringp verb-b))
	 )
    (setq verb-b (read-string "verb to be gen'd, OR nothing to turn off test1: "))
    (if (string= verb-b "")
	(setq deactivateTest1 t))
    )
   )
  (setq nmw-prep-to-generate-this-verb-lang (nmw-data-prompt-for-lang nmw-prep-to-generate-this-verb-lang))
  (n-file-find "$HOME/work/adyn.com/httpdocs/teacher/generate_grammatical_reference.pl")
  (goto-char (point-max))
  (n-r "my \\$test1 =" t)
  (end-of-line)
  (forward-word -1)
  (delete-char 1)
  (insert (if deactivateTest1
	      "0"
	    "1"
	    )
	  )
  (if (not deactivateTest1)
      (progn
	(n-s "Print1VerbTable(\"" t)
	(delete-region (point) (progn
				 (n-s "\"" t)
				 (forward-char -1)
				 (point)
				 )
		       )
	(insert verb-b)
	)
    )
  
  (n-file-find "$HOME/work/adyn.com/httpdocs/teacher/t.ksh")
  
  (if (not deactivateTest1)
      (progn
	(goto-char (point-min))
	(n-s (concat "^#?Grammar " nmw-prep-to-generate-this-verb-lang) t)
	(forward-line 0)
	(cond
	 ((and (looking-at "#")
	       (not deactivateTest1)
	       )
	  (delete-char 1)
	  )
	 ((and (not (looking-at "#"))
	       deactivateTest1
	       )
	  (insert "#")
	  )
	 )
	)
    )
  )
(defun nmw-data-multiple-verbs-ok()
  (interactive)
  (forward-line 0)
  (if (string-match "^\\(verb\\|base\\)" (file-name-nondirectory (buffer-file-name)))
      (insert "'expectedVerbCnt' => 2,")
    (insert "'expectedVerbCnt' => 1,")
    )
  (forward-char -2)
  )
(defun nmw-data-suppress-token(&optional justOne noteToSave)
  "suppress all temporarily noted instances of the current temporarily noted token"
  (save-excursion
    (if noteToSave
	(setq noteToSave (concat "'" noteToSave "'"))
      (setq noteToSave "1")
      )
    (let(
	 (token (nmw-grab-token))	;; probably we'll throw this val away, but just in case...
	 before
	 after
	 )
      (save-restriction
	(widen)
	(save-excursion
	  (n-narrow-to-line)
	  (forward-line 0)
	  (cond
	   ((looking-at ".*#\\([^;]+\\);;\\([A-Z][a-z]+\\)\\(;;tmp\\)?' =>.*")
	    (setq token (n--pat 1)
		  lang  (n--pat 2)
		  )
	    )
	   ((looking-at (concat "[ \t]*'\\([A-Z][a-z]+\\)' =>"))
	    (setq lang (n--pat 1))
	    (insert "'suppress_" lang "_note#" token ";;" lang "' => " noteToSave ",\n")
	    )
	   (t
	    (error "nmw-data-suppress-token: ")
	    )
	   )
	  )    
	(if (not justOne)
	    (widen))
	(goto-char (point-min))
	(setq before (concat "'"          lang "_note#" token ";;" lang "\\(" ";;" "tmp" "\\)?" "' =>[^\n]+")
	      after  (concat "'suppress_" lang "_note#" token ";;" lang "' => " noteToSave ",")
	      )
	(replace-regexp before after) 
	)
      )
    )
  )
(defun nmw-data-mv-to-base()
  (nmw-narrow-to-current-entry)
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       oldBaseMaxId
       )
    (delete-region (point-min) (point-max))
    (n-widen)
    
    (n-file-find "base")
    (n-widen)
    
    (goto-char (point-max))
    (n-r "'id' => \\([0-9]+\\)" t)
    (setq oldBaseMaxId (string-to-int (n--pat 1)))
    
    (goto-char (point-max))
    (n-r "}" t)
    (forward-char 1)
    (if (not (looking-at ","))
	(insert ",")
      (forward-char 1)
      )
    (insert data)
    
    (n-r "'id' => " t)
    (end-of-line)
    (forward-word -1)
    (delete-region (point) (progn
			     (forward-word 1)
			     (point)
			     )
		   )
    (insert (int-to-string (1+ oldBaseMaxId)))
    )
  (n-widen nil)
  )
(defun nmw-complete-replace-with-tense(&optional followUpEdits)
  (end-of-line)
  (let(
       (cmd (progn
	      (forward-char -1)
	      (prog1 
		  (buffer-substring-no-properties (point) (1+ (point)))
		(delete-char 1)
		)
	      )
	    )
       (token (save-excursion
		(save-restriction
		  (n-narrow-to-line)
		  
		  (forward-line 0)
		  (if (n-s "#")
		      (nstr-downcase
		       (buffer-substring-no-properties (point) (progn
						   (n-s ";;" t)
						   (forward-char -2)
						   (point)
						   )
					 )
		       ) 
		    ) 
		  )
		)
	      )
       )
    (cond
     ((string= cmd "?")
      (message "a-pp,A-past subj,c-cond,f-fut,i-imp,I-imperfect,l-plup,p-pret,P-past,r-present participle,R-present,s-subjunctive")
      (setq followUpEdits nil)
      )
     ((string= cmd "a")
      (insert "past participle")
      )
     ((string= cmd "A")
      (insert "past subjunctive")
      )
     ((string= cmd "c")
      (insert "conditional")
      )
     ((string= cmd "f")
      (insert "future")
      )
     ((string= cmd "i")
      (insert "imperative")
      )
     ((string= cmd "I")
      (insert "imperfect")
      )
     ((string= cmd "l")
      (insert "pluperfect")
      )
     ((string= cmd "p")
      (insert "preterite")
      )
     ((string= cmd "P")
      (insert "past")
      )
     ((string= cmd "R")
      (insert "present")
      )
     ((string= cmd "r")
      (insert "present participle")
      )
     ((string= cmd "s")
      (insert "subjunctive")
      )
     )
    (if followUpEdits
	(progn
	  (insert followUpEdits)
	  (forward-line -1)
	  (n-complete-leap)
	  (if token
	      (insert token))
	  )
      )
    )
  )
(defun nmw-data-make-note(&optional dormant value secondary)
  (setq dormant (if dormant (concat "z_" dormant)
		  ""
		  )
	)
  (let(
       (token (nmw-grab-token))
       (lang (progn
	       (forward-line 0)
	       (or (looking-at " *'\\(z/\\)?\\([A-Z][a-z]+\\)\\(/.*\\)?' => '")
		   (error "nmw-data- make-note: "))
	       (n--pat 2)
	       )
	     )
       )
    (if (not secondary)
	(setq secondary ""))
    (if (or (not token)
	    (string= token ",")
	    (string= token "")
	    )
	(insert "'" dormant lang "_note"        secondary ";;" lang "' => '@@',\n")
      (insert   "'" dormant lang "_note#" token secondary ";;" lang "' => '@@',\n")
      )
    (forward-line -1)
    (n-complete-leap)
    (if value
	(insert value))
    )
  )
(defun nmw-data-no_gen()
  (let(
       (lang (progn
	       (forward-line 0)
	       (or (looking-at " *'\\(z/\\)?\\([A-Z][a-z]+\\)\\(/.*\\)?' => '")
		   (error "nmw-data- make-note: "))
	       (n--pat 2)
	       )
	     )
       )
    (insert "'" lang "/no_gen' => '1',\n")
    (forward-line -1)
    (n-complete-leap)
    )
  )
(defun nmw-data-CombinedSeparatedVerb()
  (nmw-data-make-note)
  (insert "CombinedSeparatedVerb(\"")
  (delete-char 2)	; rm second ' and ,
  )

(defun nmw-data-FormOf()
  (nmw-data-make-note)
  (insert "FormOf(\"")
  (delete-char 2)	; rm second ' and ,
  )
(defun nmw-data-CompoundFormOf()
  (nmw-data-make-note)
  (insert "CompoundFormOf(\"")
  (delete-char 2)	; rm second ' and ,
  )
(defun nmw-data-format-for-editing--compress-lists()
  (goto-char (point-min))
  (while (n-s "\\[$")
    (save-restriction
      (narrow-to-region (point) (progn
				  (n-s "\\]" t)
				  (point)
				  )
			)
      (goto-char (point-min))
      (replace-regexp "[ \t\n]+" " ")
      )
    )
  )

(defun nmw-data-format-for-editing()
  (interactive)
  (nmw-narrow-to-current-entry)
  (save-restriction
    (narrow-to-region (progn
			(goto-char (point-min))
			(forward-line 1)
			(point)
			)
		      (progn
			(goto-char (point-max))
			(forward-line -1)
			(end-of-line)
			(if (not (save-excursion
				   (forward-char -1)
				   (looking-at ",")
				   )
				 )
			    (insert ",")
			  )
			(forward-line 1)
			(point)
			)
		      )
    (nmw-data-format-for-editing--compress-lists)
    
    (require 'nsort)
    (nsort-buf)
    (goto-char (point-min))
    
    (replace-regexp "^[ \t]*" "")
    (goto-char (point-min))
    ) 
  )
(defun nmw-data-kill()
  (save-restriction
    (nmw-narrow-to-current-entry)
    (kill-region (point-min) (point-max))
    (n-widen)
    
    (n-loc-push)
    (if (not (n-s "^{"))	;; ok, we're at EOF
	(n-loc-pop)
      (goto-char (point-max))
      (forward-word -1)
      
      (nmw-narrow-to-current-entry)
      (kill-region (point-min) (point-max))
      (n-widen)
      
      (n-loc-pop)
      (yank)
      )
    )
  )
(defun nmw-data-adjust-adjectives-for-one-entry(pronounCode)
  (while (n-s "'z/\\([A-Z][a-z]+\\)/addend' => '\\(.* \\)?\\([^' ]+\\)'")
    (setq lang (n--pat 1)
	  precedingStuff (n--pat 2)
	  token (n--pat 3)
	  token2 token
	  )
    ;;;(if (string-match " " token)
	;;;nil ; phrase, not a single adjective.  Don't try to change it.
    (cond
     ((string= lang "German")
      )
     ((string= lang "French")
      (if (string-match "s3b\\|p3b" pronounCode)
	  (progn	; feminize
	    (cond
	     ((string-match "s$" token) (setq token2 (concat token2 "se")))
	     ((string-match "if$" token) (setq token2 (nstr-replace-regexp token2 "if$" "ive")))
	     ((string-match "eux$" token) (setq token2 (nstr-replace-regexp token2 "eux$" "euse")))
	     ((string-match "eau$" token) (setq token2 (nstr-replace-regexp token2 "eau$" "elle")))
	     ((string-match "/e$" token) (setq token2 (concat token2 "e")))
	     ((string-match "ier$" token) (setq token2 (nstr-replace-regexp token2 "ier$" "i`ere")))
	     ((string-match "[^e]$" token) (setq token2 (concat token2 "e")))
	     ) 
	    )
	)
      (if (string-match "^p" pronounCode)
	  (progn	; make plural
	    (cond
	     ((string-match "eau$" token2) (setq token2 (concat token2 "x")))
	     ((string-match "[^sx]$" token2) (setq token2 (concat token2 "s")))
	     ) 
	    )
	)
      )
     ((string= lang "Italian")
      (cond
       ((string-match "s3b" pronounCode)
	(if (string-match "o$" token)
	    (setq token2 (nstr-replace-regexp token2 "o$" "a")))
	)
       ((string-match "p3b" pronounCode)
	(cond
	 ((string-match "[cg]o$" token)
	  (setq token2 (nstr-replace-regexp token2 "o$" "he"))
	  )
	 ((string-match "[ao]$" token)
	  (setq token2 (nstr-replace-regexp token2 "[ao]$" "e"))
	  )
	 ((string-match "e$" token)
	  (setq token2 (nstr-replace-regexp token2 "o$" "i"))
	  )
	 )
	)
       ((string-match "p" pronounCode)
	(cond
	 ((string-match "[cg]o$" token)
	  (let(
	       (penultimateStressKey  (concat "it-penultimateStress-" token))
	       penultimateStress
	       )
	    (setq penultimateStress (n-database-get-bool penultimateStressKey 
							 (format "Is %s pronounced w/ penultimate stress (like bianco, eg)?" token))
		  )
	    (if penultimateStress
		(progn
		  (setq token2 (nstr-replace-regexp token2 "o$" "hi"))
		  )
	      (setq token2 (nstr-replace-regexp token2 "o$" "i"))
	      )
	    )
	  (message "Ok, set its plural to %s" token2)
	  )
	 ((string-match "io$" token)
	  (nelisp-bp "-io => -ii only for stressed -Io ; otherwise => -i" "nmw-data.el" 799)
	  (setq token2 (nstr-replace-regexp token2 "io$" "ii"))
	  )
	 ((string-match "[aeo]$" token)
	  (setq token2 (nstr-replace-regexp token2 "[aeo]$" "i"))
	  )
	 )
	)
       )
      )
     ((string= lang "Spanish")
      (if (string-match "s3b\\|p3b" pronounCode)
	  (progn	; feminize
	    (cond
	     ((string-match "o$" token) (setq token2 (nstr-replace-regexp token2 "o$" "a")))
	     ) 
	    )
	)
      (if (and (string-match "p[0-9]" pronounCode)
	       (string-match "[^sxz]$" token)
	       )
	  (progn	; make plural
	    (cond
	     ((string-match "[^s]$" token2) (setq token2 (concat token2 "s")))
	     ) 
	    )
	)
      )
     ((string= lang "English")
      )
     (t
      (error "nmw-data-adjust-adjectives: %s" lang)
      )
     )
      ;;;)
    (if (not (string= token token2))
	(progn
	  (forward-line 0)
	  (insert "'" lang "/addend' => '" precedingStuff token2 "',\n")
	  (insert "'" lang "_note#" token2 ";;" lang "' => 'AdjectiveMustAgree(\"" token "\")',\n")
	  (forward-line 1)
	  ;;(n-trace "%s/%s: %s => %s/%s" lang pronounCode token precedingStuff token2)) 
	  )
      )
    )
  )
(defun nmw-data-adjust-adjectives()
  (let(
       done
       lang
       pronounCode
       token
       token2
       )
    (while (not done)
      (save-restriction
	(nmw-narrow-to-current-entry)
	(setq pronounCode (nmw-get-prop "pronoun"))
	(goto-char (point-min))
	(nmw-data-adjust-adjectives-for-one-entry pronounCode)
	(goto-char (point-max))
	)
      (setq done (not (n-s "{")))
      )
    )
  )
(defun nmw-data-init-notes-and-IDs()
  (n-prune-buf "# formatted")
  (nmw-data-init-IDs)
  ;;(if (string-match "^vocab" (nfn-prefix))
  ;;(nmw-data-init-linkbacks))
  )
(defun nmw-data-init-linkbacks()
  (goto-char (point-min))
  (while (n-s "'\\(English\\|German\\|French\\|Italian\\|Spanish\\)' =>")
    (end-of-line)
    (forward-word -1)
    (nmw-data-make-note nil nil "2")
    (insert (nfn-prefix))
    (forward-line 2)	; make-note goes above the current line; we need to advance past the n-s hit
    )
  )

(defun nmw-data-init-IDs()
  (goto-char (point-min))
  (require 'n-prune-buf)
  (n-prune-buf "'id' => ")
  (let(
       (id 0)
       )
    (while (n-s "{")
      (forward-char -1)
      (forward-sexp 1)
      (forward-line -1)
      (end-of-line)
      (forward-char -1)
      (if (not (looking-at ","))
	  (progn
	    (end-of-line)
	    (insert ",")
	    )
	)
      (end-of-line)
      (insert "\n'id' => " (int-to-string id) ",")
      (setq id (1+ id))
      )
    )
  )

(defun nmw-data-clone-langs(data src-string lineCount)
  "This routine will repeatedly clone the area of 'lineCount' lines which was selected for the call to m-\", substituting for each clone one of the foreign languages for src-string.  So for example, ^U3m-\" on the following data (where src-string is 'zz'):
  
  kdskd('zz');
  if (lang=='zz')
  	do whatever;
  
Would yield:
  
  kdskd('German');
  if (lang=='German')
  	do whatever;
  kdskd('French');
  if (lang=='French')
  	do whatever;
  kdskd('Italian');
  if (lang=='Italian')
  	do whatever;
  kdskd('Spanish');
  if (lang=='Spanish')
  	do whatever;
  "
  
  (or (string-match src-string data)
      (error "nmw-data-clone-langs: "))
  (let(
       (langs nmw-data-langs)
       s
       )
    (if (not (string= src-string "French"))
	(save-restriction
	  (narrow-to-region (progn
			      (end-of-line)
			      (point)
			      )
			    (progn
			      (forward-line (1+ (- lineCount)))
			      (point)
			      )
			    )
	  ;; First just replace the instances of zz in the original lines:
	  (goto-char (point-min))
	  (replace-regexp src-string (car langs))
	  (goto-char (point-max))
	  )
      (or (string= "French" (car langs))
	  (error "nmw-data-clone-langs: I was about to skip past %s" (car langs))
	  )
      )
    (setq langs (cdr langs))
    (while langs
      (setq s (nstr-replace-regexp data src-string (car langs))
	    langs (cdr langs)
	    )
      (insert "\n" s)
      )
    )
  )
(defun nmw-data-set-addend(&optional addend_is_subject)
  (let(
       (fn (file-name-nondirectory (buffer-file-name)))
       verb
       addendKeyBase
       addendOffset
       maxAddendOffset
       )
    (if addend_is_subject
	(save-excursion
	  (goto-char (point-min))
	  (n-s "{" t)
	  (insert "\n'addend_is_subject' => 1,")
	  )
      )
    (setq verb (if (string-match "^verb_\\(.*\\)" fn)
		   (n--pat 1 fn)
		 ""
		 )
	  ;; "c:/users/nsproul/work/adyn.com/httpdocs/teacher/data/vocab_professions" ;;
	  addendKeyBase (nfly-read-fn "link to: " (concat "$HOME/work/adyn.com/httpdocs/teacher/data/things_to_" verb))
	  )
    ;;(nfly-read-fn "link to: " (concat "$HOME/work/adyn.com/httpdocs/teacher/data/things_to_" "become"))
    (if (not addendKeyBase)
	(error "nmw-data-set-addend: addendKeyBase"))
    (setq addendKeyBase (file-name-nondirectory addendKeyBase)
	  maxAddendOffset (nmw-data-get-max-id addendKeyBase)
	  ;;(nmw-data-get-max-id "things_to_become")
	  )
    (setq addendOffset (nsimple-random maxAddendOffset))
    (n-trace "random of %d -> %d" maxAddendOffset addendOffset)
    
    (n-prune-buf "'addendKey' => '")
    (save-excursion
      (goto-char (point-min))
      (while (n-s "^}")
	(forward-line 0)
	(insert "'addendKey' => '" addendKeyBase "." (int-to-string addendOffset) "',\n")
	
 	(setq addendOffset (if (>= addendOffset maxAddendOffset)
			       0
			     (1+ addendOffset)
			     )
	      )
	(n-s "^{" 'eof)
	)
      )
    )
  )
(defun nmw-data-Infinitive()
  (nmw-data-suppress-token t "Infinitive")
  )
(defun nmw-data-make-global-note()
  (goto-char (point-min))
  (n-s "{" t)
  (forward-line 1)
  (let(
       (lang (nmw-data-choose-lang))
       )
    (insert "'" lang "_global_note;;" lang "' => '@@.',\n")
    (forward-line -1)
    (n-complete-leap)
    )
  )
(defun nmw-data-choose-lang()
  (message "f-French, g-German, i-Italian, s-Spanish")
  (let(
       (ch (read-char))
       )
    (cond
     ((eq ch ?f) "French")
     ((eq ch ?g) "German")
     ((eq ch ?i) "Italian")
     ((eq ch ?s) "Spanish")
     )
    )
  )
(defun nmw-grab-token()
  (let(
       (token   (n-grab-token "a-zA-Z#:`/,-~"))
       )
    (setq token (nstr-replace-regexp token ",$" "")
	  )
    )
  )
(defun nmw-data-get-lang()
  (save-excursion
    (forward-line 0)
    (if (or
	 (looking-at "[ \t]*'\\(z/\\)?\\(English\\|French\\|German\\|Italian\\|Spanish\\)")
	 (looking-at "\\(.*\\)\\(English\\|French\\|German\\|Italian\\|Spanish\\):")
	 )
	(n--pat 2)
      (error "nmw-data-get-lang: ")
      )
    )
  )

(defun nmw-data-get-idNumber()
  (save-restriction
    (save-excursion
      (widen)
      (nmw-narrow-to-current-entry)
      (goto-char (point-min))
      (n-s "'id' => '?\\([0-9]+\\)" t)
      (n--pat 1)
      )
    )
  )

(defun nmw-data-get-id()
  (concat (file-name-nondirectory (buffer-file-name)) "." (nmw-data-get-idNumber))
  )

(defun nmw-data-prep-unit-test-of-ProposeNotes()
  (let(
       (lang	(nmw-data-get-lang))
       (id	(nmw-data-get-idNumber))
       areaStatement
       (area	(progn
		  (nstr-replace-regexp (nfn-prefix)
				       "verb_"
				       ""
				       )
		  )
		)
       )
    (n-file-find "~/work/adyn.com/httpdocs/teacher/t_debug_ProposeNotes.sh")
    
    (setq areaStatement  (concat "area=" area))
    (n-prune-buf (concat "^" areaStatement "$"))
    
    (goto-char (point-min))
    (n-s "id=" t)
    (delete-region (point) (progn
			     (end-of-line)
			     (point)
			     )
		   )
    (insert id)
    
    (forward-line 0)
    (insert areaStatement "\n")
    
    (replace-regexp "^DebugMassageAndFootnote" "#DebugMassageAndFootnote")
    (goto-char (point-min)) 
    (replace-regexp (concat "^#DebugMassageAndFootnote " lang)
		    (concat   "DebugMassageAndFootnote " lang)
		    )
    )
  )

(defun nmw-data-prep-unit-test-of-xgen()
  (let(
       (lang	(nmw-data-get-lang))
       (id	(nmw-data-get-idNumber))
       areaStatement
       (area	(progn
		  (nstr-replace-regexp (nfn-prefix)
				       "verb_"
				       ""
				       )
		  )
		)
       )
    (n-file-find "~/work/adyn.com/httpdocs/teacher/t.sh")
    (goto-char (point-min))
    (n-s "^area=" t)
    (delete-region (point) (progn
			     (end-of-line)
			     (point)
			     )
		   )
    (insert area)
    
    (goto-char (point-min))
    
    
    
    (replace-regexp "^#?id=[0-9]*" (format "id=%s" id))	; would be %d, but id is a string...
    ;;(replace-regexp "^id=" "#id=")				; screws up the diff when only one ex is treated?
    
    
    
    
    
    (goto-char (point-min))
    (replace-regexp "^verb_" "#verb_")
    
    (goto-char (point-max))
    (n-r "^#verb_a=" t)
    (delete-char 1)
    (n-s "=\"-verb_a " t)
    (delete-region (point) (progn
			     (n-s "\"" t)
			     (forward-char -1)
			     (point)
			     )
		   )
    (insert area)
    
    (goto-char (point-min))
    (replace-regexp "^Grammar " "#Grammar ")
    
    (goto-char (point-min))
    (replace-regexp (concat "^#Grammar " lang)
		    (concat   "Grammar " lang)
		    )
    )
  (delete-other-windows)
  (n-file-find "$HOME/work/adyn.com/httpdocs/teacher/midnight")
  )

(defun nmw-data-add-question()
  (let(
       (lang	(nmw-data-get-lang))
       )
    (forward-line 0)
    (insert "'?' => '" 
	    (if lang
		(concat lang ": ")
	      ""
	      )
	    "',"
	    )
    (forward-char -2)
    )
  )
(defun nmw-data-get-max-id(dataFile)
  (n-loc-push)
  (save-window-excursion
    (n-file-find (concat "$HOME/work/adyn.com/httpdocs/teacher/data/" dataFile))
    (save-excursion
      (goto-char (point-min))
      (if (not (n-s "'id'"))
	  (nmw-data-init-notes-and-IDs))

      (goto-char (point-max))
      (n-r "'id'" t)
      (end-of-line)
      (forward-word -1)
      (prog1
	  (string-to-int (n-grab-token))
	(n-loc-pop)
	)
      )
    )
  )
(defun nmw-direct-object-determiner()
  (nmw-data-make-note)
  (insert "De(\"@@\", \"it is a direct object\")")
  (forward-line 0)
  (n-complete-leap)
  )
(defun nmw-German-adjective-explain()
  (nmw-data-make-note "explainAdjective")
  (insert "explainAdjective")
  )
(defun nmw-German-noun-explain()
  (nmw-data-make-note "explainNoun")
  (insert "explainNoun")
  )
(defun nmw-data-edit-map()
  (interactive)
  (save-restriction
    (n-narrow-to-line)
    (goto-char (point-min))
    (or (looking-at ".*'map/\\([0-9a-zA-Z_]+\\)' =>")
	(error "nmw-data-edit-map: no map/lang")
	)
    (let(
	 (lang (n--pat 1))
	 )
      (or (not (string= "English" lang))
	  (error "nmw-data-edit-map: cannot edit English map")
	  )
      (setq nmw-id (nmw-data-get-id))
      (nmw-save-place)
      (nteacher-init-map-words-mode)
      )
    )
  )
(defun nmw-data-add-noun()
  (interactive)
  (let(
       (noun	(n-grab-token "-a-zA-Z#:/`~"))
       (lang	(nmw-data-get-lang))
       )
    (n-file-find (concat "$HOME/work/adyn.com/httpdocs/teacher/grammar/" lang ".dat.htm"))
    (goto-char (point-min))
    (if (not (n-s (concat "^Noun('" noun "'")))
	(progn
	  (n-s "^Noun('" t)
	  (forward-line 0)
	  (insert "Noun('" noun "', '")
	  (n-loc-push)
	  (if (string= lang "German")
	      (insert "', '-@@'@@, '-@@')\n")
	    (insert "')\n")
	    )
	  (n-loc-pop)
	  )
      )
    )
  )
(defun nmw-data-join-indented-overflowed-lines()
  ;; Reviewers sometimes send me corrections which have been read rejustified because the being composed in Netscape or something.  This leads to my having two sets of changes to examine: the corrections themselves, and the changes in where the lines are split.  This function assumes that there is a single empty line between each pair of adjacent exercises.
  (goto-char (point-min))
  (while (not (eobp))
    (if (looking-at "[ \t]")
	(delete-region (point) (progn
				 (n-s "[^ \t]" t)
				 (forward-char -1)
				 (point)
				 )
		       )
      )
    (cond
     ((looking-at "$")
      nil
      )
     ((looking-at "\\(# \\)?[a-z_]+\\.[0-9]+ ")
      nil
      )
     (t
      (forward-line -1)
      (nsimple-join-lines)
      )
     )
    (forward-line 1)
    )
  )

(defun nmw-data-add-directives(type)
  ;; type in [spx]
  (goto-char (point-min))
  (while (n-s "[ \t]*'\\(French\\|German\\|Italian\\|Spanish\\)' => '")
    (if (not (looking-at "[^']*[{}]"))
	(progn
	  (insert "{")
	  (end-of-line)
	  (n-r "'" t)
	  (if (and
	       (string= "German" 	(nmw-data-get-lang))
	       (string= type "x")
	       )
	      (insert ">L>}")
	    (insert ">" type ">}")
	    )
	  )
      )
    )
  
  (goto-char (point-min))
  (replace-regexp "\\.xy" "")	;; artifact from web xlation
  
  (goto-char (point-min))
  (replace-regexp "{un[aeo]s? " "{un ")
  
  (goto-char (point-min))
  (replace-regexp "{vuestr[ao]s? " "{vuestro ")
  
  (goto-char (point-min))
  (replace-regexp "{quelque " "{de le ")
  
  (goto-char (point-min))
  (replace-regexp "{lo " "{il ")
  
  (goto-char (point-min))
  (replace-regexp "{irgendein " "{")
  
  (goto-char (point-min))
  (replace-regexp "{nuestr[ao]s? " "{nuestro ")
  
  (goto-char (point-min))
  (replace-regexp "\\(French.*[ {]\\)l\\\\'\\^D" "\\1le")
  
  (goto-char (point-min))
  (replace-regexp "\\(Italian.*[ {]\\)l\\\\'\\^D" "\\1il")
  
  (goto-char (point-min))
  (replace-regexp "\\(Italian.*\\)'\\^D" "\\1o")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(all\\\\'\\^D\\|alla\\|al\\|allo\\|ai\\|agli\\|alle\\) " "\\1a il ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(coll\\\\'\\^D\\|colla\\|col\\|collo\\|coi\\|cogli\\|colle\\) " "\\1con il ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(dall\\\\'\\^D\\|dalla\\|dal\\|dallo\\|dai\\|dagli\\|dalle\\) " "\\1da il ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(dell\\\\'\\^D\\|della\\|del\\|dello\\|dei\\|degli\\|delle\\) " "\\1di il ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(nell\\\\'\\^D\\|nella\\|nel\\|nello\\|nei\\|negli\\|nelle\\) " "\\1in il ")
  
  (goto-char (point-min))
  (replace-regexp "\\(Italian' =>.*[ {]\\)\\(quell\\\\'\\^D\\|quella\\|quello\\|quei\\|quegli\\|quelle\\) " "\\1quel ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(sull\\\\'\\^D\\|sulla\\|sul\\|sullo\\|sui\\|sugli\\|sulle\\) " "\\1su il ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)\\(den\\|dem\\|die\\|des\\) " "\\1der ")
  
  (goto-char (point-min))
  (replace-regexp "\\([ {]\\)una " "\\1un ")
  
  (goto-char (point-min))
  (replace-regexp "'French' => '{\\(l.'\\^D\\|la\\|les\\) " "'French' => '{le ")
  
  (goto-char (point-min))
  (replace-regexp "'Spanish' => '{\\(l.'\\^D\\|la\\|las\\) " "'Spanish' => '{el ")
  
  (goto-char (point-min))
  (replace-regexp "'Spanish' => '{del " "'Spanish' => '{de el ")
  
  (goto-char (point-min))
  (replace-regexp "'Italian' => '{del " "'Italian' => '{de il ")
  
  (goto-char (point-min))
  (replace-regexp "'Italian' => '{\\(l.'\\^D\\|la\\|le\\|i\\|gli\\) " "'Italian' => '{il ")
  
  (goto-char (point-min))
  (replace-regexp "'German' => '{\\(die\\|den\\|des\\|dem\\|das\\) " "'German' => '{der ")
  
  (goto-char (point-min))
  (replace-regexp "'German' => '{ein\\(e\\|es\\|em\\|er\\)? " "'German' => '{ein ")
  
  (goto-char (point-min))
  (while (n-s "^[ \t]*'German' => '{\\(der\\|ein\\)? ?[a-z:]+>.>}")
    (n-r "[^a-z:>{}]" t)	;; go to the beginning of the German token
    (forward-char 1)
    (nsimple-upcase-word ?1)
    )
  
  (goto-char (point-min))
  (while (n-s "^[ \t]*'English' => 'your ")
    (n-s "^[ \t]*'German' => '" t)
    (if (looking-at "{");;}
	(forward-char 1))
    (if (looking-at "ihr");; automatic downcasing changes German Ihr (your) to ihr (her)...
	(nsimple-upcase-word ?1);; ...undo that
      )
    )
  
  (goto-char (point-min))
  (while (n-s "^[ \t]*'Spanish' => '{los ")
    (save-restriction
      (nmw-narrow-to-current-entry)
      
      (goto-char (point-min))
      (replace-regexp "{los " "{el ")
      
      (goto-char (point-min))
      (replace-regexp ">s>" ">p>")
      )
    )
  )

(defun nmw-data-replace-regexp(&optional lang before after)
  (save-window-excursion
    (if (not lang)
	(setq lang (nmw-data-get-lang)))
    (if (not before)
	(setq before (progn
		       (read-string (format "%s replace: " lang))
		       )
	      )
      )
    (if (not after)
	(setq before (progn
		       (read-string (format "With: "))
		       )
	      )
      )
    (save-restriction
      (save-excursion
	(goto-char (point-min))
	(while (n-s (concat "'" lang))
	  (n-narrow-to-line)
	  (goto-char (point-min))
	  (replace-regexp before after)
	  (widen)      
	  (forward-line 1)
	  )      
	)
      )
    )
  )
(defun nmw-data-stop-curlies()
  (interactive)
  (n-s ".{" t)
  (delete-char -1)
  (n-s ">.>}" t)
  (delete-char -4)
  )
(defun nmw-data-add-noun-directives()
  (interactive)
  (let(
       (nonTokenChar "[^a-zA-Z:/`~]")
       )
    (n-r nonTokenChar t)
    (forward-char 1)
    (insert "{")
    (nmw-data-add-noun)
    (other-window 1)
    (n-s nonTokenChar t)
    (forward-char -1)
    (set-mark-command nil)
    (insert ">s>}")
    )
  )
(defun nmw-data-delete-word()
  (interactive)
  (cond
   ((looking-at ">[ps]>}\\.',$")
    (kill-region (point) (progn
			   (n-s "}" t)
			   (point)
			   )
		 )
    )
   (t
    (call-interactively 'nsimple-kill-word)
    )
   )
  )
;;(defun nmw-data-forward-word()
;;  (interactive)
;;  (if (looking-at "[^-A-Za-z:~#/`]")
;;      (if (n-s "[-A-Za-z:~#/`]")
;;	  (forward-char -1)
;;	(goto-char (point-max))
;;	)
;;    )
;;  (if (n-s "[^-A-Za-z:~#/`]")
;;      (forward-char -1)
;;    (goto-char (point-max))
;;    )
;;  )
;;(defun nmw-data-backward-word()
;;  (interactive)
;;  (if (save-excursion
;;	(forward-char -1)
;;	(looking-at "[^-A-Za-z:~#/`]")
;;	)
;;      (progn
;;	(if (n-r "[-A-Za-z:~#/`]")
;;	    (forward-char 1)
;;	  (goto-char (point-min))
;;	  )
;;	)
;;    )
;;  (if (n-r "[^-A-Za-z:~#/`]")
;;      (forward-char 1)
;;    (goto-char (point-min))
;;    )
;;  )
(defun nmw-data-is-verb-with-vt(verb)
  (let(
       possibleVt
       (langs nmw-data-langs)
       )
    (while (and langs
		(setq possibleVt (concat "$HOME/work/adyn.com/httpdocs/teacher/html/" (car langs) "_vt_" verb ".html"))
		(not (n-file-exists-p possibleVt))
		)
      (setq langs (cdr  langs))
      )
    (if langs
	possibleVt
      )
    )
  )
(defun nmw-data-launch-browser-if-is-verb-with-vt(verb)
  (let(
       (possibleVt (nmw-data-is-verb-with-vt verb))
       )
    (if possibleVt
	(n-host-shell-cmd (concat "browser " possibleVt " &")))
    )
  )
(defun nmw-data-find-where()
  (interactive)
  (let(
       (lang	(nmw-data-get-lang))
       (result  "--------")
       (token	(nmw-grab-token))
       )
    (save-window-excursion
      (n-file-find (concat "$HOME/work/adyn.com/httpdocs/teacher/data/_" lang "_vtl"))
      (goto-char (point-min))
      (if (n-s (concat "'" token "' => '\\(.*\\)',"))
	  (setq result (n--pat 1)))
      )
    (message result)
    )
  )
(defun nmw-data-add-global-prefix()
  (nmw-data-set-lang)
  (goto-char (point-min))
  (n-s (concat "'" nmw-lang "' => ") t)
  (forward-line 0)
  (insert "'" nmw-lang "/addend_prefix' => '@@ ',\n")
  (forward-line -1)
  (n-complete-leap)
  )
(defun nmw-data-fix-email-correction-format()
  (goto-char (point-min))
  (delete-region (point) (progn
			   (n-s "^#" t)
			   (forward-char -1)
			   (point)
			   )
		 )
  (while (not (eobp))
    (if (not (looking-at "#"))
	(error "nmw-data-fix-email-correction-format: expected to be at the beginning of an English line"))
    (forward-line 1)
    (narrow-to-region (point) (progn
				(n-s "^#" 'eof)
				(forward-line -1)
				(point)
				)
		      )
    (goto-char (point-min))
    (nsimple-join-lines t)
    (goto-char (point-max))
    (insert "\n")
    (widen)
    (forward-char 1)
    )
  )

(defun nmw-data-reestablish-correction-buffers( &optional arg)
  (interactive "P")
  (cond
   ((and arg (y-or-n-p " fix e-mail formatting for current buf?"))
    (nmw-data-fix-email-correction-format)
    )
   (t
    (let(
	 (bufs (save-window-excursion
		 (nbuf-get-list)
		 )
	       )
	 ca
	 cs
	 )
      (while bufs
	(cond
	 ((string-match "corrections.*answer" (car bufs))
	  (setq ca (car bufs))
	  )
	 ((string-match "corrections.*sent" (car bufs))
	  (setq cs (car bufs))
	  )
	 )
	(setq bufs (cdr bufs))
	)
      (switch-to-buffer cs)
      (delete-other-windows)
      (nsimple-split-window-vertically)
      (switch-to-buffer ca)
      (nsimple-compare-windows)
      )
    )
   )
  )
