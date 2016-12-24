(provide 'nstr)

(defun nstr-buf-execute(returnString token func &rest args)
  "put TOKEN in a buffer, execute FUNC on it"
  (let (
        (data (match-data))
        (str-context-mode major-mode)
        )
    (unwind-protect
        (progn
	  (save-excursion
	    (save-window-excursion
	      (set-buffer (get-buffer-create "*nstr-buf*"))
	      (save-restriction
		(narrow-to-region (point) (point))
		(if token
		    (insert token))
		(goto-char (point-min))
                (prog1
                    (if (not returnString)
                        (apply func args)
                      (apply func args)
                      (buffer-substring-no-properties (point-min) (point-max))
                      )
		  (delete-region (point-min) (point-max))
		  (bury-buffer (current-buffer))
		  )
		)
	      )
	    )
	  )
      (store-match-data data)
      )
    )
  )

(defun nstr-buf(token func &rest args)
  (apply 'nstr-buf-execute t token func args)
  )


(defun nstr-buf-and-return-obj( token func &rest args)
  "put TOKEN in a buffer, execute FUNC on it"
  (nstr-buf-execute nil token func args)
  )

;;(nstr-assoc "x" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")))
;;(nstr-assoc "x" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'delete)
;;(nstr-assoc "x" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'cycle)
;;(nstr-assoc "y" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")))
;;(nstr-assoc "y" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'delete)
;;(nstr-assoc "y" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'cycle)
;;(nstr-assoc "z" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")))
;;(nstr-assoc "z" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'delete)
;;(nstr-assoc "z" (list (cons "x" "xc") (cons "y" "yc") (cons "z" "zc")) 'cycle)
;;(nstr-assoc fn transforms 'cycle)

(defun nstr-assoc( elt lst &optional action)
  "like assoc, but string-match is used to match ELT to cars of LST's elts.
if optional ACTION is 'delete, rm    matching elt,                         and return the list;
if optional ACTION is 'cycle,  bring matching elt to the head of the list, and return the list"
  (cond
   ((not (and elt lst))
    nil
    )
   ((eq action 'cycle)
    (setq elt (nsimple-env-expand elt))
    (let(
	 new-end-of-list
	 )
      (catch 'nstr-assoc
	(loop
	 ;;(n-trace "nstr-assoc 'cycle calling (string-match \"%s\" \"%s\")"(nsimple-env-expand (caar lst)) elt)
	 (if (string-match (nsimple-env-expand (caar lst)) elt)
	     (throw 'nstr-assoc (append lst new-end-of-list)))
	 ;;(n-trace "match failed.")
	 (setq
	  new-end-of-list	(append new-end-of-list (list (car lst)))
	  lst			(cdr lst)
	  )
	 (if (not lst)
	     (throw 'nstr-assoc new-end-of-list))
	 )
	)
      )
    )
   ((eq action 'delete)
    (let(
	 new-list
	 )
      (while lst
	(if (string-match (caar lst) elt)
	    (setq new-list	(append new-list (cdr lst))
		  lst	nil
		  )
	  (setq new-list	(cons (car lst) new-list)
		lst		(cdr lst)
		)
	  )
	)
      new-list
      )
    )
   (t
    (catch 'nstr-assoc
      (loop
       ;;(n-trace "nstr-assoc trying to match %s in %s" (caar lst) elt)
       (if (string-match (caar lst) elt)
           (progn
             ;;(n-trace "yes")
             (throw 'nstr-assoc (car lst))
             )
         ;;(n-trace "no")
         )
       (setq lst (cdr lst))
       (if (not lst)
	   (throw 'nstr-assoc nil))
       )
      )
    )
   )
  )
(defun nstr-count-lines(str)
  (string-to-int
   (nstr-buf str '(lambda()
                    (insert
                     (prog1
                         (progn
                           (goto-char (point-max))
                           (int-to-string (n-what-line))
                           )
                       (delete-region (point-min) (point-max))
                       )
                     )
                    )
             )
   )
  )

(defun nstr-downcase( str &optional justFirstChar)
  (if justFirstChar
      (nstr-buf str '(lambda() (downcase-region (point-min) (1+ (point-min)))))
    (nstr-buf str '(lambda() (downcase-region (point-min) (point-max))))
    )
  )
(defun nstr-kill( str)
  "put STR in kill region"
  ;;(nstr-buf str '(lambda() (kill-region (point-min) (point-max))))
  (kill-new str)	;; doesn't append
  (nsimple-yank-set-my-global-kill-file-from-emacs-kill t)
  str
  )
(defun nstr-replace-regexp( str before after &optional clone)
  "n3.el: in STR, replace all instances of BEFORE with AFTER, returns the updated STR, clone if non-nil CLONE"
  (save-match-data
    
    ;; should do something more like this:
    ;;(while (string-match "//+" file)
    ;;(setq file (replace-match "/" t t file)))
    
    
    
    
    (nstr-buf str '(lambda()
                     (goto-char (point-min))
                     
                     (if (not clone)
                         (condition-case nil
                             (replace-regexp before after)
                           (error nil)
                           )
                       (nre-clone-rr before after)
                       )
                     )
              )
    )
  )

(defun nstr-join(list &optional separator)
  (if (not separator)
      (setq separator " "))
  (let(
       (string "")
       )
    (while list
      (setq string (concat string (car list))
	    list (cdr list)
	    )
      (if list
	  (setq string (concat string separator))
	)
      )
    string
    )
  )

(defun nstr-split( str &optional delimiters trimWhite)
  "given STRING, returns a list of the tokens delimited by DELIMITERS (by dft white space).
Considers \ followed by a newline to be white space."
  (if (not delimiters)
      (setq str (nstr-replace-regexp str "\\\\\\\n" " ")
	    delimiters " \t\n"
	    )
    )
  (let(
       xlist-for-nstr-split
       )
    ;;(setq xli
    (nstr-buf str '(lambda()
                     (let(
                          (delimitersRegexp (concat "["
                                                    (nstr-replace-regexp  delimiters "\\(.\\)" "\\1")
                                                    "]"
                                                    )
                                            )
                          )
		       (setq list-for-nstr-split nil)
		       (goto-char (point-max))
		       (while (not (bobp))
			 (setq token (buffer-substring-no-properties 
				      (progn
					(skip-chars-backward delimiters)
					(point)
					)
				      (progn
					(if (n-r delimitersRegexp)
					    (forward-char 1)
					  (goto-char (point-min))
					  )
					(point)
					)
				      )
			       )
			 (if (not (string= "" token))
			     (setq list-for-nstr-split (cons token list-for-nstr-split))
			   )
			 )
		       )
		     )
	      
	      )
    list-for-nstr-split
    )
  )
;;(nstr-split ",\\,," ",")
;;(nstr-split "abc  \t \\\n   def  ")
;;  (nstr-split "abc|def|gh" "|")
;;(nstr-split "I am," ", ")

(defun nstr-copy-to-register(register str)
  (nstr-buf str '(lambda() (copy-to-register register (point-min) (point-max) nil)))
  )
(defun nstr-upcase(str)
  (nstr-buf str '(lambda() (upcase-region (point-min) (point-max))))
  )
(defun nstr-dif(s1 s2)
  "return index of difference"
  (let(
       (dif	0)
       (len1	(length s1))
       (len2	(length s2))
       )
    (while (and
            (< dif len1)
            (< dif len2)
            (= (aref s1 dif)
               (aref s2 dif)
               )
            )
      (setq dif (1+ dif))
      )
    dif
    )
  )
(defun nstr-transform(transformations pattern)
  (let(
       (transformation (nstr-assoc pattern transformations)
                       )
       )
    (if transformation
        (nstr-replace-regexp pattern (car transformation) (cdr transformation))
      pattern	; if no match, return the pattern unchanged
      )
    )
  )
(defun nstr-capitalize(token)
  (nstr-buf token 'nsimple-upcase-word ?1)
  )
(defun nstr-uncapitalize(token)
  (nstr-buf token 'nsimple-uncapitalize)
  )

(defun nstr-eval(s-format &rest args)
  (let(
       (s (apply 'format s-format args))
       )
    (nstr-buf s '(lambda()
		   (insert "(progn ")
		   (goto-char (point-max))
		   (insert ")")
		   (let(
			(inputPt (point))
			)
		     (eval-last-sexp t)
		     (delete-region (point-min) inputPt)
		     )
		   )
	      )
    )
  )

(defun nstr-eval-and-return-obj(s)
  (nstr-buf-execute nil s '(lambda()
                             (insert "(setq nstr-eval-and-return-obj---retval (progn ")
                             (goto-char (point-max))
                             (insert "))")

                             ;;(goto-char (point-min))
                             ;;(replace-regexp "\\\\" "/")

                             ;;(n-trace (buffer-substring-no-properties (point-min) (point-max)))

                             (eval-last-sexp t)  ;; you'd think this would give us the val we want.  Not so.

                             nstr-eval-and-return-obj---retval
                             )
                    )
  )
(defun nstr-trim(s)
  (setq s (nstr-replace-regexp s "^[ \t\n]*" ""))
  (nstr-replace-regexp s "[ \t\n]$" "")
  )
;; (nstr-trim "         xx")


(defun nstr-chop(s)
  (nstr-buf s '(lambda()
                 (goto-char (point-max))
                 (if (< (point-min) (point-max))
                     (delete-char -1))
                 )
            )
  )
(defun nstr-call-process(chop input program &rest args)
  (let(
       (out (nstr-buf input
                      'apply
                      '(lambda(&rest args)
                         (apply 'call-process-region
                                (point-min)
                                (point-max)
                                (nsimple-env-expand program)
                                nil
                                t
                                nil
                                args
                                )
                         )
		      args
		      )
	    )
       )
    (if (not chop)
	out
      (nstr-chop out)
      )
    )
  )
(defun nstr-case-insensitive-member(key list)
  "no workie if 1. LIST elts contain embedded newlines
OR           2. KEY contains regexp chars"
  (setq key (nstr-downcase key))
  (not (string= ""
		(nstr-buf "" '(lambda()
				(while list
				  (insert (car list) "\n")
				  (setq list (cdr list))
				  )
				(downcase-region (point-min) (point-max))
				(goto-char (point-min))
				(let(
				     (hit (n-s (concat "^" (nstr-downcase key) "$")))
				     (case-fold-search t)
				     )
				  (delete-region (point-min) (point-max))
				  (if hit
				      (insert "t")
				    )
				  )
				)
			  )
		)
       )
  )
(defun nstr-get-kill()
  "return current kill"
  (nstr-buf "" '(lambda() (yank) (buffer-substring-no-properties (point-min) (point-max))))
  )
(defun nstr-beanify(s)
  (let(
       (li	(nstr-split s "_"))
       beanifiedS
       )
    (setq beanifiedS (car li)
          li (cdr li)
          )
    (while li
      (setq beanifiedS (concat beanifiedS (nstr-capitalize (car li)))
            li (cdr li)
            )
      )
    beanifiedS
    )
  )

(defun nstr-make-plural(s)
  (cond
   ((string-match "y$" s)
    (nstr-replace-regexp s "y$" "ies")
    )
   ((string-match "ch$" s)
    (nstr-replace-regexp s "$" "es")
    )
   (t
    (concat s "s")
    )
   )
  )

(defun nstr-make-singular(s)
  (setq s (nstr-replace-regexp s "ies$" "y")
        s (nstr-replace-regexp s "ses$" "s")
        s (nstr-replace-regexp s "s$" "")
        )
  )
(defun nstr-register-get(reg)
  (nstr-buf nil '(lambda() (insert-register reg) (buffer-substring-no-properties (point-min) (point-max))))
  )
(defun nstr-*(times s)
  (let(
       (sMultiplied "")
       )
    (while (> times 0)
      (setq sMultiplied (concat sMultiplied s)
            times (1- times)
            )
      )
    sMultiplied
    )
  )
(defun nstr-clipboard-win-only(data)
  (or n-win
      (message "nstr-clipboard-win-only: only valid on windows")
      (nelisp-bp data "nstr.el" 454);;;;;;;;;;;;;;;;;
      (nstr-kill data)
      )
  (nstr-call-process nil data "bash" "-x" "clipboard" "-stdin")
  )
;; (nstr-clipboard-win-only "hey")
(defun nstr-chomp(s)
  (nstr-replace-regexp s "\n$" "")
  )
(defun nstr-assert-eq(expected actual &optional msg)
  (if (not (string= expected actual))
      (error "nstr-assert-eq: expected \"%s\" but saw \"%s\"" expected actual))
  (message "OK")
  )
(defun nstr-test(input expected test_func &optional args)
  (let(
       (actual (nstr-buf input '(lambda()
                                  (goto-char (point-min))
                                  (n-s "@@" t)
                                  (delete-char -2)
                                  (apply test_func args)
                                  (buffer-substring-no-properties (point-min) (point-max))
                                  )
                         )
               )
       )
    (nstr-assert-eq expected actual (format "oops, nstr-assert-eq expected \"%s\" but saw \"%s\"" expected actual))
    )
  )
(defun nstr-grab-delimited-token(delimiter)
  (save-restriction
    (n-narrow-to-line)
    (buffer-substring-no-properties (progn
                                      (n-r delimiter t)
                                      (forward-char 1)
                                      (point)
                                      )
                                    (progn
                                      (n-s delimiter t)
                                      (forward-char -1)
                                      (point)
                                      )
                                    )
    )
  )
