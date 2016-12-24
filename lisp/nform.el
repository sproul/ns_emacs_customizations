(provide 'nform)
;; to do an invoice go into data/invoice and hit ^cf
;; 
(defun nform-get-translations-category(category)
  (goto-char (point-min))
  (if (n-s (concat "^\\[[^\n]*" category))
      (let(
           translations
           variable
           value
           )
        (goto-char (point-min))
        (forward-line 1)
        (narrow-to-region (point) (progn
                                    (if (n-s "^\\[")
                                        (forward-line 0)
                                      (goto-char (point-max))
                                      )
                                    (point)
                                    )
                          )
        (goto-char (point-min))
        (while (not (eobp))
          (setq variable (buffer-substring-no-properties (point) (progn
                                                     (n-s "=" t)
                                                     (forward-char -1)
                                                     (point)
                                                     )
                                           )
                setting (buffer-substring-no-properties (progn
                                            (forward-char 1)
                                            (point)
                                            )
                                          (progn
                                            (end-of-line)
                                            (point)
                                            )
                                          )
                )
          (if (string-match "^emacs_evaluate\\(.*\\)" setting)
              (save-window-excursion
                ;; "emacs_evaluate" at the beginning of a setting indicates
                ;; that the setting is an emacs lisp expression referring
                ;; to previously defined variables.  Load the expression
                ;; into a temporary buffer, perform the substitutions which
                ;; have been defined up to this point, and evaluate the
                ;; expression.  The resulting value is the setting.
                (n-tmpBuf)
                (insert "(setq setting " (n--pat 1 setting) ")")
                (nform-simple-translations translations)
                (eval-region (point-min) (point-max))
                )
            )
          (setq translations (cons
                              (cons variable setting)
                              translations
                              )
                )
          (forward-line 1)
          )
        (widen)
        translations
        )
    )
  )
(defun nform-substitute-insert-included-files()
  (goto-char (point-min))
  (let(
       fn
       )
    (while (n-s "%read-file \\([^%]*\\)%")
      (setq fn (n--pat 1))
      (nsimple-delete-line 1)
      (if (file-exists-p fn)
          (insert-file fn))
      (exchange-point-and-mark)
      )
    )
  )
(defun nform-get-translations(category)
  (save-restriction
    (append
     (nform-get-translations-category "generic")
     (if category
         (nform-get-translations-category category))
     )
    )
  )

(defun nform-simple-translations(translations)
  (goto-char (point-min))
  (while translations
    (setq
     before	(concat "%" (caar translations) "%")
     after	(cdar translations)
     translations	(cdr translations)
     )
    (goto-char (point-min))
    (replace-regexp before after)
    )
  )

(defun nform-substitute(&optional arg)
  (interactive)
  (if (and arg
           (not (stringp arg))
           )
      (setq arg (read-string "nform-substitute: choose category: "))
    )

  ;; do the substitution in a scratch file: $tmp/output
  (copy-file (buffer-file-name) (concat n-local-tmp "output") t)
  (find-file                    (concat n-local-tmp "output"))
  (n-file-refresh-from-disk)	; in case the file loaded in emacs before the copy

  (let(
       translations
       before
       after
       )
    ;; get translations defined at the top of the form
    (narrow-to-region (point-min) (progn
                                    (goto-char (point-min))
                                    (n-s "^$" t)
                                    (forward-line 0)
                                    (point)
                                    )
                      )
    (setq translations (nform-get-translations arg))
    (delete-region (point-min) (point-max))	; clean out these settings
    (widen)

    ;; get global translations from lisp/data/ini file
    (save-window-excursion
      (n-file-push "$dp/emacs/lisp/data/ini")
      (setq translations	(append
                                 translations
                                 (nform-get-translations arg)
                                 )
            )
      )
    (nform-simple-translations translations)

    (nform-substitute-insert-included-files)
    )
  )
(defun nform-etf-one(platform)
  (execute-kbd-macro "\M-x, l data/etf.record" nil)
  (execute-kbd-macro (concat "f" platform "" nil))
  )
(defun nform-etf()
  (interactive)
  ;;(nform-etf-one "cm-ncr")
  ;;(nform-etf-one "cm-sun4")
  (nform-etf-one "cm-sun_svr4")
  (nform-etf-one "cm-hp800")
  (nform-etf-one "cm-rs6000")
  )


