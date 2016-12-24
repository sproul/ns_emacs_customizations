(provide 'nm)
(setq nm-macs nil)                      ; list o' bufs, each a macro defn
(setq nm-executing nil)

(defvar nm-last-fn nil "file name of source for last-defined PRIMARY macro")
(defvar nm-exe nil "func obj of last-defined macro")

(defun nm-defining()
  nm-macs)

(defun nm-macroName-to-fn(name)
  (concat (n-host-to-canonical "$dp/emacs/lisp/macros/") name ".el")
  )

(defun nm-fn-to-macroName(name)
  (setq name (nstr-replace-regexp name ".el$" ""))
  (setq name (nstr-replace-regexp name ".*/" ""))
  (concat "nm-macro-" name)
  )

(defun nm-go-cur()
  "go to the current macro-defining buf"
  (if nm-macs
      (set-buffer (car nm-macs)))
  )

(defun nm-begin( &optional arg)
  (interactive "P")
  (if arg
      (serial-begin-or-end)
    (if (not executing-macro)
        (save-window-excursion
          (save-excursion
            (if (nm-go-cur)
                (nm-save-keys)
              (nm-start-kbd-macro)
              )
            (nm-alloc-buf)
            )
          )
      )
    )
  )

(defun nm-alloc-buf()
  (let(
       (procName	 (concat "0.macro-" (n-id)))
       )
    (n-file-find (concat "$NELSON_HOME/tmp/" procName))
    (emacs-lisp-mode)
    (erase-buffer)
    (insert "(defun\n")
    (setq nm-macs (cons procName nm-macs)
          ntags-enabled nil
          )
    )
  )
(defun nm-end-kbd-macro()
  (condition-case nil
      (end-kbd-macro)
    (error (nm-sync))
    )
  )

(defun nm-start-kbd-macro()
  (condition-case nil
      (start-kbd-macro nil)
    (error (nm-sync))
    )
  )

(defun nm-sync()
  (save-window-excursion
    (n-file-find "$dp/emacs/lisp/nm.el")
    (nelisp-compile)
    )
  (message "nm.el: out of sync with EMACS macro package -- recompiled")
  )

(defun nm-save-keys()
  (or (nm-go-cur)
      (error "no selected macro"))
  (nm-end-kbd-macro)
  (n-trace "Last: '%s'\n" last-kbd-macro)

  (narrow-to-region (point) (point))
  (name-last-kbd-macro 'n-temporary)
  (insert-kbd-macro 'n-temporary)
  (delete-region (progn
                   (goto-char (point-min))
                   (point)
                   )
                 (progn
                   (n-s "n-temporary" t)
                   (point)
                   )
                 )
  ;; this was messing up ^um-ralSTRING_UNDER_PT
  ;;(goto-char (point-min))
  ;;(replace-regexp "\\\\M-r" "")

  (goto-char (point-min))
  (insert "(execute-kbd-macro ")
  (goto-char (point-max))
  (widen)
  (nm-start-kbd-macro)
  )

(defun nm-primary-defn()
  "is the current macro the primary one?"
  (null (cdr nm-macs))
  )

(defun nm-change-name(name)
  (goto-char (point-min))
  (forward-line 1)
  (nsimple-delete-line 1)
  (insert "nm-macro-" name)
  (nelisp-load-file)
  )

(defun nm-name-current-kbd-macro()
  "name the current kbd macro"
  (let(
       (name (read-string  "name? "))
       newFn
       )
    (setq newFn (nm-macroName-to-fn name))
    
    (rename-file nm-last-fn newFn 1)
    (setq nm-last-fn newFn)
    (n-file-find nm-last-fn)
    (nm-change-name name)
    
    (n-file-find "$dp/emacs/lisp/data/n-data-menu-macros.el")
    (goto-char (point-min))
    (forward-line 1)
    (insert "			  (cons ?@@ \"" newFn "\")\n")
    (forward-line -1)
    (n-complete-leap)
    (recursive-edit)
    )
  )

(defun nm-end( &optional arg)
  (interactive "P")
  (if (not executing-macro)
      (save-window-excursion
        (save-excursion
          (or (nm-go-cur)
              (error "no selected macro"))
          (nm-save-keys)
          (let(
               (name (buffer-name))
               )
            (nm-finish-func-defn name)
            
            (nm-load name)
            (if (nm-primary-defn)
                (progn
                  (setq nm-macs		nil
                        nm-last-fn	(buffer-file-name)
                        )
                  (nm-end-kbd-macro)
                  )
              (setq data (buffer-substring-no-properties (point-min) (point-max)))
              
              (nbuf-kill-current)
              
              (setq nm-macs (cdr nm-macs))
              (nm-go-cur)
              (goto-char (point-min))
              (insert data)
              (goto-char (point-max))
              (insert (format "( %s )\n" name))
              )
            )
          (bury-buffer)
          )
        )
    )
  (if arg
      (nm-name-current-kbd-macro))
  )

(defun nm-load( name)
  "make executable the current macro, whose name is NAME"
  (nm-go-cur)
  (nelisp-load-file)
  (setq nm-exe (intern-soft name))
  )

(defun nm-finish-func-defn( name)
  (or (nm-go-cur)
      (error "no selected macro"))
  (insert ")\n")
  (n-r "^(defun")
  (forward-line 1)
  (insert (format "%s\n()\n(interactive)\n" name))
  )

(defun nm-repeat-until-error()
  (interactive)
  (message "... ")
  (condition-case nil
      (loop (funcall nm-exe))
    (error	(n-trace "Error terminated macros.")
                )
    )
  (if (nm-defining)
      (save-excursion
	(nm-save-keys)			; interrupt the macro...
	(nm-insert-nm-exe-let)
	(insert "    (nm-repeat-until-error)\n")
	(nm-insert-nm-exe-let-end)
	)
    )
  )

(defun nm-insert()
  "insert LISP from the last kbd macro defined at (point)"
  (interactive)
  (let(
       code
       (name	(read-string "LISP routine name: " (n-name-prefix)))
       )
    (save-excursion
      (find-file nm-last-fn)
      (setq code (buffer-substring-no-properties (point-min) (point-max)))
      )
    (insert code)
    (save-excursion
      (n-r "^(defun")
      (forward-line 1)
      (nsimple-delete-line)
      (insert name "\n")
      )
    )
  )

(defun nm-do-as-asked()
  (interactive)
  (let(
       (cmd       (progn
                    (message "enter nm cmd: a-ssert,d-elay,e-edit,l-lines,n-ame,N-ame-to-current,r-repeat")
                    (read-char))
                  )
       )
    (cond
     ((eq ?a cmd)	(nm-assert-command))
     ((eq ?d cmd)	(nm-run-w-delays))
     ((eq ?e cmd)	(nm-edit))
     ((eq ?G cmd)	(serial-execute))
     ((eq ?i cmd)	(nm-insert))
     ((eq ?l cmd)	(call-interactively 'nm-lines)
      (save-excursion
        (nm-save-keys)				; interrupt the macro...
        (nm-insert-nm-exe-let)
        (insert "    (call-interactively 'nm-lines)\n")
        (nm-insert-nm-exe-let-end)
        )
      )
     
     ((eq ?n cmd)	(nm-name-current-kbd-macro))
     ((eq ?N cmd)	(nm-make-named-kbd-macro-current))
     ((eq ?r cmd)	(nm-repeat-until-error))
     (t		(message "unknown nm cmd: %c" cmd))
     ); cond
    ) ; if ... let
  )

(defun nm-do( &optional arg)
  "do last 'macro' defined"
  (interactive "P")
  (let(
       (nkeys-fast-keys-expected t)
       )
    (cond
     ((integerp arg)
      (while (> arg 0) (setq arg (1- arg)) (funcall nm-exe)))
     (arg
      (nm-do-as-asked))
     (t
      (if (not nm-exe)
          (nm-make-named-kbd-macro-current)
        (let(
             (isearch-lazy-highlight nil)
             (nm-executing t)
             )
          (funcall nm-exe)
          (if (nm-defining)
              (save-excursion
                (nm-save-keys)				; interrupt the macro...
                (insert (format "( %s )\n" (princ nm-exe)))	; for an explicit LISP call
                )
            )
          )
        )
      )
     )
    )
  )

(defun nm-insert-nm-exe-let()
  (insert (format "(let(\n  (nm-exe '%s )\n  )\n" (princ nm-exe)))
  )

(defun nm-insert-nm-exe-let-end()
  (insert "  )\n")
  )

(defun nm-lines( beg end)
  "execute MACRO"
  (interactive "r")
  (goto-char beg)
  (setq end (n-make-marker end))
  (while (<= (point) (marker-position end))
    (funcall nm-exe)
    (forward-line 1)
    )
  )

(defun nm-clean-keys(ss)
  (setq ss (nstr-replace-regexp (nkey-clean ss) "\\\\M-r.\\|\\\\M-r" "")
        ss (nstr-replace-regexp ss "r.\\|r" "")
        )
  )

(defun nm-choose-named-macro(&optional makeCurrent)
  (interactive)
  (let(
       (macroFn	    (nmenu "choose macro" "macros"))
       macroName
       func
       )
    (setq macroName (nm-fn-to-macroName macroFn))
    
    (setq func  (intern-soft macroName))
    (if (not (functionp func))
	(save-window-excursion
	  (n-file-find macroFn)
	  (nelisp-load-file)
	  (bury-buffer)
	  )
      )
    (setq func  (intern-soft macroName))
    (if (not (functionp func))
	(error "nm-execute-named-macro: cannot find function %s" macroName))
    (if makeCurrent
	(setq nm-last-fn macroFn
	      nm-exe     func
	      )
      )
    func
    )
  )

(defun nm-make-named-kbd-macro-current()
  (interactive)
  (funcall (nm-choose-named-macro t))
  )

(defun nm-execute-named-macro()
  (interactive)
  (funcall (nm-choose-named-macro))
  )

(defun nm-edit()
  "edit the last defined kbd macro"
  (let(
       (fn	  nm-last-fn)
       )
    (n-file-find fn)
    (goto-char (point-min))
    (n-s "\"")
    )
  )

(defun nm-run-w-delays()
  (let(
       (delay (n-read-number "enter delay"))
       )
    (condition-case nil
        (loop
         (funcall nm-exe)
         (sleep-for delay)
         )
      (error	(n-trace "Error terminated macros.")
                )
      )
    )
  )
(defun nm-assert-command()
  (save-excursion
    (let(
         (cmd (progn
                (message "Assert l-ooking-at,L-not-looking-at,r-egexp can be found,R-egexp can't be found")
                (read-char)
                )
              )
         s
         )
      (cond
       ((or
         (eq cmd ?l)
         (eq cmd ?L)
         )
        (setq s (read-string "Enter string to ck against what's under pt:"))
        (if (eq cmd ?l)
            (if (not (looking-at s))
                (error "nm-assert-command: did not see expected string %s" s))
          )
        (if (eq cmd ?L)
            (if (looking-at s)
                (error "nm-assert-command: saw unexpected string %s" s))
          )
        )
       ((or
         (eq cmd ?r)
         (eq cmd ?R)
         )
        (setq s (read-string "Enter string to search for:"))
        (if (eq cmd ?r)
            (if (not (n-s s))
                (error "nm-assert-command: could not find %s" s))
          )
        (if (eq cmd ?R)
            (if (n-s s)
                (error "nm-assert-command: found %s" s))
          )
        )
       )
      )
    )
  )
