(provide 'n-file)
(setq n-file-save-hook-assoc (list
                              (cons (concat (getenv "dp") "/data/.nX")
                                    '(lambda(bfn)
                                       (if (not (eq (point-min) (point-max)))
                                           (progn
                                             (n-file-write (current-buffer) (nsimple-env-expand "$TMP/.n"))
                                             ;;(n-host-shell-cmd-visible "encrypt.n $TMP/.n $dp/data/.n.xyz; rm $TMP/.n")
                                             (delete-region (point-min) (point-max))
                                             (not-modified)
                                             (kill-buffer nil)
                                             )
                                         )
                                       )
                                    )
                              )
      )

(fset 'n-file-hook-entrance '(lambda()))

(setq n-file-possibly-create-error nil)
(defun n-file-possibly-create(fn &optional isDirectory)
  (setq fn (n-host-to-canonical fn))
  (cond
   ((file-exists-p fn)
    t
    )
   (n-file-possibly-create-error
    nil
    )
   (t
    (let(
         (dir	(if isDirectory
                    fn
                  (file-name-directory fn)
                  )
                )
         done
         )
      (call-process "mkdir" nil nil nil "-p" dir)
      (if (not isDirectory)
          (call-process "touch" nil nil nil fn)
        )
      (setq done   (file-exists-p fn))
      (if (not done)
          (let(
               (s (format "can't create %s (will try again next emacs session) -- hit a key to continue" fn))
               )
            (message "%s" s)
            (n-trace s)
            (read-char)
            (error "n-file-possibly-create: ")
            ;;(setq n-file-possibly-create-error t)
            )
        )
      done
      )
    )
   )
  )


(n-file-possibly-create "~/work/bu" t)

