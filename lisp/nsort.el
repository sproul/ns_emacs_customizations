(provide 'nsort)
(defun nsort(l1 eval-func)
  (let(
       l2
       )
    (while l1
      (setq l2 (cons
                (cons (funcall eval-func (car l1)) (car l1))
                l2
                )
            l1 (cdr l1)
            )
      (if debug-on-error
          (progn
            (n-trace "nsort evaluating: %d\t%s" (caar l2) (cadar l2))
            )
        )
      )
    ;; sort in reverse order because the while-loop below
    ;; builds l1 again in reverse order
    (setq l2 (sort l2 '(lambda(e1 e2) (> (car e1) (car e2)))))
    (while l2
      (setq l1	(cons (cdar l2) l1)
            l2	(cdr l2)
            )
      )
    l1
    )
  )

(defun nsort-buf( &optional arg)
  "sort the current buffer's contents"
  (interactive "P")
  (cond
   (arg
    (sort-lines t (point-min) (point-max))
    )
   (t
    (sort-lines nil (point-min) (point-max))
    )
   )
  )

(defun nsort-alphatize-tagged-regions(&optional doVisibleOnesOnly)
  (save-excursion
    (save-restriction
      (if doVisibleOnesOnly
	  (narrow-to-region (save-excursion
			      (n-top-of-window)
			      (point)
			      )
			    (save-excursion
			      (n-bottom-of-window)
			      (point)
			      )
			    )
	)

      (let(
	   alphabetizedAreaFound
	   )
	(goto-char (point-min))
	(while (n-s "\\(#\\|;;\\) alphabetize$")
	  (setq alphabetizedAreaFound t)
	  (forward-line 1)
	  (sort-lines nil (point) (progn
				    (n-s "^[ \t]*$" 'eof)
				    (point)
				    )
		      )
	  )
	alphabetizedAreaFound
	)
      )
    )
  )

