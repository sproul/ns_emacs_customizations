(provide 'n-complete)

(if (not (boundp 'last-command-event))   ;; trying to avoid this spate of errors I'm seeing on newest emacs
    (progn
      (warn "n-complete: uh-oh, last-command-event not bound.  Perhaps last-command-char is available?")
      (setq last-command-event ?Z)
      )
  )

(defvar n-complete-or-space-arg-was-passed nil "was it ^U<spc>, or just <spc>?")
                                        ; list of completion data:
                                        ;	pattern
                                        ;	routine to use to adjust it
                                        ;	new text
                                        ; the next 2 flds tell where point should go after the substitution.  If
                                        ; they're both nil, just call n-complete-leap to determine where to go.
                                        ;	column offset
                                        ;	line offset
                                        ;
(make-variable-buffer-local 'n-completes)
(setq-default n-completes nil)
(setq-default n-complete-leap-dft (list
                                   (list (concat "@" "@") ;; the concat is there to reduce the chance of corruption
					 'backward-delete-char 2)
                                   )
              )
(make-variable-buffer-local 'n-complete-leap)
(setq-default n-complete-leap n-complete-leap-dft)

(make-variable-buffer-local 'n-complete-dirty)
(setq-default n-complete-dirty nil)

(make-variable-buffer-local 'n-complete-dirty-hook)
(setq-default n-complete-dirty-hook nil)

(defun n-complete-add-and-append( prefix suffix)
  (delete-region (point-min) (point-max))
  (forward-line 0)
  (insert prefix)
  (save-restriction
    (widen)
    (end-of-line)
    (insert suffix)
    (forward-line 0)
    )
  (n-complete-seek)
  )
(defun n-complete-replace( before after)
  "replace BEFORE with AFTER on the current line; if there are multiple BEFOREs, only do the one closest to the eoln (strange, I know, but needed for completion to be ok -- in that case we are usually at eoln, and looking very locally)"
                                        ;  (n-trace (concat "before: " before ))
                                        ;  (n-trace (concat "after: " after ))
  (end-of-line)
  (if (n-r before)
      (progn
        (replace-regexp before after)
        )
    )
  (forward-line 0)
  (n-complete-seek)
  )

(defun n-complete-df()
  (delete-char 2)
  (let(
       (prefix	(nfn-prefix))
       )
    (if (string-match "^n[0-9]" prefix)
        (setq prefix "n"))
    (insert "(defun " prefix "-@@()\n  @@\n  )\n")
    )
  (forward-line -3)
  (n-complete-leap)
  )

(defun n-complete-leap()
  "move to the next logical place in the file to work."
  (interactive)
  (if (and (looking-at "['\"]@@")
           (eq major-mode 'nsh-mode)
           (save-excursion
             (forward-char -1)
             (looking-at "['\"]")
             )
           )
      (let(
           (quote-char (buffer-substring-no-properties (point) (1+ (point))))
           )
        ;; I'm trying to counter a longtime irritation: if I make a variable or other token and then decide to quote it, the open quote leads to an immediate close
        ;; quote, both preceding the token of interest. I end up with this:
        ;;              ""@@token
        ;;                      or
        ;;              ''@@token
        ;; when what I really want is
        ;;              "token"
        ;;                      or
        ;;              'token'
        ;; To rectify this, I detect the situation and then choose interactively what should come next:
        (delete-char 3)
        (message "l-ine quote, v-ariable quote everywhere, w-ord quote")
        (let(
             (cmd (read-char))
             )
          (cond
           ((eq cmd ?l)
            (n-complete-finish-quoting-line quote-char)
            )
           ((eq cmd ?v)
            (n-complete-quote-everywhere (buffer-substring-no-properties (point)
                                                                         (progn
                                                                           (n-s "[^A-Za-z0-9_\\$]" t)
                                                                           (forward-char -1)
                                                                           (point)
                                                                           )
                                                                         )
                                         )
            )
           ((eq cmd ?w)
            (if (n-s "[ \t\n]")
                (forward-char -1)
              (goto-char (point-max))
              )
            (insert quote-char)
            )
           )
          )
        )
    (save-match-data
      (n-sv n-complete-leap)
      )
    )
  )
(defun n-complete-elisp-err( &optional &rest arg)
  (goto-char (point-max))
  (backward-delete-char 1)
  (insert "(error \"" (n-defun-name) ": \")")
  (forward-char -2)
  )

                                        ;
                                        ; Depends on completion char being a space.
                                        ;
(defun n-complete-abbrev()
  (let(
       (case-fold-search nil)
       )
    (save-window-excursion
      (save-restriction
        (n-complete-isolate)
        (let(
             (comps	n-completes)
             expanded
             )
          (while (and comps (not expanded))
            (setq expanded (n-complete-try (car comps)))
            ;;(if expanded (nelisp-bp "n-complete" (format "expanded: %s"  (caar comps)) 103))
            (setq comps (cdr comps))
            )
          (n-complete-de-isolate (not expanded))
          expanded
          )
        )
      )
    )
  )

(setq n-complete-lineNo nil)
(setq n-complete-lineNo-entering nil) ; nil=unknown ?y=yes ?n=no

(defun n-complete-beginning-of-buffer()
  (interactive)
  (setq n-complete-lineNo nil
        n-complete-lineNo-entering nil
        )
  (beginning-of-buffer)
  )

(defun n-complete-searching()
  ;;(n-trace "n-complete-searching")
  ;;(n-trace (concat
  ;;          "n-complete-searching: buffer-read-only=" (if buffer-read-only "t" "nil")
  ;;          ", last-command=" (n--get-lisp-func-name last-command)
  ;;          ",  n-complete-lineNo-entering="  (if n-complete-lineNo-entering (int-to-string n-complete-lineNo-entering) "nil")
  ;;          )
  ;;         )
  (if (and
       (or buffer-read-only
           ;;(string= (n--get-lisp-func-name last-command) "n-complete-beginning-of-buffer")
           (eq last-command 'n-complete-beginning-of-buffer)
           (and
            (eq n-complete-lineNo-entering ?y)
            ;;(string= (n--get-lisp-func-name last-command) "n-complete-self-insert-command")
            (eq last-command 'n-complete-self-insert-command)
            )
           )
       )
      (let(
           (is-digit   (and (>= last-command-event ?0)
                            (<= last-command-event ?9)
                            )
                       )
           )
        (cond
         ((null n-complete-lineNo-entering)
          (if (not is-digit)
              (setq n-complete-lineNo-entering ?n
                    n-complete-lineNo nil
                    )
            (setq n-complete-lineNo-entering ?y
                  n-complete-lineNo (string-to-int (char-to-string last-command-event))
                  )
            (nsimple-goto-line n-complete-lineNo)
            )
          )
         ((eq n-complete-lineNo-entering ?y)
          (if (not is-digit)
              (setq n-complete-lineNo nil
                    n-complete-lineNo-entering nil
                    )
            (setq n-complete-lineNo (+ (* 10 n-complete-lineNo)
                                       (string-to-int (char-to-string last-command-event))
                                       )
                  )
            (nsimple-goto-line n-complete-lineNo)
            )
          )
         )
        
        ;; ok, at this point,
        ;;      if n-complete-lineNo-entering is nil, that means that it was ?y and we just saw a non-digit, which should be passed on to insert-character (or whatever that op is).
        ;;      if n-complete-lineNo-entering is ?y, then we are "searching," i.e., we are advancing into the file to the entered line number.  For this event, our work is done.
        ;;      if n-complete-lineNo-entering is ?n, then we are "searching" in the old sense, by means of isearch-forward-regexp.
        (cond
         ((eq n-complete-lineNo-entering ?y)
          t
          )
         ((or
           (eq n-complete-lineNo-entering ?n)
           (null n-complete-lineNo-entering)            ;; this means that we have gotten to a line by number; now we will be searching
           )
          (n-trace "n-complete-searching: last char was %c" last-command-event)
          (n-ungetc last-command-event)
          (call-interactively 'isearch-forward-regexp)
          t
          )
         )
        )
    )
  )

(defun n-complete-symbol()
  (cond
   ((n-modes-lispy-p)
    (nelisp-complete-symbol)
    )
   )
  )
(defun n-complete-ensure-matching-space-preceding(what &optional exceptions)
  (save-excursion ; don't allow some_var= lksjdfldskfj, i.e., if a space follows the =, then there must also be a space preceding it
    (if (and
         (progn
          (forward-char (- (1+ (length what))))
           (looking-at what)
     )
         (progn
           (forward-char -1)
           (and (not (looking-at " "))
                (or (not exceptions)
                    (not (looking-at (concat "[" exceptions "]")))
                    )
                )
           )
         )
        (progn
          (forward-char 1)
          (insert " ")
          )
      )
    )
  )
(defun n-complete-or-space( &optional arg)
  "either insert input which pgm guesses you want, or else put in a space"
  (interactive"P")
  (setq n-complete-or-space-arg-was-passed (not (null arg)))

  (if (not (n-complete-searching))
      (let(
           ;;	addSpace
           )
        (cond
         ((n-complete-abbrev) 	nil)
         ((n-complete-symbol) 	nil)
         (t
          (insert " ")

          ;;OK, now I'm getting fed up with spaces being added when point is at the
          ;;beginning of the line.  I think I can fix the annoying indentation
          ;;behavior by simply temporarily going to the beginning of the line before
          ;;calling the indent.  so once again I am inserting the space at this point...
          ;;
          ;;
          ;;	;;I used to just insert a space at this point, but this leads to incorrect
          ;;	;;behavior when used with modes which useindent-relative-maybe as their
          ;;	;;indenting function.  The reason is that this function assumes that it is
          ;;	;;at the beginning of the text for the line and operates as follows:
          ;;	;;
          ;;	;;1 eliminate all horizontal space
          ;;	;;2 guess what the properindentation should be
          ;;	;;3 if the proper indentation is to the last of the current column, then do
          ;;	;;nothing more
          ;;	;;
          ;;	;;what this adds up to it is that if the current column is to the right of
          ;;	;;the proper indentation, any space I insert in my Lisp at this time willbe
          ;;	;;removed.  Oops.
          ;;	;;
          ;;	;;The fix is to postpone adding the space until the last moment.
          ;;	(setqaddSpace t)
          )
         )

        (save-excursion
          (forward-line 0)
          (skip-chars-forward " \t")
          (indent-according-to-mode)
          )
        (if (< (point) (save-excursion
                         (nsimple-back-to-indentation)
                         (point)
                         )
               )
            (nsimple-back-to-indentation)
          )
        (save-excursion
          (save-restriction
            (narrow-to-region (point)
                              (progn
                                (end-of-line)
                                (point)
                                ))
            (delete-horizontal-space)

            (widen)
            (forward-line 0)
            (if (looking-at "[ t]*EOF$")
                (delete-horizontal-space))
            )
          )
        ;;(n-complete-ensure-matching-space-preceding "=" "|<>!=+-*/")
        (n-complete-ensure-matching-space-preceding "==")
        (n-complete-ensure-matching-space-preceding "!=")
        (n-complete-ensure-matching-space-preceding "-" "-")
        (n-complete-ensure-matching-space-preceding "+" "=+")
	)
    )
  )
(setq last-last-command-event nil)

(defun n-complete-self-insert-command()
  "insert a character"
  (interactive)
  (if (not n-complete-dirty)
      (progn
        (setq n-complete-dirty t)
        (if n-complete-dirty-hook
            (funcall 'n-complete-dirty-hook))
        )
    )
  (cond
   ((string= (buffer-name) "*Backtrace*")
    (message "n-complete-self-insert-command disabled in *Backtrace*")
    )

   ((n-complete-searching)
    nil
    )

   (t
    (ntoken-add-character last-command-event)
    (setq last-last-command-event last-command-event)
    (call-interactively 'self-insert-command)
    )
   )
  )

(setq n-complete-start nil
      n-complete-endnil)

(defun n-complete-isolate()
  " narrow out the buffer except for that part which completions
will be matched against: the current line, up to point."
  (setq n-complete-end (point-marker)
        n-complete-start (progn
                           (forward-line 0)
                           (point-marker)
                           )
        )
  (narrow-to-region(marker-position n-complete-start)
                   (marker-position n-complete-end))
  (forward-line 0)
  )

(defun n-complete-de-isolate( noMatch)
  (if noMatch
      (progn
        (goto-char (point-max))
        (widen)
        )
    (save-excursion
      (widen)
      (condition-case nil
	  (indent-region (marker-position n-complete-start)
                         (marker-position n-complete-end)
                         nil)
        (error nil)
        )
      )
    )
  )

(defun n-complete-try( comp )
  " given an entry COMP from the comp list, this proc will see if it's appropriate.  If
so, t is returned; otherwise nil.  A nil COMP will always succeed (matching the
completion char, a space."
  (let(
       (pattern	(car comp))
       )
    (if (looking-at pattern)
        (progn
          (n-trace "Matched %s, '%s'/'%s'\n" pattern (caddr comp) (cadddr comp))
          (apply (cadr comp) (cddr comp))
          t
          )
      nil
      )
    )
  )

(defun n-complete-dft(insertion &optional f &rest args)
  " add INSERTION; move point OFFSET characters from the end"
  (goto-char (point-max))
  (if (string-match "%V" insertion)
      (save-restriction
        (save-excursion
          (setq insertion (nstr-replace-regexp insertion "%V" (funcall f args))))
        )
    )

  (insert insertion)
  (setq n-complete-end (point-marker))
  (n-complete-seek)
  )

(defun n-complete-seek()
  (goto-char (point-min))
  (n-complete-leap)
  )

(defun n-complete-grab-token-in-file(fn patt)
  (let(
       (token (n-grab-token-in-file fn patt))
       )
    (n-complete-replace "\\?$"
			(concat token "@@")
			)
    )
  )
(defun n-complete-insert-class-name-or-insert-back-apostrophe()
  (interactive)
  (message "Which class name should I insert? ")
  (let(
       className
       fn
       (cmd	(read-char))
       )
    (cond
     ((= cmd ?\ )	(setq cmd	(read-char)))
     ((= cmd ??)	(setq cmd	nil))
     )

    (if (not n-env)
	(n-env-set))
    (setq fn (nmenu-choose-shortcut-file cmd))
    (setq className (nfn-prefix (file-name-nondirectory fn)))
    (insert className "::")
    )
  )

(defun n-complete-add-trace()
  ;; get rid of the t$ which led to this call via the complete-ing mechanism:
  (end-of-line)
  (delete-char -1)

  (let(
       (lastTrace   (save-restriction
                      (widen)
                      (save-excursion
                        (if (n-r "(n-trace")
                            (n-get-line))
                        )
                      )
                    )
       (nextTrace   (save-restriction
                      (widen)
                      (save-excursion
                        (if (n-s "(n-trace")
                            (n-get-line))
                        )
                      )
                    )
       lastTraceId
       nextTraceId
       newTraceId
       )
    (if (not lastTrace)
        (insert "(n-trace \"@@\"@@)\n@@")
      (setq lastTraceId (n-complete-add-trace--extract-trace-id lastTrace)
            nextTraceId (n-complete-add-trace--extract-trace-id nextTrace)
            newTraceId  (n-complete-add-trace--make-intermediate-trace-id lastTraceId nextTraceId)
            )
      (insert (nstr-replace-regexp lastTrace
                                   (concat lastTraceId "\\([^0-9]*\\)$")
                                   (concat newTraceId "\\1")
                                   )
              )
      )
    (goto-char (point-min))
    (n-complete-leap)
    )
  )

(defun n-complete-add-trace--extract-trace-id(traceCall)
  (if (and traceCall
           (string-match "[^0-9]\\([0-9]+\\(\\.[0-9]+\\)?\\)[^0-9]*$" traceCall)
           )
      (n--pat 1 traceCall)
    "99" ;; dft
    )
  )

(defun n-complete-add-trace--make-intermediate-trace-id(lastTraceIdS nextTraceIdS)
  (let(
       (lastTraceId (string-to-number lastTraceIdS))
       (nextTraceId (string-to-number nextTraceIdS))
       newTraceIdS
       )
    (setq newTraceIdS      (number-to-string (if (>= lastTraceId nextTraceId)
                                                 (1+ lastTraceId)
                                               (/ (+ lastTraceId nextTraceId) 2.0)
                                               )
                                             )
          )

    (setq newTraceIdS (nstr-replace-regexp newTraceIdS "\\(\\.[0-9][0-9][0-9]\\)[0-9]+$" "\\1"))
    (setq newTraceIdS (nstr-replace-regexp newTraceIdS "\\.\\([0-9]*[1-9]\\)?0*$" ".\\1")) ;; remove trailing zeroes in decimal expressions
    (setq newTraceIdS (nstr-replace-regexp newTraceIdS "\\.$" ""))
    newTraceIdS
    )
  )
;;(n-complete-add-trace--make-intermediate-trace-id "00" "4")
;;(n-complete-add-trace--make-intermediate-trace-id "5" "2")
;;(n-complete-add-trace--make-intermediate-trace-id "1.001" "4")
;;(n-complete-add-trace--make-intermediate-trace-id "1.001" "5")
;;(n-complete-add-trace--make-intermediate-trace-id "1.1" "1.2")
;;(n-complete-add-trace--make-intermediate-trace-id "1.15" "1.2")
;;(n-complete-add-trace--make-intermediate-trace-id "1.174" "1.2")
;;(n-complete-add-trace--make-intermediate-trace-id "1.00" "0")
(defun n-complete-quote-everywhere(token)
  (save-excursion
    (let(
         (regexp_token (if (string-match "^\\$" token)
                           (concat "\\" token)
                         (concat "\\b" token)
                         )
                       )
         before
         after
         )
      (setq before regexp_token
            after (concat "\"" token "\"")
            )
      (goto-char (point-min))
      (replace-regexp before after)
      )

    ;; Have to do this two pass thing because zero width look behind not supported in Emacs regular expressions.  Undo double double quoting:
    (goto-char (point-min))
    (replace-regexp (concat "\"\"\\" token)
                    (concat     "\"" token)
                    )
    (replace-regexp (concat token "\"\"")
                    (concat  token "\"")
                    )
    )
  )
(defun n-complete-finish-quoting-line(quote-char)
  (save-restriction
    (save-excursion
      (narrow-to-region (point) (progn
                                  (end-of-line)
                                  (point)
                                  )
                        )
      (goto-char (point-min))
      (replace-regexp quote-char
                      (concat "\\\\" quote-char)
                      )
      )
    )
  (end-of-line)
  (insert quote-char)
  )
