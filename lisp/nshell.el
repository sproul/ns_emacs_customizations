(provide 'nshell)
(defvar nshell--nested nil)

(setq nshell-no-save-of-prior-file nil)
;;(setq explicit-shell-file-name "/cygdrive/c/cygwin/bin/bash.exe")
;;(setq shell-file-name "bash")
;;(setq explicit-bash.exe-args '("-i"))
;;;(setq explicit-bash-args '("-i"))

(if n-is-xemacs
    (progn
      (setq explicit-shell-file-name (n-host-to-canonical "$NELSON_BIN/NT.bat"))
      ;;(if (eq system-type 'cygwin)
      ;;(setq explicit-shell-file-name "/cygdrive/c/cygwin/bin/bash.exe")
      ;;(setq explicit-shell-file-name "c:/cygwin/bin/bash.exe")
      ;;)
      (setq-default comint-process-echoes nil)
      )
  (setq-default comint-process-echoes nil)
  ;;(setq explicit-shell-file-name	"bash"
  ;;      shell-file-name	"bash"
  ;;      )
  )
                                        ;(setq shell-prompt-pattern "[0-9][0-9]:[0-9][0-9]:[0-9][0-9] [-0-9a-zA-Z_]+ [-\\.0-9a-zA-Z_]+ [-0-9]+[%#\\$]+ \\|.* # ")
(setq  shell-prompt-pattern "[0-9][0-9]:[0-9][0-9]:[0-9][0-9] [-0-9a-zA-Z_]+ [-\\.0-9a-zA-Z_]+ [-0-9]+[%#\\$]+ \\|.*# ")
;;12:51:20 nsproul dadvip0121 1058$

;; This setting prevents the confirmation prompt when you try to execute something which is not at the end of the buffer:
(setq comint-append-old-input nil)


(defun nshell-bu()
  (interactive)
  (let(
       (data	(buffer-substring-no-properties (point-min) (point-max)))
       )
    (erase-buffer)
    (find-file (concat n-local-tmp "/ks.shell_scratch_save"))
    (erase-buffer)
    (insert data)
    (save-buffer)
    (nbuf-kill-current)
    )
  )
(defun nshell-isql( &optional arg)
  "log into a sql server."
  (interactive "P")
  (let(
       (command	(if arg
                    (progn
                      (message "i-nit syb102, n-elson, peridot, THINKPAD, t-truncate sbux10 log, 2-syb102, 5-connect50")
                      (read-char)
                      )
                  ??
                  )
                )
       s
       )
    (nshell)
    (cond
     ((= command ?i)
      (or (y-or-n-p "start server")
          (error "nshell-isql: "))
      (process-send-string nil "su syb102hg\n")
      (sleep-for 2)
      (process-send-string nil "dba\n")
      (sleep-for 3)
      (setq s "cd /usr/local/syb102hg/install; ./RUN_SYB102\n")
      )
     (t
      (setq s "run_isql\n")
      )
     )
    (process-send-string nil s)
    (message "%s" s)
    )
  )

(defun nshell-clear( &optional arg)
  (interactive "P")
  (if arg
      (progn
        (n-file-find n-local-shell-out)
        (goto-char (point-max))
        )
    (if (and
         (get-buffer "out")
         (string= n-local-shell-out (buffer-file-name (get-buffer "out")))
         )
        (kill-buffer "out")
      )
    (insert "\nts=" (current-time-string) "\n")
    (nshell-save)
    (erase-buffer)



    ;;(if (and
    ;;(not n-win)
    ;;(eq major-mode 'shell-mode)
    ;;)
    ;;(n-host-shell-cmd "jobs;la"))



    )
  )
(defun nshell-repeat()
  (interactive)
  (nshell)
  (nshell-clear)
  (cond
   ((eq major-mode 'gud-mode)
    (if (not n-gdb-hot-mode-on)
        (n-gdb-hot-mode))

    (n-gdb-send-string (format "run\n"))
    )
   (t
    ;;(n-host-shell-cmd "!!")
    (call-interactively 'comint-previous-input)
    (call-interactively 'nshell-send-input)
    )
   )
  )
(defun nshell-save()
  (condition-case nil
      (append-to-file (point-min) (point-max) n-local-shell-out)
    (error      (message "could not write file, but I'm not worrying about it")
                )
    )
  )

(setq nshell-same nil)

(setq nshell-no-call nil)

(defun nshell-execute-line(&optional just-edit delimiter-for-expr-to-grab)
  (delete-other-windows)
  (split-window-vertically)
  (nshell)
  (goto-char (point-max))
  (other-window 1)
  (let(
       (line    (if delimiter-for-expr-to-grab
                    (nstr-grab-delimited-token delimiter-for-expr-to-grab)
                  (n-get-line)
                  )
                )
       )
    (other-window 1)
    (goto-char (point-max))
    (insert line)
    (if (not just-edit)
        (funcall (nkeys-binding "\C-m"))
      (save-restriction
        (nsimple-back-to-indentation)
        (n-narrow-to-line)
        (n-s " ")
        )
      )
    )
  )


(defun nshell-meat(&optional arg unknownDir)
  "n1.el: go to shell buffer
ARG is string: go to shell and cd to 'string'
ARG is 0: toggle nshell-same var, which then sends '!!' each time nshell is invoked
ARG is 3: execute current line in shell bufferwrite the current line to the shell process for editing
ARG is 4: write the current line to the shell process for editing
ARG is 5: execute the back-ticked expression under point in shell
ARG non-nil and non-zero then change shell dir to match the previous buffer's current directory
"
  (interactive "P")
  (let ((oldFn		(buffer-file-name))
        (oldDir		default-directory)
        (gotoDir 	(and (listp arg) (integerp (car arg)) (= (car arg) 4)))
        (toggleSameness 	(and (integerp arg) (=  arg 0)))
        (executeOldLine 	(and (integerp arg) (=  arg 3)))
        (editOldLine    	(and (integerp arg) (=  arg 4)))
        (executeBackTickedExpr(if (and (integerp arg) (=  arg 5)) "`"))
        (explicitDir    	(if (stringp arg) arg))
        )
    (cond
     ((or executeOldLine editOldLine executeBackTickedExpr)
      (nshell-execute-line editOldLine executeBackTickedExpr)
      )
     (t
      (if (and oldFn
               (not (string= (buffer-name) "RMAIL"))
               (eq n-file-save-hook-run-level 0)
               (not nshell-no-save-of-prior-file)
               )
          (progn
            (n-file-save-cmd)
            )
        )
      (setq nshell-no-save-of-prior-file nil)
      (if gotoDir			;; suggests user wants to operate on that file, so keep it on screen
          (other-window 1))
      (n-host-goto-shell)
      (if toggleSameness
          (setq nshell-same (not nshell-same)))
      (if (and oldDir gotoDir)
          (setq explicitDir oldDir))
      (if explicitDir
          (n-host-cd explicitDir t (not unknownDir)))
      (if (and oldFn
               (or
                (string-match "/\\.profile" oldFn)
                (string-match "/\\.bashrc" oldFn)
                (string-match "/\\.aliases" oldFn)
                )
               )
          (send-string nil "p\n")
        (if nshell-same
            (send-string nil "!!\n")))
      )
     )
    ) ; let
  (message "     %s" default-directory)
  (setq comint-get-old-input 'n-get-line
        comint-scroll-show-maximum-output nil
        )
  )
;;n19

(defun nshell-filter(string)
  (let (
        (proc (buffer-process))
        (old-buffer (current-buffer))
        (data (match-data))
        )
    (unwind-protect
        (nshell)
      (let (moving)
        ;;(set-buffer (process-buffer proc))
        ;;(setq moving (= (point) (process-mark proc)))
        (save-excursion
          (goto-char (process-mark (get-buffer-process (current-buffer))))
          (save-restriction
            (narrow-to-region(point)
                              (progn
                                (insert string)
                                (point)
                                )
                              )
            (goto-char (point-min))
            (replace-regexp "xx" "yy")
            (goto-char (point-max))
            )
          (set-marker (process-mark proc) (point)))
        (if moving
            (goto-char (process-mark proc))
          )
        )
      (set-buffer old-buffer)
      (store-match-data data)
      )
    )
 )

(defun nshell-fix-up()
  ;; makes screen jumpy
  ;;(save-excursion
  ;;(goto-char (point-min))
  ;;(replace-regexp "\t+" "\t")
  ;;)
  (save-excursion
    (if (and
         (progn
           (forward-line 0)
           (not (looking-at "ftp"))
           )
         (progn
           (nsimple-back-to-indentation)
           (looking-at "cd \\(['\"]\\)?\\([^'\"\n]*\\)")
           )
         )
        (let(
             (quoteMark (n--pat 1))
             (directory (n--pat 2))
             )
          (if (and (not (string= directory "")) (file-exists-p directory))
              (progn
                (if (and (string-match "[ \t]" directory)
                         (or (not quoteMark)
                             (string= "" quoteMark)
                             )
                         )
                    (progn
                      (forward-char 3)
                      (insert "'")
                      (end-of-line)
                      (insert "'")
                      )
                  )
                )
            )
          )
      )
    )
  )

(defun nshell-prompt(host)
  (format "%s.%s 1%%" (user-login-name) host)
  )

(setq nshell-send-input-disable nil)

(defun nshell-send-input--copy-cmd-to-eob()
  (let(
       (cmd (buffer-substring-no-properties (point) (progn
                                                      (end-of-line)
                                                      (point)
                                                      )
                                            )
            )
       )
    (goto-char (point-max))
    (insert cmd)
    )
  )

(defun nshell-send-input()
  (interactive)
  (catch 'done
    (if (and nshell-send-input-disable
             (string= (n--get-lisp-func-name last-command) "nshell-backward-delete-char-untabify")
             )
        ;; this code prot ects against the situation where I reject the last
	;; argument of a command using f10 after <enter>.  DragonDictate will
        ;; repeat the <enter>, although further editing might be appropriate.
	(message "nshell-send-input: disabled")

      (if (not (eobp))
          (save-excursion
            (forward-line 0)
            (cond
             ((looking-at "[ \t]+[0-9]+[ \t]")	;  history output?
              (delete-region (point) (progn	; remove command number
                                       (forward-word 1)
                                       (skip-chars-forward " \t")
                                       (point)
                                       )
                             )
              )
             ((looking-at "[ \t]*\\+") ;  Bourne shell verbose output?
              (delete-region (point) (progn ; remove '+'
                                       (n-s "\\+" t)
                                       (point)
                                       )
                             )
              )
             (t
              (if (looking-at shell-prompt-pattern) ; previous command?
                  (progn
                    ;;(delete-region
                    ;;(progn
                    ;;(n-r shell-prompt-pattern t)
                    ;;(n-s shell-prompt-pattern t)
                    ;;(point)
                    ;;)
                    ;;(progn
                    ;;(forward-line 0)
                    ;;(point)
                    ;;)
                    ;;)

                    (n-s shell-prompt-pattern t)
                    (if (looking-at "#!")
                        (progn
                          (delete-char 2)              ;; this is my scheme to have a commented line that I can ^L into shell and run: prepend w/ #!
                          (delete-horizontal-space)
                          )
                      )
                    )
                )
              )
             )
            (if (not (nsimple-last-line-p))
                (progn
                  (nshell-send-input--copy-cmd-to-eob)
                  )
              )
            )
        )
      (goto-char (point-max))
      (if (string= (n-host-current) "nt386")
          (save-restriction
            ;; double the backslashes to defeat NT.sh's shell substitution
            (forward-line 0)
            (n-s shell-prompt-pattern)
            (replace-regexp "[\\\\]+" "\\\\\\\\\\\\\\\\")
            (end-of-line)
            )
        )

      (setq nshell-send-input-point (point))
      (nshell-fix-up)
      ;;(buffer-substring-no-properties (point) (progn
   ;;(end-of-line)
      ;;(point)
      ;;)
      ;;)
      
      )
    )
  (comint-send-input)
  )
;;n19
(defun nshell-backward-delete-char-untabify()
  (interactive)
  (if
      (string= (n--get-lisp-func-name last-command) "nshell-send-input")
      (progn
        (goto-char nshell-send-input-point)
        (setq nshell-send-input-disable t)
        )
    (if (not
         (string= (n--get-lisp-func-name last-command) "nshell-backward-delete-char-untabify"))
        (setq nshell-send-input-disable nil))
    (backward-delete-char-untabify 1)
    )
  ;;(n-trace "back command: %s, %s" (n--get-lisp-func-name last-command) (if nshell-send-input-disable "t" "nil"))
  )
;;unused (defun nshell-suppress-purify()
;;unused   (interactive)
;;unused  (nsimple-back-to-indentation)
;;unused
;;unused   (let(
;;unused        (token (buffer-substring-no-properties (point)
;;unused                                 (progn
;;unused                                   (n-s "[^a-zA-Z0-9_:]" t)
;;unused                                   (forward-char -1)
;;unused                                   (point)
;;unused                                   )
;;unused                                 )
;;unused               )
;;unused (errorCategory (save-excursion
;;unused                         (n-r "^[A-Z]" t)
;;unused                         (nstr-downcase
;;unused                          (n-grab-token)
;;unused                          )
;;unused                         )
;;unused                       )
;;unused        )
;;unused     (delete-other-windows)
;;unused     (n-file-find (concat "~/" ".purify"))
;;unused     (goto-char (point-max))
;;unused     (insert "suppress " errorCategory " ... ; " token "\n")
;;unused     )
;;unused   (n-other-window)
;;unused
;;unused   (if(n-s "^[A-Z][A-Z][A-Z]:")
;;unused       (message "next")
;;unused     (message "no more purify errors")
;;unused     )
;;unused   )
(defun nshell-ctrl-c()
  (interactive)
  (send-string  nil
                "")
  )
(defun nshell-history()
  (interactive)
  (n-host-shell-cmd "history")
  )
(defun nshell-get-explicit-shell-file-name()
  (if explicit-shell-file-name
      explicit-shell-file-name
    "bash"
    )
  )

;;(add-hook 'comint-output-filter-functions 'shell-strip-ctrl-m nil t)
;;(add-hook 'comint-output-filter-functions 'nshell-filter nil t)
;;(remove-hook 'comint-output-filter-functions 'nshell-filter)

(defun nshell-exit()
  (interactive)
  (send-string nil "\nexit\n")
  (if nshell--nested
      (progn
        (setq nshell--nested nil)
        (send-string nil "\nexit\n")
        )
    )
  )
(defun nshell-backword-word()
  (interactive)

  ;;(backward-word 1)     ;; doesn't work 24.5.1 in shell for some reason?
  (nsimple-backward-word 1)
  (if (looking-at "[0-9]+\\$ ")
      (progn
        (forward-line 0)
        ;;(backward-word 1)
        (nsimple-backward-word 1)
        )
    )
  )
(defun nshell-prompt-exists-on-this-line()
  (save-excursion
    (not (eq (progn
               (nsimple-back-to-indentation)
               (point)
               )
             (progn
               (forward-line 0)   ;; should be (forward-line 0)
               (point)
               )
             )
         )
    )
  )

(defun nshell-join-lines--delete-prompt-on-2nd-line()
  (save-excursion
    (forward-line 1)
    (if (nshell-prompt-exists-on-this-line)
        (progn
          (delete-region
           (progn
             (forward-line 0)
             (point)
             )
           (progn
             (nsimple-back-to-indentation)
             (point)
             )
           )
          ;;(insert "; ")
          )
      )
    )
  )

(setq nshell-error-diagnose-mode nil)

(defun nshell-error-diagnose()
  (interactive)
  (require (quote n-grab))
  (require 'npython)
  (cond
   ((n-r "Can't locate \\(.*\\) in @INC")
    (let(
         (missing (nre-pat 1))
         )
      (n-host-shell-cmd-visible (concat "perl.advise_on_missing " missing))
      )
    )
   ((npython-find-last-frame-of-exception)
    (n-grab-file)
    )
   (t
    (if (not nshell-error-diagnose-mode)
        (setq nshell-error-diagnose-mode t))
    
    (if (= (point) (point-max))
        (comint-show-output)
      (forward-line 1)
      )
    (forward-line 0)
    (n-s "^\\(.*[^0-9a-zA-Z]\\)?/" t)
    (n-grab-file)
    )
   )
  )

(defun nshell-eval-region(beg end)
  (interactive "r")
  "1.) when invoked on ps output, kill all listed processes
2.) ?"
  (let(
       (data (buffer-substring-no-properties beg end))
       )
    (save-excursion
      (goto-char beg)
      (cond
       ((looking-at "^[0-9a-zA-Z_]+[ \t]+[0-9]+[ \t]+")
        (insert "kill -9 "
                (nshell-eval-region--get-pids-from-ps-listed-processes data)
                "\n"
                )
        (forward-line -1)
        (n-host-shell-cmd (nsimple-current-line))
        )
       (t
        (error "nshell-eval-region: cannot interpret %s" (nsimple-current-line))
        )
       )
      )
    )
  )

(defun nshell-eval-region--get-pids-from-ps-listed-processes(ps-list)
  (setq ps-list (nstr-replace-regexp ps-list "^[^ ]* *" ""))
  (setq ps-list (nstr-replace-regexp ps-list " .*" ""))
  (setq ps-list (nstr-replace-regexp ps-list "\n" " "))
  ps-list
  )
(setq nshell-comint-ignore (list
                            "yes"
                            "y$"
                            "h$"
                            "su$"
                            "ssh.root"
                            "r .*"
                            )
      )
(defun nshell-comint-next-input()
  (interactive)
  (nshell-comint-input 'comint-next-input)
  )
(defun nshell-comint-previous-input()
  (interactive)
  (nshell-comint-input 'comint-previous-input)
  )
(defun nshell-comint-input(op)
  (let(
       (max-loops-left 50)
       done
       )
    (while (and (not done)
                (> max-loops-left 0)
                )
      (call-interactively op)
      (save-excursion
        (nsimple-back-to-indentation)
        (n-trace (concat "nshell-comint-input: looking at "
                         (buffer-substring-no-properties (point)
                                                         (progn
                                                           (end-of-line)
                                                           (point)
                                                           )
                                                         )
                         )
                 )
        (save-excursion
          (nsimple-back-to-indentation)
          (setq done (not (nsimple-looking-at-any nshell-comint-ignore))
                max-loops-left (1- max-loops-left)
                )
          )
        )
      )
    )
  )
(defun nshell-kill-st-in-docker-images-output-p()
  (if (save-excursion
        (forward-line 0)
        ;; centos_with_emacs     latest              c1f3d2161ec6        7 days ago          454.9 MB
        ;;
        (looking-at "[^ \t].....................[^ \t]..................\\([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\\)")
        )
      (let(
           (image-id (nre-pat 1))
           )
        (concat "docker.rmi " image-id)
        )
    )
  )
(defun nshell-kill-st-in-du-output-p()
  (if (not (save-excursion
             (forward-line 0)
             (nre-safe-looking-at "\\(.*\\.du5:\\)?[0-9]+\t\.?/")
             )
           )
      nil
    (let(
         (target-dir (progn
                       (forward-line 0)
                       (delete-region (point) (progn
                                                (n-s "\t" t)
                                                (point)
                                                )
                                      )
                       (buffer-substring-no-properties (point) (progn
                                                                 (end-of-line)
                                                                 (point)
                                                                 )
                                                       )
                       )
                     )
         )
      (require 'n-prune-buf)
      (n-prune-buf target-dir)
      (forward-line -1)
      (concat "rm -rf \"" target-dir "\"")
      )
    )
  )
(defun nshell-kill-st-in-diff-output-p()
  (if (save-excursion
        (forward-line 0)
        (looking-at "Only in \\(.*\\): \\(.*\\)")
        )
      (progn
        (concat "rm -rf "
                (nshell-quote-argument (concat
                                        (nre-pat 1)
                                        "/"
                                        (nre-pat 2)
                                        )
                                       )
                )
        )
    )
  )
(defun nshell-kill-st-in-find-output-p()
  (if (save-excursion
        (forward-line 0)
        (or (looking-at "/")
            (looking-at "\\$HOME/")
            (looking-at "\\$dp/")
            (looking-at ".*'s conflicted copy ")
            )
        )
      (concat "rm -rf \"" (n-get-line) "\"")
    )
  )
(defun nshell-kill-st-in-uni-output-p()
  (if (save-excursion
        (forward-line 0)
        (looking-at "Looking at The file \\(.*\\) on host \\(.*\\) should be deleted")
        )
      (concat "ssh `hostname.qualify " (nre-pat 2) "` rm -rf \"" (nre-pat 1) "\"")
    )
  )
(defun nshell-kill-st-in-ps-output-p()
  (if (save-excursion
        (forward-line 0)
        (looking-at "^[-a-z0-9][-a-z0-9]*  *\\([0-9][0-9]*\\)  *[0-9][0-9]*\\.[0-9]  *[0-9][0-9]*\\.[0-9]  *[0-9][0-9]*  *[0-9][0-9]* ")
        )
      (concat "kill -9 " (nre-pat 1))
    )
  )
(defun nshell-kill-line-and-maybe-rm()
  (interactive)
  (let(
       ;; retrieve special kill command for this object, whatever it might be...
       (special-kill-cmd (or
                          (nshell-kill-st-in-uni-output-p)
                          (nshell-kill-st-in-ps-output-p)
                          (nshell-kill-st-in-docker-images-output-p)
                          (nshell-kill-st-in-diff-output-p)
                          (nshell-kill-st-in-du-output-p)
                          (nshell-kill-st-in-find-output-p)
                          )
                         )
       )
    (call-interactively 'nsimple-kill-line)
    (if special-kill-cmd
        (save-excursion
          (goto-char (point-max))
          (insert special-kill-cmd "; ")
          )
      )
    )
  )
(defun nshell-quote-argument(&rest args)
  (save-match-data
    (apply 'shell-quote-argument args)
    )
  )
