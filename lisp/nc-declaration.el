(provide 'nc-declaration)
(setq nc-declaration-data-regexp "^[ \t]*\\(static[ \t]+\\)?\\(struct[ \t]+\\)?[a-zA-Z_0-9]+")
(setq nc-declaration-field-regexp "^[ \t]*\\(struct \\)?[a-zA-Z0-9_]+$")

(defun nc-declaration-indent()
  (interactive)
  (if (save-excursion
        (forward-line 0)
        (not (looking-at nc-declaration-field-regexp))
        )
      (n-complete-leap)
    (let(
         (proposedIndentation	(nc-declaration-propose-indentation))
         (referenceIndentation	(nc-declaration-reference-indentation))
         )
      (cond
       ((> proposedIndentation referenceIndentation)
        (nc-declaration-indent-block proposedIndentation)
        )
       ((< proposedIndentation referenceIndentation)
        (indent-to-column referenceIndentation)
        )
       )
      )
    )
  )
(defun nc-declaration-propose-indentation()
  (insert "\t")
  (current-column)
  )
(defun nc-declaration-reference-indentation()
  (save-excursion
    ;; go up to the previous line, skipping comments, and see what the
    ;; indentation is for that data item
    (while (progn
             (forward-line -1)
             (end-of-line)
             (n-r "[ \n\t]*")
             (forward-char -2)
             (if (not (looking-at "\\*/"))
                 nil		; found something which isn't a comment
               (n-r "/\\*" t)	; end of a comment.  Find its beginning
               t
               )
             )
      )
    (n-narrow-to-line)
    (forward-line 0)
    (prog1
        (if (n-s "[^;][ \t]*$")
            0	; no semicolon means this is not a data nc-declaration.  Thus there is no reference.
          (if (n-s (concat nc-declaration-data-regexp "[ \t]+"))
              (current-column)	; looks like a data nc-declaration
            0			; don't know what this looks like
            )
          )
      (widen)
      )
    )
  )
(defun nc-declaration-indent-block(dataIndentation)
  ;; in the block of data nc-declarations currently containing point, indent
  ;; the names to 'dataIndentation'
  (narrow-to-region (progn
                      (n-r ")[ \t]*$\\|^{" t)
                      (point)
                      )
                    (progn
                      (forward-line 1)
                      (n-s "^[ \t]*$\\|^{\\|^}" 'eof)
                      (point)
                      )
                    )
  (goto-char (point-min))
  (while (n-s nc-declaration-data-regexp)
    (delete-horizontal-space)
    (indent-to-column dataIndentation)
    )
  (widen)
  )

;;(defun n-x7()
;;  (interactive)
;;  (find-file-other-window "/remote/conn3/csi/users/dce/nelson/dp/emacs/lisp/ks.c")
;;  (goto-char (point-min))
;;  (n-s "TU_RUN_THREAD_INSTANCE" t)
;;  (n-s "TU_RUN_THREAD_INSTANCE" t)
;;  (nc-declaration-indent)
;;  )

