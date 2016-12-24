(defun nm-macro-rm_commas_inside_of_doubly_quoted_strings()
  (interactive)
  (condition-case nil
      (while t
	(execute-kbd-macro
	 [?\C-s ?" ?\C-m ?\C-s ?" ?\C-\M-w ?\M-, ?\M-7 ?, return return ?\M-. ?\C-\M-w])
	)
    (error (message "done"))
    )
  (goto-char (point-min))
  (replace-regexp "(\\([0-9\\.]+\\))" "-\\1")

  (goto-char (point-min))
  (replace-regexp "\"" "")
  )