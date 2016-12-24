(provide 'ntrc)
(setq ntrc-PREFIX "(prog1 (setq ntrc-x ")
(setq ntrc-MIDIX "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t ) (n-trace \"TRC")
(setq ntrc-SUFFIX " -> %s\" (prin1-to-string ntrc-x))")

(defun ntrc-init()
  (indent-rigidly (point-min) (point-max) (length ntrc-PREFIX))
  (setq truncate-lines t)
  )

(defun ntrc-cleanup()
  (setq truncate-lines nil)
  (goto-char (point-min))
  (replace-regexp ntrc-PREFIX "")
  (replace-regexp ntrc-MIDIX "")
  (replace-regexp ntrc-SUFFIX "")
  (indent-rigidly (point-min) (point-max) (- (length ntrc-PREFIX)))
  )

(defun ntrc-form( &optional arg)
  "put into place tracing ELISP code for the form whose first line is under pt"
  (interactive "P")
  (cond
   ((and arg (integerp arg) (= arg 0))	(ntrc-cleanup))
   (arg					(ntrc-init))
   )
  (let(
       (line	(n-get-line))
       )
    (forward-line 0)
    (insert ntrc-PREFIX)
    (forward-sexp 1)
    (insert ntrc-MIDIX line "..." ntrc-SUFFIX)
    )
  )


(defun ntrc-func-meat()
  "add trace output to beginning of current func"
  (interactive)
  (nc-beginning-of-defun)
  (n-s "(" t)
  (n-s "(" t)
  (let(
       (args (nstr-split
              (buffer-substring-no-properties (point) (progn
                                          (n-s ")" t)
                                          (forward-char -1)
                                          (point)
                                          )
                                )
              )
             )
       trc
       )
    (setq trc (concat " (n-trace \""
		      (n-defun-name)
		      ": "
		      ;; first: names of the args
		      (mapconcat '(lambda( arg )
				    (format "%s=%%s" arg)
				    )
				 args
				 " "
				 )
		      "\" "
		      ;; then: vals of the args
		      (mapconcat '(lambda( arg )
				    (format "(prin1-to-string %s)" arg)
				    )
				 args
				 " "
				 )
		      ");;;;;;;;;;;;;;;\n"
		      )
          )
    (if (looking-at "[ \t\n]*\"")	; doc string?
        (progn				; skip past
          (n-s "\"" t)
          (n-s "\"" t)
          )
      )
    (if (looking-at "[ \t\n]*(interactive")
        (progn				; skip past
          (n-s "(interactive" t)
          (n-r "(" t)
          (forward-sexp 1)
          )
      )
    (forward-line 1)
    (insert trc)
    )
  )

(defun p(x)
  "convenient shorthand for prin1-to-string"
  (prin1-to-string x)
  )
