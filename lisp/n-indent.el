(provide 'n-indent)
(make-variable-buffer-local 'n-indent-tab)
(make-variable-buffer-local 'n-indent-in)
(make-variable-buffer-local 'n-indent-in-except)
(set-default 'n-indent-in-except nil)
(make-variable-buffer-local 'n-indent-out)
(defun n-indent()
  (let(
       (refcol	(save-excursion
                  (forward-line 0)
                  (if (not (n-r "[^ \t\n]"))
                      0
                    (forward-line 0)
                    (if (n-s "[^ \t\n]")
                        (forward-char -1))
                    (+ (current-column)
                       (cond
                        ((and
                          n-indent-in
                          (looking-at n-indent-in)
                          (or (not n-indent-in-except)
                              (not (looking-at n-indent-in-except))
                              )
                          )
                         n-indent-tab
                         )
                        (t 0)
                        )
                       )
                    )
                  )
                )
       )
    (save-excursion
      (forward-line 0)
      (if (save-restriction
            (n-narrow-to-line)
            (forward-line 0)
            (prog1
                (n-s "[^ \t]")
              (widen)
              )
            )
          (forward-char -1))
      (if (and n-indent-out
               (looking-at n-indent-out)
               )
          (progn
            (setq refcol (-  refcol n-indent-tab))
            )
        )
      (delete-region (point) (progn
                               (forward-line 0)
                               (point)
                               )
                     )
      )
    (save-excursion
      (forward-line 0)
      (delete-horizontal-space)
      (indent-to-column refcol)
      )
    (if (< (current-column) refcol)
        (move-to-column refcol))
    )
  )

(defun n-indent-region2(p1 p2 column)
  ;; replacement for indent-region, which does not work for me
  ;; in version 19.
  (if indent-line-function
      (progn
	(if (< p2 p1)	; swap if necessary to make p1 < p2
	    (let(
		 (temporary p2)
		 )
	      (setq p2 p1
		    p1 temporary
		    )
	      )
          )
	(save-excursion
	  (let(
	       (lines	(-
			 (progn
			   (goto-char p2)
                           (n-what-line)
			   )
			 (progn
			   (goto-char p1)
			   (n-what-line)
			   )
			 )
			)
	       )
	    (while (>= lines 0)
	      (indent-according-to-mode)
	      (setq lines (1- lines))
	      (forward-line 1)
	      )
	    )
	  )
	)
    )
  )
(defun n-indent-region( &optional arg)
  "indent those lines of the current buffer which are visible, or if REGION is defined, indent the region"
  (interactive "P")
  (condition-case nil
      (if (and
	   ;;(not (eq major-mode 'njavascript-mode))
	   (not (eq major-mode 'sgml-mode))
	   )
	  (let(
	       (p1 (if arg (point)
		     (save-excursion
		       (n-top-of-window)
		       (require 'nc)
		       (nc-beginning-of-defun)
		       (point)
                       )
		     )
		   )
	       (p2 (if arg (mark)
		     (save-excursion
		       (n-bottom-of-window)
		       (point)
		       )
		     )
		   )
	       )
	    (n-indent-region2 p1 p2 nil)
	    (save-restriction
	      (setq p1 (min p1 (point-max)))
	      (setq p2 (min p2 (point-max)))
	      (narrow-to-region p1 p2)

	      (save-excursion
                (goto-char (point-min))
                (replace-regexp "[ \t]*$" "")  ;; not sure why these trailing spaces keep building up, but get rid of 'em!

		(goto-char (point-max))
		(forward-line 0)
		;; this is because if there is a space at the end of the narrowed region, it might not be at eoln, so protect it
		;; by just going to the boln:
		(narrow-to-region (point-min) (point))
		)
              ;; e23: too jumpy
	      ;;(save-excursion
              ;;(goto-char (point-min))
              ;;(replace-regexp "[ \t]*$" "")
              ;;)
	      )
	    )
	)
    (error (message "Error in n-indent-region -- suppressed"))
    )
  )
(defun n-indent-push-to-match-line1(beg end)
  (save-excursion
    (let(
         (indentation (progn
                        (goto-char beg)
                        (forward-line 0)
                        (looking-at "\\([ \t]*\\)")
                        (nre-pat 1)
                        )
                      )
         )
      (save-restriction
        (narrow-to-region beg end)
        (end-of-line)   ;; this to avoid indenting line #1, which is a guide to indentation but doesn't need it itself
        (replace-regexp "^" indentation)
        )
      )
    )
  )
