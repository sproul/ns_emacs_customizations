(defun n--get-lisp-func-name(func)
  (if (symbolp func)
      (symbol-name func)
    
    ;; ok -- it's one of my lambdas for loading required modules.  Parse its func defn:
    (setq func   (prin1-to-string func))
    (if (string-match "(call-interactively (quote \\([^)]+\\)))"
		      func
		      )
	(n--pat 1 func)
      (error "n--get-lisp-func-name: ")
      )
    )
  )
(defun n--pat( patNo &optional str)
  "return Nth match (of optional STR)"
  (let(
       (begin (match-beginning patNo))
       (end (match-end patNo))
       )
    (cond
     ((or (not begin) (not end))
      ""
      )
     (str
      (substring str begin end)
      )
     (t
      (buffer-substring-no-properties (match-beginning patNo) (match-end patNo))
      )
     )
    )
  )

