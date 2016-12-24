(provide 'ndiff)
;; list of files which are related, as far as diff is concerned
(setq ndiff-pairs (list
                   (cons "/remote/conn7/csi/users/dce/nelson/bin/sybadmin" "/remote/conn5/csi/scripts/sybadmin")
                   )
      )
(setq ndiff-pattern-pairs	
      (if (not n-not-nelson)
          (list
           (cons "e:.*" 
                 (cons "e:" "c:")
                 )
           )
        )
      )

;; list of cofiles
(setq ndiff-opposing-versions nil)
(make-variable-buffer-local 'ndiff-opposing-versions)

;; user with whom you are sharing code.  If this var is set,
;; show-changes will diff your code with that user's code.
(setq ndiff-opposing-user nil)

(setq ndiff-echo nil)

(defun ndiff-bdr-p()
  (looking-at "--\\|\\+\\+")
  )

(defun ndiff-make-lists()
  "remove the lines in *n-list* corresponding to unchanged files in *Diff*;
put diff error messages to *n-diff-errors* buffer"
  (set-buffer "*n-list*")
  (goto-char (point-min))
  (set-buffer "*Diff*")
  (goto-char (point-min))
  (while (n-s "^>>>>>>>>>")
    (forward-line 1)
    (if (looking-at "diff:")	; diff error message
        (progn
          (set-buffer "*n-list*")
          (nsimple-kill-line)
          (set-buffer (get-buffer-create "*n-diff-errors*"))
          (yank))
      (if (or (looking-at ">>>>>>>>>") (eobp))
          (progn
            (set-buffer "*n-list*")
            (nsimple-delete-line))
        (set-buffer "*n-list*")
        (forward-line 1)
        )
      )
    (set-buffer "*Diff*")
    )
  )
(defun ndiff-toggle-echo()
  (setq ndiff-echo (not ndiff-echo))
  (message "ndiff will %secho first file's contents"
           (if ndiff-echo
               ""
             "not "
             )
           )
  )

(defun ndiff-fn( fn &optional opposingFn)
  "n4.el: ndiff's inner routine: FN &optional OPPOSING_FN"
  (if (string-match (concat "^" (nsimple-getenv "P4ROOT") "/") fn)
      (n-host-shell-cmd-visible (format "p4_diff %s" fn))
    (let(
         (stdout		(get-buffer-create "*Diff*"))
         )
      (if (not opposingFn)
          (setq opposingFn (nfly-cofile fn)))
      (n-trace "ndiff-fn %s %s" fn opposingFn)
      (if n-env-op
          (progn
            (n-insert (format ">>>>>>>>>%s changes...\n"
                              (file-name-nondirectory fn))
                      stdout)
            (n-insert (format "%s\n" fn)
                      "*n-list*")
            )
        (n-erase-buffer stdout)
        )
      (switch-to-buffer stdout)
      (cond ((not (file-readable-p fn))		(insert (format "> can't find %s\n" fn)))
            ((not (file-readable-p opposingFn))	(insert (format "> can't find %s\n" opposingFn)))
            (t (call-process "diff"
                             nil
                             t
                             nil
                                        ;"-b" "-t" "-w"       for gnu diff
                             opposingFn
                             fn
                             )
               )
            )
      )
    )
  )

(defun ndiff-env()
  "n4.el: diff all the files in an env, and cat the result to *Diff*"
  (interactive)
  (nbuf-kill "*Diff*")
  (nbuf-kill "*n-list*")
  (n-env-op-domain 'ndiff-fn)
  (switch-to-buffer-other-window "*Diff*")
  )

(defun ndiff( &optional arg)
  (interactive "P")
  (let(
       (command (if arg
                    (progn
                      (message "e-nvironment, p-op, s-elf, w-indow")
                      (read-char)
                      )
                  )
                )
       )
    (cond
     ((not command)
      (save-buffer)
      (ndiff-fn (buffer-file-name))
      )
     ((= command ?e)
      (ndiff-env)
      )
     ((= command ?p)
      (let(
           (f2	(buffer-file-name))
           (f1	(progn
                  (n-loc-pop)
                  (buffer-file-name)
                  )
                )
           )
        (ndiff-fn f1 f2)
        )
      )
     ((= command ?s)
      (ndiff-self)
      )
     )
    )
  )
(defun ndiff-self()
  (let(
       (name "ndiff-self.tmp")
       tmp
       )
    (if (get-buffer name)
        (kill-buffer name))
    (setq tmp (concat n-local-tmp "ndiff-self.tmp"))
    (save-window-excursion
      (n-file-push tmp)
      (erase-buffer)
      (save-buffer)
      (n-file-pop)
      )
    (append-to-file (point-min) (point-max) tmp)
    (ndiff-fn (buffer-file-name) tmp)
    )
  )
(defun ndiff-files(file-1 file-2)
  (not (string=
        (progn
          (n-file-push file-1)
          (prog1
              (buffer-substring-no-properties (point-min) (point-max))
            (n-file-pop)
            )
          )
        (progn
          (n-file-push file-2)
          (prog1
              (buffer-substring-no-properties (point-min) (point-max))
            (n-file-pop)
            )
          )
        )
       )
  )
