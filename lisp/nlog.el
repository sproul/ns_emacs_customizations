(provide 'nlog)
(defun nlog-init()



  ;;(setq nlog-file       (concat "$dp/emacs/" ".nlog." n-local-world-name))
  ;;(setq nlog-file-other (concat "$dp/emacs/" ".nlog." (if (string= n-local-world-name "o8") "x" "o8")))

  (setq nlog-file       (concat "$dp/emacs/" ".nlog.x"))
  (setq nlog-file-other (concat "$dp/emacs/" ".nlog.o8"))




  (if (not (boundp ' nlog-mode-map))
      (setq nlog-mode-map (make-sparse-keymap)))
  (define-key nlog-mode-map " " 'n-complete-or-space)
  (define-key nlog-mode-map "\C-l" 'nlog-cite)
  (define-key nlog-mode-map "\M-\"" 'nlog-cite-and-hold)
  )
(nlog-init)
(defun nlog-mode()
  (make-variable-buffer-local 'indent-line-function)
  (setq major-mode 'nlog-mode
        mode-name "nlog mode"
        indent-line-function	'nlog-indent
        )
  (use-local-map nlog-mode-map)
  )

(defun nlog-indent()
  (n-loc-push)
  (back-to-indentation)
  (let(
       (indentation	0)
       )
    (cond
     ((or
       (looking-at ">$")
       (looking-at "[A-Z][a-z][a-z] [0-9]") ; a date?
       )
      (setq indentation 0)
      )
     (t
      (setq indentation 1)
      )
     )
    (delete-horizontal-space)
    (while (> indentation 0)
      (setq indentation (1- indentation))
      (insert "\t")
      )
    )
  (n-loc-pop)
  (if (looking-at "\t$")
      (end-of-line))
  )
(defun nlog-cite( &optional arg)
  (interactive "P")
  (save-excursion
    (if (progn
          (nsimple-back-to-indentation)
          (looking-at "_")
          )
        (delete-char 1)
      )
    )
  (let(
       label
       ln
       cmd
       )
    (cond
     ((stringp arg)
      (setq ln arg)
      )
     (arg
      (setq cmd (progn
                  (message "cite: d-dhc this comment")
                  (read-char)
                  )
            )
      )
     )
    (if (not ln)
        (progn
          (if (looking-at ".*;")
              (let(
                   (label (progn
                            (nsimple-back-to-indentation)
                            (if (looking-at "\\([^;]+: \\)")
                                (nre-pat 1)
                              ""
                              )
                            )
                          )
                   )
                (n-s ";" t)
                (delete-char -1)
                (insert "\n")
                (indent-according-to-mode)
                (nsimple-back-to-indentation)
                (insert label)
                (forward-line -1)
                )
            )
          (setq ln (n-get-line))
          (nsimple-delete-line)
          )
      )
    (if (eq ?d cmd)
        (n-host-shell-cmd-visible (concat "dhc " ln)))

    (save-window-excursion
      (save-excursion
        (nlog (concat ln "\n"))
        )
      )

    (nsimple-back-to-indentation)
    )
  )
(defun nlog-file()
  (interactive)
  (save-buffer)
  (nlog-cite (concat "\t" (buffer-file-name)))
  )

(defun nlog-lisp()
  (interactive)
  (nelisp-compile)
  (save-window-excursion
    (let(
         (func(n-defun-name))
         )
      (nlog (concat "\telisp\t\t" func "\n")
            )
      )
    )
  )
(defun nlog(&optional arg todo)
  (cond
   ((stringp arg)
    (save-window-excursion
      (n-personal-file nlog-file t)
      (forward-line (if todo 1 -1))
      (insert arg)
      (save-buffer)
      (n-file-pop)
      )
    )
   (arg
    (save-window-excursion
      (nlog)
      (n-other-window)

      (require 'n-mv-line)
      (n-mv-line 'prepend-filename-and-line)

      (n-other-window)
      (backward-delete-char 1)
      (insert " ")
      (n-file-pop)
      )
    )
   (t
    (n-personal-file nlog-file t)
    (require 'nelisp)
    (message "%d tasks" (nlog-tasks))
    )
   )
  )
(defun nlog-tasks()
  (save-excursion
    (goto-char (point-max))
    (if (not (n-r "^>"))
        0
      (forward-line 2)
      (prog1
          (- (save-excursion
               (goto-char (point-max))
               (n-what-line)
               )
             (n-what-line)
             )
        )
      )
    )
  )
(defun nlog-cite-and-hold()
  (interactive)
  (require 'n-2-lines)
  (n-2-lines 1)
  (nlog-cite)
  )
(defun nlog-cleanup()
  ;;(nbuf-kill "*Calendar*")
  (nbuf-kill ".nlog")
  (delete-other-windows)
  (n-split-and-flip)
  )
(defun nlog-cmd( &optional arg cmd default)
  (interactive "P")
  (if (and (not n-win)
           (not (string-match "^vagrant" (getenv "HOSTNAME")))
           )
      (error "nlog-cmd: not supported on non-dp platforms")
    )
  (let(
       (cmd (if (not arg)
                nil
              (message "o-ther log, c-ite w/ fn, C-ite w/ fn+LINE")
              (read-char)
              )
            )
       )
    (cond
     ((or (eq cmd ?o)
          (and (not default) (string= (buffer-name) (file-name-nondirectory nlog-file)))
          )
      (let(
           (nlog-file nlog-file-other)
           )
        (nlog-cmd nil nil "default")
        )
      )
     ((or (eq cmd ?c)
          (eq cmd ?C)
          )
      (let(
           (line        (nstr-trim (n-get-line)))
           (citation (nfn-cite))
           )
        (nlog-cmd)
        (forward-line 0)
        (insert "\t")
        (nfly-insert citation)
        (if (eq cmd ?C)
            (insert ": " line))
        (insert "\n")
        (forward-line -1)
        (forward-char 1)
        )
      )
     (t
      (nlog)
      (nbuf-post-for-kill 'nlog-cleanup)
      (delete-other-windows)
      (n-widen t
               (progn
                 (goto-char (point-max))
                 (if (not (n-r "^>"))
                     (insert ">\n"))
                 (forward-line 1)
                 ;;(if (n-file-exists-p "$dp/data/todo")
                 ;;    (progn
                 ;;      (insert (n-file-contents "$dp/data/todo")
                 ;;              )
                 ;;      (n-file-delete "$dp/data/todo")
                 ;;      )
                 ;;  )
                 (n-r "^[A-Z]" t)
                 (point)
                 )
               (point-max)
               )
      (if (not n-is-xemacs)
          (progn
            (if (n-file-exists-p "$dp/todo/todo")
                (n-host-shell-cmd-visible "lst" t t)
              ;;(require 'calendar)
              ;;(calendar)
              (nbuf-post-for-kill 'nlog-cleanup)
              (other-window 1)
              )
            )
        )
      (goto-char (point-min))
      (n-s "^>" t)
      (forward-line 1)
      )
     )
    )
  )
(defun nlog-commit()
  (let(
       (cmt (n-get-line))
       )
    (cond
     ((string-match "^	\\(.\\) \\(.*\\)" cmt)
      (let(
           (prod-code   (nre-pat 1 cmt))
           )
        (setq cmt (nstr-replace-regexp cmt "^[ \t]*[a-z][ \t]*" ""))
        (nlog-cite)
        (n-host-shell-cmd-visible (concat "commit_prod " prod-code " '" cmt "'"))
        )
      )
     (t (error "nlog-commit: unknown product in %s" cmt))
     )
    )
  )

(defun nlog-cite-cut-subtask()
  (let(
       subtask-no-header
       (subtask-no-header--end (progn
                                 (n-s ";" t)
                                 (delete-char -1)
                                 (point)
                                 )
                               )
       (subtask-no-header--start (save-restriction
                                   (n-narrow-to-line)
                                   (if (n-r ";")
                                       (1+ (point))
                                     (if (n-r ":")
                                         (forward-char 1)
                                       (nsimple-back-to-indentation)
                                       )
                                     (point)
                                     )
                                   )
                                 )
       (header  (buffer-substring-no-properties (progn
                                                  (forward-line 0)
                                                  (point)
                                                  )
                                                (save-restriction
                                                  (n-narrow-to-line)
                                                  (nsimple-back-to-indentation)
                                                  (n-s ":")  ;; if no : is found, this will be just the white space indentation for the line
                                                  (point)
                                                  )
                                                )
                )
       )
    (setq header (nstr-replace-regexp header "^\\([ \t]*\\)_" "\\1")
          subtask-no-header (buffer-substring-no-properties subtask-no-header--start
                                                            subtask-no-header--end
                                                            )
          )
    (delete-region subtask-no-header--start
                   subtask-no-header--end)
    (goto-char subtask-no-header--start)
    (concat header subtask-no-header)
    )
  )
