(provide 'nclass-browser)
(require 'ntags-find)

;;(length nclass-browser-assoc-token-to-IC)

;; IC='identified class', e.g., c:/IBJts/TestJavaClient/AccountDlg.java!AccountDlg
;; nclass-browser-assoc-token-to-IC is an assoc mapping token to IC, e.g.,
;; 	AccountDlg -> c:/IBJts/TestJavaClient/AccountDlg.java!AccountDlg
(defvar nclass-browser-assoc-token-to-IC nil)
(defvar nclass-browser-children nil)
(defvar nclass-browser-parents  nil)
(defvar nclass-browser-tags     nil)

(defvar nclass-browser-method-pruning-function nil)
(set-default 'nclass-browser-method-pruning-function 'njava-method-pruning-function)
(make-variable-buffer-local 'nclass-browser-method-pruning-function)

(defvar nclass-browser-show-data nil)
(set-default 'nclass-browser-show-data nil)
(make-variable-buffer-local 'nclass-browser-show-data)

(defvar nclass-browser-show-methods nil)
(set-default 'nclass-browser-show-methods nil)
(make-variable-buffer-local 'nclass-browser-show-methods)

(defvar nclass-browser-className nil)
(make-variable-buffer-local 'nclass-browser-className)

(if (not (boundp 'nclass-browser-mode-map))
    (progn
      (setq nclass-browser-mode-map     (make-sparse-keymap))
      )
  )

(defun nclass-browser-clear()
  (setq nclass-browser-assoc-token-to-IC nil)
  (setq nclass-browser-children nil)
  (setq nclass-browser-parents  nil)
  (setq nclass-browser-tags     nil)
  )

(defun nclass-browser-mode-meat()
  (setq major-mode 'nclass-browser-mode
        mode-name "nclass-browser"
        ;;ntags-find-current-token-class-context 'nclass-browser-find-current-token-class-context
        n-grab-file-go-by-lines nil
        nclass-browser-show-data nil
        nclass-browser-show-methods nil
        )
  (define-key nclass-browser-mode-map "?"    'nclass-browser-usage)
  (define-key nclass-browser-mode-map "\C-m" 'n-grab-file)
  (define-key nclass-browser-mode-map "d" 'nclass-browser-toggle-data)
  (define-key nclass-browser-mode-map "e"    'n-grab-file)
  (define-key nclass-browser-mode-map "g" '(lambda()
					     (interactive)
					     (nclass-browser-command nclass-browser-className)
					     (message "refreshed")
					     )
    )
  (define-key nclass-browser-mode-map "h"    'nclass-browser-usage)
  (define-key nclass-browser-mode-map "m" 'nclass-browser-toggle-methods)
  (define-key nclass-browser-mode-map "n" 'n-next-line)
  (define-key nclass-browser-mode-map "p" 'n-prev-line)
  (use-local-map nclass-browser-mode-map)
  (nclass-browser-usage)
  )
(defun nclass-browser-usage()
  (interactive)
  (message "d-toggle data, e-edit, g-refresh, m-toggle methods")
  )

(defun nclass-browser-goto-tag-source(data)
  (let(
       fileFound
       tagFound
       )
    (save-window-excursion
      (if (n-r "_ \\(.*\\):[0-9]")
	  (progn
	    (setq fileFound (n-grab-file))
	    (if fileFound
		(progn
		  (setq data (nstr-replace-regexp data "[ \t\n]+" "[ \t\n]+"))
		  (if (n-s (concat "[^0-9a-zA-Z_\\.]" data "[^0-9a-zA-Z_\\.]"))
		      (progn
			(forward-word -1)
			(n-loc-push)
			(setq tagFound t)
			)
		    )
		  )
	      )
	    )
	)
      )
    (if tagFound
	(progn
	  (n-loc-pop)
	  )
      )
    tagFound
    )
  )

(defun nclass-browser-edit-method(method)
  (let(
       (fn (save-excursion
             (end-of-line)
             (n-r "/" t)
             (n-grab-file-get-token)
             )
           )
       )
    (n-file-find fn)
    (goto-char (point-min))
    (n-s (concat "^[][ \t0-9a-zA-Z_\\.]*[ \t]" method "[ \t]*(") t)
    )
  )

(defun nclass-browser-edit()
  (let(
       hit
       )
    (save-excursion
      (nsimple-back-to-indentation)
      (cond
       ((looking-at "\\([0-9a-zA-Z_\\.]+\\) _* \\(.*\\):\\([0-9]+\\)")
        (let(
                 (file (n--pat 2))
                 (offset (n--pat 3))
                 (browse (string-match "\\.html?$" (n--pat 2)))
                 )
	  (if browse
	      (nhtml-browse nil file)
	    (n-file-find file t (string-to-int offset))
	    )
	  (setq hit nil)
	  )
	)
       ((looking-at ".*[ \t]\\([^ \n\t]+\\)[ \t]*=")
	(setq hit (nclass-browser-goto-tag-source (n--pat 1)))
	)

       ;; ! is there as a marker for Java @deprecated, - means abstract, @ means static
       ((looking-at ".*[ \t]\\([-@!]*\\)\\([0-9a-zA-Z_]+[ \t]*\\)(.*")
	(nclass-browser-edit-method (n--pat 2))
        (setq hit nil)
	)
       ((looking-at "[ \t]*\\(.*[^ \n\t]\\)")
        (setq hit (nclass-browser-goto-tag-source (n--pat 1)))
	)
       )
      )
    hit
    )
  )

(defun nclass-browser-toggle-data()
  (interactive)
  (setq nclass-browser-show-data (not nclass-browser-show-data))
  (nclass-browser-show-components)
  )
(defun nclass-browser-toggle-methods()
  (interactive)
  (setq nclass-browser-show-methods (not nclass-browser-show-methods))
  (nclass-browser-show-components)
  )
(defun nclass-browser-get-source(fileName offset className)
  (let(
       ppfn
       )
    (save-window-excursion
      (n-file-push (n-host-from-canonical fileName))
      (setq ppfn nclass-browser-method-pruning-function)
      (goto-char offset)
      (setq source (cond
		    ((eq major-mode 'nperl-mode)
		     (buffer-substring-no-properties (point-min) (point-max))
		     )
		    (t  ; ok, then assume C++ or Java-like lang, where class src bounded by curlies:
		     (buffer-substring-no-properties (progn
					 (if (not (n-s "{"))
					     (progn
					       (goto-char (point-min))
					       (n-s (concat "\\(class\\|interface\\).*\\b" className "\\b") t)
					       (n-s "{" t)
					       )
					   )
					 (point)
					 )
				       (progn
					 (forward-char -1)
					 (forward-sexp 1)
					 (forward-char -1)
					 (point)
					 )
				       )
		     )
		    )
	    )
      (n-file-pop)
      )
    (setq nclass-browser-method-pruning-function ppfn)
    )
  ;;(nelisp-bp "" (prin1-to-string nclass-browser-method-pruning-function) 163);;;;;;;;;;;;;;;;;
  source
  )

(defun nclass-browser-show-components---organize-data-sort()
  (goto-char (point-min))
  (replace-regexp "[ \t]+(" "(")

  (nclass-browser-show-components---organize-data-sort-mv-what-is-left-of-routine-name-to-eoln)
  (require 'nsort)
  (nsort-buf)
  (nclass-browser-show-components---organize-data-sort-put-back-what-should-be-left-of-routine-from-eoln)
  )

(defun nclass-browser-show-components---organize-data-sort-mv-what-is-left-of-routine-name-to-eoln()
  (goto-char (point-min))
  (while (n-s "(")
    (save-restriction
      (n-narrow-to-line)
      (if (not (n-r "[ \t]"))
	  (forward-line 0)
	)
      ;; (point) is at the routine name's beginning.  Move what's to its left to eoln:
      (let(
	   (leftOfRoutine  (buffer-substring-no-properties (point) (save-excursion
						       (forward-line 0)
						       (point)
						       )
					     )
			   )
	   )
	(delete-region (point) (progn
				 (forward-line 0)
				 (point)
				 )
		       )
	(end-of-line)
	(insert "//" leftOfRoutine)
	)
      )
    )
  )
(defun nclass-browser-show-components---organize-data-sort-put-back-what-should-be-left-of-routine-from-eoln()
  (goto-char (point-min))
  (while (n-s "//")
    (delete-char -2)
    (let(
	 (whatShouldBeLeftOfRoutine  (buffer-substring-no-properties (point) (save-excursion
								 (end-of-line)
								 (point)
								 )
						       )
				     )
	 )
      (delete-region (point) (progn
			       (end-of-line)
			       (point)
			       )
		     )
      (forward-line 0)
      (insert whatShouldBeLeftOfRoutine " ")
      )
    )
  )

(defun nclass-browser-method---mark-functions-by-attribute(attribute marker-character)
  (goto-char (point-min))
  (while (n-s (concat "\\b" attribute "\\b"))
    (save-restriction
      (n-narrow-to-line)
      (if (looking-at ".*(")
	  (progn
	    (delete-char (- (length attribute)))
	    (n-s "(" t)
	    (n-r "[ \t]" t)
	    (forward-char 1)
	    (insert marker-character)
	    )
	)
      )
      )
  )


(defun nclass-browser-shorten-method-keywords()
  (goto-char (point-min))
  (replace-regexp (concat "\\b" "synchronized" "\\b") "sync")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "public"       "\\b") "pub_")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "protected"       "\\b") "prot")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "private"       "\\b") "priv")
  )


(defun nclass-browser-expand-method-keywords()
  (goto-char (point-min))
  (replace-regexp (concat "\\b" "sync" "\\b") "synchronized")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "pub_"       "\\b") "public")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "prot"       "\\b") "protected")

  (goto-char (point-min))
  (replace-regexp (concat "\\b" "priv"       "\\b") "private")
  )


(defun nclass-browser-show-components---organize-data()
  (nclass-browser-method---mark-functions-by-attribute "static" "@")
  (nclass-browser-shorten-method-keywords)

  (goto-char (point-min))
  (replace-regexp "[ \t]*{.*" "")

  (goto-char (point-min))
  (replace-regexp "\r" "")

  (goto-char (point-min))
  (replace-regexp "[\";]" " ")

  (goto-char (point-min))
  (replace-regexp "[ \t]+" " ")

  (goto-char (point-min))
  (replace-regexp "^[ \t]*" "             ")

  (nclass-browser-show-components---organize-data-sort)

  (goto-char (point-min))
  (while (n-s "(")
    (n-r "[ \t]" t)
    (indent-to 39)
    (end-of-line)
    )

  (goto-char (point-min))
  (while (n-s "throws")
    (forward-word -1)
    (indent-to 84)
    (end-of-line)
    )

  (goto-char (point-min))
  (forward-line 0)
  (delete-horizontal-space)

  (goto-char (point-min))
  )

(defun nclass-browser-show-components()
  (require 'n-prune-buf)
  (n-prune-buf "(")                     ; clear out all the methods
  (n-prune-buf-v ":")                   ; clear out all the constants
  (if (or nclass-browser-show-data nclass-browser-show-methods)
      (save-restriction
	(save-excursion
	  (goto-char (point-min))
	  (let(
	       className fileName offset source
			 )
	    (while (n-s "^[ \t]*\\([0-9a-zA-Z_\\.]+\\) _* \\(.*\\):\\([0-9]+\\)$")
	      (setq
	       className (n--pat 1)
	       fileName (n--pat 2)
	       offset   (string-to-int (n--pat 3))
	       )
	      (end-of-line)
	      (insert "\n")

	      (if (not (string-match "\\.html?$" fileName))
		  (progn
		    (narrow-to-region (point) (point))
                    (insert (nclass-browser-get-source fileName offset className))

                    (funcall nclass-browser-method-pruning-function nclass-browser-show-data nclass-browser-show-methods)

		    (nclass-browser-show-components---organize-data)
                    (widen)
                    )
                )
              )
            )
          )
        (n-prune-buf "^[ \t]*$")
        )
    )
  )
(defun nclass-browser-query-tag(&optional token)
  (save-match-data
    (if (not token)
        (setq token (n-grab-IC)))

    (if (not nclass-browser-tags)
        (nclass-browser-load))

    (let(
         (setting-pair (assoc (nclass-browser-token-to-IC token)
                              nclass-browser-tags
                              )
                       )
         fn
         offset
         )
      (cond
       (setting-pair
        (setq fn (ntags-find-fn-from-number (cddr setting-pair))
              offset (cadr setting-pair)
              )
        (cons fn offset)
        )
       ((string-match ".*\\.\\([^\\.;]+\\)$" token)	;; e.g., if it's 'java.io.Serializable'...
        (nclass-browser-query-tag (n--pat 1 token))	;; ...search on 'Serializable' then
        )
       )
      )
    )
  )
(defun nclass-browser-sort-classes()
  ;;this method doesn't work because it ends up grouping all the children
  ;;together, and then grouping all the grandchildren together -- even those
  ;;which don't have the same parents, and so forth.  So for example, where I
  ;;would expect the following order:
  ;;
  ;;  origin ______________
  ;;    child_1 ___________
  ;;	  a_grandchild ____
  ;;	  b_grandchild ____
  ;;	child_2 ___________
  ;;
  ;;		instead I get
  ;;
  ;;
  ;;  origin ______________
  ;;    child_1 ___________
  ;;	child_2 ___________   God damn it!
  ;;	  a_grandchild ____
  ;;	  b_grandchild ____
  ;;
  ;;
  ;;	so I am punting for the moment

  ;;
  ;;	;;If I just sort this buffer, then the leading spaces screw up the order
  ;;	;;because they precede alphabetical characters.  So I temporarily replace
  ;;	;;spaces throughout with 'z!', which sorts after alphabetical characters.
  ;;	;;Sorting then gives me the correct ordering:
  ;;
  ;;	(goto-char (point-min))
  ;;	(replace-regexp " " "z!")
  ;;
  ;;	(nsort-buf)
  ;;
  ;;	(goto-char (point-min))
  ;;	(replace-regexp "z!" " ")
  )

(defun nclass-browser-command(&optional token)
  (interactive "P")
  (if (not nclass-browser-tags)
      (nclass-browser-load))
  (if (not token)
      (progn
	(setq token (n-grab-token))
	(if (string= "" token)
	    (setq token (nfn-prefix (buffer-file-name))))
	(n-loc-push)
	)
    )

  (if (string= "" token)
      (setq token "ChargeCardCB"))

  (let(
       (IC	(nclass-browser-token-to-IC token))
       (maximum-indentation 0)
       indentation-carried-over-from-parents
       )
    (setq indent-tabs-mode nil)
    (setq nclass-browser-className nil)
    (switch-to-buffer (get-buffer-create (concat "class-" token)))
    (delete-region (point-min) (point-max))
    (nclass-browser-insert-tree IC nclass-browser-parents 0 "up")
    (nclass-browser-indent maximum-indentation)
    (setq indentation-carried-over-from-parents (progn
						  (goto-char (point-max))
						  (forward-line -1)
						  (nsimple-back-to-indentation)
						  (1+ (current-column))
						  )
	  )
    (goto-char (point-max))
    (narrow-to-region (point) (point))

    (insert "0 " IC)
    (nclass-browser-insert-tree IC nclass-browser-children 0 "down")

    (nclass-browser-indent)

    (goto-char (point-min))
    (replace-regexp "^"
		    (make-string indentation-carried-over-from-parents 32)
		    )

    ;; go to the class being browsed
    (goto-char (point-min))
    (end-of-line)

    (widen)
    (nclass-browser-sort-classes)
    (nclass-browser-show-source-locations)
    (nclass-browser-mode)
    )
  )

;;(nclass-browser-IC-to-token "c:/downloads/java/jaxm1.1-scsl/jaxm-api/src/javax/xml/soap/SOAPHeader.java!SOAPHeader")

(defun nclass-browser-IC-to-token(IC)
  (nstr-buf IC 'nclass-browser-show-source-locations-convert-IC-to-token)
  )
(defun nclass-browser-show-source-locations-convert-IC-to-token()
  (save-restriction
    (n-narrow-to-line)
    (if (looking-at ".*!")
	(progn
	  (nsimple-back-to-indentation)
	  (delete-region (point) (progn
				   (n-s "!" t)
				   (point)
				   )
			 )
	  )
      )
    )
  )
(defun nclass-browser-show-source-locations()
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (while (not (eobp))
	(nsimple-back-to-indentation)
	(let(
	     (tagResult (nclass-browser-query-tag))
	     )
	  (nclass-browser-show-source-locations-convert-IC-to-token)
	  (if tagResult
	      (progn
		(end-of-line)
		(indent-to 35 5)
		(narrow-to-region (progn
				    (forward-char -1)
				    (point)
				    )
				  (progn
				    (n-r "[^ \t]" t)
				    (forward-char 1)
				    (point)
				    )
				  )
		(untabify (point-min) (point-max))
		(goto-char (point-min))
		(forward-char 1)
		(replace-regexp " " "_")
		(widen)
		(end-of-line)
		(insert (format "%s:%d"
				(n-env-use-var-names-str (car tagResult) t)
				(cdr tagResult)
				)
			)
		)
	    )
	  )
	(forward-line 1)
	)
      )
    )
  )
(defun nclass-browser-indent(&optional invert-indentation)
  (goto-char (point-min))
  (while (not (eobp))
    (indent-line-to
     (* 2
	(if invert-indentation
	    (- invert-indentation (n-grab-number))
	  (n-grab-number)
	  )
	)
     )
    (delete-region (point)
                   (progn
                     (n-s " " t)
                     (point)
                     )
                   )
    (forward-line 1)
    )
  )

;;(nclass-browser-get-parent "Expression")
;;(nclass-browser-get "Expression" nclass-browser-parents)

(defun nclass-browser-get-parent(token)
  (let(
       (parentsS (nclass-browser-get token nclass-browser-parents))
       (fnContext (buffer-file-name))
       parents
       bestMatch
       )
    (setq parents (nstr-split parentsS ";")
	  bestMatch (ntags-sort-pick-best-associated-match parents
							   '(lambda(token)
							      (let(
								   (dcl (ntags-find-where-is-defn-sync token))
								   )
								(if dcl
								    (car dcl))
								)
							      )
							   fnContext
							   )
	  )
    (error "nclass-browser-get-parent: this is dead code, I think")
    bestMatch
    )
					;(nlist-funcall
					;(string-match "^;\\([^;]+\\);" parentsS)
					;)
					;(n--pat 1 parentsS)
  )
(defun nclass-browser-insert-tree(token database depth direction)
  (let(
       (nextLevel (nclass-browser-get token database))
       )
    ;; Add the following to the 'if' to avoid stack overflows: (and nextLevel (< depth 25))  ;; 25 is arbitrary.  At 37, my stack overflows.
    (if nextLevel
	(progn
	  (setq depth (1+ depth))
	  (if (> depth maximum-indentation)
	      (setq maximum-indentation depth))
	  (save-restriction
	    (if (string= direction "up")
		(progn
		  (forward-line 0)
					;(nelisp-bp "nclass-browser-insert-tree" "beginning of insert-tree" 282);;;;;;;;;;;;;;;;;
		  (insert "\n")
		  (forward-char -1)
					;(nelisp-bp "nclass-browser-insert-tree" "before narrow to line" 285);;;;;;;;;;;;;;;;;
		  (narrow-to-region (point)
				    (progn
				      (forward-line 1)
				      (point)
				      )
				    )
		  (goto-char (point-min))
		  (insert nextLevel)
					;(nelisp-bp "nclass-browser-insert-tree" "next level inserted" 293);;;;;;;;;;;;;;;;;
		  (delete-char -1)    ; delete last semicolon
					;(nelisp-bp "nclass-browser-insert-tree" "last semi deleted" 293);;;;;;;;;;;;;;;;;
		  (goto-char (point-min))
		  (replace-regexp ";" (format "\n%d " depth))
					;(nelisp-bp "nclass-browser-insert-tree" "replace; with depth" 291);;;;;;;;;;;;;;;;;
		  (goto-char (point-min))
                                        ;(or (looking-at "\n") (error "nclass-browser-insert-tree: "))
		  (delete-char 1)
					;(nelisp-bp "nclass-browser-insert-tree" "first character deleted" 293);;;;;;;;;;;;;;;;;
		  (while (not (eobp))
		    (end-of-line)
		    (nclass-browser-insert-tree (n-grab-IC) database depth direction)
		    (forward-line 1)
		    )
		  )
	      (end-of-line)
	      (insert "\n")
					;(nelisp-bp "nclass-browser-insert-tree" (concat token " " direction ": " nextLevel) 594);;;;;;;;;;;;;;;;;
	      (narrow-to-region (point) (point))
	      (insert nextLevel)
	      (delete-char -1)        ; delete last semicolon
	      (insert "\n")           ; this lets the while-loop below terminate correctly
	      (goto-char (point-min))
	      (replace-regexp ";" (format "\n%d " depth))
	      (goto-char (point-min))
	      (delete-char 1)
	      (while (not (eobp))
		(end-of-line)
					;(nelisp-bp "nclass-browser-insert-tree-pre" token 596);;;;;;;;;;;;;;;;;
		(nclass-browser-insert-tree (n-grab-IC) database depth direction)
		(forward-line 1)
					;(nelisp-bp "nclass-browser-insert-tree-post" token 596);;;;;;;;;;;;;;;;;
		)
	      (delete-char -1)        ; eliminate superfluous final empty line
	      )
	    )
	  )
      )
    )
  )
;;(nclass-browser-get "Remote" nclass-browser-children)
(defun nclass-browser-get(key database)
  (let(
       (setting-pair (assoc key database))
       val
       )
    (setq val
	  (cond
	   (setting-pair
	    (cdr setting-pair)
	    )
	   ((string-match ".*\\.\\([^\\.;]+\\)$" key)	;; e.g., if it's 'java.io.Serializable'...
	    (nclass-browser-get (n--pat 1 key)
				database)			;; ...search on 'Serializable' then
	    )
	   )
	  )
    val
    )
  )
(defun nclass-browser-add(key item database)
  (let(
       (setting-pair (assoc key database))
       setting
       )
    (if (not setting-pair)
        (setq database (cons (cons key
                                   (concat ";" item ";")
                                   )
                             database)
              )
      (setq setting (cdr setting-pair))
      (setq item (concat item ";"))
      (cond
       ((string-match (concat ";" item) setting)
        nil
        )
       (t
        (setcdr setting-pair (concat setting item))
        )
       )
      )
    )
  database
  )

(defun nclass-browser-load-IC-setting(token IC)
  (setq nclass-browser-assoc-token-to-IC (nlist-assoc-n-add-val token
								IC
								nclass-browser-assoc-token-to-IC
								)
	)
  )

(defun nclass-browser-load(&optional tagDbSuffix)
  (message  "DISABLED: loading class browser database...")
  ;;  (if (not tagDbSuffix)
  ;;      (progn
  ;;        (setq nclass-browser-children nil
  ;;              nclass-browser-parents nil
  ;;              nclass-browser-tags nil
  ;;              tagDbSuffix "main"
  ;;              )
  ;;        )
  ;;    )
  ;;  (n-file-find (concat "$NELSON_HOME/tmp/tags/" tagDbSuffix ".classes"))
  ;;  (goto-char (point-min))
  ;;  (let(
  ;;       parent
  ;;       parentFn
  ;;       parentToken
  ;;
  ;;       child
  ;;       childFn
  ;;       childToken
  ;;       )
  ;;    (while (n-s "^\\(.*\\)>\\(.*\\) \\([0-9]+\\) \\([0-9]+\\)")
  ;;      (setq
  ;;       parent (n--pat 1)
  ;;       child (n--pat 2)
  ;;       child_offset     (string-to-int (n--pat 3))
  ;;       child_fileNumber (string-to-int (n--pat 4))
  ;;       )
  ;;      (if (string-match ".*!\\(.*\\)" child)
  ;;	  (nclass-browser-load-IC-setting (n--pat 1 child) child))
  ;;
  ;;      (if (string-match ".*!\\(.*\\)" parent)
  ;;	  (nclass-browser-load-IC-setting (n--pat 1 parent) parent)
  ;;	)
  ;;
  ;;
  ;;      (setq nclass-browser-tags (nlist-assoc-unique-add-val child
  ;;							    (cons child_offset child_fileNumber)
  ;;							    nclass-browser-tags)
  ;;	    )
  ;;      (if (not (string= parent ""))
  ;;	  (progn
  ;;	    (setq nclass-browser-parents (nclass-browser-add child parent nclass-browser-parents))
  ;;	    (setq nclass-browser-children (nclass-browser-add parent child nclass-browser-children))
  ;;	    )
  ;;	)
  ;;      )
  ;;    )
  ;;  (kill-buffer nil)
  ;;  (message "done")
  )

(defun nclass-browser-get-parenthesized-expressions-on-individual-lines()
  (save-excursion
    (goto-char (point-min))
    (while (n-s "(")
      (condition-case nil
	  (save-restriction
	    (forward-char -1)
	    (narrow-to-region (point) (progn
					(forward-sexp 1)
					(point)
					)
			      )
	    (goto-char (point-min))
	    (replace-regexp "\n" " ")
	    (goto-char (point-max))
	    )
	(error (forward-line 1)
	       )
	)
      )
    )
  )

(defun nclass-browser-token-to-IC-best-match(fnContext IC-list)
  (require 'ntags-sort)
  (ntags-sort-pick-best-associated-match IC-list
					 'nclass-browser-IC-to-token
					 fnContext
					 )
  )

(defun nclass-browser-is-an-IC(possible-IC)
  (string-match "!" possible-IC)  ;; e.g., c:/j2sdkee1.3.1-src/j2ee/j2ee13/src/share/com/sun/ejb/ejbql/Expression.java!Expression
  )

(defun nclass-browser-get-fnContext()
  (let(
       (bn	(buffer-name))
       )
    (cond
     ((or (string= bn "*scratch*")
	  (eq major-mode 'nlog-mode)
	  )
      nil
      )
     ((buffer-file-name)
      (buffer-file-name)
      )
     (t
      default-directory
      )
     )
    )
  )

(defun nclass-browser-token-to-IC(token &optional fnContext)
  (if (nclass-browser-is-an-IC token)
      token
    (let(
	 (IC-list  (assoc token nclass-browser-assoc-token-to-IC))
	 )
      (if (not IC-list)
	  token
	(setq IC-list (cdr IC-list))
	(cond
	 ((= 1 (length IC-list))
	  (car IC-list)
	  )
	 (t
	  (if (not fnContext)
	      (setq fnContext (nclass-browser-get-fnContext)))

	  (nclass-browser-token-to-IC-best-match fnContext IC-list)
	  )
	 )
	)
      )
    )
  )

(defun nclass-browser-IC-to-string(IC)
  (if (string-match "!\\(.*\\)" IC)
      (n--pat 1 IC)
    IC
    )
  )


(if (not nclass-browser-children)
    (nclass-browser-load))

(defun n-grab-IC()
  "grab the IC (identified class) under point."
  ;;
  ;; for the moment, IC's sometimes start with a file expression which includes a drive letter on PCs, e.g.,
  ;; c:/j2sdkee1.3.1-src/j2ee/j2ee13/src/share/com/sun/ejb/ejbql/Expression.java!Expression
  ;; This can confuse (n-grab-token), but (nfn-grab) is set up not to be thrown off by a leading drive letter:
  (nfn-grab)
  )