(defun n-file-hook-entrance()
  (require 'nfn)
  (let(
       (f (buffer-file-name))
       )
    (setq mode-line-format  (list ""
                                  mode-line-modified
                                  'nsyb-cm-locked
                                  (n-env-use-var-names-str default-directory t t)
                                        ;                              mode-line-buffer-identification
                                  "%b"
                                  "   "
                                  global-mode-string
                                  "   %[("
                                  'mode-name
                                  "%n"
                                  mode-line-process
                                  ")%]----"
                                  (cons -3 "%p")
                                  "-%-"
                                  )
          )
    (force-mode-line-update)

    (if (and
         (not (file-exists-p (file-name-directory f)))
         (y-or-n-p "create dir? ")
         )
        (n-host-shell-cmd-visible (concat "mkdir -p " (file-name-directory f)))
      )
    (if n-win
        ;; if buffer-file-type is nil, then the file is treated
        ;; as binary data and no carriage returns are attached.
        ;; This is the preferred way to go, since it reduces
        ;; problems using these files under unix.
        (setq buffer-file-type
              (not (string-match "\\.bat$" f))
              )
      )
    ;;(if (not n-win) (n-file-fixup-control-Ms))

    (if (nfn-is-extensity-p f) (n-file-extensity-fixups))

    (cond
     ((string-match "/[cC]:" f)
      (setq f (nstr-replace-regexp f ".*/\\([cC]:\\)" "\\1")
            f (n-host-to-canonical f)
            )
      (find-alternate-file f)
      )
     ((or
       (string-match ".elprofile$" f)
       (string-match ".alias$" f)
       )
      (goto-char (point-max))
      )
     ((or
       (string-equal (nsimple-env-expand "$dp/data/.nX")  f)
       (string-equal (nsimple-env-expand "$TMP/.nX")  f)
       )
      (delete-region (point-min) (point-max))
      (call-process "bash" nil t t (nsimple-env-expand "$dp/bin/.n"))
      (not-modified)
      ;;(nbuf-post-for-kill 'save-buffer)
      )
     ((string-match "eclipse_.*launch.ahk$" f)
      (goto-char (point-max))
      (n-r "SendInput .*Test.*")
      (n-s " " t)
      )
     ((and
       (string-match "/emacs/lisp/data/n-data-menu-\\(.*\\).el$" f)
       (= (point-min) (point-max))
       )
      (insert "(setq n-data-menu-" (n--pat 1 f) "
      (list
  (cons?@@ \"@@\")
)
)
")
      (goto-char (point-min))
      (n-complete-leap)
      )
     ((string-match "teacher.java$" f)
      (goto-char (point-min))
      (if (not (n-s "NSPROUL;//null"))
          (n-s "null;//NSPROUL"))
      (forward-word-1)
      )
     ((string-match "t_debug_ProposeNotes.sh$" f)
      (goto-char (point-min))
      (n-s "^id=" t)
      )
     ((save-excursion
	(goto-char (point-min))
        (buffer-file-name)
	(looking-at "\\(:$\\|#!/bin/sh\\)")
	)
      (nsh-mode)
      )
     )
    )
  (require 'nsyb)
  ;;(nsyb-see-if-it-is-locked)
  (if (and
       (looking-at "# A Perforce Change Specification.")
       (n-s "<enter description here>")
       )
      (progn
        (nsimple-delete-line 1)
        (n-open-line)
        (insert "\t@@")
        ;;(recursive-edit)
        ;;(call-interactively 'server-edit)
        )
    )
  (setq make-backup-files nil)          ;; I don't know who is setting this, but I want it off!  -nas 3/4/10
  (if (not (string= "" (buffer-substring-no-properties (point-min) (point-max))))
      (setq this-command 'n-complete-beginning-of-buffer)       ; a way to get n-complete-searching to put us into search mode as we enter a non-empty file
    )
  )

(defun n-file-set-hook()
  (if (not (member 'n-file-hook-entrance  find-file-hooks))
      (setq find-file-hooks (list 'n-file-hook-entrance))
    )
  )

(setq-default n-file-pushed nil)
(make-variable-buffer-local 'n-file-pushed)

(defun n-file-fixup-control-Ms(f)
  (if (and
       (not (string-match "\...v$" f))	; don't touch pvcs files
       (not (string-match "project.jnl$" f))	; don't touch pvcs files
       (looking-at "[^\n]*\015$")
       (save-excursion
	 (forward-line 1)
	 (looking-at ".*\015$") ; \015 is ^M
	 )
       )
      (save-excursion
	(goto-char (point-min))
	(replace-regexp "\015$" "")
	(message "removed trailing ^Ms")
	(set-buffer-modified-p nil)
	)
    )
  )

(defun n-file-delta(addend)
  (if (integerp n-file-pushed)
      (progn
        (setq n-file-pushed (+ n-file-pushed addend))
        (if (and
             (eq n-file-pushed 0)
             (not (buffer-modified-p))
             )
            (nbuf-kill (current-buffer))
          )
        )
    )
  )

(defun n-file-push(fn &optional switchToBuffer)
  (if (file-directory-p fn)
      (error "n-file-push: %s is a directory" fn))
  (setq fn (n-host-to-canonical fn))
  (let(
       (buf	(get-buffer (file-name-nondirectory fn)))
       alreadyLoaded
       )
    (if (and buf
	     (string= fn
		      (n-host-to-canonical (buffer-file-name buf))
		      )
             )
	(setq alreadyLoaded t)
      (setq buf (find-file-noselect fn))
      )
    (if switchToBuffer
	(progn
	  (error "n-file-push: not reliable -- I dunno why!  Fuck this -- just use n-file-find.")
	  (if n-open-file-in-new-window
	      (switch-to-buffer-other-window buf)
	    (switch-to-buffer buf)
	    )
	  )
      (set-buffer buf)
      (if (not alreadyLoaded)
	  (setq n-file-pushed 0))
      (n-file-delta 1)
      )
    )
  )
(defun n-file-pop()
  (n-file-delta -1)
  )
(defun n-file-find(fn &optional mustExist offset by-lines column-offset)
  "get FN;
optional:

MUSTEXIST: signal error if the file cannot be read
OFFSET: place in the file to which  point should be set
	If it's a string, a conversion to an int is attempted.
	If that fails, then it is assumed to be a search pattern.
BY-LINES: boolean telling whether the offset is in terms of lines or bytes
"
  (n-trace "n-file-find 0: %s" fn)
  (if (not fn)
      (message "n-file-find: no file")
    (let(
         (is	(progn
                  (setq fn (n-host-to-canonical fn))
                  (file-readable-p fn)
                  )
                )
         )
      (n-trace "n-file-find 1: %s" fn)
      (cond
       ((file-directory-p fn)
        (n-trace "n-file-find 1.1: %s" fn)
	(require 'ndired)
        (n-trace "n-file-find 1.2: %s" fn)
	(ndired fn)
        (n-trace "n-file-find 1.3: %s" fn)
	)
       ((and (not is) mustExist)
	(error "n-file-find cannot read %s" fn)
	)
       ((string= fn (buffer-file-name))
	nil	; we are already in this file
	)
       (n-open-file-in-new-window
	(find-file-other-window fn)
        (n-file-hook-entrance)
	)
       )
      (n-trace "n-file-find 2: %s" fn)
      (find-file fn)
      (n-trace "n-file-find 3: %s" fn)
      (if offset
	  (progn
	    (if (stringp offset)
		(if (string-match "^[0-9]+$" offset)
		    (setq offset (string-to-int offset))
		  )
	      )
	    (if (stringp offset)
		(n-s offset t)
	      (if by-lines
		  (progn
		    (goto-line offset)
		    (if column-offset
			(progn
			  (forward-line 0)
			  (forward-char column-offset)
			  )
		      )
		    )
		(goto-char offset)
		)
	      )
	    )
	)
      (n-trace "n-file-find 4: %s" fn)
      is
      )
    )
  )
;;(n-file-find "/cygdrive/c/Users/nelsons/Dropbox/bin/win" nil nil  nil nil)
;;(n-file-find "/cygdrive/c/Users/nelsons" nil nil  nil nil)

(defun n-file-init()  ;; unused currently
  (n-trace ".emacs check point 7.51")
  (let(
       (active	(n-database-get "active-file"))
       )
    (n-trace ".emacs check point 7.52")
    ;; the format of the stored file names: name:offset|name:offset|name:offset|...
    ;; e.g.,
    ;; active-file=/home/nelson/z/dp/emacs/lisp/n-file.el:5768|/home/nelson/data/whitelight/whatever:197|

    (while (and active (string-match "\\([^|]+\\):\\([0-9]+\\)|?\\(.*\\)?" active))
      (n-trace ".emacs check point 7.53")
      (setq next (n--pat 3 active))
      (let(
           (file (n--pat 1 active))
           (where (string-to-int (n--pat 2 active)))
           )
        (setq active (n--pat 3 active))
        (message "%s:%d" file where)
        (sleep-for 1)
        (n-file-find file)
        (goto-char where)
        (n-trace ".emacs check point 7.54")
        )
      )
    )
  (n-trace ".emacs check point 7.55")
  ;; here is the delay
  (n-database-set "active-file" "")
  (n-trace ".emacs check point 7.56")
  )
(defun n-file-add-active(name offset)

  ;; remove previous entry for this file, if any.
  (n-file-subtract-active name)

  (let(
       (active	(n-database-get "active-file"))
       )
    (if (not active)
        (setq active ""))
    (if (string-match (concat "\\(.*|\\)\\(" name ":[0-9]+|\\)\\(.*\\)")
                      active)
        (setq active (concat
                      (n--pat 1 active)
                      (n--pat 3 active)
                      )
              )
      )

    (setq active (concat active
                         (format "%s:%d|" name offset)
                         )
          )
    (n-database-set "active-file" active)
    )
  )
(defun n-file-subtract-active(name)
  (let(
       (active	(n-database-get "active-file"))
       )
    (if (and active
             (string-match (concat "\\(.*|\\)\\(" name ":[0-9]+|\\)\\(.*\\)")
                           active)
             )
        (progn
          (setq active (concat
                        (n--pat 1 active)
                        (n--pat 3 active)
                        )
                )
          (n-database-set "active-file" active)
          )
      )
    )
  )

(defun n-file-copy-elsewhere(before after)
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       (srcFn (n-host-to-canonical (buffer-file-name)))
       destFn
       )
    (setq
     before (nsimple-env-expand before)
     after (nsimple-env-expand after)
     destFn (nstr-replace-regexp srcFn before after)
     )

    (n-trace "n-file-copy-elsewhere %s %s: cp %s %s\n" before after srcFn destFn)


    (find-file destFn)
    (delete-region (point-min) (point-max))
    (insert data)
    (save-buffer)
    (kill-buffer (current-buffer))
    )
  )

(setq n-file-save-hook-run-level 0)

(defun n-file-save-hook()
  (setq n-file-save-hook-run-level (1+ n-file-save-hook-run-level))
  (unwind-protect
      (condition-case nil
          (let(
               (bfn           (buffer-file-name))
               bn
               fn2
               )
            (setq bn           (file-name-nondirectory bfn))

            (cond
             ((string-equal (nsimple-env-expand "$dp/data/.nX")  bfn)
              (if (not (eq (point-min) (point-max)))
                  (progn
                    (n-file-write (current-buffer) (nsimple-env-expand "$TMP/.n"))
                    (n-host-shell-cmd-visible "encrypt.n $TMP/.n $dp/data/.n.xyz; rm $TMP/.n")
                    (delete-region (point-min) (point-max))
                    (not-modified)
                    (kill-buffer nil)
                    )
                )
              )
             ((string-match "__shared_cs.js$" bfn)
              (progn
                (require 'njava)
                (njavascript-duplicate-client-and-server-code)
                )
              )
             ((eq major-mode 'nsh-mode)
              (n-file-chmod  "a+x")
              )

             ((and
               (not n-win)
               (or
                (string-match "exceed.*\.kbd$" bn)
                (string-match ".*\.bat$" bn)
                (string-match ".*\.BAT$" bn)
                )
               )
              (save-excursion
                (goto-char (point-min))
                (replace-regexp "\\([^\015]\\)$" "\\1\015")

                ;;quirk: the last line must be empty, without even a ^M
                (goto-char (point-max))
                (forward-line 0)
                (if (looking-at "\015$")
                    (delete-char 1)
                  (end-of-line)
                  (insert "\n")
                  )
                )
              )
             ((and n-win
                   (string= (n-host-to-canonical "$dp/data/HOSTS")
                            (n-host-to-canonical bfn)
                            )
                   )
              (not-modified)
              ;;(n-host-shell-cmd-visible (format "cp %s $SYSTEMROOT/SYSTEM32/DRIVERS/ETC/HOSTS" (n-host-to-canonical bfn)))
              (n-host-shell-cmd-visible (format "hosts.update_from_drop"))
              (not-modified t)
              )
             ((and (eq 1 n-file-save-hook-run-level)
                   (n-file-output-file-this-file-overwrites)
                   )
              (copy-file (buffer-file-name) (n-file-output-file-this-file-overwrites) t)
              )
             )

            (if (save-excursion
                  (goto-char (point-max))
                  (n-r "^# on-write: \\(.*\\)")
                  )
                (let(
                     (cmd (nre-pat 1))
                     )
                  (setq cmd (nstr-replace-regexp cmd "\\$FN" (buffer-file-name)))
                  (n-host-shell-cmd-visible cmd)
                  )
              )



            (if (and (string-match "/site_cp/.*py$" bfn)
                     (not n-win)
                     )
                ;; this is to force uwsgi to reload the python if it is running (see u.wsgi --touch-reload=$dp/python/site_cp/scripts/u.wsgi)
                (n-file-touch "$dp/python/site_cp/scripts/u.wsgi")
              )
            )
        )
    (setq n-file-save-hook-run-level (1- n-file-save-hook-run-level))
    )
  nil ;; otherwise file is considered to be written, Whereas what I am really doing here is to react to the potential writing of the file (not to actually write the file myself)
  )

(defun n-file-touch(fn)
  (setq fn (n-host-to-canonical-or-cygwin fn))
  (call-process "touch" nil (get-buffer-create "t") nil "touch" fn)
  (if (not (n-file-exists-p fn))
      (progn
        (if (n-file-exists-p "$dp/bin/touch")
            (progn
              (message "I see $dp/bin/touch is back, about to delete it...")
              (sleep-for 2)
              (n-file-delete "$dp/bin/touch")
              (n-file-touch fn) ;; retry
              )
          (error "n-file-touch: expected %s to exist, but it does not"))
        )
    )
  )


;; after-save-hook
;; before-save-hook
;; write-contents-functions
;; write-file-functions
(or (memq 'n-file-save-hook write-file-hooks)
    (setq write-file-hooks
          (cons 'n-file-save-hook write-file-hooks)))

(setq n-file-save-cmd-old-fn nil)
(setq n-file-save-cmd-new-fn nil)
(defun n-file-save-cmd(&optional arg)
  "like save-buffer cept some mode-specific handling"
  (interactive "P")
  (let(
       (modified (buffer-modified-p))
       )
    (setq n-file-save-cmd-old-fn (buffer-file-name))
    (if modified
        (progn
          (n-file-save-hook)
          (save-buffer)
          )
      )
    (cond
     (arg
      (nfly-write-file)

      (if (string= (nfn-suffix) "cgi")
          (nsh-check-for-potential-suexec-violation))

      (if (and (integerp arg)
               (or (= arg 3)  (= arg 4))
               )
          (progn
            (n-file-delete n-file-save-cmd-old-fn)
            (n-file-adjust-shortcuts n-file-save-cmd-old-fn (buffer-file-name))
            (if (= arg 4)
                (n-host-shell-cmd-visible (concat "sed -i -e 's/" (file-name-nondirectory n-file-save-cmd-old-fn) "/" (file-name-nondirectory (buffer-file-name)) "/g' $dp/bin/* $dp/bin/*/*"))
              )
            )
        )
      )
     )
    ;;  (if (and n-win
    ;;           (not n-not-nelson)
    ;;           )
    ;;      (ntags-update))
    )
  (setq n-file-save-cmd-new-fn (buffer-file-name))
  )

(defun n-file-adjust-shortcuts(old_fn new_fn)
  (let(
       (shortcuts_fn (concat (getenv "dp") "/emacs/lisp/data/n-data-menu-nbuf-shortcuts.el"))
       )
    (n-host-shell-cmd-visible (concat "sedi -v "
                                      shortcuts_fn
                                      ;; this is hard -- the backslashes get stripped as you pass this around...
                                      ;;" 's;" (nre-escape-double (n-env-use-var-names-str old_fn)) ";" (nre-escape-double (n-env-use-var-names-str new_fn)) ";'"

                                      ;; much simpler, and will be right most of the time:
                                      " 's;/" (file-name-nondirectory old_fn) "\";/" (file-name-nondirectory new_fn) "\";'"
                                      )
                              )
    )
  )
;;(n-file-adjust-shortcuts "/cygdrive/c/Users/nelsons/dp/public-maven-repo-master/bin/mrc.inject" "/cygdrive/c/Users/nelsons/dp/public-maven-repo-master/bin/mrc.ucm")

(defun n-file-length(fn)
  (save-window-excursion
    (n-file-push fn)
    (prog1
        (1- (point-max))
      (n-file-pop)
      )
    )
  )
(defun n-file-recover()
  "work with file recovery facilities (e.g., emacs backup, manual backup to a:, etc)"
  (interactive)
  (let(
       (command (progn
                  (message "a-recover from a:, d-diff with emacs backup, D-diff with a:, r-emacs-recover")
                  (read-char)
                  )
          )
       )
    (cond
     ((eqcommand ?a)
      (let(
           (backup (nstr-replace-regexp (buffer-file-name) "^." "a"))
           )
        (delete-region (point-min) (point-max))
        (insert-file-contents backup)
        )
      )
     ((eq command ?d)
      (let(
           (backup (concat "#" (file-name-nondirectory (buffer-file-name)) "#"))
           )
        (goto-char (point-min))
        (delete-other-windows)
        (nsimple-split-window-vertically)
        (find-file backup)
        (compare-windows t)
        )
      )
     ((eq command ?D)
      (let(
	   (backup (nstr-replace-regexp (buffer-file-name) "^." "a"))
	   )
	(goto-char (point-min))
	(delete-other-windows)
	(nsimple-split-window-vertically)
	(find-file backup)
	(compare-windows t)
	)
      )
     ((eq command ?r)
      (recover-file (buffer-file-name))
      )
     )
    )
  )

(defun n-file-find-from-path ( fn &optional ffpath mustExist)
  "finds FN optionally using FFPATH.
Return nil if unsuccessful.

Optional 3rd arg signifies that it is an error if the file doesn't exist"
  (interactive "sFind file: $ffpath/" )
  (let (
        longFn
        foundIt
        )
    (while (and ffpath (not foundIt))
      (setq longFn (expand-file-name (concat (car ffpath) fn)))
      (n-trace "n-file-find-from-path: '%s' - %s\n" longFn fn )
      (if (file-exists-p longFn)
          (progn
                                        ;(n-trace "\t%s exists open new: %s\n" longFn (if n-open-file-in-new-window "t" "nil"))
            (n-file-find longFn)
            (setq foundIt t)
            )
        (setq ffpath (cdr ffpath))
          )
      )
    
    (if foundIt
        t
      (if mustExist
          (error "n-file-find-from-path: cannot load %s" fn))
      nil
      )
    )
  )

(defun n-file-refresh-from-disk()
  "n5.el: get a fresh copy of the current copy from the disk, no questions asked"
  (interactive)
  (let(
       (fn (n-file-name))
       (place	(point))
       )
    (not-modified)
    (find-alternate-file fn)
    (goto-char place)
    (message "Fresh disk copy")
    )
  )

(setq n-file-name-val nil)
(make-variable-buffer-local 'n-file-name-val)

(defun n-file-name()
  "n5.el: same as buffer-file-name, 'cept it's an error if there's no file name
associated with the current buffer"
  (if n-file-name-val
      n-file-name-val
    (let(
         (fn (buffer-file-name))
         )
      (if fn
          fn
        (if (equal major-mode 'dired-mode)
            default-directory
          ""
          )
        )
      )
    )
  )


(defun n-file-ls( &optional arg)
  "do ls -l on the current file"
  (interactive "P")
  (let(
       output
       (fn
        ;;(if (and arg (n-makefile-p))
        ;;(n-make-eval-pt-token)
        (buffer-file-name)
        ;;)
        )
       )
    (if (not fn)
        (error "n-file-ls: no file"))
    (require 'nshell)
    (cond
     ((and arg (integerp arg) (= arg 3))
      (n-file-find (nstr-replace-regexp (buffer-file-name)
                                        (concat "/"
                                                (nstr-replace-regexp (nsimple-env-expand "$dp") ".*/" "")
                                                "/"
                                                )
                                        "/work.daily/"))
      )
     (arg
      (n-host-shell-cmd-visible (concat "lsb -choose_for_restore " fn))
      )
     (t
      (setq output (save-window-excursion
                     (n-zap "*ks*")
                     (call-process (nshell-get-explicit-shell-file-name) nil t t "l" fn)
                     (goto-char (point-min))
                     (prog1
                         (n-get-line)
                       (nbuf-kill-current)
                       )
                     )
            )
      (message "%s" output)
      )
     )
    )
  )

(defun n-file-ls-backups()
  "do lsb on the current file"
  (interactive)
  (n-host-shell-cmd-visible (format "lsb %s" (buffer-file-name)))
  )

(defun n-file-correct-capitalization(path)
  ;;
  ;; If PATH matches a file which already exists on a file system which does
  ;; not distinguish between case, then this routine will adjust that path to
  ;; match the name of the existing file
  ;;
  ;;
  (let(
       list
       (directory (file-name-directory path))
       correctedFile
       (file (file-name-nondirectory path))
       downFile
       )
    (if (and directory        ; this should always be true, except in systems with broken filename handling
             (not (string-match "^/cygdrive/$" directory))
             )
        (progn
          (setq downFile (nstr-downcase file)
                list		(directory-files directory)
                )
          (while list
            (if (string=
                 (nstr-downcase (car list))
                 downFile)
                (progn
                  (setq correctedFile (concat directory (car list)))
                  (setq list nil)
                  )
              (setq list (cdr list))
              )
            )
          )
      )
    (if correctedFile correctedFile path)
    )
  )
(defun n-file-delete(fn &optional killBuf)
  "n6.el: delete fn, don't complain if it doesn't exist.  If optional arg
KILLBUF non-nil, kill buffer by same name also"
  (setq fn (n-host-to-canonical fn))
  (if (file-exists-p fn)
      (if (file-directory-p fn)
          (progn
            (n-trace "rm -r %s..." fn)
            (call-process "rm" nil (get-buffer "*Messages*") nil "-r" fn)
            (n-trace "\n")
            )
        (n-file-delete-cmd fn)
        )
    )
  (if killBuf
      (nbuf-kill (file-name-nondirectory fn)))
  )

(defun n-file-exists-p(fn)
  (let(
       (rc (if (not fn)
               nil
             (if (and (not (string= fn ""))
                      (not (string-match "..*//" fn))
                      )
                 (setq fn (n-host-to-canonical fn))
               )
             (condition-case nil
                 (file-exists-p fn)
               (error nil)
               )
             )
           )
       )
    (n-trace "n-file-exists-p %s: %s" fn (if rc "exists" "NO"))
    rc
    )
  )


(defun n-file-delete-cmd-nelson(fn)
  (if (not (n-file-exists-p "$dp/bin/k"))
      (n-host-shell-cmd-visible "echo ':' > $dp/bin/k"))
  (n-host-shell-cmd-visible (format "echo \"rm '%s'\" >> $dp/bin/k"
                                    (n-env-use-var-names-str fn)
                                    )
                            )
  )

(defun n-file-delete-cmd( &optional arg)
  "delete the current file; with optional ARGUMENT non-nil, restore the last file deleted bythis command"
  (interactive "P")
  (let(
       (backupFn (n-host-to-canonical "$TMP/deleted"))

       (command	(if (or
                     (not arg)
                     (stringp arg)
                     )
                    ?d
                  (message "o-bsolete, r-estore, z-ombie-target")
                  (read-char)
                  )
                )
       (fn	 (if (stringp arg)
                     arg
                   (buffer-file-name)
                   )
                 )
       )
    (cond
     ((eq command ?o)

      (if (n-env-is-whitelight)
	  (n-file-delete-cmd-whitelight fn))

      (if (not n-not-nelson)
	  (n-file-delete-cmd-nelson fn))

      (n-file-delete-cmd)
      (if (file-exists-p (concat (file-name-directory fn) "makefile"))
	  (progn
	    (find-file (concat (file-name-directory fn) "makefile"))
	    (goto-char (point-min))
	    (if (n-s (nfn-prefix (file-name-nondirectory fn)))
		(forward-word -1)
	      )
	    )
	)
      )
     ((eq command ?r)
      (setq fn	(read-file-name "Enter file to be restored:" default-directory))
      (rename-file backupFn fn 1)
      (n-file-find fn)
      )
     ((eq command ?d)
      (if (not fn)
          (error "No file associated with %s" (buffer-name)))
      (find-file fn)	; make fn's buffer current
      (kill-buffer (current-buffer))
      (if (file-exists-p backupFn)
          (delete-file backupFn))
      (rename-file fn backupFn t)
      (n-file-chmod "+w" backupFn)
      (not-modified)
      (if (string-match "c:/.*/teacher/html/.*_vt_.*.html" fn)
	  (let(
	       (ofn (nstr-replace-regexp fn ".*/teacher/" "d:/old/teacher/"))
	       )
	    (n-file-delete ofn)
	    (message "%s and %s removed" fn ofn)
	    )
	(message "%s removed" fn)
	)
      )
     ((eq command ?z)
      (n-host-shell-cmd-visible (format "rm.zombies.add \"%s\"" fn))
      )
     )
    )

  ;; if this command executes as part of a series of buffer cycle calls,
  ;; update the appropriate recordkeeping
  (if (and
       (string= (n--get-lisp-func-name this-command) "n-file-delete-cmd")
       (string= (n--get-lisp-func-name last-command) "nbuf-cycle")
       )
      (progn
	(setq this-command 'nbuf-cycle)
	(call-interactively 'nbuf-cycle)
	)
    )
  )
(defun n-file-read( fn)
  "read FN into the current buf"
  (let(
       (buf	(current-buffer))
       (data	(buffer-substring-no-properties (progn
                                                  (find-file fn)
                                                  (point-min))
                                                (point-max))
                )
       )
    (nbuf-kill-current)
    (set-buffer buf)
    (insert data)
    )
  )
(defun n-file-bu( &optional arg)
  "bu cur file"
  (interactive "P")
  (if arg
      (n-file-bu-all)
    (let(
         (data	 (buffer-substring-no-properties (point-min) (point-max)))
         )
      (find-file (concat "~/work/bu/" (file-name-nondirectory (buffer-file-name))))
      (erase-buffer)
      (insert data)
      (save-buffer)
      )
                                        ;    (copy-file (buffer-file-name)
                                        ;               (concat "~/work/bu/" (file-name-nondirectory (buffer-file-name)))
                                        ;               0)
    (message "backed up %s" (file-name-nondirectory (buffer-file-name)))
    )
  )


(defun n-file-bu-all()
  "backup files of interest (as defined by n-env-domain-file-list)"
  (let(
       (fileList	n-env-domain-file-list)
       )
    (while fileList
      (n-host-shell-cmd (concat "cp "
                                (nre-simple-emacs-to-csh (n-host-to-canonical (car fileList)))
                                " "
                                "~/work/bu/"
                                )
                        )

      (message "%s" (concat "Backing up " (car fileList))
               )
      (setq fileList (cdr fileList))
      )
    )
  )
(defun n-file-md-p(dir)
  (if (not (file-exists-p dir))
      (progn
        (call-process "mkdir" nil nil nil "-p" dir)
        (or (file-exists-p dir)
            (error "n-file-md-p: dir not found")
            )
        (message (concat dir " created."))
        )
    )
  )
;;(n-file-md-p "/cygdrive/c/xxx2/a/b/c/d")

(defun n-file-toggle-read-onlyness(&optional fn)
  "if the current file is read-only, make it writable; if the current file is writable, make it read-only"
  (interactive)
  (if (not (buffer-file-name))
      (toggle-read-only)
    (let(
	 isCurrentFile
	 )
      (if (not fn)
	  (progn
	    (setq isCurrentFile t)
	    (setq fn (buffer-file-name))
	    )
	)
      (let(
           (make-it-writable    (nbuf-read-only-p))
           )
        (if make-it-writable
            ;; for some reason, (file-writable-p fn) is not reliable -- so use nbuf-read-only-p instead
            (progn
              (n-file-chmod "+w" fn)
              )
          )
        (if isCurrentFile
            (n-file-refresh-from-disk))
        )
      )
    )
  )
(defun n-file-writable-p(&optional fn)
  (if (not fn)
      (setq fn (buffer-file-name)))
  (file-writable-p fn)
)
(defun n-file-replace-regexp(fn before after &optional insertAtEofIfNoMatch)
  (let (
	(data (match-data))
	ok
	)
    (unwind-protect
	(progn
	  (setq fn (n-host-to-canonical fn))
	  (if (not (file-exists-p fn))
	      (message "n-file-replace-regexp could not find %s" fn)
	    (n-file-push fn)
	    (or (file-writable-p fn)
		(if (y-or-n-p (format "Want to update %s, but it's r/o.  Chmod? " fn))
		    (progn
		      (n-file-toggle-read-onlyness)
		      t
		      )
		  )
		(error "n-file-replace-regexp: %s" fn)
		)

	    (save-excursion
	      (goto-char (point-min))

	      (setq ok (n-s before))
	      (goto-char (point-min))
	      (if (and (not ok) insertAtEofIfNoMatch)
		  (progn
		    (goto-char (point-max))
		    (insert insertAtEofIfNoMatch)
		    )
		(replace-regexp before after)
		)
	      (save-buffer)
	      )
	    (n-file-pop)
	    )
	  )
      (store-match-data data)
      )
    ok
    )
  )
(defun n-file-write( &optional buf fN)
  "write BUFFER to a file with same name (or
optionally to FILENAME"
  (save-excursion
    (if (not buf)
	(setq buf (current-buffer))
      (if (stringp buf)
	  (setq buf (get-buffer buf)))
      )
    (set-buffer buf)
    (write-file (if fN
		    fN
		  (buffer-name)
		  )
		)
    )
  )
(defun n-file-extensity-fixups()
  (if (and (not buffer-read-only)
	   (not (n-s "Copyright (C) 1995-2001 Extensity, Inc."))
	   )
      (replace-regexp "Copyright (C) [0-9]+[ \t]*[-,][ \t]*[0-9]+ @?\\(Large\\|Extensity\\)\\( Software\\)?, Inc."
		      "Copyright (C) 1995-2000 Extensity, Inc."
		      )
    )
  )

(defun n-file-copy(f1 f2 arg)
  (setq f1 (n-host-to-canonical f1)
	f2 (n-host-to-canonical f2)
	)

  (if (and
       arg
       (n-file-exists-p f2)
       (not (file-writable-p f2))
       )
      (n-file-chmod "+w" f2)
    )
  (copy-file f1 f2 arg)
  )

;;(setq mode "+w" fn "/cygdrive/c/Users/nelsons/dp/emacs/lisp/n-file.el")
(defun n-file-chmod(mode &optional fn)
  (if (not fn)
      (setq fn (buffer-file-name)))
  (call-process "sh" nil (get-buffer-create "t") nil (n-host-to-canonical "$dp/bin/nchmod") mode (n-host-to-canonical-or-cygwin fn))
  )

(defun n-file-always-load( &optional arg)
  "add current file to the list of files which are automatically loaded at emacs init x.
W/ optional arg, remove file from that list.
If arg is 0, also rm it."
  (interactive "P")
  (let(
       (fn	(n-file-name))
       )
    (n-file-find "$dp/emacs/lisp/data/n-data-menu-nbuf-shortcuts.el")
    (goto-char (point-min))
    (widen)
    (narrow-to-region (progn
                        (n-s (concat "(setq n-data-menu-nbuf-shortcuts_" n-env) t)
                        (n-r "(setq " t)
                        (point)
                        )
                      (progn
			(forward-sexp 1)
                        (point)
                        )
                      )
    (goto-char (point-min))
    (n-s "(cons" t)
    (forward-line 0)
    (insert "       (cons ?@@ \"" (n-env-use-var-names-str fn) "\")\n")
    (forward-line -1)
    (n-complete-leap)
    (recursive-edit)
    )
  )
(defun n-file-maybe-md-p(dir)
  (if (not (file-accessible-directory-p dir))
      (if (y-or-n-p (concat "create dir " dir "? "))
          (progn
            (n-file-md-p dir)
            )
        )
    )
  )
(defun n-file-contents(fn)
  (save-window-excursion
    (n-file-find fn)
    (buffer-substring-no-properties (point-min) (point-max))
    )
  )
(defun n-file-output-file-this-file-overwrites()
  (let(
       (bfn (buffer-file-name))
       )
    (cond
     ((string-match "Dropbox/craig/shared/html/scripts/" bfn)
      (nstr-replace-regexp bfn "Dropbox/craig/shared/html/scripts/" "tmp/craig/html/scripts/")
      )
     (t nil)
     )
    )
  )
(defun n-file-make-writable()
  (if buffer-read-only
      (n-file-toggle-read-onlyness))
  )
(defun n-file-exists-replace-p(fn before after)
  (let(
       (tfn (nstr-replace-regexp fn before after))
       )
    (if (n-file-exists-p tfn)
        tfn)
    )
  )
(defun n-file-first-file-that-exists(file-list)
  (let(
       f
       )
    (while file-list
      (setq f (car file-list)
            file-list (cdr file-list)
            )
      (if (n-file-exists-p f)
          (setq file-list nil)
        )
      )
    f
    )
  )
