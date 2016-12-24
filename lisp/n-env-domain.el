(provide 'n-env-domain)

(defun n-env-domain-rr-do( before after query)
  (setq n-replace-before before
	n-replace-after  after
	)
  (if (not n-env-domain-file-list)
      (error "n-env-domain-file-list must be set for n-env-domain-replace-regexp to work"))
  (let(
       (fileSpecList    n-env-domain-file-list)
       (n-replace-query query)
       fileSpec
       )
    (save-excursion
      (while (setq fileSpec (car fileSpecList))
	(setq fileSpecList (cdr fileSpecList))
	(n-xdired (file-name-directory fileSpec)
		  (file-name-nondirectory fileSpec)
		  'n-env-domain-f-replace-regexp-func
		  nil
		  nil
		  t
		  )
	)
      )
    )
  )

(defvar n-env-domain-f-replace-before nil "n-env-domain-f-replace-regexp-func arg var")
(defvar n-env-domain-f-replace-after  nil "n-env-domain-f-replace-regexp-func arg var")
(defvar n-env-domain-f-replace-query  nil "n-env-domain-f-replace-regexp-func mode")

(defun n-env-domain-f-replace-regexp-func( longFn )
  "n3.el: go into FN and replace n-env-domain-f-replace-before with n-env-domain-f-replace-after"
  (n-file-push longFn)
  (goto-char (point-min))
  (if n-env-domain-f-replace-query
      (if (save-excursion
            (n-s n-env-domain-f-replace-before)
            )
          (progn
            (switch-to-buffer (current-buffer))
            (query-replace-regexp n-env-domain-f-replace-before n-env-domain-f-replace-after)
            )
        )
    (replace-regexp n-env-domain-f-replace-before n-env-domain-f-replace-after)
    )
  (n-file-pop)
  )


(defun n-env-domain-replace-regexp( before after)
  "replace BEFORE with AFTER in the grep domain"
  (interactive "sReplace regexp: 
swith: ")
  (n-env-domain-rr-do before after nil)
  )

(defun n-env-domain-replace-regexp-query( before after)
  "query replace BEFORE with AFTER in the grep domain"
  (interactive "sQuery replace regexp: 
swith: ")
  (n-env-domain-rr-do before after t)
  )
