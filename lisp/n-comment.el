(provide 'n-comment)
(make-variable-buffer-local 'n-comment-side-column)
(make-variable-buffer-local 'n-comment-end)
(make-variable-buffer-local 'comment-start)
(make-variable-buffer-local 'n-comment-boln)

(defun n-comment()
  "start a comment"
  (interactive)
  (cond
   ((n-comment-p)
    (n-comment-end-wide)
    )
   ((n-comment-inside-p)
    (forward-line 1)
    (back-to-indentation)
    )
   ((n-comment-inside-unclosed-p)
    (n-comment-end-side)
    )
   ((n-comment-on-same-line-p)
    (search-forward comment-start)
    (skip-chars-forward " \t")
    )
   ((nsimple-blank-line-p)
    (n-comment-begin-wide)
    )
   (t
    (n-comment-begin-side)
    )
   )
  )

(defun n-comment-begin-wide()
  (if (not (nsimple-blank-line-p))
      (progn
        (forward-line 0)
        (insert "\n")
        (forward-line -1)
        )
    )
  (indent-according-to-mode)
  (insert comment-start "\n")
  (insert n-comment-boln " ")
  (indent-according-to-mode)
  )
(defun n-comment-begin-side()
  (cond
   ((save-excursion
      (forward-line 0)
      (looking-at "#include")
      )
    (end-of-line)
    (just-one-space)
    (delete-char -1)
    (insert "\t" comment-start " For ")
    )
   ((< (current-column) 40)
    (indent-to-column 40)
    (insert comment-start " ")
    )
   (t
    (forward-line -1)
    (n-comment-begin-wide)
    )
   )
  )

(defun n-comment-convert-side-to-wide()
  (let(
       commentTextBefore
       commentTextAfter
       begin
       end
       )
    (setq end			(point)
          begin		(progn
                          (forward-line 0)
                          (search-forward comment-start)
                          (skip-chars-forward " \t")
                          (point)
                          )
          commentTextBefore	(buffer-substring-no-properties begin end)
          )
    (delete-region begin end)
    (setq begin		(point)
          end 		(progn
                          (end-of-line)
                          (if (and
                               n-comment-end
                               (search-backward n-comment-end begin t)
                               )
                              (1- (point))
                            (point)
                            )
                          )
          commentTextAfter	(buffer-substring-no-properties begin end)
          )
    
    (delete-region (progn
                     (end-of-line)
                     (search-backward comment-start)
                     (skip-chars-backward " \t")
                     (point)
                     )
                   (progn
                     (end-of-line)
                     (point)
                     )
                   )
    (forward-line 0)
    (insert "\n")
    (forward-line -1)
    (n-comment)
    (insert commentTextBefore " ")
    (save-excursion
      (insert commentTextAfter)
      )
    )    
  )
(defun n-comment-inside-unclosed-p()
  (n-comment-p nil 'inside-unclosed)
  )
(defun n-comment-inside-p()
  (n-comment-p nil 'inside)
  )
(defun n-comment-on-same-line-p(&optional lineOffset)
  (n-comment-p lineOffset 'on-same-line)
  )
(defun n-comment-p(&optional lineOffset arg)
  (if comment-start
      (save-excursion
        (save-restriction
          (if lineOffset
              (forward-line lineOffset))
          (let(
               (savedPoint	(point))
               (begin 	(progn
                          (forward-line 0)
                          (point)
                          )
                        )
               (end 	(progn
                          (end-of-line)
                          (point)
                          )
                        )
               )
            (goto-char savedPoint)
            (cond
             ((eq arg 'inside)
              (goto-char begin)
              (and
               (search-forward comment-start savedPoint t)
               (or (not n-comment-end)
                   (progn
                     (goto-char savedPoint)
                     (search-forward n-comment-end end t)
                     )
                   )
               )
              )
             ((and
               (eq arg 'inside-unclosed)
               (search-backward comment-start begin t)
               )
              t)
             ((and
               (eq arg 'on-same-line)
               (search-forward comment-start end t)
               )
              t)
             ((progn
                (forward-line 0)
                (skip-chars-forward " \t")
		(require 'nre)
                (nre-looking-at-no-regexp n-comment-boln)
                )
              t)
             (t
              nil)
             )
            )
          )
        )
    )
  )
(defun n-comment-virgin-p()
  (save-excursion
    (forward-line 0)
    (skip-chars-forward " \t")
    (search-forward n-comment-boln (+ (point) (length n-comment-boln)) t)
    (skip-chars-forward " \t")
    (looking-at "\n")
    )
  )
(defun n-comment-indent()
  (indent-according-to-mode)
  (if (and
       (not (eq major-mode 'nhtml-mode))
       (n-comment-p -1)
       (n-comment-virgin-p)
       )
      (let(
           (indentationFront	(progn
                                  (forward-line -1)
                                  (search-forward n-comment-boln)
                                  (skip-chars-forward " \t")
                                  (current-column)
                                  )
                                )
           (indentationBack	(save-restriction
                                  (n-narrow-to-line)
                                  (end-of-line)
                                  (if (not (n-r "\t"))
                                      0
                                    (forward-char 1)
                                    (current-column)
                                    )
                                  )
                                )
           )
        (forward-line 1)
        (end-of-line)
        (indent-to-column (max indentationFront indentationBack))
        )
    )
  )
(defun n-comment-space()
  (cond
   ((n-comment-virgin-p)
    (n-comment-indent)
    )
   ((> 72 (current-column))
    (insert " ")
    )
   ((< 80 (current-column))
    (end-of-line)
    (let(
         data
         begin
         end
         )
      (setq data (if (save-restriction
                       (n-narrow-to-line)
                       (forward-line 0)
                       (forward-char 80)
                       (not (n-r " ")) 
                       )
                     ""
                   (setq begin (progn
                                 (delete-char 1)
                                 (point)
                                 )
                         end (progn
                               (end-of-line)
                               (point)
                               )
                         )
                   (prog1
                       (buffer-substring-no-properties begin end)
                     (delete-region begin end)
                     )
                   )
            )
      (nsimple-newline-and-indent)
      (insert data " ")
      )
    )
   (t
    (nsimple-newline-and-indent)
    )
   )
  (indent-according-to-mode)
  )
(defun n-comment-back-to-indentation()
  (let(
       key
       )
    (search-forward n-comment-boln)
    (skip-chars-forward " \t")
    (setq key (read-char))
    (if (= key ?,)
        (nfly-jump)
      (n-ungetc key)
      )
    )
  )
(defun n-comment-end-wide()
  (end-of-line)
  (insert "\n")
  (indent-according-to-mode)
  (if n-comment-end
      (insert n-comment-end "\n")
    (insert n-comment-boln "\n")
    )
  (indent-according-to-mode)
  (if (and (not (eobp))
           (nsimple-blank-line-p)
           )
      (progn
        (nsimple-kill-line 1)
        (nsimple-back-to-indentation)
        )
    )
  )
(defun n-comment-end-side()
  (end-of-line)
  (just-one-space)
  (if n-comment-end
      (insert n-comment-end))
  (if (eobp)
      (nsimple-newline-and-indent)
    (forward-line 1)
    (back-to-indentation)
    )
  )
(defun n-comment-routine()
  (interactive)

  (forward-line -1)
  (if (not (looking-at "$"))
      (progn
	(end-of-line)
	(insert "\n")
        )
    )

  (save-restriction
    (narrow-to-region (point) (point))
    (insert n-comment-boln "\n")
    (yank)
    (insert "\n")
    (goto-char (point-min))
    (let(
         (begin (point))
         )
      (goto-char (point-min))
      (nsimple-marginalize-region 75 (point-min) (point-max))

      (goto-char (point-max))
      (insert "_____")
      (goto-char (point-min))
      )
    )
  (while
      (progn
        (forward-line 0)

        ;; This is needed because if there are no spaces at the beginning of the line, the
        ;; indentation function does not work
        (just-one-space)

        (indent-according-to-mode)
        (if (looking-at ".*_____")
            nil
          (forward-line 1)
          )
        )
    )
  (n-s "_____" t)
  (delete-char -5)
  )
