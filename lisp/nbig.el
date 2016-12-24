;; handle big numbers (by treating each as a triple: [ prefix_string n_places_count int ]
(provide 'nbig)

(setq nbig-prefix "")
(setq nbig-length 0)

(defun nbig-grab()
  (save-excursion
    (skip-chars-forward "0-9")
    (nbig-parse
     (buffer-substring-no-properties (point) (progn
				 (skip-chars-backward "0-9")
				 (point)
				 )
		       )
     )
    )
  )

(defun nbig-parse(nString)
  ;; emacs can handle 8 digit numbers.  check for a nine digit number, and use the prefix if needed
  (if (string-match "\\([0-9][0-9][0-9]\\)\\([0-9][0-9][0-9][0-9][0-9][0-9].*\\)" nString)
      (let(
	   (prefix  (n--pat 1 nString))
	   (smallNString (n--pat 2 nString))
	   placesCount
	   )
 	(setq placesCount (length smallNString))
	(list prefix 
	      placesCount 
	      (string-to-int smallNString)
	      )
	)
    (list nil nil (string-to-int nString))
    ) 
  )

(defun nbig-get(n)
  (let(
       (prefix         (car n))
       (placesCount   (cadr n))
       (smallN       (caddr n))
       )
    (if (not prefix)
	(int-to-string smallN)
      (format (concat "%s%0"
		      placesCount
		      "d"
		      )
	      prefix 
	      smallN
	      )
      )
    )
  )

(defun nbig-add(bigN n)
  (list (car bigN)
	(cadr bigN)
	(+ n (caddr bigN))
	)
  )

(defun nbig-test()
  (setq xs "2100000000")
  (setq x (nbig-parse xs))
  (setq x (nbig-add x 5))
  (message "%s" (nbig-get x))
  )
(nbig-test)
