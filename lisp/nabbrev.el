(provide 'nabbrev)
(defun nabbrev-cmd()
  (interactive)
  (message "abbrev: a-bbrev token, t-oggle abbrevs")
  (let(
       (cmd	(read-char))
       )
    (cond
     ((= cmd ?a)
      (abbrev-mode 1)
      (call-interactively 'add-global-abbrev))
     ((= cmd ?t)
      (call-interactively 'abbrev-mode))
     (t (error "nabbrev-cmd: "))
     )
    )
  )

