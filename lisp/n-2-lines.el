(provide 'n-2-lines)
(setq n-2-lines-clone-one-to-one-mode nil)
(setq n-2-lines-clone-one-to-many-mode nil)
(setq n-2-lines-clone-many-to-many-mode nil)

(defun n-2-lines-set-point()
  (end-of-line)
  (save-restriction
    (n-narrow-to-line)
    (forward-word -1)
    (cond
     ((save-excursion
        (forward-line 0)
        (looking-at ".*@@")
        )
      (forward-line 0)
      (n-complete-leap)
      )
     ((or
       (looking-at "n\"")
       (looking-at "endl;")
       (looking-at "endl;")
       )
      (forward-word -1)
      )
     ((save-excursion
        (forward-line 0)
        (looking-at ".*/[^>]")
        )
      (if (n-s "/[^>]")
          (progn
            (forward-char -1)
            )
        )
      (if (looking-at "verb_")
          (n-s "verb_" t))
      )
     )
    )
  )

(defun n-2-lines-vanilla( &rest args)
  (let(
       (n-2-lines-clone-one-to-one-mode nil)
       (n-2-lines-clone-one-to-many-mode nil)
       (n-2-lines-clone-many-to-many-mode nil)
       )
    (apply 'n-2-lines args)
    )
  )

(defun n-2-lines-do-clone-loop(narrowToNewRegion data)
  (let(
       (reg1 (nsimple-register-get ?1))
       (reg2 (nsimple-register-get ?2))
       (case-replace t)
       (case-fold-search t)
       )
    (cond
     (n-2-lines-clone-many-to-many-mode
      (let(
           (l1 (nstr-split reg1))
           (l2 (nstr-split reg2))
           )
        (n-loc-push)
        (n-2-lines-do-clone narrowToNewRegion data (nlist-zip l1 l2))
        (n-loc-pop)   ;; get back to the original line
        )
      )
     ((or
       (not (string-match reg1 data))	;; if c-x1 is not present, ignore clone mode
       (and (not n-2-lines-clone-one-to-many-mode)
            (not n-2-lines-clone-many-to-many-mode)
            )
       )
      (n-2-lines-do-clone narrowToNewRegion data (list reg1 reg2))
      )
     (n-2-lines-clone-one-to-many-mode
      (let(
           (l (nreverse (nstr-split reg2)))
           )
        (while l
          (n-loc-push)
          (n-2-lines-do-clone narrowToNewRegion data (list reg1 (car l)))
          (n-loc-pop)   ;; get back to the original line

          (setq l (cdr l))
          )
        )
      )
     )
    )
  )

(defun n-2-lines-do-clone(narrowToNewRegion data tokenPairs)
  (if (not (eq this-command 'n-2-lines-clone-file))
      (progn
        (insert "\n")
        )
    )

  (if (or narrowToNewRegion n-2-lines-clone-one-to-one-mode)
      (narrow-to-region (point) (point))
    )
  (save-excursion
    (insert data)
    (require 'nre)
    (while tokenPairs
      (let(
           (token1 (car  tokenPairs))
           (token2 (cadr tokenPairs))
           )
        (setq tokenPairs (cdr tokenPairs))
        (setq tokenPairs (cdr tokenPairs))

        (goto-char (point-min))
        (nre-clone-rr token1 token2)
        )
      )
    )
  (n-2-lines-set-point)
  (if (and n-2-lines-clone-one-to-one-mode (not narrowToNewRegion))
      (widen))
  )

(defun n-2-lines-clone-file()
  (interactive)

  (or n-2-lines-clone-one-to-many-mode
      (and (y-or-n-p "n-2-lines-clone-file: this does not make sense unless it is n-2-lines-clone-one-to-many-mode -- turn it on?")
           (setq n-2-lines-clone-one-to-many-mode t)
           )
      (error "n-2-lines-clone-file: stop")
      )

  (let(
       (n-2-lines-clone-one-to-one-mode t)
       (beforeFn (buffer-file-name))
       (beforeData (buffer-substring-no-properties (point-min) (point-max)))
       (token1 (nstr-downcase (nsimple-register-get ?1)))
       (l (nreverse (nstr-split (nsimple-register-get ?2))))

       (beforeToken (nsimple-register-get ?1))
       afterFn
       token2
       )
    (while l
      (setq token2 (car l)
            afterFn (concat (file-name-directory beforeFn)
                            (nstr-replace-regexp (file-name-nondirectory beforeFn) beforeToken token2 "clone")
                            )
            )
      (and (string= beforeFn afterFn)
           (error "n-2-lines-clone-file: file names are the same")
           )
      (and (file-exists-p afterFn)
           (error "n-2-lines-clone-file: %s already exists" afterFn))
      (n-file-find afterFn)

      (delete-region (point-min) (point-max))	;; I know it's a new file, but some modes seed the empty file w/ a template we don't want

      (n-2-lines-do-clone nil beforeData (list token1 token2))

      (setq l (cdr l))

      (if l		;; ie, if this is not the last time through the loop
          (progn
            (message "Inspect -- hit any key to advance")
            (read-char)
            )
        )
      )
    )
  )
(defun n-2-lines( &optional arg narrowToNewRegion)
  "^u92-parse-token1/token2-into-regs-and-initiate-99, ^u97-clone-one-to-many-mode, 98-clone-many-to-many-mode, ^u99-clone-one-to-one-mode, ^u88 to act on the region"
  (interactive "p")
  (if (not arg)
      (setq arg 1))
  (save-restriction
    (cond
     ((and arg (integerp arg) (= arg 88))
      (save-restriction
        (call-interactively 'narrow-to-region)
        (let(
             (lineCnt (progn
                        (goto-char (point-max))
                        (n-what-line)
                        )
                      )
             )
          (goto-char (point-min))
          (n-2-lines lineCnt)
          )
        )
      )
     ((and arg (integerp arg) (= arg 92))
      (nsimple-register-grab-token-pair-12)
      (n-2-lines 99)
      )
     ((and arg (integerp arg) (= arg 96))
      (setq n-2-lines-clone-one-to-one-mode "zz")
      (message "n-2-lines-clone-one-to-one-mode is %s" n-2-lines-clone-one-to-one-mode)
      )
     ((and arg (integerp arg) (= arg 97))
      (setq n-2-lines-clone-one-to-many-mode (not n-2-lines-clone-one-to-many-mode)
            n-2-lines-clone-one-to-one-mode n-2-lines-clone-one-to-many-mode
            )
      (if n-2-lines-clone-one-to-many-mode
          (message "n-2-lines-clone-one-to-many-mode will clone %s into %s"
                   (nsimple-register-get ?1)
                   (nsimple-register-get ?2)
                   )
        (message "n-2-lines-clone-one-to-many-mode off")
        )
      )
     ((and arg (integerp arg) (= arg 98))
      (setq n-2-lines-clone-many-to-many-mode (not n-2-lines-clone-many-to-many-mode)
            n-2-lines-clone-one-to-one-mode n-2-lines-clone-many-to-many-mode
            )
      (if n-2-lines-clone-many-to-many-mode
          (message "n-2-lines-clone-many-to-many-mode will clone %s into %s"
                   (nsimple-register-get ?1)
                   (nsimple-register-get ?2)
                   )
        (message "n-2-lines-clone-many-to-many-mode off")
        )
      )
     ((and arg (integerp arg) (= arg 99))
      (n-2-lines-toggle-clone-mode)
      )
     (t
      (setq last-command 'undefined)
      (let(
           (data	(if (and arg
                                 (integerp arg)
                                 (> arg 1)
                                 )
                            (buffer-substring-no-properties (progn
                                                              (forward-line 0)
                                                              (point)
                                                              )
                                                            (progn
                                                              (forward-line (1- arg))
                                                              (end-of-line)
                                                              (point)
                                                              )
                                                            )
                          (n-get-line)
                          )
                        )
           )
        (end-of-line)
        (cond
         (n-2-lines-clone-one-to-one-mode
          (n-2-lines-do-clone-loop narrowToNewRegion data)
          )
         ((or
           (string-match "^\\([0-9][0-9]-[0-9][0-9]-[0-9][0-9]\t\\)\\([0-9][0-9][0-9][0-9]\\)\\(\t.*\\)" data)
 	   )
	  (insert "\n"
		  (n--pat 1 data)
		  (format "%04d" (1+ (string-to-int (n--pat 2 data))))
		  (n--pat 3 data)
		  )
	  )
         ;;((or
         ;;(string-match "\\b\\([0-9]+\\)\\b" data)
         ;;)
         ;;(insert "\n"
         ;;(nstr-replace-regexp data
         ;;(n--pat 1 data)
         ;;(format "%d" (1+ (string-to-int (n--pat 1 data))))
         ;;)
         ;;)
         ;;)
         ((or
           (string-match "^[ \t]*'z/\\(.*\\)" data)
           )
          (insert "\n'"
                  (n--pat 1 data)
                  )
          (forward-char -2)
          )

         ((or
           (string-match "^\\([ \t]*\\)\\(sb\\)?\\.append(.*)$" data)
           )
          (insert "\n"
                  (n--pat 1 data)
                  (if (string= "sb" (n--pat 1 data))
                      "  "
                    ""
                    )
                  ".append()"
                  )
          (forward-char -1)
          )

         ((and
           (not (eq major-mode 'nbookkeeping-mode))
           (not (eq major-mode 'nsql-interactive-mode))
           (or
            (string-match "^\\([ \t]*\\)[0-9a-zA-Z_]+=\\$\\([0-9]\\)$" data)  ;sh: "variable=$1"
            )
           )
          (insert "\n"
                  (n--pat 1 data)
                  "@@=$"
                  (int-to-string (1+ (string-to-int (n--pat 2 data))))
                  )
          (forward-line 0)
          (n-complete-leap)
	  )

         ((and
           nil ;; disabling this excessive incrementing for now
           (eq arg 1)
           (not (eq major-mode 'nbookkeeping-mode))
           (not (eq major-mode 'nsql-interactive-mode))
           (n-2-lines-increment-numbers-for-one-line)
           )
          t
          )

 	 ;;((or
         ;;(string-match "\\(.*\\.\\)\\([0-9]+\\)\\('.*\\)$" data)
         ;;(string-match "\\(.*-\\)\\([0-9]+\\)\\(/.*\\)$" data)
         ;;)
         ;;(insert "\n"
         ;;(n--pat 1 data)
         ;;"@@"
         ;;(int-to-string (1+ (string-to-int (n--pat 2 data))))
         ;;(n--pat 3 data)
         ;;)
         ;;(forward-line 0)
         ;;(n-complete-leap)
         ;;)

	 ((string-match "^#include" data)
	  (insert "\n" data)
	  (forward-word -2)
	  (kill-word 1)
	  )

         ;;((or
         ;;(string-match "\\(.*\\)\\[\\([0-9]+\\)\\]\\(.*\\)" data)
         ;;)
         ;;(insert "\n"
         ;;(n--pat 1 data)
         ;;"[@@"
         ;;(int-to-string (1+ (string-to-int (n--pat 2 data))))
         ;;"]"
         ;;(n--pat 3 data)
         ;;)
         ;;(forward-line 0)
         ;;(n-complete-leap)
         ;;(if (looking-at ".*= ")
         ;;(n-s ".*= " t))
         ;;)

	 ((stringp n-2-lines-clone-one-to-one-mode)
	  (require 'nmw-data)
	  (nmw-data-clone-langs data n-2-lines-clone-one-to-one-mode arg)
	  )
	 (t
	  (insert "\n")
	  (if narrowToNewRegion
	      (narrow-to-region (point) (point))
	    )
	  (save-excursion
            ;;(setq data (nstr-replace-regexp data "\\bsrc\\b" "dest"))
            ;;(setq data (nstr-replace-regexp data "\\bold\\b" "new"))
            ;;(setq data (nstr-replace-regexp data "1" "2"))
            ;;(setq data (nstr-replace-regexp data "0" "1"))

	    (insert data)
	    )
	  (n-2-lines-set-point)
	  )
	 )
	)
      )
     )
    )
  )
(defun n-2-lines-toggle-clone-mode()
  (setq n-2-lines-clone-one-to-one-mode (not n-2-lines-clone-one-to-one-mode))
  (message "n-2-lines-clone-one-to-one-mode is %s"(if n-2-lines-clone-one-to-one-mode "t" "nil"))
  )
(defun n-2-lines-increment-numbers-for-one-line()
  (if (save-excursion
        (forward-line 0)
        (looking-at ".*\\([0-9]+\\)[^0-9]?")
        )
      (let(
           (n (string-to-int (nre-pat 1)))
           n1
           (line (n-get-line))
           )
        (setq n1 (1+ n))
        (end-of-line)
        (insert "\n" (nstr-replace-regexp line
                                          (int-to-string n )
                                          (int-to-string n1)
                                          )
                )
        (forward-word -1)
        t
        )
    )
  )
