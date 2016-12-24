(provide 'n-mv-line)
(setq n-mv-to t)
(setq n-mv-del nil)

(defun n-mv-line-to-shell()
  "from *.hi*: grab the current line, and send it to shell"
  (let(
       (line	(n-get-line))
       cmd
       )
    (if (string-match "[0-9]+ \\(.*\\)" line)
        (setq cmd (substring line (match-beginning 1) (match-end 1)))
      (setq cmd line)
      )
    (n-host-shell-cmd cmd)
    )
  (set-buffer "*.hi*")
  (forward-line 1)
  )

(defun n-mv-token()
  (let(
       (tt (n-grab-token))
       )
    (other-window 1)
    (insert " " tt)
    (other-window 1)
    )
  )

(defun n-mv-lines-from-grabbed-file()
  (save-restriction
    (let(
         (lines (n-grab-file-stealthily-get-lines))
         )
      (forward-line 1)
      (narrow-to-region (point) (point))
      (insert lines)
      (goto-char (point-min))
      (n-mv-line 'all-the-lines)
      (delete-region (point-min) (point-max))
      )
    )
  )


(defun n-mv-line( &optional arg)
  "n3.el: in a two window env: either put the current line into the other window,
or grab the other window's current line, and dump it into the current window,
depending on the setting of the variable n-move-from.

If the destination buffer is a command shell, then the moved
line gets sent to the buffer process.
"
  (interactive "P")
  (setq n-mv-line-jump-start	t)

  (n-mv-line-split-to-shell-if-appropriate)

  (if (and arg (listp arg))
      (progn
        (message "a-ll, c-Cite-and-mv-line, C-toggle-Clone-mode, f-grab-File-and-mv-line-from-it, t-mv-Token")
        (setq arg (read-char))
        )
    )
  (cond
   ((or (eq arg ?c) (eq arg 'prepend-filename-and-line))
    (n-mv-line-cite)
    (n-mv-line)
    )
   ((eq arg ?t)
    (n-mv-token)
    )
   ((eq arg ?f)
    (n-mv-lines-from-grabbed-file)
    )
   ((eq arg ?c)
    (require 'n-2-lines)
    (n-2-lines-toggle-clone-mode)
    )
   ((integerp arg)
    (while (> arg 0)
      (setq arg (1- arg))
      (n-mv-line)
      )
    )
   ((or (eq arg ?a) (eq arg 'all-the-lines))
    (while (not (eobp))
      (n-mv-line)
      (end-of-line)
      )
    )
   ((string= (buffer-name) "*.hi*")
    (n-mv-line-to-shell)
    )
   ((progn (other-window 1)
	   (prog1
	       (string-match (buffer-name) "\\*Help\\*$")
	     (other-window -1)
	     )
	   )
    (require 'nelisp)
    (nelisp-get-lisp-invocation-from-help-window)
    )
   ((n-mv-from-c-to-gdb-p)
    (n-mv-from-c-to-gdb arg)
    )
   ((and
     (save-excursion
       (forward-line 0)
       (looking-at "[><]")
       )
     (string-match "^d\\." (buffer-name))
     )
    (n-mv-diff-line)
    )
   (t
    (n-mv-line-meat)
    )
   )	; cond
  )

(defun n-mv-line-statusify( line )
  "insert a stored status line 'o Accomplished whatever!' into status mail, and
remove the bullet in the log to signify that I've cited it"
  (if (string-match "[ \t]*\\(o \\)" line)
      (progn
        (insert "\t" (substring line (match-beginning 1)) "\n")
        (set-buffer ".log")
        (forward-line -1)
        (if (n-s "o ")
            (backward-delete-char 2))
        (forward-line 1)
        t
        )
    )
  )

(defun n-mv-from-c-to-gdb-p()
  (and (equal (nfn-suffix) "c")
       (let(
            isGdb
            )
         (n-mv-line-jump)
         (setq isGdb (string-match "^\\*gdb-" (buffer-name)))
         (n-mv-line-jump)
         isGdb
         )
)
  )

(defun n-mv-from-c-to-gdb( arg)
  "grab C token under point, go to gdb buf and print its value"
  (let(
       (cToken	(n-grab-token))
       )
    (other-window 1)
    (goto-char (point-max))
    (insert (format "p %s%s" (if arg "*" "") cToken))
    )
  (funcall (nkeys-binding "\C-m"))
  )



(defun n-mv-line-toggle-trait()
  (message "toggle line-moving trait: t-to/from, d-delete src lines")
  (let(
       (cmd (read-char))
       )
    (cond
     ((= cmd ?t)
      (message "n-mv-line %s other window"
               (if (setq n-mv-to (not n-mv-to))
                   "to"
                 "from")
               )
      )
     ((= cmd ?d)
      (message "n-mv-line will %sdelete source window lines as they're moved"
               (if (setq n-mv-del (not n-mv-del))
                   ""
                 "not ")
               )
      )
     )
    )
  )
(defun n-mv-line-cite()
  (let(
       (fn	(n-env-use-var-names-str (buffer-file-name) nil))
       (ln	(n-what-line))
       )
    (other-window 1)
    (forward-line 1)
    (insert (format "%s:%d\n" fn ln))
    (forward-line -1)
    (other-window 1)
    )
  )


(defun n-mv-diff-line()
  (forward-line 0)
  (delete-char 2)
  (n-mv-line)
  (n-other-window 1)
  (funcall indent-line-function)
  (n-other-window 1)
  )

(defun n-mv-line-jump()
  "intended to substitute for (other-window 1) as a
method for getting back and forth between n-mv-line's
2 windows.  Removes the assumption that there are no
other windows around."
  (if n-mv-line-jump-start
      (other-window 1)
    (other-window -1)
    )
  (setq n-mv-line-jump-start (not n-mv-line-jump-start))
  )

(defun n-mv-line-split-to-shell-if-appropriate()
  (let(
       (buf (current-buffer))
       (pp (point))
       )
    (other-window 1)
    (if (and
	 (eq buf (current-buffer))
	 (= pp (point))
	 )
	(if (not (y-or-n-p "Looks like just one window: switch to shell?"))
	    (error "^L within same window is stoopit")
 	  (delete-other-windows)
	  (nsimple-split-window-vertically)
	  (nshell)
	  )
      )
    (other-window -1)
    )
  )

(defun n-mv-line-rm-prompt()
  (save-excursion
    (nsimple-back-to-indentation)
    (if (not (save-excursion
               (forward-line 0)
               (looking-at ".*PS1="))
             )
        (delete-region (point) (progn
                                 (forward-line 0)
                                 (point)
                                 )
                       )
      )
    )
  )


(defun n-mv-line-meat()
  (if (not n-mv-to)
      (n-mv-line-jump))
  (if (string= (buffer-name) "*Diff*")
      (progn
	(forward-line 0)
	(delete-char 2)
	)
    )
  (let(
       (fromLog		(equal ".log" (buffer-name)))
       (toMailFromMail	(if (string= (buffer-name) "RMAIL") "MAYBE"))

       toStatus
       curLine
       )
    (save-excursion
      (setq curLine	(buffer-substring-no-properties
                         (progn
                           (forward-line 0)
                           (cond
                            ((and (eq major-mode 'nperl-mode)
                                  (looking-at "# test with:")
                                  )
                             (n-s ":" t)
                             )
                            ;;((looking-at "#")
                            ;; (n-s "#" t)
                            ;; )
                            ((looking-at "--")
                             (n-s "--" t)
                             )
                            )

                           (point)
                           )
                         (progn
                           (end-of-line)
                           (point)
                           )
                         )
            )
      )
    (require 'n-2-lines)
    (if n-2-lines-clone-one-to-one-mode
        (progn
          (setq curLine (nstr-replace-regexp curLine
                                             (nsimple-register-get ?1)
                                             (nsimple-register-get ?2)
                                             )
                )
          (setq curLine (nstr-replace-regexp curLine
                                             (nstr-capitalize (nsimple-register-get ?1))
                                             (nstr-capitalize (nsimple-register-get ?2))
                                             )
                )
          )
      )
    (cond
     (n-mv-del 		(nsimple-delete-line))
     ((nsimple-on-last-line-p)		nil)
     (t 				(forward-line 1))
     )
    (n-mv-line-jump)
    (setq
     toMailFromMail	(and toMailFromMail 	(string-match (buffer-name) "*mail*"))
     toStatus					(string-match (buffer-name)  "^nelson.status")
     )
    (if (or
	 (eq (nkeys-binding "\C-m") 'nshell-send-input)
	 (eq (nkeys-binding "\C-m") 'shell-send-input)
         (eq (nkeys-binding "\C-m") 'comint-send-input)
         )
        (progn
	  (goto-char (point-max))
	  (insert curLine)

          ;; get rid of leading white space
          (nsimple-back-to-indentation)
          (delete-horizontal-space)
          (if (looking-at "#")
              (delete-region (point) (progn
                                       (delete-char 1)
                                       (skip-chars-forward " \t")
                                       (point)
                                       )
                             )
            )

	  (funcall (nkeys-binding "\C-m"))
	  )
      (end-of-line)
      (if (eobp)
	  (insert "\n")
	(forward-line 1)
	(forward-line 0)
	)
      (cond
       ((and fromLog toStatus) 	(n-mv-line-statusify curLine))
       (toMailFromMail
	(insert " >> " curLine "\n"))
       (t
	(insert curLine "\n")
	)
       )
      (forward-line -1)
      )
    )
  (if n-mv-to
      (n-mv-line-jump))
  )
