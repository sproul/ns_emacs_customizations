(provide 'ntoken)
(setq ntoken-list nil)
(setq ntoken-newest "")
(setq ntoken-atomic-list nil)
(setq ntoken-atomic-newest "")
(setq ntoken-atomic-newest-character-capital nil)

(defun ntoken-add-character(character)
  (let(
       (isCapital (and (<= ?A character) (>= ?Z character)))
       (isAlphanumeric (nsimple-alnum-p character))
       )
    (cond
     ((and
       isAlphanumeric
       (string= (n--get-lisp-func-name last-command) "n-complete-self-insert-command")
       (or
        (eq ntoken-atomic-newest-character-capital isCapital)
        (and ntoken-atomic-newest-character-capital 
             (not isCapital)
             (= 1 (length ntoken-atomic-newest))
             ); allow capitalized words
        )
       )
      (setq ntoken-atomic-newest (concat ntoken-atomic-newest
                                         (char-to-string character)
                                         )
            )
      )
     (t
      (if (not (string= ntoken-atomic-newest ""))
          (progn
            (setq ntoken-newest (concat ntoken-newest ntoken-atomic-newest))
            (if (not (eq last-command 'n-complete-self-insert-command))
                (progn
                                        ;(message "%s" ntoken-newest)
                  (setq ntoken-list (cons 
                                     ntoken-newest
                                     ntoken-list
                                     )
                        ntoken-newest ""
                        ntoken-atomic-list nil
                        )
                  )
              )
            
            (setq ntoken-atomic-list (cons 
                                      ntoken-atomic-newest
                                      ntoken-atomic-list 
                                      )
                  )
            ;;(message "%s" ntoken-atomic-newest)
            
            (setq ntoken-atomic-newest 
                  (if isAlphanumeric
                      (char-to-string character)
                    ""
                    )
                  )
            )
        )
      )
     )
    (setq ntoken-atomic-newest-character-capital isCapital)
    )
  )

(defun ntoken-merge-last-into-current()
  (setq ntoken-newest (concat (car ntoken-list)
                              ntoken-newest
                              )
        ntoken-list (cdr ntoken-list)
        )
  )
