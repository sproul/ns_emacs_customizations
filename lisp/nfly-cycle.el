(provide 'nfly-cycle)

(defun nfly-cycle-1(&optional arg) (interactive "P") (nfly-cycle-go arg "1"));;c-v: code-to-build
(defun nfly-cycle-2(&optional arg) (interactive "P") (nfly-cycle-go arg "2"));;m-v: backups
(defun nfly-cycle-3(&optional arg) (interactive "P") (nfly-cycle-go arg "3"));;mc-v: releases

(defun nfly-cycle-go(edit &optional which)
  (interactive)
  (if (not which)
      (setq which (read-string "which cycle transforms should be edited (1,2,3)? " "2")))
  (let(
       (name (concat "n-data-cycle-" which))
       transforms
       )
    (if edit
	(n-file-find (concat "$dp/emacs/lisp/data/" name ".el"))
      (condition-case nil
	  (setq transforms  (eval (intern-soft name)))
	(error
	 (progn
	   (load (nsimple-env-expand (concat "data/" name)))
 	   (setq transforms  (eval (intern-soft name)))
	   (if (not transforms)
	       (error "nfly-cycle-go: not set even after intern-soft"))
	   )
	 )
	)
      (if (not transforms)
	  (progn
	    (load (nsimple-env-expand (concat "data/" name)))
	    (setq transforms  (eval (intern-soft name)))
	    (if (not transforms)
		(error "nfly-cycle-go: %s not set" name))
	    )
	)
      (nfly-to-canonical)
      (nfly-cycle-minibuffer transforms)
      )
    )
  )

(defun nfly-cycle-minibuffer(transforms)
  (let(
       (start  (buffer-substring-no-properties (point-min) (point-max)))
       maxTransformations
       current
       done
       )

    (if (not
         (or
          (eq last-command 'nfly-cycle-1)
          (eq last-command 'nfly-cycle-2)
          (eq last-command 'nfly-cycle-3)
          )
         )
        (nfly-reset-starting-fn start)
      )

    ;;(if (file-directory-p start)
    ;;(progn
    ;;(nfly-minibuffer-set-full-file)
    ;;(setq start (buffer-substring-no-properties (point-min) (point-max)))
    ;;)
    ;;)

    (setq maxTransformations (length transforms)
          current start
          )
    (while (and
            (> maxTransformations 0)
            (not done)
            )
      (setq current (nfly-cycle current transforms));; finds first regexp match; does xform
      (delete-region (point-min) (point-max))

      (setq done t)

      (insert current)

      (setq maxTransformations (1- maxTransformations))
      )
    (if (not done)
	(progn
	  (delete-region (point-min) (point-max))
	  (insert start)
	  )
      )
    )
  )


(defun nfly-cycle(fn transforms)
  "matches FN to first regexp car of an elt of TRANSFORMS; returns fn =~ s/(car elt)/(cdr elt)/"
  (let(
       (savedFn fn)
       from
       to
       transform
       )
    (setq transforms	(nstr-assoc fn transforms 'cycle)
	  transform	(car transforms)
	  from		(nsimple-env-expand (car transform))
	  to		(nsimple-env-expand (cadr transform))
	  fn		(nstr-replace-regexp fn from to)
	  fn		(n-host-to-canonical fn)
	  )
    ;;(n-trace "==================================================\n")
    ;;(n-trace "nfly-cycle: from %s (%s)" savedFn from)
    ;;(n-trace "nfly-cycle:   to %s (%s)" fn      to)
    ;;(n-trace "==================================================\n")
    fn
    )
  )
(defun nfly-cycle-compose-dir-list(&rest dirs)
  (let(
       (canonicalDirsThatExist (nfn-expand-wildcards-which-exist dirs t))
       dir-cycle-list
       dir1
       )
    (setq dir1 (car canonicalDirsThatExist))
    (while (cdr canonicalDirsThatExist) ;; while >= 2 elts left in list
      (setq
       dir-cycle-list (cons (list (car  canonicalDirsThatExist)
                                  (cadr canonicalDirsThatExist)
                                  )
                            dir-cycle-list
                            )
       canonicalDirsThatExist (cdr canonicalDirsThatExist)
       )
      )

    ;; link the ends of the list:
    (setq
     dir-cycle-list (cons (list (car  canonicalDirsThatExist)
                                dir1
                                )
                          dir-cycle-list
                          )
     )
    
    (nreverse dir-cycle-list)
    )
  )
