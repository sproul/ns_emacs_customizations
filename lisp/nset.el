(provide 'nset)
;; implement sets using assoc lists

(defun nset-add(set elt)
  (if (nset-in set elt)
      set
    (cons (cons elt t)
	  set
	  )
    )
  )

(defun nset-in(set elt)
  (if set
      (assoc elt set))
  )

(defun nset-rm(set elt)
  (let(
       set2
       )
    (while set
      (if (not (equal elt (caar set)))
	  (setq set2 (cons (car set)
			   set2
			   )
		)
	)
      (setq set (cdr set))
      )
    set2
    )
  )

;;(setq x (nset-add nil "a"))
;;(setq x (nset-add x "b"))
;;(setq x (nset-add x "c"))
;;(nset-in x "a")
;;(nset-in x "x")
;;(nset-rm x "a")
;;(nset-rm x "b")
;;(nset-rm x "c")
