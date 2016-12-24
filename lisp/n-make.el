(provide 'n-make)
					;(defun n-x8()
					;  (interactive)
					;  (set-buffer "ks")
					;  (message "x=%s" (n-make-eval-var "X"))
					;  )
					;
(setq n-make-sybdummy (list
                       (cons "LIBDIRTAIL"	"lib")
                       (cons "LIBSUFFIX"	".a")
                       (cons "OBJSUFFIX"	".o")
                       )
      
      )

(defun n-make-eval-pt-token()
  (n-make-eval (n-grab-token2)))

(defun n-make-eval-pt()
  "macro-expand the token under point and show it on the msg line"
  (interactive)
  (message "%s" (n-make-eval-pt-token))
  )

(defun n-make-eval( exp &optional buf)
  "perform substitutions necessary to evaluate STR, a makefile expression
defined in the current buf"
  (if (not buf)
      (setq buf (current-buffer)))
  (save-window-excursion
    (let(
         subexp
         )
      (set-buffer (n-zap (concat "ks-" exp)))
      (insert exp)

      (while (progn
               (goto-char (point-min))
               (n-s "\\$(\\([a-zA-Z0-9_]+\\))"))
        (setq subexp (buffer-substring-no-properties (match-beginning 1)
                                       (match-end 1))
              )
        (delete-region (match-beginning 0)
                       (match-end 0))
        (insert (n-make-eval  (n-make-rtv-defn subexp buf)
                              buf))
        )
      (setq exp (buffer-substring-no-properties (point-min) (point-max)))
      (kill-buffer (current-buffer))
      )
    exp
    )
  )

(defun n-make-eval-var( var)
  "macro-expand a makefile var VAR"
  (n-make-eval (concat "$(" var ")"))
  )

(defun n-make-rtv-defn( var buf)
  "evaluate make-style VAR in BUF"
  (let(
       (cbuf (current-buffer))
       defn
       )
    (set-buffer buf)
    (save-excursion
      (goto-char (point-min))
      (setq defn (cond
                  ((n-s (concat "^[ \t]*" var "[ \t]+=[ \t]+"))
                   (n-grab-defn)
                   )
                  ((assoc var n-make-sybdummy)
                   (cdr (assoc var n-make-sybdummy))
                   )
                  (t
                   (nsimple-getenv var)
                   )
                  )
            )
      )
    (set-buffer cbuf)
    defn
    )
  )

(defun n-grab-defn()
  "return a defn starting at point and continuing to eoln, and if \ precedes
\n, including succeeding lines"
  (buffer-substring-no-properties (point)
                    (progn
                      (n-s "[^\\]\n")
                      (forward-char -1)
                      (point))
                    )
  )

(defun n-make-outside-eval( var &optional &rest additionalVars)
  "go find the Makefile and extract the value of $(VAR)."
  (save-excursion
    (let(
         (makeFile (cond
                    ((file-readable-p "Makefile") "Makefile")
                    ((file-readable-p "makefile") "makefile")
                    ((file-readable-p 	(concat "../generic/Makefile"))
                     (concat "../generic/Makefile"))
                    ((file-readable-p	(concat "../generic/makefile"))
                     (concat "../generic/makefile"))
                    )
                   )
         val
         )
      (setq val (if (not makeFile)
                    (getenv var)
                  (n-file-push makeFile)
                  (prog1
                      (n-make-eval-var var)
                    (n-file-pop)
                    )
                  )
            )
      (if (and (or (not val)
                   (string= val "")
                   )
               additionalVars
               )
          (apply 'n-make-outside-eval additionalVars)
        val
        )
      )
    )
  )
(defun n-make-possibly-add-to()
  (let(
       (fnPrefix (nfn-prefix))
       )
    (if (and
	 (file-exists-p "makefile")
	 (save-window-excursion
	   (find-file "makefile")
	   (goto-char (point-min))
	   (not (n-s (concat "\\b" fnPrefix "\\b")))
	   )
	 (y-or-n-p "add to makefile? ")
	 )
	(progn
	  (find-file-other-window "makefile")
	  (require 'nsyb)
	  (nsyb-cm-lock-if-necessary)
	  (goto-char (point-min))
	  (cond
	   ((n-s "java_modules =")
	    (forward-line 1)
	    (insert "\t" fnPrefix ".class\t\\\n")
	    )
	   ((n-s "^CLASSES =")
	    (forward-line 1)
	    (insert "\t" fnPrefix "\t\\\n")
	    )
	   (t
	    (error "n-make-possibly-add-to: ")
	    )
	   )
	  )
      )
    )
  )
