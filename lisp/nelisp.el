(provide 'nelisp)
(setq nelisp-first-run t)
(defun nelisp-mode-meat()
  (setq
   n-comment-boln ";;"
   comment-start ";"
   n-comment-end nil

   ntags-enabled t
   )
  (setq n-complete-leap
        (append (list
                 (list "[^ \t] )"		'forward-char -1))
                n-complete-leap-dft
                )
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	".*/d$"	'n-complete-replace	"/d" "[0-9]@@")
                 (list	".*/s$"	'n-complete-replace	"/s" "[ \\\\t]@@")
                 (list	".*/w$"	'n-complete-replace	"/w" "[0-9a-zA-Z_]@@")
                 (list	"^[ \t]+1$"	'n-complete-replace	"1$"	"(prog1\n@@\n)")
                 (list	".*[^-a-zA-Z0-9\\.]b$"	'n-complete-replace	"b"	"(buffer-substring-no-properties @@)")
                 (list	".*[^-a-zA-Z0-9\\.]c$"	'n-complete-replace	"c"	"(concat @@)")
                 (list	".*[^-a-zA-Z0-9\\.]cc$"	'n-complete-replace	"cc$"	"(current-column)")
                 (list	".*[^-a-zA-Z0-9\\.]CC$"	'n-complete-replace	"CC$"	"(condition-case nil\n@@\n(error @@nil)\n)\n@@")
                 (list	".*[^-a-zA-Z0-9\\.]co$"	'n-complete-replace	"co$"	"(cond\n(@@\n@@)\n)\n@@")
                 (list	"^[ \t]+d$"	'nelisp-data-load nil nil)
                 (list	".*[^-a-zA-Z0-9\\.]dc$"	'n-complete-replace	"dc$"	"(delete-char )")
                 (list	"df$"			'n-complete-df )
                 (list	".*[^-a-zA-Z0-9\\.]e$"	'n-complete-elisp-err)
                 (list	".*[^-a-zA-Z0-9\\.]fc$"	'n-complete-replace	"fc$"	"(forward-char )")
                 (list	".*[^-a-zA-Z0-9\\.]fl$"	'n-complete-replace	"fl$"	"(forward-line )")
                 (list	".*[^-a-zA-Z0-9\\.]fs$"	'n-complete-replace	"fs$"	"(forward-sexp )")
                 (list	".*[^-a-zA-Z0-9\\.]fw$"	'n-complete-replace	"fw$"	"(forward-word )")
                 (list	".*[^-a-zA-Z0-9\\.]g$"	'n-complete-replace	"g$"	"(goto-char @@)")
                 (list	"^[ \t]*g\\.\\.$"	'n-complete-replace	"g..$"	"(goto-char (point-max))@@")
                 (list	"^[ \t]*g\\.a$"	'n-complete-replace	"g..$"	"(nsimple-back-to-indentation)@@")
                 (list	"^[ \t]*g\\.b$"	'n-complete-replace	"g..$"	"(forward-line 0)@@")
                 (list	"^[ \t]*g\\.e$"	'n-complete-replace	"g..$"	"(end-of-line)@@")
                 (list	"^[ \t]*g\\.,$"	'n-complete-replace	"g..$"	"(goto-char (point-min))@@")
                 (list	".*[^-a-zA-Z0-9\\.]i$"	'n-complete-replace	"i$"	"(interactive)\n@@")
                 (list	".*[^-a-zA-Z0-9\\.]le$"	'n-complete-replace	"le$"	"(let(\n(@@)\n)\n@@\n)")
                 (list	"^(setq n-data-menu-nbuf-shortcuts_[^ ]*$"	'n-env-project-make)
                 (list	".*[^-a-zA-Z0-9\\.]kr$"	'n-complete-replace	"kr$"	"(kill-region )")
                 (list	".*[^-a-zA-Z0-9\\.]me$"	'n-complete-replace	"me$"	"(message \"@@\")")
                 (list	".*[^-a-zA-Z0-9\\.]nr$"	'n-complete-replace	"nr$"	"(narrow-to-region @@)")
                 (list	"^p$"			'nelisp-provide	"p$"	nil)
                 (list	".*[^-a-zA-Z0-9\\.]p$"	'n-complete-replace	"p"	"(progn\n@@\n)@@")
                 (list	".*[^-a-zA-Z0-9\\.]pa$"	'n-complete-replace	"pa"	"(point-min) (point-max)@@")
                 (list	".*[^-a-zA-Z0-9\\.]pi$"	'n-complete-replace	"pi"	"(point-min)@@")
                 (list	".*[^-a-zA-Z0-9\\.]px$"	'n-complete-replace	"px"	"(point-max)@@")
                 (list	".*[^-a-zA-Z0-9\\.]pt$"	'n-complete-replace	"pt"	"(point)@@")
                 (list	"^[ \t]+q$"	'nelisp-require nil nil)
                 (list	".*[^-a-zA-Z0-9\\.]r$"	'n-complete-replace	"r$"	"(replace-regexp \"@@\" \"@@\")")
                 (list	".*[\t ]\\([-a-zA-Z0-9]+\\)\\.sc$"	'n-complete-replace	"\\([\t ]\\)\\([-a-zA-Z0-9]+\\)\\.sc"	"\\1(setq \\2 (cdr \\2))\n@@")
                 (list	".*[^-a-zA-Z0-9\\.]se$"	'n-complete-replace	"se$"	"(save-excursion\n@@\n)")
                 (list	".*[^-a-zA-Z0-9\\.]sm$"	'n-complete-replace	"sm$"	"(save-match-data\n@@\n)")
                 (list	".*[^-a-zA-Z0-9\\.]sr$"	'n-complete-replace	"sr$"	"(save-restriction\n@@\n)")
                 (list	".*[^-a-zA-Z0-9\\.]sw$"	'n-complete-replace	"sw$"	"(save-window-excursion\n@@\n)")
                 (list	"^[ \t]*t$"	'n-complete-add-trace)
                 (list	".*[^-a-zA-Z0-9\\.]w$"	'n-complete-replace	"w$"	"(while (@@)\n@@\n)")
                 (list	".*[^-a-zA-Z0-9\\.]wi$"	'n-complete-replace	"wi$"	"(widen)\n@@")
                 (list	".*[\t ]\\([-a-zA-Z0-9]+\\)\\.d$"	'n-complete-replace	"\\([\t ]\\)\\([-a-zA-Z0-9]+\\)\\.d"	"\\1(cdr \\2) ")
                 (list	".*[\t ]\\([-a-zA-Z0-9]+\\)\\.a$"	'n-complete-replace	"\\([\t ]\\)\\([-a-zA-Z0-9]+\\)\\.a"	"\\1(car \\2) @@")
                 (list	".*[^-a-zA-Z0-9\\.]dr$"	'n-complete-replace	"dr$"	"(delete-region )")
         )
        )
        )
  (if nelisp-first-run
      (progn
	(nelisp-define-key "	" 'n-complete-leap)
	(nelisp-define-key " " 'n-complete-or-space)
	(nelisp-define-key "\C-a" 'nsimple-back-to-indentation)
	(nelisp-define-key "\C-c\C-e" 'nelisp-compile-defun)
	(nelisp-define-key "\C-j" 'nelisp-join-lines)
	(nelisp-define-key "\C-m" 'nelisp-newline-and-indent)
	(nelisp-define-key "\C-x " 'nelisp-toggle-bp)
	(nelisp-define-key "\C-xB" 'nkeys-interactive-bind)
	(nelisp-define-key "\C-xC" 'nlog-lisp)
	(nelisp-define-key "\C-x\C-b" 'nelisp-trace-func)
	(nelisp-define-key "\C-x\C-e" 'eval-last-sexp)
	(nelisp-define-key "\C-x\C-i" 'ntrc-func)
	(nelisp-define-key "\C-xe" 'eval-region)
	(nelisp-define-key "\C-xo" 'nelisp-optionalize)
	(nelisp-define-key "\M-" 'nelisp-domain-replace-regexp-query) ; same as m-c-5 on ncd
	(nelisp-define-key "\M-" 'nelisp-domain-replace-regexp) ; same as m-c-7 on ncd
	(nelisp-define-key "\M-'" 'nelisp-2-lines)
	(nelisp-define-key "\M-;" 'nm-end)
	;;(nelisp-define-key "\M-/" 'n-comment-routine)
	(nelisp-define-key "\M-\C-d" 'nelisp-makeDefun)
        (nelisp-define-key "\M-\C-h" 'nmidnight-ext-choose)
        (if (boundp 'completion-at-point)
            (nelisp-define-key "\M-\t" 'completion-at-point)
          (nelisp-define-key "\M-\t" 'lisp-complete-symbol)
          )
        (nelisp-define-key "\M-c" 'nelisp-compile)
	(nelisp-define-key "\M-q" 'nbuf-kill-current)
	(nelisp-define-key "\M-%" 'nre-query-replace)
	(nelisp-define-key "\M-\C-a" 'nelisp-grap)
	(nelisp-define-key "\M-\C-q" 'n-env-grep-goto)
	(nelisp-define-key "\M-\C-x" 'nsimple-compare-windows)
	(nelisp-define-key "" 'nsimple-backward-delete-char-untabify)
  	(setq nelisp-first-run nil)
	)
    )
  )

                                        ; code to support interactive lisp mode
(setq nelisp-hots (list
                   (list "\C-s" "(n-s \"\")\n" -3)
                   (list "\C-r" "(n-r \"\")\n" -3)
                   (list "\C-f" "(forward-char )\n" -2)
                   (list "\C-d" "(delete-char )\n" -2)
                   (list "\C-w" "(delete-region )\n" -2)
                   (list "\C-x\C-f" "(find-file )\n" -2)
                   (list "\C-x\C-k" "(delete-file )\n" -2)
                   (list "\M-q" "(nbuf-kill-current)\n" 0)
                   )
      )

(setq nelisp-hots-active t)		 ; init will toggle it back

(defun nelisp-key( node)
  (car node))

(defun nelisp-text( node)
  (cadr node))

(defun nelisp-offset( node)
  (caddr node))

(defun nelisp-hots-toggle()
  "toggle personal interactive lisp hot keys"
  (interactive)
  (use-local-map
   (if (setq nelisp-hots-active (not nelisp-hots-active))
       nelisp-hot-map
     lisp-interaction-mode-map
     )
   )
  (nelisp-hot-mode-tell)
  )

(defun nelisp-hot-mode-tell()
  (message "elisp hotkeys %s" (if nelisp-hots-active "on" "off")))

(defun nelisp-hot-comp()
  "called when a hotkey is hit in lisp interactive mode.  inserts
appropriate text (from nelisp-hots) corresponding to the key that was hit"
  (interactive)
  (if nelisp-hots-active
      (let(
           (node	(assoc (this-command-keys) nelisp-hots))
           offset
           text
           )
        (insert (nelisp-text node))
        (forward-char (nelisp-offset node))
        (lisp-indent-line)
        )
    )
  )

(setq nelisp-hot-map nil)

(defun nelisp-init()
  (define-key lisp-interaction-mode-map "\M-t" 'nelisp-hots-toggle)
                                        ;  (define-key lisp-interaction-mode-map "\M-c" 'eval-print-last-sexp)
                                        ;  (define-key lisp-interaction-mode-map "\M-\C-c" 'n-eval-exp-other-window)
                                        ;  (define-key lisp-interaction-mode-map "\M-\C-_" 'nelisp-domain-replace-regexp)	; same as m-c-7 on ncd
  (define-key lisp-interaction-mode-map "\M-\C-]" 'nelisp-domain-replace-regexp-query)	; same as m-c-5 on ncd
  
  (setq nelisp-hot-map (copy-keymap lisp-interaction-mode-map))
  
  (let(
       (hots	nelisp-hots)
       node
       key
       )
    (while hots
      (setq node	(car hots)
            hots	(cdr hots)
            key	(nelisp-key node))
      (define-key nelisp-hot-map key 'nelisp-hot-comp
        )
      )
    )
  (nelisp-hots-toggle)
  )

(defun nelisp-compile()
  (interactive)
  
  (let(
       (isData (string-match "^n-data-menu-" (nfn-prefix)))
       )
    (if isData
        (n-env-use-var-names t))
    
    (save-excursion
      (save-window-excursion
        (save-some-buffers t)
        )
      (if (string= "*scratch*" (buffer-name))
          (n-scratch-compile)
        (n-indent-region)  ;; too jumpy on e23
        (nelisp-load-file)
        )
      (if isData
          (exit-recursive-edit))
      )
    )
  )
(defun nelisp-load-file(&optional fn)
  (interactive)
  (if (not fn)
      (progn
        (setq fn	(buffer-file-name))
        (save-buffer)
        )
    )
  (let(
       compiledFn
       )
    (setq compiledFn (concat fn "c"))
    (if (file-exists-p compiledFn)
        (delete-file compiledFn))
    (load-file fn)
    )
  )

(defun nelisp-2-lines-expand-menu-cons(arg)
  ;; we are working with something that looks like a list
  ;; intended for use by the nmenu package.
  ;;
  ;; If arg, then a subcategory is desired.
  (cond
   (arg
    (n-2-lines)
    (forward-line -1)
    (n-s "\\?. " t)
    (delete-region (point) (progn
			     (end-of-line)
			     (point)
			     )
		   )
    (insert "(list\n")
    (insert "\"\"")
    (n-s "\\?" t)
    (n-loc-push)
    (nelisp-2-lines)
    (insert "@@")                       ; replace the colons lost by the leap
    (forward-line 1)
    (insert ")\n")
    (insert ")\n")
    (save-excursion
      (n-loc-pop)
      (delete-char 1)
      (insert "@@")
      )
    (n-indent-region2 (point) (progn
				(forward-sexp -1)
				(point)
				)
		      nil
		      )
    (n-complete-leap)
    )
   (t
    (n-2-lines)
    (forward-line 0)
    (n-s "\\?" t)
    (delete-char 1)
    (insert "@@")
    (forward-char 1)
    (cond
     ((looking-at "\".*/.*\")$")	;; doubling file path?  Rm file from path in line #2
      (end-of-line)
      (n-r "/" t)
      (delete-region (progn
		       (forward-char 1)
		       (point)
		       )
		     (progn
		       (n-s "\"" t)
		       (forward-char -1)
		       (point)
		       )
		     )
      (nfly-read-fn-to-replace-region (point) (progn
                                                (n-r "\"" t)
                                                (forward-char 1)
                                                (point)
                                                )
                                      )
      )
     ((looking-at "\".*\")$")
      (delete-region (point) (progn
			       (end-of-line)
			       (point)
			       )
		     )
      (insert "\"@@\")")
      )
     (t
      (delete-region (point) (progn
			       (end-of-line)
			       (point)
			       )
		     )
      (insert "@@)")
      )
     )
    (forward-line 0)
    (n-complete-leap)
    )
   )
  )
(defun nelisp-2-lines-increment-n--pat-call(n--pat-arg)
  (n-2-lines)
  (nsimple-back-to-indentation)
  (n-s "[-a-zA-Z0-9]" t)	; get to the token being set by the first n--pat call
  (forward-char -1)
  (delete-region (point) (progn
			   (n-s "(n--pat" t)
			   (n-r "[^ \t][ \t]+(" t)
			   (forward-char 1)
			   (point)
			   )
		 )
  (insert "@@")
  (n-s "(n--pat " t)
  (delete-region (point) (progn
			   (n-s "[^0-9]" t)
			   (forward-char -1)
			   (point)
			   )
		 )
  (insert (int-to-string (1+ n--pat-arg)))
  (forward-line 0)
  (n-complete-leap)
  )

(defun nelisp-2-lines( &optional arg)
  (interactive "P")
  (save-match-data
    (require 'n-2-lines)
    (cond
     ((save-excursion
        (forward-line 0)
        (looking-at "(setq n-data-menu-nbuf-shortcuts_")
        )
      (nelisp-2-lines-create-empty-nbuf-shortcuts-list)
      )
     ((save-excursion
        (forward-line 0)
        (looking-at "[\t ]*(cons \\?")
        )
      (nelisp-2-lines-expand-menu-cons arg)
      )
     ((save-excursion
        (forward-line 0)
        (looking-at ".*\\b\\([-_a-zA-Z0-9]+\\)[ \t]+(n--pat \\([0-9]+\\)")
        )
      (nelisp-2-lines-increment-n--pat-call (string-to-int (n--pat 2)))
      )
     (t
      (call-interactively 'n-2-lines)
      )
     )
    )
  )
(defun nelisp-evaluate-string(string)
  (save-window-excursion
    (n-tmpBuf)
    (insert "(setq nelisp-evaluate-string " string ")")
    (let(
         nelisp-evaluate-string
         )
      (eval-region (point-min) (point-max))
      nelisp-evaluate-string
      )
    )
  )
(defun nelisp-restructure-to-loop-with-arg-as-its-control-var()
  (let(
       (fun	(n-defun-name))
       )
    (narrow-to-region (progn
                        (nc-beginning-of-defun)
                        (point)
                        )
                      (progn
                        (forward-sexp 1)
                        (point)
                        )
			)
      (goto-char (point-min))
      (n-s "(interactive" t)
      (forward-line 1)
      (insert "  (if (integerp arg)
      (while (> arg 0) (" fun ") (setq arg (1- arg)))\n")
      )
  (goto-char (point-max))
  (insert "\n)")
  (indent-region (point) (progn
                           (goto-char (point-min))
                           (point)
                           )
                 nil
                 )
  (widen)
  )

(defun nelisp-optionalize( &optional arg)
  "go to prceding defun and convert it to an option-taking cmd
if arg: see iter"
  (interactive "P")
  (n-r "^(defun" t)
  (if (not (looking-at "(defun [-a-zA-Z0-9]+()"))
      (error "not a simple func"))
  (if (not (looking-at "(defun [-a-zA-Z0-9]+([ \t]*&optional argument ?)"))
      (progn
        (n-s "()")
        (forward-char -1)
        (insert " &optional arg")
        (forward-line 1)
        (skip-chars-forward " \t\n")
        (n-skip-str)                    ; advance past doc string
        (if  (looking-at "[ \t]*$")
            (forward-line 1))
        (if (not (looking-at "[ \t]*(interactive)"))
            (progn
              (insert "  (interactive)\n")
              (forward-line -1)
              )
          )
        (n-s ")")
        (forward-char -1 )
        (insert " \"P\"")
        )
    )
  (if arg
      (progn
        (narrow-to-region (progn
                            (forward-line 0)
                            (point)
                            )
                          (progn
                            (end-of-line)
                            (point)
                            )
                          )
        (forward-line 0)
        (replace-regexp " \"P\"" " \"p\"")
        (widen)
        (nelisp-restructure-to-loop-with-arg-as-its-control-var)
        )
    )
  )

(defun nelisp-makeDefun( &optional arg)
  (interactive "P")
  (if arg
      (nsimple-downcase-word)
    (save-restriction
      (let(
	   (loc	(point-marker))
	   functionName
	   invocation
	   )
	(save-excursion
	  (n-r "['(]" t)
	  (if (looking-at "'")
	      (setq functionName (progn
				   (forward-char 1)
				   (n-grab-token)
				   )
		    )
	    (setq invocation (buffer-substring-no-properties (point)
                                                             (progn
                                                               (forward-sexp 1)
                                                               (point)
                                                               )

                                                             )
		  )
	    )
	  )
	(setq nsimple-yanker 'nsimple-yanker-and-leaper)
	(narrow-to-region (point) (point))
	(insert "(defun ")
	(if functionName
	    (progn
	      (insert functionName "()\n  @@\n)\n")
	      )
	  (insert invocation "\n  @@\n  )\n")
	  (goto-char (point-min))
	  (n-s "(defun " t)
	  (delete-char 1)  ; delete '(' before routine name
	  (n-s "[^-a-z0-9A-Z_]" t)  ; advance past routine name
	  (forward-char -1)
	  (if  (looking-at " ")
	      (delete-char 1))
	  (insert "(")
	  )
	(kill-region (point-min) (point-max))
	(message "defun in kill")
	)
      )
    )
  )
(defun nelisp-define-key( key func)
  (define-key emacs-lisp-mode-map key func)
  (define-key lisp-interaction-mode-map key func)
  )
(defun nelisp-grap( &rest args )
  "n-env-grep on the token under point in the n.*.el"
  (interactive "P")
  (n-loc-push)
  (if (or
       (string= (buffer-name) "*compilation*")
       (string-match "\\*gdb-" (buffer-name))
       )
      (call-interactively 'n-env-grap-meat)
    (apply 'nelisp-domain-func 'n-env-grap-meat args))
  )

(defun nelisp-domain-replace-regexp()
  (interactive)
  (nelisp-domain-func 'n-env-domain-replace-regexp))

(defun nelisp-domain-replace-regexp-query()
  (interactive)
  (nelisp-domain-func 'n-env-domain-replace-regexp-query))

(defun nelisp-domain-func( func &rest args)
  "execute FUNC after resetting the domain to my elisp files"
  (let(
       (n-env			"lisp")
       (n-grab-token-chars           "-a-z0-9A-Z")
       )
    (call-interactively func)
    )
  )

(setq nelisp-bp-indentation "")

(defun nelisp-bp( functionName &optional file_name line_number indentDelta)
  (let(
       (n-trace-slow nil)  ;; to avoid infinite recursion
       )
    ;;(n19-bisect-sees-failure)
    (save-excursion
      (if (and (integerp indentDelta) (equal indentDelta -1))
          (setq nelisp-bp-indentation (nstr-chop nelisp-bp-indentation)))
      (n-trace (concat nelisp-bp-indentation
                       "bp "
                       functionName
                       (if file_name
                           (concat "(" file_name ":" (int-to-string line_number) ")")
                         ""
                         )
                       ": ^R-recursive, e-edit, s-tack"
                       )
               )
      (let(
           (elisp-bp-cmd (read-char))
           )
        (cond
         ((= elisp-bp-cmd 18)		; ^R
          (save-excursion
            (recursive-edit))
          )
         ((= elisp-bp-cmd ?e)
          (save-excursion
            (n-file-find file_name)
            (goto-line line_number)
            (recursive-edit))
          )
         ((= elisp-bp-cmd ?s)
          (error "nelisp-bp: show stack")
          )
         )
        (message "")
        )
      (if (and (integerp indentDelta) (equal indentDelta 1))
          (setq nelisp-bp-indentation (concat nelisp-bp-indentation " ")))
      )
    )
  t
  )

(defun nelisp-trace-func(&optional x)
  (interactive)
  (beginning-of-defun)
  (let(
       (args (nstr-split
	      (nstr-replace-regexp
	       (buffer-substring-no-properties (progn
                              (n-s "(" t)
                                                 (n-s "(" t)
				   (point)
				   )
				 (progn
				   (n-s ")" t)
				   (forward-char -1)
				   (point)
				   )
				 )
	       "&[a-zA-Z]*"
	       ""
	       )
	      )
	     )
       (argS "")
       (argSSubs "")
       )
    (while args
      (if (not (string= argS ""))
	  (setq argS (concat argS ",")))
      
      (setq argS (concat argS (car args) ":%s")
	    argSSubs (concat argSSubs " (prin1-to-string " (car args) ")")
	    args (cdr args)
	    )
      )

    (forward-line 1)
    (insert (concat "  (n-trace \"" (n-defun-name) "(" argS ")\"" argSSubs ")\n"))
    )
  )

(defun nelisp-toggle-bp( &optional arg)
  (interactive "P")
  (cond
   (arg
    (if (y-or-n-p "rm all bp's in current file? ")
	(save-excursion
	  (goto-char (point-min))
	  (while (n-s "^[ \t]*(nelisp-bp.*;;;;;;;;;;;;;;")
	    (nsimple-delete-line)
	    )
	  )
      )
    )
   (t
    (forward-line 0)
    (if (looking-at " (nelisp-bp")
	(nsimple-kill-line)
      (progn
	(insert
	 (format " (nelisp-bp \"%s\" \"%s\" %d);;;;;;;;;;;;;;;;;\n"
		 (n-defun-name)
		 (buffer-name)
		 (n-what-line)
		 )
	 )
	(forward-char 1)
	)
      )
    )
   )
  )

(defun nelisp-generate-e_-files()
  (interactive)
  "refresh ef, ev (lists of all ELISP functions and variables)"
  (nelisp-generate-e_-file "ef" 'fboundp)
  (nelisp-generate-e_-file "ev" 'boundp)
  )

(defun nelisp-generate-e_-file( fn pred)
  (n-file-find (concat "$dp/emacs/lisp/" fn))
  (nbuf-kill-current)
  
  (if (get-buffer "*n-output*")
      (kill-buffer "*n-output*"))
  (with-output-to-temp-buffer "*n-output*"
    (let(
         (func	pred)
         )
      (mapatoms '(lambda( obj)
                   (if (and (symbolp func)
                            (funcall func obj)
                            )
                       (progn
                         (prin1 obj)
                         (prin1 "\n")
                         )
                     )
                   )
                )
      )
    )
  (set-buffer "*n-output*")
  (toggle-read-only)
  (goto-char (point-min))
  (replace-regexp "\"" "")
  (sort-lines nil (point-min) (point-max))
  (if (string= "ef" fn)
      (progn
        (goto-char (point-min))
        (replace-regexp "^" "(")
        )
    )
  (write-file (n-host-to-canonical (concat "$dp/emacs/lisp/" fn)))
  )
(defun nelisp-newline-and-indent()
  (interactive)
  (cond
   ((n-complete-abbrev)
    (nsimple-newline-and-indent)
    )
   ((save-excursion
      (nsimple-back-to-indentation)
      (looking-at "[-A-Z0-9a-z]+[ \t][-A-Z0-9a-z\t ]+$")
      )
    (save-restriction
      (n-narrow-to-line)
      (nsimple-back-to-indentation)

      (insert "(")
      (replace-regexp " " "-")
      (forward-line 0)
      (replace-regexp "\t" " ")
      (end-of-line)
      (insert ")")
      )
    )
   (t (nsimple-newline-and-indent))
   )
  )

(defun nelisp-scratch-init( &optional arg)
  (interactive "P")
  (if (string= "*scratch-text*" (buffer-name))
      (find-file (n-host-to-canonical "$dp/todo"))
    (let(
         data
         begin
         end
         (func (condition-case nil
                   (n-defun-name)
                 (error nil)
                 )
               )
         )
      (if (and arg (string= "midnight" (file-name-nondirectory (buffer-file-name))))
          (progn
            (setq begin  (progn
                           (goto-char (point-min))
                           (forward-line 1)
                           (point)
                           )
                  data (buffer-substring-no-properties begin (point-max))
                  )
            (delete-region begin (point-max))
            )
        )

      (switch-to-buffer-other-window
       (if (not (get-buffer "*scratch-text*"))
           (save-window-excursion
             (n-file-find (concat "$dp/emacs/scratch." n-local-world-name))
             (nbuf-post-for-kill 'save-buffer)
             (rename-buffer "*scratch-text*")
             )
         (get-buffer "*scratch-text*")
         )
       )
      (if data
          (progn
            (delete-region (point-min) (point-max))
            (insert data)
            )
        )
      )
    )
  )

(defun nelisp-goto-key-func()
  (interactive)
  (let(
       (key	(progn
                  (read-key-sequence "hit key combination whose function will be browsed:")
                  )
                )
       func
       name
       )
    (setq func 	(nkeys-binding key)
	  name	(n--get-lisp-func-name func)
	  )
    (save-window-excursion	; kluge to force it to use LISP database
      (nelisp-scratch-init)

      (require 'ntags-find)
      (ntags-find-where-is-defn name)

      (bury-buffer)
      )
    )
  )
;;(defun nelisp-goto-function-source()
;;  (interactive)
;;  (let(
;;       (name	(completing-read "Goto source of ELISP func: " obarray 'fboundp t))
;;       )
;;    (save-window-excursion	; kluge to force it to use LISP database
;;      (nelisp-scratch-init)
;;      (ntags-find-where-is-defn name)
;;      )
;;    )
;;  )

;;(defun nelisp-external()
;;  (if (file-exists-p "$dp/emacs/lisp/tmp.el"))
;;      (save-window-excursion
;;        (set-buffer (find-file-noselect (n-host-to-canonical "$dp/emacs/lisp/tmp.el")))
;;        (eval-region (point-min) (point-max))
;;        (n-file-delete-cmd)
;;        )
;;    )
;;  )

(defun nelisp-compile-defun()
  (interactive)
  (save-excursion
    (nc-beginning-of-defun)
    (forward-sexp 1)
    (eval-last-sexp nil)
    )
  (save-buffer)
  )
(defun nelisp-provide(before after)
  (forward-line 0)
  (if (looking-at "p$")
      (delete-char 1))
  (insert "(provide '" (nfn-prefix) ")\n")
  )
(defun nelisp-file-copied-hook(oldFileName newFileName)
  (goto-char (point-min))
  (if (n-s "^(provide '$")
      (progn
	(forward-line 0)
	(delete-region (point) (progn
				 (end-of-line)
				 (point)
				 )
		       )
	(nelisp-provide)
	)
    )
  (let(
       (oldModuleName (nfn-prefix oldFileName))
       (newModuleName (nfn-prefix newFileName))
       )
    (goto-char (point-min))
    (replace-regexp oldModuleName newModuleName)
    )
  )
(defun nelisp-require(&rest unused)
  (nsimple-back-to-indentation)
  (if (looking-at "q$")
      (delete-char 1))

  (let(
       (guess "n")
       )
    (save-excursion
      (save-restriction
	(widen)
	(forward-line 1)
	(if (or (looking-at "[ \t]*(setq .*(\\(n[^ \t)]+\\)")
		(looking-at "[ \t]*(\\(n[^ \t)]+\\)")
		)
	    (setq guess (n--pat 1))
	  )
	)
      )
    (insert "(require '" guess ")")
    (forward-line 0)
    (forward-word 2)
    )
  )
(defun nelisp-data-load(&rest unused)
  (nsimple-back-to-indentation)
  (if (looking-at "d$")
      (delete-char 1))
  
  (let(
       (guess "n-data-")
       )
    (save-excursion
      (save-restriction
	(widen)
	(forward-line 1)
	(if (or (looking-at ".*\\(\\bn-data-[-a-zA-Z0-9]+\\)")
		(looking-at ".*\\(\\bnsql-[-a-zA-Z0-9]+\\)")
		)
 	    (setq guess (n--pat 1))
	  )
	)
      )
    (insert "(n-database-load \"" guess "\")")
    (forward-line 0)
    (forward-word 5)
    )
  )
(defun nelisp-join-lines()
  (interactive)
  (if (save-excursion
	(forward-line 0)
	(looking-at "[ \t]*)$")
	)
      (progn
	(forward-line 1)
	(nsimple-transpose-lines)
	(forward-line -1)
	(n-open-line)
	)
    (nsimple-join-lines)
    )
  )
(defun nelisp-fetch-local-names-from-let(names)
  (if (not (n-s "^[ \t]*(let($"))
      (goto-char (point-max))
    (save-restriction
      (narrow-to-region (save-excursion
			  (forward-line 1)
			  (point)
			  )
			(progn
			  (forward-char -1)
			  (forward-sexp 1)
			  (forward-char -1)
			  (point)
			  )
			)
      (goto-char (point-min))
      (while (not (eobp))
	(nsimple-back-to-indentation)
	(cond
	 ((looking-at "\\([-_a-zA-Z0-9]+\\)")
	  (setq names (cons (n--pat 1) names))
	  )
	 ((looking-at "(\\([-_a-zA-Z0-9]+\\)")
	  (setq names (cons (n--pat 1) names))
	  (forward-sexp 1)
	  )
	 (t
	  (goto-char (point-max))
	  )
	 )
	(forward-line 1)
	(end-of-line)
	)
      )
    )
  names
  )
(defun nelisp-fetch-local-names()
  (save-restriction
    (narrow-to-region (point)
		      (progn
			(n-r "^(")
			(point)
			)
		      )
    
    (let(
	 names
	 )
      (if (looking-at "(defun [-_a-zA-Z0-9]+(\\(.*\\))")
	  (setq names (nstr-split (n--pat 1))))
      (while (not (eobp))
	(setq names (nelisp-fetch-local-names-from-let names))
	)
      names
      )
    )
  )
(defun nelisp-intern-uninterned-local-names()
  (let(
       (locals (nelisp-fetch-local-names))
       added-locals
       local
       internSoft
       sym
       )
    (while locals
      (setq local  (car locals)
	    locals (cdr locals)
	    internSoft (intern-soft local)
	    )
      (if (or (not internSoft)
	      (not (boundp internSoft))
	      )
	  (progn
	    (setq sym (intern local)
		  added-locals (cons local added-locals)
		  )
	    (nstr-eval "(setq %s 5)" local)
	    )
	)
      )
    added-locals
    )
  )
(defun nelisp-unintern(names)
  (while names
    (setq name  (car names)
	  names (cdr names)
	  )
    (unintern name)
    )
  )

(defun nelisp-complete-symbol()
  nil)
(defun n-x8()
  (interactive)
  (if (get-buffer "*Completions*")
      (kill-buffer "*Completions*"))
  (let(
       (oldPt (point))
       done
       char
       (added-locals (nelisp-intern-uninterned-local-names))
       )
    (save-window-excursion
      (setq done (call-interactively 'lisp-complete-symbol))
      (setq done (call-interactively 'lisp-complete-symbol))
      )
    (if (= oldPt (point))
	(progn
	  (message "completion added nothing (nelisp.el:1004)")
	  (insert " ")
	  t
	  )
      (if (not (get-buffer "*Completions*"))
	  (progn
	    (message "")
	    t
	    )
	(insert " ")
	(message "data already inserted; SPC to see *Completions*")
	(setq char (read-char))
	(cond
	 ((eq char ? )
	  (save-window-excursion
	    (delete-char -1)
	    (nsimple-show-buffer "*Completions*")
	    (message "enter char to choose from completes...")
	    (setq char (read-char))
	    (if (or (<= char 26) (>= char 256))
		(n-ungetc char)
	      (insert char)
	      (n-complete-symbol)
	      )
	    )
	  )
	 (t
	  ;;(setq oldP
	  (n-ungetc char)
	  )
	 )
	)
      )
    (nelisp-unintern added-locals)
    )
  )

(defun nelisp-get-lisp-invocation-from-help-window()
  (other-window 1)
  (goto-char (point-min))

  (or (and (n-s "(call-interactively")
           (n-s "(quote" t)
           )
      (n-s "runs the command" t)
      (n-s "interactive" t)
      )
  ;; use forward-word in case we need to cross to the next line, e.g., w/:
  ;; M-j runs the command (lambda nil (interactive) (if nil (require nil))
  ;; (setq this-command (quote n-other-window)) (call-interactively (quote
  ;; n-other-window))), which is an interactive Lisp function.

  (forward-word 1)
  (forward-word -1)
  (skip-chars-forward " ")
  (let(
       (op (n-grab-token))
       )
    (n-other-window)
    (forward-line 1)
    (insert "(" op "@@)\n")
    )
  (forward-line -1)
  (delete-other-windows)
  (indent-according-to-mode)
  (end-of-line)
  (insert "\n\t@@")
  (indent-according-to-mode)
  (forward-line -1)
  (n-complete-leap)
  )
(defun nelisp-help( token)
  (let(
       (tt	(intern token))
       )
    (condition-case nil
        (progn
          (with-output-to-temp-buffer "*Help*"
            (prin1 tt)
            (princ ":
")
            (if  (documentation tt)
                (princ (documentation tt)))
            )
          )
      (error (message "nelisp-help: no information for %s" token))
      )
    )
  )
(defun nelisp-assert-looking-at(regexp)
  (or (looking-at regexp)
      (error "nelisp-assert-looking-at: expected to see %s" regexp))
  )
(defun nelisp-assert-looking-behind(regexp)
  (save-excursion
    (forward-char (- (length regexp)))
    (nelisp-assert-looking-at regexp)
    )
  )
(defun nelisp-2-lines-create-empty-nbuf-shortcuts-list()
  (forward-line 0)
  (forward-sexp 1)
  (n-loc-push)
  (insert "\n(setq n-data-menu-nbuf-shortcuts_@@
        (append
         n-data-menu-nbuf-shortcuts-common
        (list
         (cons ?@@ \"@@\")
         )
)
)
")
  (n-loc-pop)
  (n-complete-leap)
  (call-interactively 'n-indent-region)
  )
