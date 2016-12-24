(defun put_next_from_m-o-inner()
  (execute-kbd-macro "\M-o\C-n\M-u\255\212")  
  )

(defun
  nm-macro-put_next_from_m-o()
  (interactive)
  (save-window-excursion
    (while (progn
	     (put_next_from_m-o-inner)
	     (message "again?")
	     (let(
		  (cmd (read-char))
		  )
	       (cond
		((= ?9 cmd)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 (put_next_from_m-o-inner)
		 t
		 )
		(t
		 (or (= 32 cmd)
		     (= ?y cmd)
		     )
		 )
		)
	       )
	     )
      )
    )
  )
