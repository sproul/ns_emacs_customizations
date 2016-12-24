(provide 'nfly)
(setq split-width-threshold nil)  ;; e23
(setq nfly-fn nil)
(setq nfly-reading-file-name nil)
(setq nfly-completion-stack nil)
(setq ange-ftp-generate-anonymous-password "afraid@sybase.com")
;;(setq ange-ftp-ftp-program-name "rftp")

(defun nfly-cofile(fn)
  (n-host-from-canonical
   (let(
        route
        fn2
        )
     (setq fn2	(cond
		 ((string-match "/teacher/" fn)
		  (nstr-replace-regexp fn ".*/teacher/" "d:/old/teacher/")
		  )
		 ((assoc fn ndiff-pairs)
		  (cdr (assoc fn ndiff-pairs))
		  )
		 ((and ndiff-opposing-user
		       (string-match "^~/" fn)
		       )
		  (nstr-replace-regexp fn
				       "^~"
				       (concat "~" ndiff-opposing-user)
				       )
		  )
		 ((and ndiff-opposing-user
		       (string-match (concat "/" (user-login-name) "/")
				     fn)
		       )
		  (nstr-replace-regexp fn
				       (concat "/" (user-login-name) "/")
				       (concat "/" ndiff-opposing-user "/")
				       )
		  )
		 (t
		  (setq route (nstr-assoc fn ndiff-pattern-pairs))
		  (if route
		      (setq
		       route (cdr route)
		       fn2 (nstr-replace-regexp fn (car route) (cdr route))
		       )
		    )
		  )
		 )
	   )
     (cond
      ((not (string= fn fn2))
       fn2)
      (t
       (setq fn2 (concat (file-name-directory fn)
			 "CODE."
			 (file-name-nondirectory fn)
			 )
             )
       (if (not (file-exists-p fn2))
           (nsyb-codeline-file-cmd fn))
       fn2
       )
      )
     )
   )
  )
(defun nfly-match( dir &rest dirEnds)
  (let(
       (dirSaved dir)
       (dirEndsSaved dirEnds)
       newDir
       hit
       )
    (while (and dir (not hit))
      (setq dirEnds dirEndsSaved)
      (while (and dirEnds (not hit))
        (setq newDir (concat dir (car dirEnds)))
        (if (file-exists-p newDir)
            (setq hit t)
          (setq dirEnds (cdr dirEnds))
          )
        )
      (setq dir (nfn-truncate-dir dir))
      )
    (if hit
        newDir
      dirSaved
      )
    )
  )
(defun nfly-delete-char-or-clear(&optional arg)
  (interactive "*p")
  (if (eobp)
      (delete-region (point-min) (point-max))
    (delete-char arg)
    )
  )
(defun nfly-diff()
  (interactive)
  (let(
       (fn (buffer-substring-no-properties (point-min) (point-max)))
       )
    (delete-region (point-min) (point-max))
    (insert (n-host-to-canonical fn))
    )
  (goto-char (point-min))
  (replace-regexp "/" "\\\\")
  (kill-region (point-min) (point-max))
  (nfly-abort)
  )
(defun nfly-switch-to-mixed-and-kill()
  (interactive)
  (nstr-kill (nfn-mixed
              (nstr-replace-regexp
               (nfn-to-pc (buffer-substring-no-properties (point-min) (point-max)))
               "\\\\"
               "/"
               )
              )
             )
  (nfly-abort)
  )
(defun nfly-switch-to-backslashes-and-kill()
  (interactive)
  (let(
       (dos-style-fn  (nfn-to-pc (buffer-substring-no-properties (point-min) (point-max))))
       )
    (nsimple-convert-backslashes-for-this-string-in-future ?n dos-style-fn)
    (nstr-kill dos-style-fn)
    )
  (nfly-abort)
  )

(defun nfly-switch-to-P2-and-kill()
  (interactive)
  (goto-char (point-min))
  (delete-region (point) (progn
                           (n-s "/p4/" t)
                           (point)
                           )
                 )
  (insert "//")
  (nstr-kill (buffer-substring-no-properties (point-min) (point-max)))
  (nfly-abort)
  )

(defun nfly-read-fn-to-replace-region(pt1 pt2)
  (let(
       (initialValue     (buffer-substring-no-properties pt1 pt2))
       )
    (delete-region pt1 pt2)
    (catch 'n-exit
      (nfly-read-fn nil initialValue)
      )
    (nfly-do-posted)
    )
  )

(defun nfly-read-fn(&optional prompt initialValue)
  (if (not prompt)
      (setq prompt ""))
  (if (not initialValue)
      (setq initialValue default-directory))

  (setq initialValue (n-host-to-canonical initialValue))

  (let(
       (nfly-fn			(buffer-file-name))
       nfly-dft-fn
       nfly-dir
       (nfly-buffer-name	(buffer-name))
       (n-host-defaultDrive	(nfn-drive nfly-fn))
       (nfly-reading-file-name 	t)
       (saved-map		(copy-tree minibuffer-local-completion-map))
       fn
       )

    (if (string-match "/$" initialValue)
        (setq nfly-dir initialValue
              nfly-dft-fn ""
              )
      (setq nfly-dir (file-name-directory initialValue)
            nfly-dft-fn  (file-name-nondirectory initialValue)
            )
      )
    (if (boundp 'minibuffer-local-filename-completion-map) (define-key minibuffer-local-filename-completion-map " " 'nfly-complete)) ; minibuffer-complete-word
    (if (boundp 'minibuffer-local-must-match-filename-map) (define-key minibuffer-local-must-match-filename-map " " 'nfly-complete)) ; minibuffer-complete-word
    (define-key minibuffer-local-completion-map " " 'nfly-complete)
    ;;(define-key minibuffer-local-completion-map "@" 'nfly-rftp)
    (define-key minibuffer-local-completion-map "," 'nfly-shortcut-passive)
    (define-key minibuffer-local-completion-map ";" 'nfly-cygdrive-shortcut)
    (define-key minibuffer-local-completion-map "$" 'nfly-enter-dollar-pseudo-sign)
    (define-key minibuffer-local-completion-map "!" 'nfly-shortcut-active)
    (define-key minibuffer-local-completion-map "\\" 'nfly-switch-to-backslashes-and-kill)
    (define-key minibuffer-local-completion-map ">" 'nfly-switch-to-P2-and-kill)
    (define-key minibuffer-local-completion-map ")" 'nfly-minibuffer-set-full-file)
    (define-key minibuffer-local-completion-map "(" 'nfly-minibuffer-set-short-file)
    (define-key minibuffer-local-completion-map "{" 'nfly-minibuffer-set-routine-call)
    (define-key minibuffer-local-completion-map "\C-g" 'nfly-abort)
    (define-key minibuffer-local-completion-map "" 'nfly-backspace)
    (define-key minibuffer-local-completion-map "\C-d" 'nfly-delete-char-or-clear)
    (define-key minibuffer-local-completion-map "\C-j" 'nfly-fill-kill-with-package-and-class)
    (define-key minibuffer-local-completion-map "\C-k" 'nfly-fill-kill)
    (define-key minibuffer-local-completion-map "\C-m" 'nfly-exit-minibuffer)
    (define-key minibuffer-local-completion-map "\C-n" 'nsimple-backward-delete-char-untabify)
    (define-key minibuffer-local-completion-map "\C-r" 'nfly-mini-r)
    (define-key minibuffer-local-completion-map "\C-s" 'nfly-mini-s)
    ;;(define-key minibuffer-local-completion-map "\C-v" 'nfly-ff-remote-cmd)
    (define-key minibuffer-local-completion-map "\C-v" 'nfly-cycle-1)
    (define-key minibuffer-local-completion-map "\M-," 'nfly-truncate)
    (define-key minibuffer-local-completion-map "\M-/" 'nfly-switch-to-mixed-and-kill)
    (define-key minibuffer-local-completion-map "\M-c" 'nfly-prep-midnight)
    (define-key minibuffer-local-completion-map "\M-e" 'nfly-yank-and-explore)
    (define-key minibuffer-local-completion-map "\M-h" 'nfly-goto-url)
    (define-key minibuffer-local-completion-map "\M-p" 'nfly-make-into-p4)
    (define-key minibuffer-local-completion-map "\M-u" 'nfly-make-into-unc)
    (define-key minibuffer-local-completion-map "\M-v" 'nfly-cycle-2)
    (define-key minibuffer-local-completion-map "\M-y" 'nfly-yank-and-put)
    (define-key minibuffer-local-completion-map "\M-3" 'nfly-switch-to-3)
    (define-key minibuffer-local-completion-map "\M-4" 'nfly-switch-to-4)
    (define-key minibuffer-local-completion-map "\M-5" 'nfly-switch-to-5)
    (define-key minibuffer-local-completion-map "\M-6" 'nfly-switch-to-6)
    ;;(define-key minibuffer-local-completion-map "\M-7" 'nfly-switch-to-7)
    (define-key minibuffer-local-completion-map "\M-\C-d" 'nfly-diff)
    (define-key minibuffer-local-completion-map "\M-\C-h" 'nfly-make-into-url-and-kill)
    (define-key minibuffer-local-completion-map "\M-\C-v" 'nfly-cycle-3)
    (define-key minibuffer-local-completion-map "\M-\C-y" 'nfly-yank-and-put-basename)
    ;;unused (define-key minibuffer-local-completion-map "\M-\C-g" 'nfly-switch-to-griffin)
    ;;unused (define-key minibuffer-local-completion-map "\M-\C-p" 'nfly-switch-to-platinum)
    (setq nfly-completion-stack nil
          fn (read-file-name prompt
                             nfly-dir
                             initialValue
    nil
                             nfly-dft-fn
                             )
          )

    (if n-is-xemacs
        (progn
          ;; In XEmacs, the mini buffer key map is constantly reset to one of the following maps, which have been overloaded with
          ;; key mappings which conflict with mine.  So reset these maps to be harmless copies of the minibuffer completion map
          ;; which I have changed above:
          (setq read-file-name-map		minibuffer-local-completion-map)
          (setq read-file-name-must-match-map 	minibuffer-local-completion-map)
          )
      )


    ;;(n-trace "nfly-read-fn(prompt=%s, nfly-dir=%s, initialValue=%s, nfly-dft-fn=%s) => %s"
    ;;prompt
    ;;nfly-dir
    ;;initialValue
    ;;nfly-dft-fn
    ;;fn)
    (if (not (string= "" fn))
        (setq fn
              ;; (nfly-maybe-mount
              (n-host-to-canonical fn)   ;;(n-host-from-canonical fn)
              ;;)
              )
      )
    (setq fn (nstr-replace-regexp fn
                                  pseudo-dollar-sign
                                  "$"
                                  )
          )
    fn
    )
  )

(setq pseudo-dollar-sign "$$")
(defun nfly-enter-dollar-pseudo-sign()
  (interactive)
  (insert pseudo-dollar-sign)
  )
(defun nfly-goto-url()
  (interactive)
  ;;(nfly-make-into-url)
  (require 'njava)
  (nhtml-browse nil (buffer-substring-no-properties (point-min) (point-max)))
  (nfly-abort)
  )
(defun nfly-make-into-url-and-kill()
  (interactive)
  (nfly-make-into-url)
  (nfly-fill-kill)
  )
(defun nfly-make-into-url()
  (interactive)
  (goto-char (point-min))
  (replace-regexp "\\\\" "/")
  (goto-char (point-min))

  (cond
   ((looking-at "//")
    (delete-region (point) (progn
			     (n-s "//[^/]+/" t)
			     (point)
			     )
		   )
    )
   ((looking-at ".*/work/adyn.com/cgi-bin/")
    (delete-region (point) (progn
			     (n-s "cgi-bin/" t)
			     (point)
			     )
		   )
    (insert "www.adyn.com/cgi-bin/")
    (forward-line 0)
    )
   ((looking-at ".*/work/adyn.com/httpdocs/")
    (delete-region (point) (progn
			     (n-s "httpdocs/" t)
			     (point)
			     )
		   )
    (insert "www.adyn.com/")
    (forward-line 0)
    )
   ((looking-at ".*/work/monroe/site/web/")
    (delete-region (point) (progn
			     (n-s "work/monroe/site/web/" t)
			     (point)
			     )
		   )
    (insert "localhost:7081/")
    (forward-line 0)
    )
   ((looking-at ".*SkyNet/automationweb/ras/ROOT/ras/")
    (delete-region (point) (progn
			     (n-s "ROOT/ras/" t)
			     (point)
			     )
		   )
    (insert "localhost:18080/ras/ras/")
    (forward-line 0)
    )
   )
  (insert "http://")
  (end-of-line)
  )

(defun nfly-make-into-unc()
  (interactive)
  (delete-region (point-min)
                 (progn
                   (goto-char (point-min))
                   (or (n-s "/cygdrive/z/")
                       (n-s "/cygdrive/Z/")
                       (n-s "z:/")
                       (n-s "Z:/")
                       (n-s "/home/nelsons/")
                       (n-s "~/")
                       (error "could not find something that looked like my home")
                       )
                   (point)
                   )
                 )
  (insert "//rnonas405.us.oracle.com/vol3/unixhome/nsproul/")
  (end-of-line)
  (nfly-switch-to-backslashes-and-kill)
  )

(defun nfly-make-into-p4()
  (interactive)
  (n-host-to-canonical)

  (goto-char (point-min))
  (delete-region (point-min)
                 (progn
                   (goto-char (point-min))
                   (n-s "/p4" t)
                   (point)
                   )
                 )
  (insert "/")
  (end-of-line)
  (nfly-fill-kill)
  )

(defun nfly-sql-switch(to)
  (if (string-match "/sql_out/[0-9a-zA-Z_]+[0-9]\\." (buffer-substring-no-properties (point-min) (point-max)))
      (progn
	(goto-char (point-min))
	(n-s "/sql_out/[0-9a-zA-Z_]+" t)
	(delete-char -1)
	(insert to)
	t
	)
    )
  )

(defun nfly-switch-to-3()
  (interactive)
  (if (not (nfly-sql-switch "3"))
      (progn
	(nfly-switch-extensity-project "Rel3_1")
	(save-excursion
	  (forward-line 0)
	  (if (looking-at ".*/pso/[0-9a-zA-Z_]+/bkgproc")
	      (replace-regexp "/pso/\\([0-9a-zA-Z_]+\\)/bkgproc" "/largesoft/bkgproc/\\1")
	    )
	  )
	)
    )
  )
(defun nfly-switch-to-4()
  (interactive)
  (if (not (nfly-sql-switch "4"))
      (nfly-switch-extensity-project "Rel4_2"))
  )
(defun nfly-switch-to-5()
  (interactive)
  (if (not (nfly-sql-switch "5"))
      (nfly-switch-extensity-project "Rel5_0"))
  )
(defun nfly-switch-to-6()
  (interactive)
  (nfly-switch-extensity-project "Rel5_6_Patch")
  )
(defun nfly-switch-to-griffin()
  (interactive)
  (save-excursion
    (forward-line 0)
    (replace-regexp "\\\\" "/")
    (forward-line 0)
    (replace-regexp "c:/p4/depot/" "//griffin/f/dev/")
    (replace-regexp "c:/users/" "//griffin/f/users/")
    )
  )
(defun nfly-switch-to-platinum()
  (interactive)
  (save-excursion
    (forward-line 0)
    (replace-regexp "\\\\" "/")
    (forward-line 0)
    (replace-regexp "f:/p4/depot/" "//platinum/c/dev/")
    (replace-regexp "f:/users/" "//platinum/c/users/")
    )
  )
(defun nfly-switch-to-old-V0()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "V0" "V0.old")
    )
  )

(defun nfly-switch-extensity-project(proj)
  (let(
       atEnd
       )
    (save-excursion
      (goto-char (point-min))
      (cond
       ((looking-at "[cC]:[\\/]dev[\\/]")
	(forward-word 2)
	(forward-char 1)
	(delete-region (point) (progn
				 (n-s "[\\/]")
				 (point)
				 )
		       )
	(insert proj "/")
	(setq atEnd (eobp))
	)
       ((looking-at "[cC]:[\\/]")
	(forward-char 3)
	(delete-region (point) (progn
				 (n-s "[\\/]")
				 (point)
				 )
		       )
	(insert proj "/")
	(setq atEnd (eobp))
	)
       )
      )
    (if atEnd
	(end-of-line)
      )
    )
  )

(defun nfly-find-file(&optional fn)
  (interactive)
  (setq fn (nfly-read-fn nil fn))
  (cond
   ((not fn) 	nil)
   
   ((string= fn "")	nil)
   
   ((and (file-directory-p fn)
         (not (eq ?/  (elt fn (1- (length fn)))))
         (not (eq ?\\ (elt fn (1- (length fn)))))
         )
    (nshell (concat fn "/"))               ; if no slash at end of dirspec, send shell there
    )
   ((and (string-match "\\*" fn)
         (not (file-exists-p fn))
         )
    (require 'ndired)
    (ndired fn)
    )
   (t
    (n-file-find
     (n-file-correct-capitalization fn)
     )
    )
   )
  )
(defun nfly-ff-remote-cmd()
  (interactive)
  (nfly-post 'nfly-ff-remote)
  (nfly-abort)
  )
;;(defun nfly-ff-remote( &optional fn)
;;  (interactive)
;;  (if (not fn)
;;                                        ;(setq fn (buffer-substring-no-properties (point-min) (point-max)))
;;      (setq fn "login.com")
;;    )
;;  (if (not fn)
;;      (setq fn (nmenu "" (list
;;                          (cons ?l "login.com")
;;                          )
;;                      )
;;            )
;;    )
;;  (let(
;;       (tfn	(concat n-local-tmp	fn))
;;       getCmd
;;       retCmd
;;       )
;;    (cond
;;     ((n-host-vms-p)
;;      (setq getCmd	(format "copy %s %s"
;;                                (n-host-vmsify fn)
;;                                (n-host-vmsify tfn))
;;            retCmd	(format "copy %s %s"
;;                                (n-host-vmsify tfn)
;;                                (n-host-vmsify fn))
;;            )
;;      )
;;     (t
;;      (setq getCmd	(format "cp %s %s" fn tfn)
;;            retCmd	(format "rm %s; cp %s %s" fn tfn fn)
;;            )
;;      )
;;     )
;;    (message "%s,%s" getCmd retCmd )
;;    (n-host-shell-cmd getCmd)
;;    (n-sleep-for 4)
;;    (n-file-find tfn)
;;    (n-trace "b=%s" (buffer-name))
;;    (nbuf-post-for-kill 'save-buffer)
;;    (nbuf-post-for-kill 'n-host-shell-cmd retCmd)
;;    )
;;  )
(defun nfly-menu( dir)
  (require 'nmenu)
  (setq nmenu-aborted nil)
  (cond
   ((string-match (concat (n-host-to-canonical "$dp/emacs/lisp/") "n?$")
                  dir
                  )
    (nmenu dir "lisp")
    )
   ((string-match "/Tools/SkyNet/xxxxxxxxx$" dir)
    (concat dir
            (nmenu dir "SkyNet")
            )
    )
   ((string-match "/Tools/SkyNet/automationweb/buildportlets/$" dir)
    (concat dir
            (nmenu dir "buildportlets")
            )
    )
   ((string-match "/Tools/build/buildcommon/main/$" dir)
    (concat dir
            (nmenu dir "buildcommon")
            )
    )
   ((string-match "/Tools/SkyNet/automationweb/ras/$" dir)
    (concat dir
            (nmenu dir "ras")
            )
    )
   ((string-match "selenium-rc_svn/trunk/$" dir)
    (concat dir
            (nmenu dir "selenium")
            )
    )
   ((string-match "//plato/$" dir)
    (concat dir
            (nmenu dir "plato")
            )
    )
   )
  )
(defun nfly-find-file-shell( &optional arg)
  (interactive "P")
  ;;(nelisp-external)
  
  ;; somehow this keeps getting undone.  Since it is a cheap operation,
  ;; and this code executes frequently, I'll redo it here:
  (fset 'message (symbol-function 'nsimple-message))
  
  (if arg
      (call-interactively 'execute-extended-command)
    (catch 'n-exit
      (call-interactively 'nfly-find-file)
      )
    (nfly-do-posted)
    )
  )
(defun nfly-menu-call(fn)
  "present menu shortcuts based on FN.  If the menu is aborted,
return nil; otherwise return the file FN."
  (interactive)
  (let(
       choice dir tmp
              )
    (setq fn (n-host-name-xlate fn "unix" n-host-defaultDrive))
    (while (progn
             (setq tmp (n-host-to-canonical (nfly-menu fn)))
	     (cond
	      (nmenu-backed-out
	       (setq fn (nfn-truncate-dir fn)
		     nmenu-backed-out nil
		     )
	       )
	      (tmp
	       (setq choice	(concat choice tmp)
		     fn (if (file-name-absolute-p tmp)
                            tmp
                          (concat fn tmp)
                          )
                     )
               nil
	       )
	      (t 
               nil)
	      )
	     )
      )
    (if nmenu-aborted
	nil
      fn
      )
    )
  )

(defun nfly-entry-hook()
  (condition-case nil
      (call-interactively 'nfly-complete t)
    (error nil)
    )
  )
(add-hook 'minibuffer-setup-hook 'nfly-entry-hook) ; FIXME: causes a lisp error
(setq minibuffer-setup-hook nil)

(defun nfly-complete(&optional nmenu-only)
  (interactive)
  (if nfly-reading-file-name
      (nfly-complete-file-name nmenu-only)
    (minibuffer-complete)
    )
  )

(defun nfly-complete-file-name-skip-bs()
  (let(
       (dir (buffer-substring-no-properties (point-min) (point-max)))
       )
    (cond
     ((string-match "trunk/rc/server-coreless/$" dir)
      (goto-char (point-max))
      (insert "src/main/java/org/openqa/selenium/server/")
      )
     )
    )
  )
(defun nfly-complete-file-name(&optional nmenu-only)
  (if (save-excursion
        (goto-char (point-max))
        (bobp)
        )
      ;; if we are just looking for some arbitrary item (i.e., the
      ;; minibuffer contains no prompt), this space
      ;; is probably spurious padding from DragonDictate.  Ignore it.
      nil

    (let(
         (extra    (if (not (eobp))
                       (prog2
                           (delete-region (point) (progn
                                                    (n-s "[/\\]" 'eof)
                                                    (point)
                                                    )
                                          )
                           (buffer-substring-no-properties (point) (point-max))
                         (delete-region (point) (point-max))
                         )
                     )
                   )
         (startingFn (n-host-to-canonical (buffer-substring-no-properties (point-min) (point-max))))
         (choice (progn
                   (nfly-menu-call
                    (n-host-to-canonical (buffer-substring-no-properties (point-min) (point-max)))
                    )
                   )
                 )
         )

      ;; convert to canonical to avoid n-s problems w/ backslashes
      (goto-char (point-min))
      (insert startingFn)
      (delete-region (point) (progn
                               (goto-char (point-max))
                               (point)
                               )
                     )

      (cond
       ((not choice)
        (nfly-abort)
        )
       ((not (string= (n-host-to-canonical choice)
                      startingFn)
             )
        (erase-buffer)
        (insert choice)
        )
       ((not nmenu-only)
        (call-interactively 'minibuffer-complete)
        )
       )
      (if (string-match (concat "^" startingFn) (buffer-substring-no-properties (point-min) (point-max)))
          (progn
            (setq nfly-completion-stack (cons
                                         (list (buffer-substring-no-properties (point-min) (point-max))
                                               (- (length (buffer-substring-no-properties (point-min) (point-max))) (length startingFn))
                                               )
                                         nfly-completion-stack
                                         )
                  )
            ;;              (n-trace "nfly-completion-stack push: %s,%d"
            ;;                       (caar nfly-completion-stack)
            ;;                       (cadar nfly-completion-stack)
            ;;                       )
            )
        )
      (if extra
          (save-excursion
            (insert extra)
            )
        )
      )
    (nfly-complete-file-name-skip-bs)
    )
  )
(defun nfly-backspace()
  (interactive)
  (if (and nfly-completion-stack
           (string= (caar nfly-completion-stack) (buffer-substring-no-properties (point-min) (point-max)))
           )
      (progn
        (nsimple-backward-delete-char-untabify (cadar nfly-completion-stack))
        (setq nfly-completion-stack (cdr nfly-completion-stack))
        )
    (nsimple-backward-delete-char-untabify)
    )
  )

(defun nfly-abort()
  (interactive)
  (if (not nfly-reading-file-name)
      (abort-recursive-edit))
  
  (require 'nmini)
  (erase-buffer)
  
  (throw 'n-exit t)
  ;;(exit-minibuffer)
  )

(setq nfly-shortcut-matches
      (list
       (cons ?d (list "distrib/"))
       (cons ?g (list "generic/"))
       (cons ?i (list "include/" "distrib/generic/include/" "generic/include/" "usr/include/"))
       (cons ?n (list "nt386/midnight.dev_update"))
       (cons ?s (list "sun4/"))
       )
      )
(defun nfly-minibuffer-set-full-file()
  (interactive)
  (erase-buffer)
  (insert (nfly-go-dft (if nfly-fn
			   nfly-fn
                         nfly-dir
			 )
		       )
	  )
  )
(defun nfly-minibuffer-set-routine-call()
  (interactive)
  (let(
       (routineName (save-window-excursion
		      (set-buffer nfly-buffer-name)
		      (save-restriction
			(save-excursion
			  (n-narrow-to-line)
			  (forward-line 0)
			  (n-s "(" t)
			  (forward-char -2)
			  (prog1
			      (n-grab-token)
			    (other-window -1)
			    )
			  )
			)
		      )
		    )
       )
    (erase-buffer)
    (insert (file-name-nondirectory nfly-fn))
    (n-r "\\." t)
    (delete-region (point) (progn
			     (end-of-line)
			     (point)
			     )
		   )
    (insert "." routineName "()")
    (nfly-fill-kill)
    )
  )

(defun nfly-minibuffer-set-short-file()
  (interactive)
  (if nfly-fn
      (progn
	(erase-buffer)
	(insert (nfly-go-dft (file-name-nondirectory nfly-fn)))
	(nfly-fill-kill)
	)
    )
  )

(defun nfly-shortcut-active()
  (interactive)
  (let(
       (cmd	(read-char))
       newdir
       (fn	(buffer-substring-no-properties (point-min) (point-max)))
       )
    (if (= cmd ?\ )
        (setq cmd	(read-char))
      )
    (cond
     ((= cmd ??)      (ntags-find-where-is-defn "nfly-shortcut-active"))
     ((= cmd ?F)      (setq newdir (nfly-ftp)))
     ;;((= cmd ?@)      (setq newdir (nfly-rftp)))
     ((= cmd ?L)      (setq newdir (nfly-go-to-lib default-directory)))
     ((= cmd ?z)	(setq newdir (nfly-cofile fn)))
     (t
      (setq newdir (apply 'nfly-match (buffer-substring-no-properties (point-min) (point-max))
                          (cdr
                           (assoc
                            cmd
                            nfly-shortcut-matches))))
      )
     )
    (if newdir
        (progn
          (erase-buffer)
          (insert (n-host-from-canonical newdir))
          (nfly-complete t)
          )
      )
    )
  )
(defun nfly-shortcut-passive()
  (interactive)
  (let(
       (cmd	(read-char))
       newdir
       (fn	(buffer-substring-no-properties (point-min) (point-max)))
       )
    (if (= cmd ?\ )
        (setq cmd	(read-char))
      )
    (cond
     ((= cmd ??)      (setq newdir (nmenu "" "nfly-shortcuts")))
     (t
      (setq n-data-menu-nfly-shortcuts (n-database-load "n-data-menu-nfly-shortcuts"))
      (setq newdir	(cdr (assoc cmd n-data-menu-nfly-shortcuts)))
      )
     )
    (if newdir
        (progn
          (erase-buffer)
          (insert (n-host-from-canonical newdir))

	  (goto-char (point-min))
	  (if (looking-at ".*@@")
	      (n-complete-leap)
	    (goto-char (point-max))
	    (nfly-complete t)
	    )
          )
      )
    )
  )

(defun nfly-fill-kill(&optional noTranslation)
  (interactive "P")
  (if (eobp)
      (progn
        (if (and (not noTranslation)
                 n-win
                 )
            (progn
              (goto-char (point-min))
              (replace-regexp "\\\\" "/")
              )
          )
	(setq last-command 'lskdjf)  ; not 'kill-region: don't append to kill ring
        (kill-region (point-min) (point-max))
        (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
        (nfly-abort)
        )
    (kill-line)
    (nsimple-yank-set-my-global-kill-file-from-emacs-kill)
    )
  )
(defun nfly-truncate()
  (interactive)
  (let(
       (dir	(nfn-truncate-dir (buffer-substring-no-properties (point-min) (point-max))))
       )
    (if dir
	(progn
	  (erase-buffer)
	  (insert dir)
	  )
      )
    )
  (nfly-complete t)
  )
(setq enable-recursive-minibuffers t)
(defun nfly-yank-and-explore( &optional arg)
  (interactive)
  (nfly-post 'n-host-shell-cmd-visible (concat "e \"" (nfly-yank-get-fn) "\""))
  (nfly-abort)
  )
(defun nfly-yank-get-fn()
  (n-host-to-canonical (buffer-substring-no-properties (point-min) (point-max)))
  )
(defun nfly-yank-and-put( &optional arg)
  (interactive "P")
  (nfly-exit-hook)

  (if arg
      (progn
	(goto-char (point-min))
	(insert (nfn-fn-to-java-package (buffer-substring-no-properties (point-min) (point-max))))
	(delete-region (point) (point-max))
	)
    )
  (nfly-post 'nfly-insert (nfly-yank-get-fn))
  (nfly-abort)
  )
(defun nfly-yank-and-put-basename()
  (interactive)
  (nfly-exit-hook)
  ;;(nfly-minibuffer-set-full-file)
  (let(
       (fn  (buffer-substring-no-properties (point-max) (progn
                                                          (goto-char (point-max))
                                                          (n-r "/" t)
                                                          (forward-char 1)
                                                          (point)
                                                          )
                                            )
            )
       )
    (nfly-post 'insert fn)
    )
  (nfly-abort)
  )

(defun nfly-insert(data)
  (set-mark (point))
  (cond
   ((string= (nfn-suffix) "bat")
    (setq data (n-host-name-xlate data "nt386")
          data (nstr-replace-regexp data "^\\\\cygdrive\\\\\\(.\\)\\\\" "\\1:\\\\")
          ;;(nstr-replace-regexp "\\cygdrive\\c\\x" "^\\\\cygdrive\\\\\\(.\\)\\\\" "\\1:\\\\")
          )

    (insert data)
    )
   ((or (eq major-mode 'nsh-mode)
        (eq major-mode 'emacs-lisp-mode)
        (eq major-mode 'nperl-mode)
        (eq major-mode 'nlog-mode)
        (eq major-mode 'shell-mode)
        (eq major-mode 'ruby-mode)
        (string= (buffer-name) "*scratch-text*")
        (string= (buffer-name) "todo")
        (string= (buffer-name) "todo<2>")


        ;; ENABLING FOR ALL CIRCUMSTANCES!
        ;; ENABLING FOR ALL CIRCUMSTANCES!
        ;; ENABLING FOR ALL CIRCUMSTANCES!
        t

        )
    ;;;(if (nfn-full-path-p data)
    (progn
      (require 'n-env)
      (setq data  (n-host-to-canonical data))
      (setq data (n-env-use-var-names-str data))
      (if (or (eq major-mode 'nsh-mode)
              (eq major-mode 'shell-mode)
              )
          (progn
            (setq data (nfn-win-to-cygwin data))
            ;;(if (string-match ".* .*" data)
            ;;    (setq data (concat "\"" data "\"")))
            )
        )
      )
      ;;;)
    ;;(if (not (eq major-mode 'shell-mode))
    (insert data)
    ;;(just-one-space)
    ;;(insert data)
    ;;(if (not (string-match "/$" data))
    ;;  (just-one-space))
    ;;)
    )
   (t
    (setq data (n-host-to-canonical data t))
    (insert data)
    )
   )
  )

(defun nfly-write-file(&optional fn)
  (save-buffer)
  (if (not fn)
      (setq fn (nfly-read-fn)))

  (setq fn (n-host-to-canonical fn))

  (if fn
      (progn
        (if (and (file-accessible-directory-p fn)
                 (not (string-match "[\\\\/]$" fn))
                 )
            (setq fn (concat fn "/"))
          )
        
        (if(string-match "[\\\\/]$" fn)
            (setq fn (concat fn (file-name-nondirectory (buffer-file-name))))
          )

        (n-file-maybe-md-p (file-name-directory fn))

        (if (not (file-writable-p fn))
            (progn
              (if (not (y-or-n-p (format "%s is not writable.  Chmod? " fn)))
                  (error "nfly-write-file: "))
              (n-file-toggle-read-onlyness fn)
              )
          )
        (let(
             (oldFile (buffer-file-name))
             )
          (setq fn(n-host-to-canonical fn)
                oldFile	(n-host-to-canonical oldFile)
                )
          (if (string= fn oldFile)
              (error "nfly-write-file: src and dest are the same"))
          (copy-file oldFile fn t)
          (if (not (file-writable-p fn))
              (n-file-chmod "+w" fn)
            )
          (find-file fn)
          (cond
     ((eq major-mode 'nelisp-mode)
            (nelisp-file-copied-hook oldFile fn)
            )
           ((eq major-mode 'nez-mode)
            (nez-file-copied-hook oldFile fn)
            )
           ((eq major-mode 'njava-mode)
            (njava-file-copied-hook oldFile fn)
            )
           ((eq major-mode 'nperl-mode)
            (nperl-file-copied-hook oldFile fn)
            )
           ((eq major-mode 'nsh-mode)
            (nsh-file-copied-hook oldFile fn)
            )
           )
          )
        )
    )
  (message (concat fn " written."))
  )
(setq nfly-posted nil)
(defun nfly-post(cmd &rest rest)
  (setq nfly-posted (cons (cons cmd rest) nfly-posted))
  )
(defun nfly-do-posted()
  (while  nfly-posted
    (apply (caar nfly-posted) (cdar nfly-posted))
    (setq nfly-posted (cdr nfly-posted))
    )
  )

(setq nfly-dft
      (list
       ;;(cons "/verify/midnight\\.\\([^/]*\\)" "/midnight.\\1")
       ;;(cons "/midnight\\.\\([^/]*\\)" "/verify/midnight.\\1")
       )
      )
(defun nfly-go-dft(fn)
  (let(
       (match	(nstr-assoc fn nfly-dft))
       )
    (if match
        (cond
         ((stringp (cdr match))
          (nstr-replace-regexp fn (car match) (cdr match))
          )
         (t (error "nfly-go-dft: "))
         )
      fn
      )
    )
  )
(defun nfly-mini-s()
  (interactive)
  (let(
       (ch	(char-to-string (read-char)))
       )
    (n-s ch)
    )
  )
(defun nfly-mini-r()
  (interactive)
  (let(
       (ch	(char-to-string (read-char)))
       )
    (n-r ch)
    )
  )
(defun nfly-go-to-lib(dir)
  (let(
       (plat	(nfn-plat dir))
       (distrib	(nfly-match dir "distrib/"))
       )
    (concat distrib plat "/devlib/")
    )
  )
(setq nfly-minibuffer-correction nil)
(defun nfly-exit-minibuffer()
  (interactive)
  (if nfly-minibuffer-correction
      (setq nfly-minibuffer-correction nil)
    (nfly-exit-hook)
    (exit-minibuffer)
    )
  )
(defun nfly-exit-hook()
  (goto-char (point-min))
  (n-trace "exit-hook: %s" (buffer-substring-no-properties (point-min) (point-max)))
  (replace-regexp (concat "~/") "$HOME/")
  )

;;  /anonymous@ftp.sun.com:/:
;;  total 32
;;  dr-xr-xr-x   8 root     0            512 Jul  7  2000 .
;;  dr-xr-xr-x   8 root     0            512 Jul  7  2000 ..
;;  lrwxrwxrwx   1 root     users          9 Sep 26  1996 bin -> ./usr/bin
;;  -rw-r--r--   1 root     users         50 Jul  8  1999 welcome.msg
;;
;;  /anonymous@ftp.omegaresearch.com:/pub:
;;  02-19-99  03:10PM       <DIR>          apidocs
;;  11-26-97  10:15AM                  238 index.txt
;;  02-27-02  04:27PM       <DIR>          utilities
;;
;;old
;;(find-file "/anonymous@ftp.omegaresearch.com:/pub/")
;;(find-file "/anonymous@ftp.sun.com:/")

(defun nfly-ftp()
  (goto-char (point-min))
  (if (n-s "@")
      nil
    (erase-buffer)
    (let(
         (host	(nmenu "host" "hosts"))
         )
      (if host
          (progn
            (insert "/" (user-login-name) "@" host ":/")
            )
        )
      )
    )
  )
(defun nfly-rftp()
  (interactive)
  
  (erase-buffer)
  (let(
       (target	(nmenu "host" "ftp_hosts"))
       )
    (insert "/" target ":/")
    )
  )

(defun nfly-jump()
  (interactive)
  (message "buf: ")
  (let(
       newFile
       (cmd	(read-char))
       )
    (cond
     ((= cmd ?\ )	(setq cmd	(read-char)))
     ((= cmd ??)	(setq cmd	nil))
     )

    (if (not n-env)
	(n-env-set))
    (require 'nmenu)
    (setq newFileOffsetCons  (nmenu-choose-shortcut-fileOffsetCons cmd))
    (n-file-find (nsimple-env-expand (car newFileOffsetCons))
                 nil
                 (cdr newFileOffsetCons)
                 t
                 )
    )
  )

(defun nfly-diff()
  (interactive)
  (let(
       (old (buffer-substring-no-properties (point-min) (point-max)))
       cmd
       (new nfly-starting-fn)
       )
    (if (file-directory-p old)
        (setq cmd "cmpr"
              )
      (setq cmd "diff -b"
            )
      )

    (other-window 1)
    (delete-other-windows)
 (nshell)
    (nshell-clear)

    (send-string nil (format "echo %s %s %s\n" cmd old new))
    (send-string nil (format      "%s %s %s\n" cmd old new))
    (sleep-for 0 200)
    (goto-char (point-min))
    )
  )
(defun nfly-reset-starting-fn(fn)
  (setq fn (n-host-to-canonical fn))
  (setq nfly-starting-fn fn)
  )
(defun nfly-cygdrive-shortcut()
  (interactive)
  (delete-region (point-min) (point-max))
  (insert (cond
           (n-is-xemacs "c:/")
           (n-win  "/cygdrive/c/")
           (t      (n-host-to-canonical "$HOME/"))
           )
          )
  )
(defun nfly-prep-midnight()
  (interactive)
  (goto-char (point-min))
  (if (not (looking-at ".*/$"))
      (progn
        (end-of-line)
        (insert "/")
        )
    )
  (end-of-line)
  (insert (nsimple-env-expand "midnight.$OS"))
  )
(defun nfly-to-canonical()
  (insert (prog1
              (n-host-to-canonical (buffer-substring-no-properties (point-min) (point-max)))
            (delete-region (point-min) (point-max))
            )
          )
  )

(defun nfly-fill-kill-with-package-and-class()
  (interactive)
  (delete-region (point-min) (point-max))
  (insert (nfn-fn-to-java-package nfly-fn) "." (nfn-prefix nfly-fn))
  (nfly-fill-kill)
  )
