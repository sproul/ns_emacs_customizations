(defun
  nm-macro-put1_next_from_todo()
  (interactive)
  (save-window-excursion
    (while (progn
	     (execute-kbd-macro "\205\C-n\255\C-u\212")
	     (message "again?")
	     (let(
		  (cmd (read-char))
		  )
	       (or (= 32 cmd)
		   (= ?y cmd)
		   )
	       )
	     )
      )
    )
  )
