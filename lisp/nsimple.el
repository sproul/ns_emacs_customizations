(provide 'nsimple)
(setq nsimple-shared-completes
      (list
       (list	".*\\.u$"	'n-complete-replace	"\\.u" ".us.oracle.com@@")
       )
      )

(setq nsimple-line-max-that-is-comfortable-to-look-at 179)
;; kill logic:
;;      on unix, the kill always works through nsimple-yank-data-file.
;;      on PCs on xemacs, when we set the kill, we always set the contents of nsimple-yank-data-file (but we rely on the xemacs to read from the clipboard)
;;      on PCs on cygwin emacs, I think it works like unix.  (Need to check to see what kind of clipboard integration they support.)
;;
;; On nelsons-xp the performance was terrible where I would synchronously update that remote file from LISP.  So I'm switching to a model where the nsimple-yank-data-file
;; is always local, and we leave it to emacs_propagate_clipboard to do the slow, network-bound stuff if appropriate.
;; n.b.: following setting must be matched by hardcoded values in clipboard_watcher.ahk:
(setq nsimple-yank-data-file (concat (if n-win "/cygdrive/c" (getenv "HOME")) "/tmp/global_emacs_kill")) ;; slow if in HOME under Windows.  Why??
(setq nsimple-yank-propagation-cached-origin (getenv "SSH_ORIGIN"))
(setq nsimple-yank-dropbox-global-data-file (concat (getenv "dp") "/data/kill.txt"))

(defconst nsimple-BORDER "===================================================================\n")

(defun yes-or-no-p(prompt)
  (y-or-n-p prompt)
  )
(defun nsimple-macro-on-file()
  (interactive)
  (save-window-excursion
    (funcall (nkeys-binding "e"))
    (nm-do)
    )
  (funcall (nkeys-binding "n"))
  )
(defun nsimple-scroll-up()
  (interactive)
  (scroll-up -6)
  )
(defun nsimple-scroll-down()
  (interactive)
  (scroll-down -6)
  )
(defun nsimple-kill-line(&optional arg)
  (interactive)
  (if (eobp)
      (progn
        (forward-line 0)
        (if (eobp)
            (progn
              (delete-char -1)
              (nsimple-back-to-indentation)
              )
          (kill-region (point) (point-max))
          )
        )
    (save-excursion
      (end-of-line)
      (if (eobp)
          (insert "\n"))
      )
    (kill-region (progn
                   (forward-line 0)
                   (point)
                   )
                 (progn
                   (end-of-line)
                   (forward-char 1)
                   (point)
                   )
                 )
    )
  (if (and (eobp)
           (not (bobp))
           )
      (forward-line -1)
    )
  (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
  (setq this-command 'kill-region);; to append next kill
  )
(defun nsimple-kill-line-OLD_COMPLEX_HARD_TO_APPRECIATE_____UNUSED(&optional arg)
  "n1.el:  kill a line"
  (interactive "*p")

  (let (
        atEof
        up
        (additionalLines	(if arg (1- arg) 0))
        end
        beg
)
    (setq end      (save-excursion

                     (if arg
                         (setq additionalLines (forward-line additionalLines)))
                     (end-of-line)
                     (if (eobp)
                         (progn
                           (insert "\n")
                           (setq atEof t)
                           )
                       (forward-char 1)
                       )
                     (point)
                     )
          )
    (setq beg     (progn
                    (forward-line (- additionalLines))
                    (if (and atEof (not (bobp)))
                        (setq up t)
                      )
                    (point)
                    )
          )


    (if (nbuf-read-only-p)
        (nsimple-copy-region-as-kill beg end)
      (kill-region beg end)
      )


    (if (and up
             (string= (n--get-lisp-func-name this-command) "nsimple-kill-line")
             )
        (backward-delete-char 1))
    )
  (if (string-match "midnight.grep" (buffer-name))
      (if (eobp)
          (forward-line -1)      ;; I never want to be at EOF on an empty line if I'm looking at grep output
        )
    (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
    (setq this-command 'kill-region);; to append next kill
    )
  )

(defun nsimple-absorb()
  (interactive)
  (message "nsimple-absorb")
  (read-char)
  )
(defun nsimple-boln-p()
  (save-restriction
    (narrow-to-region (point)
                      (progn
                        (forward-line 0)
                        (point)
                        )
                      )
    (funcall (nkeys-binding "\C-a"))    ;; this way we'll just go back to the prompt if we're in a shell
    (prog1
        (looking-at "[ \t]*$")
      (goto-char (point-max))
      (widen)
      )
    )
  )
(defun nsimple-back-to-indentation()
  (interactive)
  (let(
       (inhibit-field-text-motion t)
       )
    (back-to-indentation)
    (cond
     ((and (eq major-mode 'gud-mode) (looking-at ".* <[0-9]+>"))
      (n-s ">[ \t]*" t)
      )
     (t
      (save-restriction
        (n-narrow-to-line)
        (back-to-indentation)
        (cond
                                        ;((eq major-mode 'minibuffer-inactive-mode)
                                        ; (forward-line 0)
                                        ; (n-s ": " t)
                                        ; )
         ((or
           (eq major-mode 'shell-mode)
           (eq major-mode 'nmidnight-mode)
           )
          (if (save-excursion
                (n-s shell-prompt-pattern)
                )
              (progn
                (end-of-line)
                (n-r shell-prompt-pattern t)
                (n-s shell-prompt-pattern t)
                )
            )
          )
         ;; Also look out for the leading stuff ant inserts (e.g., "[exec]"):
         ((and (eq major-mode 'nmidnight-mode)
               (looking-at "\\[[-0-9a-zA-Z_]+\\] ")
               )
          (n-s " " t)
          )
         )
        )
      )
     )
    )
  )

(setq kill-ring nil) ;; don't need this forever, but I'm screwing it up now -- gotta reset
(defun nsimple-yank-set-emacs-kill-from-my-global-kill()
  (save-window-excursion
    (save-excursion
      (let(
           (data (progn
      ;;(if (not (file-readable-p nsimple-yank-data-file))
                   ;;(n-file-chmod "777" nsimple-yank-data-file))
                   (set-buffer (find-file-noselect nsimple-yank-data-file))

                   ;;(delete-region (point-min) (point-max))
                   ;;(call-process "xsel" nil t nil "-p")
                   ;;(prog1
                   ;;(buffer-substring-no-properties (point-min) (point-max))
                   ;;)

                   (buffer-substring-no-properties (point-min) (point-max))
                   )
                 )
           )
        ;;(cond
        ;;((and kill-ring
        ;;(string= data (car kill-ring))
        ;;)
        ;;nil
        ;;)
        ;;(t
        ;;(setq kill-ring (cons data kill-ring))
        ;;)
        ;;)

        (if (or (not kill-ring)
                (not (car kill-ring))
                (not (equal data (car kill-ring)))
                )
            (apply nsimple-original-copy-region-as-kill (list
                                                         (point-min) (point-max)
                                                         )
                   )
          )


        (not-modified)
        (kill-buffer nil)
        )
      )
    )
  )

(defun nsimple-yank()
  (if (and (not n-is-xemacs)
           (nsimple-yank-data-file-in-effect)
           )
      (nsimple-yank-set-emacs-kill-from-my-global-kill))
  (yank)
  )

(setq nsimple-yanker-dft--cached-prompt-to-convert-backslashes-data nil)  ;; input_data to ("n"|"y")
(defun nsimple-convert-backslashes-for-this-string-in-future(ynd data)
  (setq nsimple-yanker-dft--cached-prompt-to-convert-backslashes-data (cons
                                                                       (cons data ynd)
                                                                       nsimple-yanker-dft--cached-prompt-to-convert-backslashes-data
                                                                       )
        )
  )

(defun nsimple-yanker-dft--cached-prompt-to-convert-backslashes()
  (let(
       (input (buffer-substring-no-properties (point-min) (point-max)))
       cachedYnd
       cachedYndNode
       ynd
       )
    (setq cachedYndNode (assoc input nsimple-yanker-dft--cached-prompt-to-convert-backslashes-data)
          cachedYnd (if cachedYndNode (cdr cachedYndNode))
          )
    (if (not cachedYnd)
        (progn
          (message "m-mixed, 2-double, u-unix")
          (setq ynd (read-char)
                cachedYnd ynd
                )
          (nsimple-convert-backslashes-for-this-string-in-future ynd input)
          )
      )
    cachedYnd
    )
  )

(setq  nsimple-yanker-dft--possibly-remove-chaf--hitlist nil)
(defun nsimple-yanker-dft--possibly-remove-chaf(patt)
  (save-excursion
    (goto-char (point-min))
    (if (n-s patt)
        (let(
             (patt-to-remove (assoc patt nsimple-yanker-dft--possibly-remove-chaf--hitlist))
             )
          (if (not patt-to-remove)
              (setq patt-to-remove (cons patt  (nsimple-y-or-n-p (format "filter out %s (y/n)?" patt)))
                    nsimple-yanker-dft--possibly-remove-chaf--hitlist (cons patt-to-remove nsimple-yanker-dft--possibly-remove-chaf--hitlist)
                    )
            )
          (if (cdr patt-to-remove)
              (progn
                (goto-char (point-min))
                (replace-regexp patt "")
                )
            )
          )
      )
    )
  (goto-char (point-min))
  )
(defun nsimple-yanker-dft()
  (save-restriction
    (narrow-to-region (point) (point))
    (nsimple-yank)
    (undo-boundary)
    (goto-char (point-min))
    (if (and (looking-at "/")
             (not (n-s "\n"))
             )
        (nfly-insert (nsimple-cut-all))
      )
    (let(
         (lineCount	 (n-what-line))
         change
         )
      (save-excursion
        (nsimple-yanker-dft--possibly-remove-chaf "^root.*# ")

        (goto-char (point-min))
        (replace-regexp "" "\"")
        (goto-char (point-min))
        (replace-regexp "" "'")
        (goto-char (point-min))
        (replace-regexp "" "\"")
        (goto-char (point-min))
        ;;(replace-regexp "@@" "-")

        (goto-char (point-min))
        (if (and
             (not (looking-at "\\\\.$"))
             (n-s "\\\\[^\"\\\\]")
             ;;(not (n-s "[ \t\n/\*\+]"))
             (not (n-s "\""))
             (setq change (nsimple-yanker-dft--cached-prompt-to-convert-backslashes))
             )
            (progn
              (goto-char (point-min))
              (cond
               ((= ?m change) (replace-regexp "\\\\" "/"))
               ((= ?2 change) (replace-regexp "\\\\" "\\\\\\\\"))
               ((= ?u change) (progn
                                (replace-regexp "\\\\" "/")
                                (goto-char (point-min))
                                (replace-regexp "^\\(.\\):" "/cygdrive/\\1")
                                )
                )
               )
              )
          )

        (goto-char (point-min))
        (if (and
             (not (n-s "[ \t\n/\\*]+"))
             (not (n-s "://"))
             (n-s "//")
             (not (nsyb-p4-near-command))
             (not (eq 'cygwin system-type))
             (y-or-n-p "convert to single forward slashes? ")
             )
            (progn
              (goto-char (point-min))
              (replace-regexp "//" "/")
              )
          )
        )
      (if (progn
            (goto-char (point-min))
            (save-excursion
              (not (n-s "^[^-]"))         ; if every boln is '-',
              (n-s "\n")                  ; and there are multiple lines, then we are looking at context diff output.  Get rid of the hyphens
              )
            )
          (replace-regexp "^-" "")
        )

      (widen)
      (if nsimple-yanker-should-indent
          (save-excursion
            (undo-boundary)
            (cond
             ((= lineCount 1)
              (indent-according-to-mode)
              )
             ((= lineCount 2)
              (indent-according-to-mode)
              (forward-line -1)
              (indent-according-to-mode)
              )
             (t
              (call-interactively 'n-indent-region)
              )
             )
            )
        )
      )
    )
  )

(defun nsimple-yanker-and-leaper()
  (yank)
  (goto-char (point-min))
  (n-complete-leap)
  (if nsimple-yanker-should-indent
      (progn
        (undo-boundary)
        (call-interactively 'n-indent-region))
    )
  )

(setq nsimple-yanker 'nsimple-yanker-dft)
(defvar nsimple-yanker-should-indent nil)
(make-variable-buffer-local 'nsimple-yanker-should-indent)

(defun nsimple-yank-hook-clean-aria-copy-and-paste()
  ;; clean up after pasting from Aria, e.g.:
  ;; +1 (650) 506-8243
  ;; Work Email: steven.frehe@oracle.com
  ;; Address: 200 Oracle Parkway
  (goto-char (point-min))
  (replace-regexp "\n" " ")
  (goto-char (point-min))
  (n-s "(\\([0-9][0-9][0-9]\\)) \\([0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]\\).*: \\([^ ]*@oracle.com\\)")
  (let(
       (areacode   (nre-pat 1))
       (phone   (nre-pat 2))
       (email   (nre-pat 3))
       )
    (delete-region (point-min) (point-max))
    (insert email " " areacode " " phone "\n")
    )
  )

(defun nsimple-yank-hook()
  (cond
   ((and (string= (buffer-name) "information.pt")
         (save-excursion
           (goto-char (point-min))
           (n-s "^Work Email:")
           )
         )
    (nsimple-yank-hook-clean-aria-copy-and-paste)
    )
   )
  (nsimple-yank-hook-rm-diff-bs)
  )
(defun nsimple-yank-hook-rm-diff-bs()
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "^[<>] " "")
    )
  )

(defun nsimple-yanker-caller()
  (setq nsimple-yanker-should-indent  (or
                                       (eq major-mode 'emacs-lisp-mode)
                                       (eq major-mode 'nperl-mode)
                                       (eq major-mode 'nsh-mode)
                                       (and (eq major-mode 'njava-mode)
                                            (not (string-match "HibernateGamerSite.java" (buffer-file-name)))
                                            )
                                       )
        )
  (save-restriction
    (narrow-to-region (point) (point))
    (if (listp nsimple-yanker)
        (apply (car nsimple-yanker) (cdr nsimple-yanker))
      (funcall nsimple-yanker)
      (nsimple-yank-hook)
      )
    (goto-char (point-max))
    )
  )
(defun nsimple-yank-command( &optional arg)
  (interactive "P")
  (let(
       (data (match-data))
       )
    (if (not arg)
        (nsimple-yanker-caller)
      (message "0-9-repeat, c-ommentify, d-dropbox, i-ndent/process-not, j-ava_class_import_string")
      (let(
           (command (read-char))
           )
        (cond
         ((equal command ?c)
          (save-restriction
            (narrow-to-region (point) (point))
            (nsimple-yank-command)
            (if (save-excursion
                  (forward-char -1)
                  (not (looking-at "\n"))
                  )
                (insert "\n")
	      )
	    (goto-char (point-min))
	    (nsimple-marginalize-region 75 (point-min) (point-max))



            ;; The reason I did this is that I need to have at least one line exposed behind the region of newly inserted stuff.
            ;; This line is needed as a reference point for the proper indentation in the context of the file as a whole. I debugged this under Python.
            ;;
            ;; This might be better incorporated into n-indent-region
            (let(
                 (min   (point-min))
                 (max   (point-max))
                 )
              (widen)
              (narrow-to-region (progn
                                  (goto-char min)
                                  (forward-line -1)
                                  (point)
                                  )
                                (progn
                                  (goto-char max)
                                  (forward-line 1)
                                  (point)
                                  )
                                )
              (n-indent-region)
              )

            ;; extraneous for python at least...
	    ;;(goto-char (point-min))
	    ;;(insert  comment-start "\n")
	    ;;(replace-regexp "^" (concat comment-start " "))
	    )
          ;; cannot do this because, in python at least, the assumed margins obliterate our space-dictated flow control.
          ;; I could theoretically solve this problem by making the indentation code
          ;; more sophisticated about accepting conceivably reasonable indentation
          ;; and only correcting indentation which is clearly wrong, but this would
          ;; go against the long-standing convention for all other languages I use
          ;; where it is possible to deterministically figure out what the
          ;; appropriate indentation is. This is a change best delayed until I have
          ;; standardized on Python as a dominant implementation language (which will
          ;; probably be never).
          ;;
          ;; So, instead, do an n-indent-region above with the restricted region.
          ;;
          ;;
          ;; (n-indent-region)
          )
	 ((equal command ?d)
          (nsimple-yank--from-dropbox)
          )
	 ((equal command ?i)
          (yank)
    )
	 ((equalcommand ?j)
	  (save-restriction
	    (narrow-to-region (point) (point))
	    (yank)
	    (goto-char (point-min))
	    (replace-regexp "/" ".")
	    (replace-regexp "\\.java$" "")
	    )
	  )
	 ((and (>= command ?0) (<= command ?9))
	  (setq command (- command ?0))
	  (while (> command 0) (nsimple-yank-command) (setq command (1- command)))
	  )
	 )
	)
      )
    (store-match-data data)
    )
  )
(defun nsimple-call-process(visible program inputFile &rest arguments)
  (n-trace "nsimple-call-process: %s %s %s"
           (if inputFile
               (concat inputFile " >")
             ""
             )
           program
           (let(
                (argumentString	"")
                (values		arguments)
                )
             (while values
               (setq argumentString	(format "%s \"%s\""
                                                argumentString
                                                (car values)
                                                )
                     values		(cdr values)
                     )
    )
	     argumentString
             )
           )
  (if visible
      (progn
	(delete-other-windows)
	(nsimple-split-window-vertically)
	(switch-to-buffer (get-buffer-create "*Messages*"))
	(delete-region (point-min) (point-max))
	)
    )
  (apply 'call-process program inputFile (get-buffer-create "*Messages*") t arguments)
  )
(defun nsimple-goto-trace()
  (interactive)
  (delete-other-windows)
  (nsimple-split-window-vertically)
  (n-other-window)
  ;;(switch-to-buffer (get-buffer-create "*Messages*"))
  (switch-to-buffer (get-buffer-create "*trace*"))
  (n-other-window)
  )
(defun nsimple-kill-function()
  (if (eq major-mode 'nperl-mode)
      (progn
	(forward-line 0)
	(if (looking-at "^sub")
	    (forward-line 2)
	  (if (looking-at "^{")
	      (forward-line 1))
	  )
	(nc-beginning-of-defun)
	(kill-region (progn
		       (forward-line -1)
		       (point)
		       )
		     (progn
		       (forward-line 1)
		       (forward-sexp 1)
		       (forward-line 1)
		       (point)
		       )
		     )
	)
    (nc-beginning-of-defun)
    (kill-sexp 1)
    )
  )
(defun nsimple-kill-region( &optional arg)
  (interactive "P")
  (if arg
      (let(
           (command	(progn
                          (message "d-to-dropbox, f-unction, s-exp")
                          (read-char)
                          )
                        )
           )
        (cond
         ((eq command ?d)
          (call-interactively 'kill-region)
          (nsimple-kill--to-dropbox)
          )
         ((eq command ?f)
	  (nsimple-kill-function)
	  )
	 ((eq command ?s)
	  (kill-sexp 1)
          )
         )
        )
    (call-interactively 'kill-region)
    (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
    )
  )
(defun nsimple-equal( &optional arg)
  (interactive "P")
  (if arg
      (let(
           (length	(save-excursion
                          (forward-line -1)
                          (end-of-line)
                          (current-column)
                          )
                        )
           )
        (self-insert-command length)
        (insert "\n")
        )
    (call-interactively 'n-complete-self-insert-command)
    )
  )
(defun nsimple-split-window-vertically()
  (interactive)
  (if (string= (buffer-name) "*merge*")
      (nmerge-edit-both-chunks)	; see comment in nmerge.el (search for "doesn't work")
    (split-window-vertically)
    )
  )
(defun nsimple-backward-delete-char-untabify( &optional arg)
  (interactive "p")
  (cond
   ((eq (point) 1)
    (if (not (buffer-modified-p))
        (let(
             (start	(substring (buffer-file-name) 0 -1))
             (nfly-minibuffer-correction t)
             )
          (nbuf-kill-current)
          (nfly-find-file start)
          )
      (message "nsimple-backward-delete-char-untabify called at buffer beginning")
      )
    )
   ((integerp arg)
    (while (> arg 0) (nsimple-backward-delete-char-untabify) (setq arg (1- arg)))
    )
   (t
    (backward-delete-char-untabify 1)
    )
   )
  )
(defun nsimple-scroll-to-top()
  ;;(setq scroll-conservatively 10)
  ;;(setq scroll-margin 7)
  (setq scroll-conservatively 0)
  (setq scroll-margin 0)  
  (forward-line 0)
  (let(
       (current-line	(n-what-line))
       top-line
       )
    (while (> current-line
              (save-excursion
                (n-top-of-window)
                (n-what-line)
                )
              )
      (scroll-down -1)
      )
    )
  )
(defun nsimple-search-command-yank()
  (interactive)
  (isearch-done)
  (call-interactively 'nsimple-yank-command)
  )
(defun nsimple-search-command-kill-region()
  (interactive)
  (isearch-done)
  (call-interactively 'nsimple-kill-region)
  )

(setq nsimple-indent-cmd-target-col 0)

(defun nsimple-indent-cmd( &optional arg)
  (interactive "P")
  (if (and arg
	   (not (integerp arg))
	   )
      (setq arg (progn
		  (message "2-cut len to 120, 8-cut len to 80, s-set target col to current,  t-indent to target col")
		  (read-char)
		  )
	    )
    )
  (cond
   ((eq arg ?2)
    (nsimple-marginalize-region-cmd 120)
    )
   ((eq arg ?8)
    (nsimple-marginalize-region-cmd)
    )
   ((eq arg ?s)
    (setq nsimple-indent-cmd-target-col (current-column))
    (message "Target column is now %d" nsimple-indent-cmd-target-col)
    )
   ((eq arg ?t)
    (indent-to-column nsimple-indent-cmd-target-col)
    )
   ((integerp arg)
    (save-restriction
      (call-interactively 'narrow-to-region)
      (save-excursion
        (goto-char (point-min))
        (while (progn
                 (forward-line 0)
                 (if (not (eobp))
                     (progn
                       (indent-to-column arg)
                       (end-of-line)
                       (if (not (eobp))
                           (forward-line 1))
		       )
		   )
		 )
	  )
	)
      )
    )
   (t
    (save-restriction
      (call-interactively 'narrow-to-region)
      (save-excursion
	(goto-char (point-min))
	(replace-regexp "^" "    ")
	)
      )
    )
   )
  )
(defun nsimple-read-char()
  (condition-case nil
      (read-char)
    (error 0)
   )
  )
(defun nsimple-underline()
  (interactive)
  (let(
       (length
	(progn
	  (end-of-line)
	  (current-column
	   )
	  )
	)
       )
    (end-of-line)
    (insert "\n")
    (while (> length 0)
      (insert "-")
      (setq length (1- length))
      )
    )
  (insert "\n")
  )
(defun nsimple-register-help()
  (interactive)
  (message " -pt_to_register, i-nsert_register_contents, j-ump_to_register_pt, s-ave_to_register")
  (let(
       (command	(read-char))
       )
    (cond
     ((eq command ? )
      (call-interactively 'point-to-register)
      )
     ((eq command ?i)
      (call-interactively 'insert-register)
      )
     ((eq command ?j)
      (call-interactively 'jump-to-register)
      )
     ((eq command ?s)
      (call-interactively 'copy-to-register)
      )
     )
    )
  )
(defun nsimple-register-0( &optional arg) (interactive "P") (let((nsimple-register	?0)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-1( &optional arg) (interactive "P") (let((nsimple-register	?1)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-2( &optional arg) (interactive "P") (let((nsimple-register	?2)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-3( &optional arg) (interactive "P") (let((nsimple-register	?3)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-4( &optional arg) (interactive "P") (let((nsimple-register	?4)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-5( &optional arg) (interactive "P") (let((nsimple-register	?5)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-6( &optional arg) (interactive "P") (let((nsimple-register	?6)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-7( &optional arg) (interactive "P") (let((nsimple-register	?7)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-8( &optional arg) (interactive "P") (let((nsimple-register	?8)) (call-interactively 'nsimple-register-n)))
(defun nsimple-register-9( &optional arg) (interactive "P") (let((nsimple-register	?9)) (call-interactively 'nsimple-register-n)))

(defun nsimple-register-set(data &optional reg)
  (if (not reg)
      (setq reg nsimple-register))

  (nstr-copy-to-register reg data)
  (save-excursion
    (n-database-set (format "nsimple-register-%c" reg) data)
    )
  (message "copy-to-register %c" reg)
  )

(defun nsimple-register-get(reg)
  (if (not reg)
      (setq reg nsimple-register))

  (condition-case nil
      (nsimple-register-get reg)
    (error
     (let(
          (data (nstr-register-get reg))
          )
       (if (not data)
           (setq data (n-database-get (format "nsimple-register-%c" reg))))

       (if data
           data
         ""
         )
       )
     )
    )
  )
(defun nsimple-register-grab-token-pair-12()
  (let(
       (pair-list (n-grab-token-pair))
       )
    (nsimple-register-set (car  pair-list) ?1)
    (nsimple-register-set (cadr pair-list) ?2)
    )
  )
(defun nsimple-register-get-and-insert(&optional reg)
  (insert (nsimple-register-get reg))
  )

(defun nsimple-register-n( &optional arg)
  (interactive "P")
  (let(
       command
       )
    (cond
     ((and arg (integerp arg) (eq arg 3))
      (setq command	?t)
      )
     (arg
      (setq command	(progn
                          (message ",-put-comma'd list, r-egion, t-oken")
                          (read-char)
                          )
            )
      )
     (t
      (nsimple-register-get-and-insert)
      )
     )

   (if command
	(let(
	     data
	     )
	  (cond
	   ((eq command ?,)
            (nsimple-register-get-and-insert)
            (save-restriction
              (call-interactively 'narrow-to-region)
              (goto-char (point-min))
              (replace-regexp " " ",")
              (goto-char (point-max))
              (insert ",")
              )
	    )
	   ((eq command ?r)
	    (setq data (buffer-substring-no-properties (point) (mark)))
            (nsimple-register-set data)
	    )
	   ((eq command ?t)
	    (setq data (n-grab-token))
            (if (eq major-mode 'nperl-mode)
                (progn
                  (if (string-match "^%" data)
                      (setq data (nstr-replace-regexp data "^%" "$")))
                  )
              )
            (nsimple-register-set data)
            )
           (t
            (nsimple-register-set data)
            )
           )
          )
      )
    )
  )
(defun nsimple-send-string(s &rest arguments)
  (process-send-string nil
                       (apply 'format s arguments)
                       )
  (process-send-string nil "\n")
  )
(defun nsimple-capitalize-and-join-to-eoln()
  (save-restriction
    (narrow-to-region (point) (progn
				(end-of-line)
				(point)
				)
		      )
    (goto-char (point-min))
    (while (n-s " ")
      (delete-char -1)
      (nsimple-upcase-char)
      )
    )
  )
(defun nsimple-upcase-char()
  (save-restriction
    (narrow-to-region (point) (1+ (point)))
    (upcase-word 1)
    )
  )

(if (not (functionp 'characterp))
    (defun characterp(c) (integerp c)))

(defun nsimple-upcase-word(&optional arg)
  (interactive "P")
  (if arg
      (let(
           (command (cond
                     ((and (characterp arg) (= arg ?1) ?1))
                     ((and (characterp arg) (= arg ?r) ?r))

		     (t
                      (message "1-char, j-oin-to-eoln, J-oin-from-pop-to-eoln, r-region")
                      (read-char)
                      )
		     )
		    )
           )
        (cond
         ((eq command ?1)
	  (nsimple-upcase-char)
          )
	 ((eq command ?j)
	  (nsimple-capitalize-and-join-to-eoln)
          )
	 ((eq command ?J)
	  (n-loc-pop)
	  (nsimple-capitalize-and-join-to-eoln)
          )
         ((eq command ?r)
          (call-interactively 'upcase-region)
          )
         )
        )
    (upcase-word 1)
    )
  )

(defun nsimple-uncapitalize()
  (save-restriction
    (narrow-to-region (point) (1+ (point)))
    (downcase-word 1)
    )
  )
(defun nsimple-downcase-word(&optional arg)
  (interactive "P")
  (if arg
      (let(
           (command (progn
                      (message "1-char, r-region")
                      (read-char)
                      )
                    )
           )
        (cond
         ((eq command ?1)
	  (nsimple-uncapitalize)
          )
         ((eq command ?r)
          (call-interactively 'downcase-region)
          )
         )
        )
    (downcase-word 1)
    )
  )

(defun nsimple-kill-word-and-grab()
  (interactive)
  (if (string= (buffer-name) "*merge*")
      (emerge-fast-mode)                ; see comment in nmerge.el (search for "doesn't work")
    (forward-word -1)
    (kill-word 1)
    (yank)
    (forward-line 1)
    (end-of-line)
    )
  )
(defun nsimple-newline-and-indent( &optional noSave)
  (interactive "P")
  "same as newline-and-indent except current line is indented before going to the next line"
  (require 'n-comment)
  (cond
   ((n-comment-p nil 'inside)
    (indent-according-to-mode)
    (if (looking-at "$")
	(delete-horizontal-space))
    (insert "\n")
    (indent-according-to-mode)
    (insert n-comment-boln " ")
    (n-comment-indent)
    )
   (t
    (indent-according-to-mode)
    (if (looking-at "$")
	(delete-horizontal-space))
    (insert "\n")
    (indent-according-to-mode)
    )
   )

  (if (and (not noSave)
           (buffer-file-name)
           )
      (save-buffer)
    )
  )

(setq nsimple-join-lines-comma-mode nil)


(defun nsimple-break-line-if-over(maxcol &optional newLineLead)
  (if (not newLineLead)
      (setq newLineLead ""))
  (end-of-line)
  (if (> (current-column) maxcol)
      (save-restriction
        (n-narrow-to-line)
        (move-to-column maxcol)
        (if (and (n-r "[ \t]")
                 (> (current-column) (- maxcol 70))
                 (> (current-column) 35)
                 )
            (progn
              (delete-horizontal-space)
              (insert "\n" (nre-unregexpify newLineLead t))
              (end-of-line)
              (if (> (current-column) maxcol)
                  (nsimple-break-line-if-over maxcol newLineLead))
              )
          )
        (end-of-line)
        )
    )
  )

(defun nsimple-join-lines-while-regexp(re)
  (while (progn
           (nsimple-join-lines)
           (nsimple-break-line-if-over 179 re)
           (save-excursion
             (forward-line 1)
             (looking-at re)
             )
           )
    )
  )


(defun nsimple-join-lines( &optional arg)
  (interactive "P")
  (if (looking-at "\"@@$")
      (delete-char 3))
  (cond
   ((stringp arg)
    (nsimple-join-lines-while-regexp arg)
    )
   ((and (integerp arg) (= arg 5))
    (setq nsimple-join-lines-comma-mode (not nsimple-join-lines-comma-mode))
    )
   ((integerp arg)
    (while (> arg 0)
      (setq arg (1- arg))
      (nsimple-join-lines)
      )
    )
   ((or (eq arg t)
	(and (not (null arg)) (listp arg))
	)
    (condition-case nil
	(loop
         (nsimple-join-lines)
         )
      (error nil)
      )
    )
   (t
    (if (eq major-mode 'shell-mode)
        (nshell-join-lines--delete-prompt-on-2nd-line)
      )

    (require 'n-comment)
    (if (n-comment-p 1)
        (save-excursion
          (forward-line 1)
          (delete-region (progn
                           (forward-line 0)
                           (point)
                           )
                         (progn
                           (search-forward n-comment-boln)
                           (point)
                           )
                         )
          )
      )
    (end-of-line)
    (save-excursion
      (if (progn
            (forward-line 1)
            (looking-at ">+")
            )
          (delete-region (point) (progn
                                   (n-s ">+" t)
                                   (point)
                                   )
                         )
        )
      )
    (if (and (> (point) (point-min))
             (save-excursion
               (forward-char -1)
               (or
                (looking-at "\\\\")
                (looking-at "")
                )
               )
             )
        (backward-delete-char 1)
      )
    (set-mark (point))
    (delete-char 1)
    (just-one-space)
    (if nsimple-join-lines-comma-mode
	(progn
	  (forward-char -1)
	  (insert ",")
	  (forward-char 1)
	  )
      )
    (cond
     ((looking-at "inflating: ")
      (delete-region (point)
                     (progn
                       (n-s "inflating: " t)
                       (point)
                       )
                     )
      )
     ((looking-at "|[ \t]")
      (delete-char 1)
      (just-one-space)
      )
     ((looking-at "\\*")
      (delete-char 1)
      (just-one-space)
      )
     ((looking-at "// ")
      (delete-char 3)
      )
     ((looking-at "# ")
      (delete-char 2)
      )
     ((or (looking-at "[,)&\\?]")
	  (and
	   (> (point) 2)
	   (save-excursion
	     (forward-char -2)
	     (or
	      (looking-at "[-\"\\.(&\\?] ")
              )
	     )
	   )
	  )
      (backward-delete-char 1)
      )
     )

    (if (and
	 (> (point) 1)
	 (save-excursion
	   (forward-char -1)
	   (looking-at "\\.[A-Z][a-z]")
	   )
	 )
 	(progn
	  (insert "  ")
	  )
      )

    )
   (end-of-line)
   )
  (if (looking-at "@@$")
      (progn
        (delete-char 2)
        (if (nre-looking-behind-at " ")
            (progn
              (just-one-space)
              (delete-char -1)
              )
          )
        )
    )
  (if (and (looking-at "$")
           (nre-looking-behind-at " ")
           )
      (delete-char -1)
    )
  )
(defun nsimple-transpose-chars()
  (interactive)
  (if (and
       (looking-at "[ \t]+")
       (save-excursion
         (skip-chars-forward " \t")
         (or
          (eobp)
          (looking-at "\n")
          )
         )
       )
      (delete-region (point) (progn
                               (end-of-line)
                               (point)
                               )
                     )
    )
  (transpose-chars nil)
  )

(defun nsimple-transpose-lines()
  (interactive)
  (transpose-lines 1)
  (save-excursion
    (forward-line -2)
    (funcall indent-line-function)
    (forward-line 1)
    (funcall indent-line-function)
    )
  )


(defvar nsimple-transpose-words-xlate nil)
(set-default 'nsimple-transpose-words-xlate nil)
(make-variable-buffer-local 'nsimple-transpose-words-xlate)

(defun nsimple-transpose-args()
  (save-restriction
    (n-narrow-to-line)
    (let(
         (at-left-arg-end (looking-at "[,)\"' \t]"))
         left
         right
         )
      (if (not at-left-arg-end)
          (progn
            ;; apparently at right-arg-beginning
            (skip-chars-backward ", \t'\"")
            ;; now we are at the end of the left arg
            )
        )
      (setq left (n-grab-programming-arg t)
            right (save-excursion
                    (skip-chars-forward ", \t'\"")
                    (prog1
                        (n-grab-programming-arg t)
                      (n-loc-push)
                      )
                    )
            )
      (insert right)
      (n-loc-pop)
      (insert left)
      )
    )
  )

(defun nsimple-transpose-args--test1(input expected)
  (interactive)
  (nstr-test input expected 'nsimple-transpose-args)
  )

(defun nsimple-transpose-args--test()
  (nsimple-transpose-args--test1 "abc(arg1, @@arg2)"                        "abc(arg2, arg1)")
  (nsimple-transpose-args--test1 "abc(arg1@@, arg2)"                        "abc(arg2, arg1)")
  (nsimple-transpose-args--test1 "abc(\"literal arg2@@\", arg1)"              "abc(arg1, \"literal arg2\")")
  (nsimple-transpose-args--test1 "abc(\"literal arg2\", @@arg1)"              "abc(arg1, \"literal arg2\")")
  (nsimple-transpose-args--test1 "abc(\"literal arg2\", \"@@literal arg1\")"    "abc(\"literal arg1\",\"literal arg2\")")
  (nsimple-transpose-args--test1 "abc(\"literal arg2@@\", \"literal arg1\")"    "abc(\"literal arg1\", \"literal arg2\")")
  ;;      currently I can't grab expressions like the following if point is at the arg end.  This wouldn't be hard though --
  ;; just see if we are sitting on a ')'...
  ;;(nsimple-transpose-args--test1 "abc(\"literal arg1@@\", functional_arg(\"literal arg2\"))" "abc(functional_arg(\"literal arg2\"), \"literal arg1\")")
  ;;(nsimple-transpose-args--test1 "abc(\"literal arg1\", @@functional_arg(\"literal arg2\"))" "abc(functional_arg(\"literal arg2\"), \"literal arg1\")")
  ;; abc(functional_arg1(\"literal arg1@@\"), functional_arg2(\"literal arg2\"))
  ;; abc(functional_arg1(\"literal arg1\"), @@functional_arg2(\"literal arg2\"))
  )
;;(nsimple-transpose-args--test)

(defun nsimple-transpose-file-path-components()
  (save-restriction
    (n-narrow-to-line)
    (let(
	 (left (save-excursion
		 (buffer-substring-no-properties (point)
                                                 (progn
                                                   (n-r "[/: \t]" 'bof)
                                                   (point)
                                                   )
                                                 )
		 )
	       )
	 (right (save-excursion
		  (forward-char 1)
		  (buffer-substring-no-properties (point)
                                                  (progn
                                                    (if (n-s "[/:\t]")
                                                        (forward-char -1)
                                                      (end-of-line)
                                                      )
                                                    (point)
                                                    )
                                                  )
		  )
		)
	 )
      (n-r left t)
      (delete-region (point)(progn
                              (n-s right t)
                              (point)
                              )
		     )
      (insert right "/" left)
      )
    )
  )

(defun nsimple-transpose-words--looks-like-arg-boundary()
  (or (looking-at "['\"]?, ?['\"A-Za-z0-9_]")   ;; at end of left boundary
      (save-excursion
        (save-restriction
          (narrow-to-region (1+ (point)) (point-min))
          (forward-char -3)
          (looking-at ".?, ?[\"'a-zA-Z0-9_]")
          )
        )
      )
  )

(defun nsimple-transpose-words()
  (interactive)
  (cond
   ((looking-at "/")
    (nsimple-transpose-file-path-components)
    )
   ((nsimple-transpose-words--looks-like-arg-boundary)
    (nsimple-transpose-args)
    )
   (t
    (let(
         (start-point (point))
         (token (n-grab-token))
	 to-cons
	 )
      (setq to-cons (nstr-assoc token nsimple-transpose-words-xlate))
      (if to-cons
	  (progn
	    (delete-region (point)
			   (progn
			     (skip-chars-forward (n-grab-token-chars))
			     (point)
			     )
			   )
	    (save-excursion
	      (insert (cdr to-cons))
	      )
	    )
	(if (looking-at "$")
	    (forward-word -1))
        (goto-char start-point)
	(transpose-words 1)
	)
      )
    )
   )
  )

(defun nsimple-delete-line( &optional arg)
  "what you think"
  (cond ((not arg) (setq arg 1))
        ((> 0 arg) (forward-line arg) (setq arg (- arg)))
        )
  (let(
       (line (n-get-line))
       )
    (delete-region (progn
                     (forward-line 0)
                     (point)
                     )
                   (progn
                     (forward-line arg)
                     (point)
                     )
                   )
    line
    )
  )

(if (not (boundp 'nsimple-original-copy-region-as-kill))
    (setq nsimple-original-copy-region-as-kill	(symbol-function 'copy-region-as-kill))
  )
(if (not (boundp 'nsimple-original-message))
    (setq nsimple-original-message	(symbol-function 'message))
  )

(defun nsimple-message(&optional s &rest rest)
  (if (not s)
      (setq s ""))
  (let(
       (output (apply 'format s rest))
       )

    (if (and
         (not (string= output "Done"))
         (not (string= output "Wrote /home/nelsons/tmp/set_clipboard.ahk.tmp"))
         (not (string= output "Mark set"))
         (not (string-match "Replaced [0-9]+ occurrences?" output))
         )
        (save-window-excursion
          (funcall nsimple-original-message "%s" output)
          )
      )
    )
  )
(fset 'message (symbol-function 'nsimple-message))
(defun nsimple-blank-line-p()
  "return t if the current line is blank"
  (save-excursion
    (forward-line 0)
    (looking-at "[ \t]*$")
    )
  )
(defun nsimple-kill-to-end-of-line()
  (interactive)
  (if (looking-at ".@@$")
      (delete-char 3)
    (save-excursion (nsimple-copy-region-as-kill (point) (progn (end-of-line) (point))))
    (if (not (nbuf-read-only-p))
        (call-interactively 'kill-line))
    (setq this-command 'kill-region);; to append next kill
    )
  )
(defun nsimple-kill-word(&optional arg)
  (interactive "P")
  (cond
   ((and (nbuf-read-only-p)
	 (string= (n--get-lisp-func-name last-command) "kill-region")
	 )
    (kill-append (buffer-substring-no-properties
  (point)
		  (progn
		    (forward-word 1)
		    (point)
		    )
		  )
		 nil
		 )
    )
   ((nbuf-read-only-p)
    (nsimple-copy-region-as-kill (point) (progn
                                           (forward-word 1)
                                           (point)
                                           )
                                 )
    )
   (t
    (call-interactively 'kill-word)
    )
   )
  (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
  (setq this-command 'kill-region) ;; to append next kill
  )

(defun nsimple-compare-windows--ck-for-diff-resulting-from-reordering()
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       )
    (switch-to-buffer (get-buffer-create "nsimple-compare-windows--ck-for-diff-resulting-from-reordering"))
    (delete-region (point-min) (point-max))
    (insert data)
    (n-prune-buf-v "^[<>]")
    (nsort-buf)
    (goto-char (point-min))
    (n-s "^>" t)
    (n-open-line)
    (insert "half")
    (goto-char (point-min))
    (replace-regexp "^[<>] " "")
    (n-r "^half$" t)
    (forward-line 1)
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (goto-char (point-min))
    (nsimple-compare-windows)
    (n-other-window)
    (if (eobp)
        (message "this diff shows an ordering difference between 2 identical sets of lines")
      (message "this diff shows a data difference, not just a shuffling of lines")
      )
    )
  )
(defun nsimple-compare-windows( &optional arg)
  (interactive "P")
  (let(
       (cmd (if (not arg)
                ?d
              (message "s-ort ck")
              ?s
              )
            )
       )
    (cond
     ((= cmd ?s)
      (nsimple-compare-windows--ck-for-diff-resulting-from-reordering)
      )
     ((= cmd ?d)
      (let(
           (c1 (buffer-substring-no-properties (point) (1+ (point))))
           (c2 (progn
                 (other-window 1)
                 (buffer-substring-no-properties (point) (1+ (point)))
                 )
               )
           )
        (if (not (string= c1 c2))
            (progn
              (end-of-line)
              (other-window 1)
              (end-of-line)
              )
          (other-window 1)
          )
        (compare-windows t)
        )
      )
     (t (error "nsimple-compare-windows: "))
     )
    )
  )

(defun nsimple-backward-word (&optional arg)
  "Move backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (nsimple-forward-word (- (or arg 1)))
  )


(defun nsimple-forward-word(&optional arg)
  (interactive "P")
  (let(
       (inhibit-field-text-motion t)
       )
    (if (not arg)
        (setq arg 1))
    (if (and
         (string-match " .Minibuf-" (buffer-name))
         (looking-at "c:")
         (eq arg 1)
         )
        (forward-char 2)
      (forward-word arg)
      )
    )
  )
(defun nsimple-indent-backspace()
  (interactive)
  ;; for modes w/ the simple-minded nsimple-indent() -- don't hack tabs
  (delete-char -1)
  )

(defun nsimple-indent()
  (save-excursion
    (nsimple-back-to-indentation)
    (delete-region (point)
		   (progn
		     (forward-line 0)
		     (point)
		     )
		   )
    (indent-to-column
     (save-excursion
       (forward-word -1)
       (nsimple-back-to-indentation)
       (current-column)
       )
     )
    )
  (if (save-excursion
	(save-restriction
	  (narrow-to-region (point)
			    (progn
			      (forward-line 0)
			      (point)
			      )
			    )
	  (looking-at "[ \t]*$")
	  )
	)
      (end-of-line)
    )
  )
(defun nsimple-marginalize-region-find-splitting-point(len)
  "avoid splitting
1. HTML tags
2. punctuation from associated items
3. 'italicizing commas' from succeeding token (I have some code which temporarily indicates the need to italicize a token by prepending a comma to it)"
  (save-restriction
    (n-narrow-to-line)
    (move-to-column len)
    (if (and
	 (not (n-r "[ \t]"))
	 (not (n-s "[ \t]"))
	 )
	(end-of-line)
      (if (not (looking-at "[ \t]"))	;; i.e., the n-s above moved point after /s
	  (forward-char -1))
      (if (not (looking-at "[ \t]"))
	  (error "nsimple-marginalize-region-find-splitting-point:should be looking at white spc"))
      (delete-char 1)
      )
    )
  )
(defun nsimple-marginalize-region-cmd(&optional len)
  (interactive)
  (if (not len)
      (setq len 75))
  (save-excursion
    (nsimple-marginalize-region len (point-min) (point-max))
    (goto-char (point-min))
    (replace-regexp "#\\([^ \t]\\)" "# \\1")
    )
  )

(defun nsimple-marginalize-region(len begin end)
  (save-restriction
    (narrow-to-region begin end)

    (goto-char (point-min))
    (replace-regexp (concat "^\\([ \t]*\\)" (nre-make-pattern n-comment-boln))
                    "\\1")

    (goto-char (point-min))
    (replace-regexp "^\\([ \t]*\\)" "")

    (goto-char (point-max))
    (if (save-excursion
          (forward-char -1)
          (not (looking-at "\n"))
          )
        (progn
          (insert "\n") ;; to make sure while-loop exits
          )
      )

    (goto-char (point-min))
    (replace-regexp "^" (concat n-comment-boln " "))
    
    (goto-char (point-min))
    (while (not (eobp))
      (end-of-line)
      (just-one-space)
      (delete-char -1)

      (if (> len (current-column))
          (forward-line 1)
	(nsimple-marginalize-region-find-splitting-point len)
	(funcall (nkeys-binding "\C-m"))
	)
      (end-of-line)
      )
    (delete-char -1)

    (goto-char (point-max))
    (forward-line 0)
    (if (looking-at (concat n-comment-boln "$"))
        (nsimple-delete-line)
      )


    (goto-char (point-min))
    (replace-regexp (nre-make-pattern (concat n-comment-boln n-comment-boln))
                    n-comment-boln
                    )
    (indent-region (progn
                     (goto-char begin)
                     (forward-line 1)
                     (point)
                     )
                   end
                   )
    )
  )

(defun nsimple-delete-vertical-space()
  (if (n-r "[^ \t\n]")
      (forward-char 1)
    (goto-char (point-min))
    )
  (delete-region (point)
                 (progn
                   (if (n-s "[^ \t\n]")
                       (forward-char -1)
                     (goto-char (point-max))
                     )
                   (point)
                   )
                 )
  )

(defun nsimple-just-one-blank-line()
  (nsimple-delete-vertical-space)
  (insert "\n\n")
  )
(defun n-x7()
  (interactive)
  (let(
       (line (n-get-line))
       )

    (n-other-window)
    (goto-char (point-min))
    (setq hit (n-s line))
    (n-other-window)
    (if hit
        (nsimple-delete-line 1)
      (forward-line 1)
      )
    )
  )
(defun nsimple-y-or-n-p(prompt)
  (message prompt)
  (let(
       (cmd (read-char))
       )
    (or
     (eq cmd ?y)
     (eq cmd ? )
     )
    )
  )
(defun nsimple-is-empty-line()
  (save-excursion
    (forward-line 0)
    (looking-at "$")
    )
  )
(defun nsimple-eat-mouse-click()
  (interactive)
  (message "Dell is lame.")
  )
(defun nsimple-coin-flip()
  (eq 1 (% (point) 2))
  )
(defun nsimple-alnum-p( c)
  "return t if CHAR is alphanumeric"
  (or (and (>= c ?0) (<= c ?9))
      (and (>= c ?a) (<= c ?z))
      (and (>= c ?A) (<= c ?Z)))
  )

(defun n-bottom-of-window()
  (interactive)
  (move-to-window-line -1)
  )

(defun n-top-of-window()
  (interactive)
  (move-to-window-line 0)
  )

(defun n-narrow-to-line()
  "n3.el: narrow-to-region, where the current line, not including the newline,
 is the region.   Moves point to the beginning of the line"
  (save-excursion
    (narrow-to-region (progn
                        (forward-line 0)
                        (point)
                        )
                      (progn
                        (end-of-line)
                        (point)
                        )
                      )
    )
  )

(defun nsimple-clean-region(beg end)
  "like delete-region cept the newlines are untouched.  Useful for deleting stuff where you don't want downstream line numbers to be affected (e.g., when working based on grep's output)"
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
	(delete-region (point) (progn
				 (end-of-line)
				 (if (> end (point))
				     (point)
				   (goto-char (point-max))  ;; to break the loop
				   end
		   )
				 )
		       )
	(forward-line 1)
	)
      )
    )
  )
(defun nsimple-random(n)
  (if (eq n 0)
      0
    (random n)
    )
  )
(defun nsimple-show-buffer(bufName)
  (if (not (eq (count-windows) 2))
      (progn
	(delete-other-windows)
	(split-window-vertically)
	)
    )
  (other-window 1)
  (switch-to-buffer bufName)
  (other-window 1)
  )

(defun nsimple-tab()
  (interactive)

  (if (string= (nfn-suffix) "menu")
      (insert "\t")
    ;;
    ;; need this nonsense to keep position -- otherwise untabify moves me before spaces
    (insert "\t" "@@@@")
    (forward-char (- (length "@@@@")))

    (let(
         (boln (save-excursion
                 (forward-line 0)
                 (point)
                 )
               )
         )
      (untabify boln (point))
      (n-s "@@@@" t)
      (delete-char (- (length "@@@@")))
      )
    )
  )

(defun nsimple-cut-region(beginning ending)
  (let(
       (data (buffer-substring-no-properties beginning ending))
       )
    (delete-region beginning ending)
    data
    )
  )

(setq nsimple-env-vars (make-hash-table :test 'equal))

(defun nsimple-env-vals-dump()
  (maphash '(lambda(key val)
              (n-trace "\"%s\" -> \"%s\"" key val)
              )
           nsimple-env-vars
           )
  )

(defun nsimple-env-val-with-src(variable)
  (gethash variable nsimple-env-vars)
  )

(defun nsimple-eval-var(variable)
  (let(
       (val-and-src (nsimple-env-val-with-src variable))
       value
       )
    (if val-and-src
        (setq value (car val-and-src))
      )
    value
    )
  )

(defun nsimple-set-val-and-src(variable val src)
  ;;(n-trace "nsimple-set-val-and-src(variable:%s,val:%s,src:%s)" (prin1-to-string variable) (prin1-to-string val) (prin1-to-string src))
  ;;(remhash variable nsimple-env-vars)
  (puthash variable (cons val src) nsimple-env-vars)
  )

(defun nsimple-get-src-of-var(variable)
  (let(
       (val-and-src (nsimple-env-val-with-src variable))
       src
       )
    (if val-and-src
        (setq src (cdr val-and-src))
      )
    src
    )
  )

(defun nsimple-getenv(variable &optional default)
  (save-match-data
    (let(
         value
         )

      (setq value (nsimple-eval-var variable))

      (if (not value)
          (setq value (getenv variable))
        )

      (if (and (not value)
               (string-match "^\\(local_\\)?env\\.\\(.*\\)" variable)
               )
          (progn
            (setq value (getenv (n--pat 2 variable)))
            )
        )

      (if (and (not value)
               (eq major-mode 'nsh-mode)
               )
          (setq value (nsh-last-assignment variable))
        )

      (if (not value)
          (setq value default)
        )
      ;;(nelisp-bp (format "(nsimple-getenv %s) -> %s" variable value) "nsimple.el" 1446)
      value
      )
    )
  )

;;(nsimple-env-expand "//172.20.127.137/c$/bea/repository30/bin")
;;(nsimple-env-expand "//172.20.127.137/x.$HOSTNAME")
;;(find-file "//172.20.127.137/c$/bea/repository30/bin/")
(defun nsimple-env-expand(string)
  ;;(n-trace "nsimple-env-expand(string:%s)" (prin1-to-string string))
  (if string
      (save-match-data
        (let(
             (expanded "")
             value
             var
             )
          (unwind-protect
              (progn
                (while (or
                        (string-match "^\\([^\\$]*\\)\\${\\([a-z_A-Z0-9\\.]*\\)}\\(.*\\)" string)
                        (string-match "^\\([^\\$]*\\)\\$\\([a-z_A-Z0-9]*\\)\\(.*\\)" string)
                        )
                  (setq var		(n--pat 2 string)
                        value		(nsimple-getenv var)
                        expanded	(concat expanded
                                                (n--pat 1 string)
                                                (if value
                                                    value
                                                  (concat "$" (n--pat 2 string))
                                                  )
                                                )
                        string	 (n--pat 3 string)
                        )
                  ;;(n-trace "...now string is \"%s\" (%s=\"%s\")" string var value)
                  )
                (setq string (concat expanded string)
                      )
                )
            )
          )
        )
    )
  )
;; std is buggy in 21.2.1:
;;
;; with following data:
;; ls /ptbuild/thirdparty/ACE/5.3.1
;; (point) goes to ..........^
;;
;; what the fuck?
;;
(defun end-of-line()
  (interactive)
  (save-match-data
    (while (not (looking-at "$"))
      (forward-char 1)
      )
    )
  )

;; std is buggy in 21.2.1, probably because of 21.2.1 (end-of-line) bug (cf above)
(defun kill-line(&rest args)
  (interactive)
  (kill-region (point) (progn
                         (end-of-line)
                         (point)
                         )
               )
  )
(defun nsimple-bp-get-id(bp-regexp)
  (let(
       (lastAlertNumber (save-excursion
                          (if (n-r bp-regexp)
                              (string-to-int (n--pat 1))
                            -1
                            )
                          )
                        )
       (nextAlertNumber (save-excursion
                          (if (n-s bp-regexp)
                              (string-to-int (n--pat 1))
                            -1
                            )
                          )
                        )
       )
    (if (= lastAlertNumber -1)
        (if (= nextAlertNumber -1)
            50
          (- nextAlertNumber 10)
          )
      (if (= nextAlertNumber -1)
          (+ lastAlertNumber 10)
        (/ (+ lastAlertNumber nextAlertNumber) 2.0)
        )
      )
    )
  )
(defun nsimple-on-last-line-p()
  (save-excursion
    (end-of-line)
    (eobp)
    )
  )


(defun nsimple-grab-columns(colIndex)
  (or (eq colIndex 0)
      (error "nsimple-grab-columns: nonzero not impl"))
  (let(
       li
       )
    (while (not (eobp))
      (nsimple-back-to-indentation)
      (setq li (cons (n-grab-token) li))
      (forward-line 1)
      (end-of-line)
      )
    (setq nsimple-grab-columns-output (nreverse li))
    )
  )

(defun nsimple-grab-comma-list()
  "on current line grab comma-delimited tokens to a list (also setq nsimple-grab-comma-list-output), excluding trailing paren"
  (let(
       li
       )
    (save-restriction
      (narrow-to-region (point) (progn
                                  (end-of-line)
                                  (forward-char -1)
                                  (if (not (looking-at ")"))
                                      (forward-char 1))
                                  (point)
                                  )
                        )
      (forward-line 0)
      
      (while (not (eobp))
        (setq li (cons (buffer-substring-no-properties (point) (progn
                                                   (if (n-s ",")
                                                       (forward-char -1)
                                                     (goto-char (point-max))
                                                     )
                                                   (point)
                                                   )
                                         )
                       li
                       )
              )
        (n-s ",[ \t]*")
        )
      (setq nsimple-grab-comma-list-output (nreverse li))
      )
    )
  )


(defun nsimple-grab( &optional arg)
  "copy REGION to the kill buffer; with optional ARGUMENT non-nil, interactively select alternative sources for a copy to the kill buffer"
  (interactive "P")
  (if (not arg)
      (call-interactively 'nsimple-copy-region-as-kill)

    (let(
         (command	(progn
                          (message ",-comma-list, /-cite, b-ullshit mail list addition, c-olumn0, d-dropbox, G-lobal-pt, r-ecursive edit and grab, s-exp")
                          (read-char)
                          )
                        )
         )
      (cond
       ((equal command ?,)
        (nsimple-grab-comma-list)
        )
       ((equal command ?/)
        (nsimple-grab-with-citation)
        )
       ((equal command ?b)
        (call-interactively 'n-rmail-dcl-bs)
        )
       ((equal command ?d)
        (call-interactively 'nsimple-grab)
        (nsimple-kill--to-dropbox)
        )
       ((equal command ?c)
        (nsimple-grab-columns 0)
        )
       ((equal command ?r)
        (n-grab-recursive)
        )
       ((equal command ?s)
        (nsimple-copy-region-as-kill (point) (progn
                                               (forward-sexp 1)
                                               (point)
                                               )
                                     )
        )
       )
      )
    )
  )

(defun nsimple-grab-with-citation()
  (nstr-kill (concat (nfn-cite)
                     ":"
                     (buffer-substring-no-properties (point) (mark))
                     )
             )
  )

(defun nsimple-yank-data-file-in-effect()
  (require 'nm)
  (cond
   ((not nsimple-yank-data-file)
    (if (nsimple-y-or-n-p "No clipboard because no nsimple-yank-data-file, reload nsimple.el (y/n)?")
        (n-load "nsimple.el")
      )
    nil
    )
   ((not (n-file-writable-p nsimple-yank-data-file))
    (message "No clipboard because nsimple-yank-data-file not writable, am I root?")
    nil
    )
   ((nm-defining)
    (message "No clipboard because a macro is being defined")
    nil
    )
   ;;(nm-executing
   ;;(message "No clipboard because a macro is executing")
   ;;nil
   ;;)
   (t
    t
    )
   )
  )

(defun nsimple-yank-set-my-global-kill-file-from-emacs-kill(&optional emacs_propagate_clipboard)
  (if (nsimple-yank-data-file-in-effect)
      ;; assumes last kill is what's wanted
      (save-window-excursion
        (let(
             emacs_propagate_clipboard_process
             )
          (set-buffer (find-file-noselect nsimple-yank-data-file))
          (delete-region (point-min) (point-max))
          (yank)

          (save-buffer)
          (not-modified)
          (kill-buffer nil)


          (if (and (not nsimple-yank-propagation-cached-origin) (not (eq system-type 'cygwin)))
              (progn
                (n-trace "darn, nsimple-yank-propagation-cached-origin should be set but isn't. ")
                )
            )
          (if emacs_propagate_clipboard
              (condition-case nil
                  (progn
                    (setq emacs_propagate_clipboard_process
                          (if nsimple-yank-propagation-cached-origin
                              (start-process "emacs_propagate_clipboard" "t" "bash" "-x" "emacs_propagate_clipboard" "-pc" nsimple-yank-propagation-cached-origin nsimple-yank-data-file (if n-is-xemacs "" "updateClipboard"))
                            (start-process "emacs_propagate_clipboard" "t" "bash" "-x" "emacs_propagate_clipboard" nsimple-yank-data-file (if n-is-xemacs "" "updateClipboard"))
                            )
                          )
                    )
                (error
                 (setq nsimple-yank-data-file nil)
                 (message "lemme guess -- 2k7 ERROR_ACCESS_VIOLATION?  emacs_propagate_clipboard error: preserve sanity by disabling this thing")
                 )
                )
            )
          (message "")	;; speeds us along back to the old minibuffer setting
          )
        )
    )
  )
(defun nsimple-yank--from-dropbox()
  (save-window-excursion
    (set-buffer (find-file-noselect nsimple-yank-dropbox-global-data-file))
    (nsimple-copy-region-as-kill (point-min) (point-max))
    (kill-buffer nil)
    )
  (yank)
  )

(defun nsimple-kill--to-dropbox()
  (save-window-excursion
    (n-file-find nsimple-yank-dropbox-global-data-file)
    (delete-region (point-min) (point-max))
    (yank)
    (save-buffer)
    (kill-buffer (current-buffer))
    )
  (nsimple-yank-command)
  )

;;(nsimple-env-expand "$P4ROOT/PT/portal/stable/TopLevel/UnitTestCode/java/main/src/com/plumtree/server/test/core/CPTGadgetCacheTest.java")
;;(nsimple-set-val-and-src "a"  "v1" "s1")
;;(nsimple-env-val-with-src "a")
;;(nsimple-env-expand "$PORTAL_HOME/")

(defun avg(&rest args)
  (let(
       (total (apply '+ args))
       )
    (/ total (length args))
    )
  )

;;(avg 1 4 9)

(defun nsimple-copy-region-as-kill(beg end)
  (interactive "r")
  (apply nsimple-original-copy-region-as-kill beg (list end))
  (nsimple-yank-set-my-global-kill-file-from-emacs-kill 'emacs_propagate_clipboard)
  )
(defun nsimple-yank-pop-command()
  (interactive)
  (let(
       (p       (point))
       (line    (n-get-line))
       )
    (while
        (progn
          (call-interactively 'yank-pop)
          (if (and n-win
                   (eq (point) p)
                   (equal line (n-get-line))
                   )
              (progn
                t ;; nothing appears to have changed.  Guard against apparent no-op yank-pop calls on win32
                )
            )
          )
      )
    )
  )

(defun nsimple-grab-for-external-win32()
  (interactive)
  (prog1
      (nstr-kill (n-get-line))
    (forward-line 1)
    )
  )

(defun nsimple-to-txt( &optional doubleSpace)
  (interactive "P")

                                        ; making this my dft for now...
  (setq doubleSpace (not doubleSpace))

  (write-file (concat (buffer-file-name) ".txt"))
  (goto-char (point-min))
  (while (< (point) (point-max))
    (nsimple-break-line-if-over 70)
    (forward-line 1)
    (end-of-line)
    )
  (goto-char (point-min))
  (replace-regexp "^" "\t")
  (if doubleSpace
      (progn
        ;; no workie, don't know why
        (goto-char (point-min))
        (while (> (point) (point-max))
          (forward-line 1)
          (insert "\n")
          (end-of-line)
          )
        )
    )
  )
(defun nsimple-delete-char()
  (interactive)
  (if (looking-at "$")
      (if (and (eobp)
               (eq major-mode 'shell-mode)
               (nsimple-boln-p)
               )
          (call-interactively 'comint-delchar-or-maybe-eof)
        (call-interactively 'backward-delete-char)

        )
    (call-interactively 'delete-char)
    )
  )
(defun nsimple-current-line()
  (n-get-line)
  )
(defun nsimple-programming-enter-double-quote()
  (interactive)
  (if (not (looking-at "`.*`"))
      (nsimple-programming-enter-double "\"" t)
    (insert "\"")
    (save-excursion
      (n-s "`.*`" t)
      (insert "\"")
      )
    )
  )

(defun nsimple-programming-enter-single-quote()
  (interactive)
  (nsimple-programming-enter-double "'" t)
  )

(defun nsimple-programming-enter-backwards-quote()
  (interactive)
  (nsimple-programming-enter-double "`" t)
  )

(defun nsimple-programming-token-boundary-precedes-p()
  (or (nsimple-boln-p)
      (save-excursion
        (forward-char -1)
        (looking-at "[ \t(\\{\\[]")
        )
      )
  )

(defun nsimple-programming-enter-double(char &optional only-consider-as-opener-after-programming-token-boundary)
  (if (and
       (not (looking-at (concat "[^" char "]*" char "[^" char "]*$")))
       (or
        (and (nsimple-eoln-p)
             (or (not only-consider-as-opener-after-programming-token-boundary)
                 (nsimple-programming-token-boundary-precedes-p)
                 )
             )
        (and (not (nsimple-eoln-p))
             (nsimple-programming-token-boundary-precedes-p)
             )
        )
       )

      ;;(if (not (looking-at (format ".*%s" char)))
      ;;      (progn
      ;;        (forward-char -2)
      ;;        (if (looking-at "[^( ]")
      ;;            (forward-char 2)
      ;;          (forward-char 2)
      ;;          (if (not (looking-at char))
      (progn
        (insert char char "@@")
        (forward-char -3)
        )
   ;;            )
    ;;          )
    ;;    )
    (insert char)
    )
  )
(defun nsimple-sleep( &optional arg)
  (interactive "p")
  (sleep-for arg)
  )
(defun nsimple-delete-word(&optional n)
  (if (not n)
      (setq n 1))
  (delete-region (point)
                 (progn
                   (forward-word n)
                   (point)
                   )
                 )
  )

(if (not (functionp 'buffer-substring-no-properties))
    (defun buffer-substring-no-properties(&rest args)
      (let(
           (z (apply 'buffer-substring args))
           )
        (if (stringp z)
            z
          (elt z 0)
          )
        )
      )
  )
(defun nsimple-eoln-p()
  (looking-at "$")
  )
(defun nsimple-last-line-p()
  (= (save-excursion
       (end-of-line)
       (point)
       )
     (point-max)
     )
  )
(defun nsimple-goto-line(lineNo)
  (goto-line lineNo)
  (nsimple-back-to-indentation)
  (message "Line %d" lineNo)
  )
(defun nsimple-end-of-buffer()
  (interactive)
  (end-of-buffer)
  (cond
   ((eq major-mode 'nfacts-mode)
    (forward-line -20)
    (if (n-s "q\n@@")
        (delete-char -2)
      (end-of-buffer)
      )
    )
   ((string-match ".*\\.grep\\..*" (buffer-name))
    (progn
      (if (n-r "^grep done")
          (delete-region (progn
                           (forward-char -1)
                           (point)
                           )
                         (point-max)
                         )
        (forward-word -1)       ;; just to get off any empty last line
        )
      (forward-line 0)
      )
    )
   ((eq major-mode 'dired-mode)
    (forward-line -1)
    )
   )
  )
(defun nsimple-cut-all()
  (let(
       (all (buffer-substring-no-properties (point-min) (point-max)))
       )
    (delete-region (point-min) (point-max))
    all
    )
  )

(setq nsimple-dabbrev-expand-cnt 0)
(defun nsimple-dabbrev-expand()
  (interactive)

  (setq nsimple-dabbrev-expand-cnt (if (eq last-command 'nsimple-dabbrev-expand)
                                       (1+ nsimple-dabbrev-expand-cnt)
                                     0
                                     )
        )
  (let(
       (starting-point (point))
       )
    (call-interactively 'dabbrev-expand)
    (save-excursion
      (save-restriction
        (narrow-to-region (point) starting-point)
        (goto-char (point-min))
        (if (n-s "[|=]")
            (delete-region (1- (point))
                           (progn
                             (goto-char (point-max))
                             (point)
                             )
                           )
          )
        )
      )
    )
  )
(defun nsimple-looking-at-any(regexp-list)
  (while (and regexp-list
              (not (looking-at (car regexp-list)))
              )
    (setq regexp-list (cdr regexp-list))
    )
  regexp-list
  )
(defun nsimple-join-lines-programmatic(&rest block-end-patts)
  (if (and (not arg)
           (save-excursion
             (nsimple-back-to-indentation)
             (progn
               (setq block-end-patts (maplist '(lambda(patt_in_a_list)
                                                 (concat (car patt_in_a_list) " *$")
                                                 )
                                              block-end-patts
                                              )
                     )
               (nre-looking-at-one-of block-end-patts)
               )
             )
           (save-excursion
             (forward-line 1)
             (not (looking-at "[ \t]*\\(@@\\)?$")
                  )
             )
           )
      (progn
        (forward-line 1)
        (nsimple-transpose-lines)
        )
    (call-interactively 'nsimple-join-lines)
    )
  (indent-according-to-mode)
  )
(defun nsimple-delete-backwards-if(str)
  (save-restriction
    (n-narrow-to-line)
    (save-excursion
      (forward-char (- (length str)))
      (if (looking-at str)
          (delete-char (length str)))
      )
    )
  )
(if (not (functionp 'looking-back))
    (defun looking-back(regexp)
      (save-restriction
        (save-excursion
          (narrow-to-region  (point)
                             (progn
                               (forward-line 0)
                               (point)
                               )
                             )
          (looking-at (concat ".*" regexp "$"))
          )
        )
      )
)
