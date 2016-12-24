(provide 'nmerge)
;;to enter edit mode:	e
;;return to fast mode:	^c^cf, mcf
;;
;; fnn is the new version, typically from my view (fn2)
;; fnc is the current version, typically from the project codeline (fn1)
;;
(setq nmerge-file-list (concat "$dp/emacs/" "diff.dat"))

;; the following variable indicates that we are not merging a list
;; of files from diff.dat
(setq nmerge-1-module nil)

(defun nmerge( &optional arg)
  (interactive "P")
  (if (get-buffer "*merge*")
      (progn
        (switch-to-buffer "*merge*")
        (emerge-recenter t)
        )

    (if (not arg) (setq arg 0))
    (if (not (integerp arg))
        (progn
          (message "merge: 2-files, s-wc_out, u-ser")
          (setq arg (read-char))
          )
      )
    (cond
     ((eq arg ?u)
      ;; from the opposing user's tree, merge in my changes
      (or (string-match ndiff-opposing-user (buffer-file-name))
          (error ": not in %s's tree" ndiff-opposing-user)
          )
      (let(
           (fnn	(concat (buffer-file-name) ".new"))
           (fnc (nstr-replace-regexp (buffer-file-name)
                                     ndiff-opposing-user
                                     n-local-user
                                     )
                )
           (fnm	(buffer-file-name))
           )
        (if (y-or-n-p (format "nmerge %s into %s? " fnc fnm))
            (progn
              (nmerge-go fnc nil fnm 1)
              )
          )
        )
      )
     ((eq arg ?2)
      (let(
           (fnn	(concat (buffer-file-name) ".new"))
           (fnc (save-window-excursion
                  (n-loc-pop)
                  (nelisp-bp "nmerge" "nmerge.el" 56);;;;;;;;;;;;;;;;;
                  (buffer-file-name)
                  )
                )
           (fnm	(buffer-file-name))
           )
        (if (y-or-n-p (format "nmerge %s into %s? " fnc fnm))
            (progn
              (nmerge-go fnc nil fnm 1)
              )
          )
        )
      )
     (t
      (let(
           (stem	(nmerge-get-next-fn))
           fnm
           )
        (setq fnm	(nmerge-get-fn stem "new")
  )
        (nmerge-go (nmerge-get-fn stem "cur")
                   (nmerge-get-fn stem "old")
                   fnm
                   )
        )
      )
     )
    )
  (auto-save-mode -1)
  )
(defun nmerge-get-next-fn()
  (n-file-push nmerge-file-list)
  (goto-char (point-min))
  (if (n-s "^:next:$")
      (forward-line 1)
    (or (y-or-n-p "nmerge: no place-mark found.  Continue? ")
        (error "nmerge: "))
    (goto-char (point-max))
    (if (n-r "=" 'bof)
        (forward-line 1))
    (insert ":next:\n")
    (save-buffer)
    )
  (or (not (eobp))
      (error "nmerge: no more files"))
  (prog1
      (n-get-line)
    (forward-line 0)
    (message "merge %d/%d" (1- (n-what-line)) (save-excursion
                                                (goto-char (point-max))
                                                (1- (n-what-line))
                                                )
             )
    )
  )
(defun nmerge-get-fn(fn suffix)
  (let(
       (dir (n-database-get suffix
                            (not (string= "old" suffix))
                            nmerge-file-list)
            )
       )
    (if dir
        (concat dir fn))
    )
  )

(defun nmerge-go(fnc fn1 fnm &optional merging-just-1-module)
  (setq nmerge-1-module merging-just-1-module)
  (if (not (file-exists-p fnm))
      (error "nmerge-fn: %s does not exist" fnm))
  (let(
       (fnn (concat fnc ".new"))
       )
    (n-file-copy fnm fnn t)

    (if (and fn1 (file-exists-p fn1))
	(progn

	  (setq emerge-diff-options "")
	  (emerge-files-with-ancestor nil fnn fnc fn1 fnm)

	  (n-trace "new=%s, current=%s, old=%s" fnn fnc fn1)
	  )

      (setq emerge-diff-options
	    (if (not n-win)
		;; only do this if we have gnu diff
		"--ignore-blank-lines --ignore-space-change --minimal"
	      "-b"
	      )
	    )
      (emerge-files nil fnn fnc fnm)
      (n-trace "new=%s, current=%s, no old" fnn fnc )
      )
    )

  (define-key emerge-basic-keymap "q" 'nmerge-quit)
  (define-key emerge-fast-keymap "q" 'nmerge-quit)
  (define-key emerge-fast-keymap "2" 'nmerge-edit-both-chunks)




  (define-key emerge-basic-keymap "\M-2" 'nmerge-edit-both-chunks)
  (define-key emerge-basic-keymap "\M-\C-f" 'emerge-fast-mode)
  ;; for some reason this doesn't work for me!
  ;; so I have a slimy in my global mc-f function which looks at the mode
  ;; and calls emerge-fast-mode, if appropriate
  ;;
  ;;
  ;;

  (nbuf-post-for-kill (buffer-name emerge-A-buffer))
  (nbuf-post-for-kill (buffer-name emerge-B-buffer))
  (nbuf-post-for-kill (buffer-name emerge-merge-buffer))
  (n-shorten-mode-line emerge-A-buffer)
  (n-shorten-mode-line emerge-B-buffer)
  (n-shorten-mode-line)
  (emerge-next-difference)
  (if (looking-at ".*Sccsid")
      (progn
        (emerge-select-B)
        (message "dft sccs")
        )
    )
  (setq emerge-auto-advance 1)
  (n-file-pop)
  )
(defun nmerge-quit()
  (interactive)
  (let(
       (command	(progn
                  (message "n-next, b-back out, s-stop")
                  (read-char)
                  )
                )
       )
    (cond
     ((= command ?b)
      (emerge-really-quit t)
      (nbuf-kill emerge-A-buffer)
      (nbuf-kill emerge-B-buffer)
      (nbuf-kill "*merge*")
      (nbuf-kill "*emerge-diff*")
      (nbuf-kill "*emerge-diff-errors*")
      )
     ((= command ?s)
      (emerge-really-quit nil)
      (if nmerge-1-module
          (setq nmerge-1-module nil)
        (nmerge-quit-advance-marker))
      )
     ((= command ?n)	
      (emerge-really-quit nil)
      (nbuf-kill-current)
      (nmerge-quit-advance-marker)
      (nmerge)
      )
     )
    )
  )
(defun nmerge-quit-advance-marker()
  (n-file-push nmerge-file-list)
  (goto-char (point-min))
  (n-s "^:next:$" t)
  (forward-line 1)
  (transpose-lines 1)
  (save-buffer)
  )
(defun nmerge-edit-both-chunks()
  (interactive)
  (emerge-edit-mode)
  (let(
       (difference	(aref emerge-difference-list emerge-current-difference))
       )
    (let(
         (dataA	(save-window-excursion
                  (set-buffer emerge-A-buffer)
                  (buffer-substring-no-properties (aref difference 0)
                                    (1- (aref difference 1))
                                    )
                  )
                )
         (dataB	(save-window-excursion
                  (set-buffer emerge-B-buffer)
                  (buffer-substring-no-properties (aref difference 2)
                                    (1- (aref difference 3))
                                    )
                  )
                )
         (dataM-begin		(aref difference 4))
         (dataM-end		(1- (aref difference 5)))
         (dataM-contains-A	(or (equal (aref difference 6) 'A)
                                    (equal (aref difference 6) 'default-A)
                                    (equal (aref difference 6) 'prefer-A)
                                    )
                                )
         )
      (if dataM-contains-A
          (progn
            (goto-char dataM-end)
            (save-excursion
              (insert dataB)
              )
            )
        (goto-char dataM-begin)
        (insert dataA)
        )
      (read-char)
      )
    )
  )
(defun n-x7()
  (interactive)
  (find-file "$NELSON_HOME/work/awk/a")
  (n-loc-push)
  (find-file "$NELSON_HOME/work/awk/b")
  (nmerge t)
  )
;;
