(provide 'nre)
(setq search-exit-option t)

(defun nre-is-current-line-in-other-buffer()
  (save-window-excursion
    (let(
	 (line (n-get-line))
	 )
      (other-window 1)
      (save-excursion
	(goto-char (point-min))
	(n-s line)
	)
      )
    )
  )
(defun nre-similar-consecutive()
  (n-s "^\\([^\n]+\\).\n\\1.\n" t)
  )

(defun nre-isearch-hook()
  (nkeys-define-key isearch-mode-map "\C-w" 'nsimple 'nsimple-search-command-kill-region)
  (nkeys-define-key isearch-mode-map "\C-y" 'nsimple 'nsimple-search-command-yank)
  (nkeys-define-key isearch-mode-map "\C-z" nil 'isearch-yank-word)
  (nkeys-define-key isearch-mode-map "\M-z" nil 'isearch-yank-line)
  )

(if n-is-xemacs
    (progn
      ;;(remove-hook 'isearch-mode-hook 'nre-isearch-hook)
      ;;(add-hook 'isearch-mode-hook 'nre-isearch-hook)
      )
  (setq search-delete-char ?\C-h)
  (setq search-quote-char ?\C-\\)
  )


(defun nre-search( &optional arg )
  (interactive "P")

  (if n-is-xemacs
      (progn
        (push-mark)
        )
    )

  (if (not arg)
      (call-interactively 'isearch-forward-regexp)
    (let(
         (command (progn
                    (message "cC^C-omplain if line in other buf, s-imilar consecutive, d-uplicate-key, n-re-mode, p-perl-regexp-to-emacs")
                    (read-char)
                    )
                  )
         )
      (cond
       ((eq command ?c)
        (if (nre-is-current-line-in-other-buffer)
            (forward-line 1)
          (message "Didn't see it. ['C' cycles across all lines, ^C deletes all lines in other buffer.  -Nelson]")
          )
        )
       ((eq command ?C)
        (while (not (eobp))
          (if (nre-is-current-line-in-other-buffer)
              (error "nre-search: line is in other buffer")
            (forward-line 1)
            (end-of-line)
            )
          )
        )
       ((eq command ?)
        (while (not (eobp))
          (if (nre-is-current-line-in-other-buffer)
              (nsimple-delete-line 1)
            (forward-line 1)
            (end-of-line)
            )
          )
        )
       ((eq command ?d)
        (nsql-find-duplicate-key)
        )
	 ((eq command ?n)
	  (n-loc-push)
	  (call-interactively 'nre-mode)
	  )
	 ((eq command ?p)
	  (save-restriction
	    (save-excursion
	      (narrow-to-region (progn
				  (forward-line 0)
				  (n-s "\"" t)
				  (point)
				  )
				(progn
				  (end-of-line)
				  (n-r "\"" t)
                                  (point)
                                  )
                                )
              (nre-perl-to-emacs)
              )
            )
          )
	 ((eq command ?s)
	  (nre-similar-consecutive)
	  )
         )
        )
    )
  )

(defun nre-make-pattern(pattern)
  "double backslashes to make PATTERN acceptable for pattern matching.
Especially useful when working with PC file names"
  (setq pattern (nstr-replace-regexp pattern "\\\\" "\\\\\\\\"))
  (setq pattern (nstr-replace-regexp pattern "\\*" "\\\\*"))
  pattern
  )

(defun nre-rm-garnish()
  (goto-char (point-min))
  (require 'n-prune-buf)
  (n-prune-buf "^\\^")
  )

(setq nre-mode-map nil)

(defun nre-mode( beg end)
  (interactive "r")
  (let(
       (data	(buffer-substring-no-properties beg end))
       (nreBuf	(get-buffer  "*nre*"))
       )
    (switch-to-buffer (if nreBuf
                          (if (y-or-n-p "zap existing *nre* buf?")
                              (n-zap "*nre*")
                            (error "*nre* buf already in use"))
                        (get-buffer-create "*nre*")
                        )
                      )
    (insert "\n" nsimple-BORDER data "\n" nsimple-BORDER)
    )
  (goto-char (point-min))
  
  (setq major-mode 'nre-mode)
  (setq mode-name "regexp debug mode")
  (if (not nre-mode-map)
      (progn
        (setq nre-mode-map (copy-keymap emacs-lisp-mode-map))
        (define-key nre-mode-map "\M-c" 'nre-tst)
        (define-key nre-mode-map "\M-w" 'nre-white)
        (define-key nre-mode-map "\M-t" 'nre-token)
        )
    )
  (use-local-map nre-mode-map)
  )

(defun nre-white()
  (interactive)
  (insert "[\t\n]+")
  )

(defun nre-token()
  (interactive)
  (insert "[_a-zA-Z0-9]+")
  )

(defun nre-get-pat1()
  (eval
   (buffer-substring-no-properties (progn
                       (goto-char (point-min))
                       (point)
                       )
                     (progn
                       (if (n-sv (list
                                  (list "/")
                                  (list nsimple-BORDER)
                                  )
                                 "cannot find end of pat1"
                                 )
                           (progn
                             (forward-line -2)
                             (end-of-line)
                             (point)
                             )
                         )
                       )
                     )
   )
  )
(defun nre-get-pat2()
  (goto-char (point-min))
  (if (not (n-s "^/$"))
      nil
    (buffer-substring-no-properties (progn
                        (forward-line 1)
                        (point)
                        )
                      (progn
                        (n-s nsimple-BORDER t)
                        (forward-line -2)
                        (end-of-line)
                        (point)
                        )
                      )
    )
  )

(defun nre-get-search-data()
  (buffer-substring-no-properties (progn
                      (goto-char (point-min))
                      (n-s nsimple-BORDER t)
                      (point)
                      )
                    (progn
                      (goto-char (point-max))
                      (forward-line -1)
                      (point)
                      )
                    )
  )

(defun nre-tst( &optional arg)
  (interactive)
  (execute-kbd-macro
   [?\M-, ?\C-k ?\C-_ ?\C-n ?\C-n ?\C-s ?\C-m ?\C-y return])
  )

(defun nre-add-ptr()
  (let(
       (col	(current-column))
       )
    (end-of-line)
    (insert "\n" (make-string col ?^))
    )
  )

(defun nre-dump()
  (let(
       (msg	"")
       (patNo	1)
       )
    (while (match-beginning patNo)
      (setq msg (concat msg "'" (nre-pat patNo) "' ")
            patNo	(1+ patNo)
            )
      )
    (message "%s" msg)
    )
  )

;;(defun nre-prep-for-elisp(pat)
;;  (nstr-buf pat '(lambda()
;;                   (goto-char (point-min))
;;                   (replace-regexp "\n" "\\\\n")
;;                   (goto-char (point-min))
;;                   (replace-regexp "\\\\" "\\\\\\\\")
;;                   (buffer-substring-no-properties (point-min) (point-max))
;;                   )
;;            )
;;  )
(defun nre-looking-at-no-regexp(string)
  (let(
       (patternEnd	(+ (point) (length string)))
       )
    (if (> patternEnd (point-max))
        nil
      (string= string (buffer-substring-no-properties (point) patternEnd))
      )
    )
  )
                                        ;(nre-perl-to-emacs "\\.\\./")
                                        ;(nre-perl-to-emacs "\\|")
(defun nre-perl-to-emacs(&optional s)
  "translate perl regular expression STRING to an emacs regular expression.
If no argument, convert the nearest string in the current line of emacs-lisp code"
  (if s
      (nstr-buf s 'nre-perl-to-emacs)
    ;;(nre-perl-to-emacs "'German' => '{der $2>s>}'")
    ;;(nre-perl-to-emacs "$2")
    (save-restriction
      (n-narrow-to-line)
      (forward-line 0)
      (replace-regexp "\\$\\([0-9]\\)" "\\\\\\1")
      (forward-line 0)
      (replace-regexp "\\\\(" "__________________place_holder_")
      (forward-line 0)
      (replace-regexp "(" "\\\\(")
      (forward-line 0)
      (replace-regexp "__________________place_holder_" "(")

      (forward-line 0)
      (replace-regexp "\\\\|" "__________________place_holder_")
      (forward-line 0)
      (replace-regexp "|" "\\\\|")
      (forward-line 0)
      (replace-regexp "__________________place_holder_" "|")

      (forward-line 0)
      (replace-regexp "\\\\)" "__________________place_holder_")
      (forward-line 0)
      (replace-regexp ")" "\\\\)")
      (forward-line 0)
      (replace-regexp "__________________place_holder_" ")")

      (forward-line 0)
      (replace-regexp "\\\\" "\\\\")
      (forward-line 0)
      (replace-regexp "\\\\s" "[ \\\\t]")
      (forward-line 0)
      (replace-regexp "\\\\S" "[^ \\\\t\\\\n]")
      (forward-line 0)
      (replace-regexp "\\\\d" "[0-9]")
      (forward-line 0)
      (replace-regexp "\\\\D" "[^0-9]")
      (forward-line 0)
      (replace-regexp "\\\\w" "[0-9a-zA-Z_]")
      (forward-line 0)
      (replace-regexp "\\\\W" "[^0-9a-zA-Z_]")

      ;;
      ;; handle sit where [\.\d] -> [\.[0-9]], whereas we want [\.0-9]
      (goto-char (point-min))
      (replace-regexp    "\\[\\([^]\\[]+\\)\\]\\]" "\\1]")
      (goto-char (point-min))
      (replace-regexp "\\[\\[\\([^]\\[]+\\)\\]" "[\\1")
      
      (if (eq major-mode 'emacs-lisp-mode)
          (progn
            (forward-line 0)
            (replace-regexp "\\\\" "\\\\\\\\")
            (forward-line 0)
            (replace-regexp "\\\\n" "n")
            (forward-line 0)
            (replace-regexp "\\\\t" "t")
	    (forward-line 0)
	    (replace-regexp "\"" "\\\\\"")
            )
        (forward-line 0)
        (replace-regexp "\\\\t" "	")

        (forward-line 0)
        (replace-regexp "\\\\n" "
")
        
        )
      )
    )
  )

(defun nre-transform-skip-comments()
  (forward-line 0)
  (while (and
	  (not (eobp))
	  (looking-at "[ \t]*#")
	  (= 0 (forward-line 1))
	  )
    (forward-line 0)
    )
  )

(defun nre-transform-get-next-noncomment-line-and-advance()
  (nre-transform-skip-comments)
  (prog1
      (nre-perl-to-emacs
       (n-get-line)
       )
    (forward-line 1)
    (nre-transform-skip-comments)
    )
  )


(defun nre-transform()
  (save-window-excursion
    (if (buffer-file-name)
	(save-buffer))
    (delete-other-windows)
    (split-window-vertically)
    (n-loc-pop)
    (if (not (string-match "^transform\\." (buffer-name)))
	(progn
	  (n-loc-push)  ;; restore it
	  (find-file (n-host-to-canonical "$dp/data/transform"))
	  )
      (n-loc-push)  ;; so I don't constantly have to reestablish it...
      )
    (goto-char (point-min))
    (let(
	 query
	 before
	 tmp
	 after
	 )
      (while (progn
	       (end-of-line)
	       (not (eobp))
	       )
	(forward-line 0)
	(setq tmp 	(nre-transform-get-next-noncomment-line-and-advance)
	      query	(string= "?" tmp)
	      before	(if (not query)
                            tmp
			  (nre-transform-get-next-noncomment-line-and-advance)
                          )
	      after	(nre-transform-get-next-noncomment-line-and-advance)
	      )
 	;;(setq before (nre-perl-to-emacs before))
	(other-window 1)
	(goto-char (point-min))
	(cond
	 (query
	  (query-replace-regexp before after)
	  )
	 (t
	  (replace-regexp before after)
	  )
	 )
	(other-window 1)
	)
      )
    )
  )

(defun nre-query-replace()
  (interactive)
  (let(
       (my-message-replacement (symbol-function 'message))
       )
    (unwind-protect
        (fset 'message nsimple-original-message)
      (let(
           (from	(nre-perl-to-emacs (read-string "Replace: ")))
           (to		                   (read-string "With: "))
           )
	(if (string= from "")
	    (setq from "^"))
        (query-replace-regexp from to)
        )
      (fset 'message my-message-replacement)
      )
    )
  )
(defun nre-with-arg()
  (interactive)
  (nre t)
  )

(defun nre-init-transform(beforesAndAfters)
  (save-window-excursion
    (n-file-find "$dp/data/transform")

    (delete-region (point-min) (point-max))
    (while beforesAndAfters
      (insert (car beforesAndAfters) "\n")
      (setq beforesAndAfters (cdr beforesAndAfters))
      )
    (save-buffer)
    )
  )

(defun nre-reg1-to-reg2()
  (save-excursion
    (goto-char (point-min))
    (let(
         (before (nsimple-register-get ?1))
         (after (nsimple-register-get ?2))
         )
      (message "s/%s/%s/g" before after)
      (replace-regexp before after)
      )
    )
  )

(defun nre-make-mv-cmds-from-reg1-to-reg2()
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (while (not (eobp))
        (forward-line 0)
        (insert "mv ")
        (let(
             (fn (buffer-substring-no-properties (point) (progn
                                                           (end-of-line)
                                                           (point)
                                                           )
                                                 )
                 )
             )
          (narrow-to-region (point) (point))
          (insert " " fn)
          (nre-reg1-to-reg2)
          (widen)
          )
        (forward-line 1)
        (end-of-line)
        )
      )
    )
  )

(defun nre-grep-replace-regexp-reg1-to-reg2()
  (goto-char (point-min))
  (while (n-s "^/")
    (save-window-excursion
      (n-grab-file)
      (save-restriction
        (n-narrow-to-line)
        (nre-reg1-to-reg2)
        )
      )
    )
  )


(defun nre( &optional arg)
  (interactive "P")
  (if (not arg)
      (let(
           (from	(nre-perl-to-emacs (read-string "Replace: ")))
           (to		                   (read-string "With: "))
           )
	(if (string= from "")
	    (setq from "^"))
        (replace-regexp from to)
        )
    (let(
         (cmd	(progn
                  (message ".-rm char under pt, !-rep12,1-2 reg transform,3-fn-mv, ::scratch cur,^-rm^M,<-prep-html,c-clone,d-ebug-from-info,DDD-DD-DDDD-removal,e-env,g-rep,G-rep-cloned,j-junit-0,J-junit-1,m-mv-1-to-2,n-touch,ps-to-PIDs,t-ransform, /:last file component, *-dir-component-to-*, 8-dir-component-to-*.SUF")
                  (read-char)
                  )
                )
         )
      (cond
       ((= cmd ?8)
        (save-excursion
          (goto-char (point-min))
          (replace-regexp "^[ \t]*" "")

          (goto-char (point-min))
          (replace-regexp "^\\./" "")
          
          (goto-char (point-min))
          (replace-regexp "/[^\\./\\*]+\\.\\([^\\./]+\\)$" "/*.\\1")
          (n-prune-duplicates)
          )
        )
       ((= cmd ?*)
        (save-excursion
          (goto-char (point-min))
          (replace-regexp "^[ \t]*" "")

          (goto-char (point-min))
          (replace-regexp "^\\./" "")

          (goto-char (point-min))
          (replace-regexp "/[^/\\*]+\\(/[/\\*]+\\)?$" "/*\\1")
          (n-prune-duplicates)
          )
        )
       ((= cmd ?.)
        (save-excursion
          (replace-regexp (buffer-substring-no-properties (1+ (point)) (point))
                          ""
                          )
          )
        )
       ((= cmd ?!)
        (nre-grep-replace-regexp-reg1-to-reg2)
        )
       ((= cmd ?/)
        (nre-remove-last-component)
        )
       ((= cmd ?1)

        (nstr-copy-to-register ?2 (n-grab-token))

        (nre-reg1-to-reg2)
        )
       ((= cmd ?3)
        (save-excursion
          (goto-char (point-min))
          (replace-regexp n-file-save-cmd-old-fn n-file-save-cmd-new-fn)
          )
        )
       ((= cmd ?^)
        (n-host-shell-cmd-visible (concat "pc_to_unix " (buffer-file-name)))
        )
       ((= cmd ?<)
        (n-host-shell-cmd-visibly-transform "perl -w $dp/bin/perl/split_tags_into_separate_lines.pl")
        )
       ((= cmd ?:)
        (let(
             (data	(buffer-substring-no-properties (point-min) (point-max)))
             )
          (nelisp-scratch-init)
          (goto-char (point-max))
          (narrow-to-region (point) (point))
          (insert data)
          )
        (goto-char (point-min))
        (replace-regexp ":.*" "")
	(require 'n-prune-buf)
        (n-prune-duplicates)
        (n-prune-buf-v "/")
        (goto-char (point-min))
        )
       ((= cmd ?c)
        (let(
             (case-replace t)
             (case-fold-search t)
             (before (nre-perl-to-emacs (read-string "Clone case while replacing:")))
             (after  (read-string "with:"))
             )
          (replace-regexp before after) ; it's a mystery: call-interactively doesn't clone case
          )
        )
       ((= cmd ?D)
        (save-excursion (replace-regexp "[0-9][0-9]/[A-Z][a-z][a-z]/20[0-9][0-9]" "DD-Mon-YYYY"))
        (save-excursion (replace-regexp "[0-9][0-9]:[0-9][0-9]:[0-9][0-9]" "HH-mm-ss"))
        )
       ((= cmd ?e)
        (n-env-replace-regexp)
        )
       ((= cmd ?g)
        (n-env-replace-regexp-based-on-env-grep-output)
        )
       ((= cmd ?G)
        (let(
             (case-replace t)
             (case-fold-search t)
             )
          (n-env-replace-regexp-based-on-env-grep-output)
          )
        )
       ((= cmd ?j)
        (save-excursion
          (replace-regexp "public void test" "public void xtest")
          )
        )
       ((= cmd ?J)
        (save-excursion
          (replace-regexp "public void xtest" "public void test")
          )
        )
       ((= cmd ?m)
        (nre-make-mv-cmds-from-reg1-to-reg2)
        )
       ;;((= cmd ?M)
       ;;(nre-massage-Mom-teacher-corrections)
       ;;)
       ((= cmd ?n)
        (goto-char (point-min))
        (replace-regexp "^" "ntouch ")
        (delete-other-windows)
        (nsimple-split-window-vertically)
        (nshell)
        (n-other-window)
        )
       ((= cmd ?p)
        (goto-char (point-min))
        (replace-regexp "^[0-9a-zA-Z_]+ *\\([0-9]+\\) .*" "\\1")
        ;; next one happens on cygwin
        (replace-regexp "^ +\\([0-9]+\\) .*" "\\1")
        (delete-region (point) (progn
                                 (goto-char (point-max))
                                 (point)
                                 )
                       )
        (goto-char (point-min))
        (insert "kill -9 ")
        (nsimple-join-lines t)
	)
       ((= cmd ?t)
        (nre-transform)
        )
       ((= cmd ?T)

        (n-loc-push)
        (n-file-find "$dp/data/transform")
        (message "will execute transform at the end of the recursive edit")
        (recursive-edit)
        (n-loc-pop)
        (nre-transform)
        )
    (t (message "Unrecognized command %c" cmd))
       )
      )
    )
  )
(defun nre-remove-last-component()
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "/[^/]*$" "")
    (n-prune-duplicates)
    )
  )

(defun nre-pattern( &optional arg)
  "clone REGION, substituting mc-2 for mc-1.
Without an argument, prompt for the number of lines to be affected"
  (interactive "P")
  (if arg
      (call-interactively 'narrow-to-region)
    (narrow-to-region (point)
                      (progn
                        (message "command of lines: ")
                        (let(
                             (command (read-char))
                             )
                          (cond
                           ((or (< command ?0) (> command ?9))
                            (forward-line 1)
                            )
                           (t
                            (forward-line (- command ?0))
                            )

                           )
                          (point)
                          )
                        )
                      )
    )
  (goto-char (point-min))
  (insert (buffer-substring-no-properties (point-min) (point-max)))
  (let(
       (old (nsimple-register-get ?1))
       (new (nsimple-register-get ?2))
       capitalOld
       capitalNew
       )
    (setq capitalOld (nstr-capitalize old))
    (setq capitalNew (nstr-capitalize new))

    (save-excursion
      (replace-regexp old new)
      )
    (save-excursion
      (replace-regexp capitalOld capitalNew)
      )
    
    (goto-char (point-max))
    )
  (widen)
  )

(defun nre-ODBC()
  (save-excursion
    (let(
         (substitutions (list
                         (list "SWORD" "short")
                         (list "UCHAR" "unsigned char *")
                         (list "hEnv" "mEnvironment")
                         (list "retCode" "returnCode")
                         (list "RETCODE" "SQLRETURN")
                         (list "// ?\\.+$" "")
                         (list "hStmt" "mStatement")
                         (list "( " "(")
                         (list " )" ")")
                         (list "\\[ " "[")
                         (list "  \\]" "]")
                         (list "@@" "@@")
                         (list "@@" "@@")
                                        ;(list "@@" "@@")
                         )
                        )
         )
      (while substitutions
        (goto-char (point-min))
        (apply 'replace-regexp (car substitutions))
        (setq substitutions (cdr substitutions))
        )
      )
    (let(
         (prefixes (list "sz" "w" "c" "psz" "lpsz"))
         )
      (while prefixes
        (goto-char (point-min))
        (while (n-s (concat "\\b" (car prefixes) "[A-Z]"))
          (let(
               (before	(n-grab-token))
               after
               )
            (setq after
                  (save-restriction
                    (narrow-to-region (point) (point))
                    (insert before)
                    (goto-char (point-min))
                    (replace-regexp (concat  "^" (car prefixes))
                                    ""
                                    )
                    (goto-char (point-min))
                    (nsimple-downcase-word t)
                    (prog1
			(buffer-substring-no-properties (point-min) (point-max))
                      (delete-region (point-min) (point-max))
                      )
                    )
                  )
            (goto-char (point-min))
            (replace-regexp before after)
            )
          (goto-char (point-min))
          )
        (setq prefixes (cdr prefixes))
        )
      )
    )
  )

(defun nre-alnum-p( c)
  "return t if CHAR is alphanumeric"
  (or (and (>= c ?0) (<= c ?9))
      (and (>= c ?a) (<= c ?z))
      (and (>= c ?A) (<= c ?Z)))
  )

(defun nre-act-on-hits-in-grep-buffer(func)
  (require 'nmidnight)
  (switch-to-buffer midnight-grep-output-buffer)
  (goto-char (point-min))

  ;; look for a line beginning with a file name
  (require 'nfn)
  (require 'nsyb)
  (while (and (not (eobp))
              (n-s "/")
              )
    (save-window-excursion
      (n-grab-file)
      (nsyb-cm-lock-if-necessary)
      (save-window-excursion
        (save-restriction
          (funcall func)
          )
        )
      )
    (end-of-line)
    (forward-line 1)
    )
  )

(defun nre-skip-element()
  "for navigating through source code, where we want to treat nested function calls as tokens.
Calling nre-skip-element repeatedly
abc($stem_b, $inf_b(lskdjf, sldkfj), $lskjf)
    ^      ^                       ^       ^
"
  (if (looking-at ",")
      (forward-char 1))
  (skip-chars-forward " \t\n")
  (if (not (n-s "[,(){}]"))
      (goto-char (point-max))
    (forward-char -1)
    (cond
     ((looking-at "[({]")
      (forward-sexp 1)
      )
     )
    )
  )

(defun nre-rm-arg-from-each-call(fName, argNo)
  (nre-act-on-hits-in-grep-buffer '(lambda()
				     (n-s "(" t)
				     (while (> argNo 0)
				       (nre-skip-element)
				       )
				     (nsimple-clean-region (point) (progn
								     (nre-skip-element)
								     (point)
								     )
							   )
				     (if (looking-at ",")
					 (delete-region (point) (progn
								  (n-s ",[ \t]*" t)
								  (point)
								  )
							)
				       )
				     )
				  )
  )


(defun nre-rm-class-designation-from-each-call(fName)
  (nre-act-on-hits-in-grep-buffer '(lambda()
				     (if (n-s (concat "::" fName "("))
					 (progn
					   (delete-region (progn
							    (n-r "::" t)
							    (forward-char 2)
							    (point)
							    )
							  (progn
							    (n-r "[^0-9a-zA-Z_]" t)
							    (point)
							    )
							  )
					   )
				       )
				     )
				  )
  )
(defun nre-massage-Mom-teacher-corrections()
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "^[ \t]*>*[ \t]*" "")

    (goto-char (point-min))
    (replace-regexp "\\.[\\. \t]+$" ".")

    (goto-char (point-min))
    (replace-regexp "^\\(#\\|[a-z_]+\\.[0-9]+\\(/[a-z_]+\\.[0-9]+\\)?:\\)" "xxx\\1")

    (goto-char (point-min))
    (replace-regexp "^$" "xxx")

    (goto-char (point-min))
    (replace-regexp "\n" " ")

    (goto-char (point-min))
    (replace-regexp "xxx" "\n")
    )
  )
(defun nre-unregexpify(str &optional strip)
  (let(
       (after (if strip "" "_"))
       )
    (nstr-replace-regexp str "[\\\\\\*\\^\\$]" after)
    )
  )
(defun nre-safe-looking-at(s)
  (condition-case nil
      (looking-at s)
    (error nil)
    )
  )
(defun nre-clone-rr(token1 token2)
  (let(
       (case-replace t)
       (case-fold-search t)
       )
    (replace-regexp
     (nstr-downcase token1) 	;; no uppercase letters allowed cuz it'd disable case preservation in replace-regexp
     token2
     )
    )
  )
(defun nre-variablize()
  (interactive)
  (save-restriction
    (n-narrow-to-line)
    (if (n-s "[^ a-zA-Z0-9]")
        (narrow-to-region (1- (point))
                          (progn
                            (forward-line 0)
                            (point)
                            )
                          )
      )
    (nsimple-uncapitalize)
    (while (n-s " ")
      (delete-char -1)
      (nsimple-upcase-char)
      )
    )
  )
(defun nre-pat(n &optional s)
  (if (not s)
      (buffer-substring-no-properties (match-beginning n)  (match-end n))
    (substring s (match-beginning n) (match-end n))
    )
  )

(defun nre-pat--test()
  (let(
       (s       "xabc")
       m
       )
    (string-match "\\(.*\\)a" "xabc")
    (setq m       (nre-pat 0 s))
    (if (string= "x" m)
        (message "OK")
      (message "expected x, saw %s" m)
      )
    )
  )
;;(nre-pat--test)

(defun nre-grep-count(patt)
  (let(
       (cnt 0)
       )
    (save-excursion
      (goto-char (point-min))
      (while (n-s patt)
        (setq cnt (1+ cnt))
        )
      )
    cnt
    )
  )
(defun nre-replace-word(before after)
  ;; The reason the stock replace-regexp doesn't work is that it considers _ to be a word boundary, when very frequently is
  ;; used within variable names. So I must protect against that character being used as a word boundary.
  ;;
  (setq before (nstr-replace-regexp before "\\$" "\\$"))
  (replace-regexp (concat "\\([^-A-Za-z0-9_]\\)" before "\\([^-A-Za-z0-9_]\\)")
                  (concat "\\1" after "\\2")
                  )
  ;;(nre-replace-word "$xx" "ab.xx") $xx
  )
(defun nre-looking-behind-at(exp)
  (let(
       hit
       )
    (save-restriction
      (narrow-to-region (point)
                        (progn
                          (forward-line 0)
                          (point)
                          )
                        )
      ;; We repeatedly look for this pattern, and if at the last one we are at the end of line, then we know that the assertion should succeed. Otherwise there are two possibilities: 1.) There were no hits anywhere in the line or 2.) There was ahead, but it wasn't at the end.
      (while (n-s exp)
        (setq hit t)
        )
      (and hit
           (looking-at "$")
           )
      )
    )
  )
(defun nre-looking-at-one-of(&rest patts)
  (setq patts (car patts))
  (let(
       rc
       )
    (while (and (not rc) patts)
      (setq rc (looking-at (car patts))
            patts (cdr patts)
            )
      )
    rc
    )
  )

(defun nre-delete-by-regexp(regexp reverse)
  (delete-region (point) (progn
                           (if reverse
                               (n-r regexp t)
                             (n-s regexp t)
                             )
                           (point)
                           )
                 )
  )
(defun nre-escape-double(s)     ;; potentially needed if being forwarded to a shell
  (nstr-replace-regexp s "\\$" "\\\\\\\\$")
  )
(defun nre-escape(s)
  (nstr-replace-regexp s "\\$" "\\\\$")
  )
;; (message (nre-escape "$mrc"))
