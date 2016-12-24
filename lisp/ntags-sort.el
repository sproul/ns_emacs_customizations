(provide 'ntags-sort)
(defun ntags-sort(l &optional contextFn)
  (require 'nclass-browser)
  (if (not contextFn)
      (setq contextFn (nclass-browser-get-fnContext)))
  (n-trace nil)
  (cond
   ((or
     (eq major-mode 'shell-mode)
     (eq major-mode 'nsh-mode)
     )
    (ntags-sort-prefer "/man/" l)
    )
   ((n-modes-lispy-p)
    (ntags-sort-prefer "/lisp/" l)
    )
   (t
    (ntags-sort-c l contextFn)
    )
   )
  )
(defun ntags-sort-c(l contextFn)
  (let(
       (dplat	(n-host-devo-env))
       (cfn	(if contextFn
		    (n-host-to-canonical contextFn)
                  )
                )
       cplat
       cprod
       cuser
       cproj
       csubproj
       csuffix
       cdrive
       l2
       )
    (if cfn
	(progn
	  (setq
	   cplat	(nfn-plat cfn)
	   cuser	(nfn-user cfn)
	   cprod	(nfn-prod cfn)
	   cproj	(nfn-proj cfn t)
	   csubproj	(nfn-subproj cfn)
	   csuffix	(nfn-suffix cfn)
	   cdrive	(nfn-drive)
	   )
	  (n-trace "ntags-sort-c: %s is %s: \n\tplat=%s, \n\tprod=%s, \n\tproj=%s, \n\tsubproj=%s, \n\tdrive=%s"
		   (buffer-file-name) cfn cplat cprod cproj csubproj cdrive)
	  )
      )
    (require 'nsort)
    (setq l2 	(nsort l 'ntags-sort-eval-c))
    (if debug-on-error
        (let(
             (lt	l2)
             )
          (n-trace "ntags-sort-c: Tag from %s...\n" (n-file-name))
          (while lt
            (n-trace "%s\n" (car lt))
            (setq lt (cdr lt))
            )
          (n-trace "ntags-sort-c: eod\n")
          )
      )
    l2
    )
  )
(defun ntags-sort-eval-c(fnCon)
  (if (not cfn)
      (ntags-sort-eval-c-guess fnCon)
    (let(
	 (fn	(n-host-to-canonical
                 (car fnCon)
                 )
                )
	 (n	0)
	 drive
	 plat
	 prod
	 proj
	 subproj
	 suffix
	 (user "")
	 )
      (cond
       ((and
	 (string-match "build.xml" cfn)
	 (string-match "manual/antfunc.html.txt" fn)
	 )
	(setq n (- n 200))
	)
       ((string= fn cfn)
	(setq n (- n 200))
	)
       ((string= (nfn-suffix fn) csuffix)
	(setq n (if (and (string= csuffix "java")
			 (string= (nfn-prefix fn) ntags-find-token)
			 )
		    (- n 6)	; give slight extra credit for a Java class which is not an inner class
		  (- n 5)
		  )
	      )
	)
       )

      (cond
       ((or (string-match "/api32.hlp$" fn)
	    )
	(setq n (- n 1))
	)
       ((or (string-match "\\.hlp$" fn)
	    )
	  (setq n (+ n 1))
	  )
	 ((or (string-match "msvc.*/include/win" fn)
	      (string-match "/demo?s/" fn)
	      (string-match "/sample?s/" fn)
	      (string-match "/example?s/" fn)
	      )
	  (setq n (- n 5))
	  )
	 ((or (string-match "msvc.*/include" fn)
	      )
	  (setq n (- n 3))
	  )
	 )

	(setq proj (nfn-proj fn t))
	(cond
	 ((string= cproj proj)
	  (setq n (- n 50)))
	 (t
	  (setq n (+ n 100)))
	 )
	(setq subproj (nfn-subproj fn))
	(cond
	 ((string= csubproj subproj)
	  (setq n (- n 20)))
	 ((string= "standard" subproj)
      (setq n (- n 10)))
     ((string-match "/largesoft/" fn)
      (setq n (- n 5)))
     )
    (if (and n-win
             (<= n 0)
             cdrive
             (setq drive (nfn-drive (car fnCon)))
             )
        (if (= cdrive drive)
            (progn
              (setq n (- n 100))
              )
          (setq n (+ n 100))
          )
      )
    (setq plat (nfn-plat fn))
    (cond
     ((string= cplat plat)
      (setq n (- n 5)))
     ((string= dplat plat)
      (setq n (- n 1)))
     (t
      (setq n (+ n 5)))
     )
    (if (<= n 0)
        (progn
          (setq user (nfn-user fn))
          (cond
           ((or (not user)
                (not cuser)
                )
            nil
            )
           ((string= cuser user)
            (setq n (- n 5)))
           (t
            (setq n (+ n 5)))
           )
          )
      )
    (if (<= n 0)
        (progn
          (setq prod (nfn-prod fn))
          (cond
           ((string= cprod prod)
            (setq n (- n 10)))
           ((string= "distrib" prod)
            (setq n (- n 5)))
           (t
            (setq n (+ n 5)))
           )
          )
      )
    (if (string-match "\\.h$" fn)
        (setq n (- n 16))
      )

    (n-trace "ntags-sort-c: ? %s is %s:\n\tplat=%s, \n\tprod=%s, \n\tproj=%s, \n\tsubproj=%s, \n\tdrive=%s, \n\tuser=%s :	%d"
             (car fnCon) fn plat prod proj subproj drive user n)
    n
    )
    )
  )
(defun ntags-sort-prefer(ss l)
  (let(
       l1 l2
          )
    (while l
      (if (string-match ss (car (car l)))
          (setq l1 (cons (car l) l1))
        (setq l2 (cons (car l) l2))
        )
      (setq l (cdr l))
      )
    (append l1 l2)
    )
  )

;;(defun n-x8()
;;  (interactive)
;;  (find-file "c:/dev/Rel4_2/pso/documentum/bkgproc/DocumentumExport.java")
;;  (goto-char (point-min))
;;  (n-s "ErInvoice.getTotalERAmount")
;;
;;  (call-interactively 'ntags-find-where)
;;  )

(defun ntags-sort-pick-best-associated-match(items getFn contextFn)
  (save-window-excursion
    (let(
	 (fnsToItems (nlist-make-assoc-via-function-mapping getFn items))
	 sortedFnsToItems
	 )
      (setq sortedFnsToItems (ntags-sort fnsToItems contextFn))
      (if sortedFnsToItems
	  (cdar sortedFnsToItems)
	)
      )
    )
  )
(defun ntags-sort-eval-c-guess(fnCon)
  (let(
       (fn	(n-host-to-canonical
                 (car fnCon)
                 )
                )
       (JAVA (nsimple-getenv "JAVA"))
       (n 0)
       )
    (cond
     ((string-match (concat JAVA "/javax?/") fn)
      (setq n (- n 35))
      )
     ((string-match "/javax?/" fn)
      (setq n (- n 25))
      )
     ((string-match "-api/src" fn)
      (setq n (- n 13))
      )
     ((string-match "-ri/src/" fn)
      (setq n (- n 13))
      )
     ((string-match "-src/j2ee/" fn)
      (setq n (- n 13))
      )
     ((string-match "-scsl/standard/src/" fn)
      (setq n (- n 12))
      )
     ((string-match "/IBJts/Java" fn)
      t
      )
     )

    (if (string-match "/src/com/sun/" fn)
	(setq n (+ n 2)))
    (if (string-match "/doc/" fn)
	(setq n (+ n 3)))
    (if (string-match "/examples?/" fn)
	(setq n (+ n 10)))
    (if (string-match "/demos?/" fn)
	(setq n (+ n 10)))
    (if (string-match "/samples?/" fn)
	(setq n (+ n 10)))
    
    n
    )
  )
