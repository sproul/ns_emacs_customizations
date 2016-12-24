(provide 'ntags-find)
(setq-default ntags-find-current-token-class-context (lambda() ""))
(make-variable-buffer-local 'ntags-find-current-token-class-context)

(setq-default ntags-enabled nil)
(make-variable-buffer-local 'ntags-enabled)

(setq-default ntags-find-class-context-operator-regexp "::")
(make-variable-buffer-local 'ntags-find-class-context-operator-regexp)

(setq-default ntags-find-class-context-operator-length (length ntags-find-class-context-operator-regexp))
(make-variable-buffer-local 'ntags-find-class-context-operator-length)

(setq ntags-find-synchronous nil)

(setq ntags-find-done nil)
(setq ntags-find-hits nil)
(setq ntags-find-reference-mode nil)
(setq ntags-find-override-dbs nil)
(make-variable-buffer-local 'ntags-find-override-dbs)

(setq ntags-find-override-by-buf (list
                                  )
      )

(defun ntags-find-override-dbs-get()
  (append
   (if (assoc (buffer-name) ntags-find-override-by-buf)
       (cdr (assoc (buffer-name) ntags-find-override-by-buf))
     nil)
   ntags-find-override-dbs
   )
  )


(setq ntags-find-filter-parser-leftover nil)

(defun ntags-find-filter-parser( proc msg )
  "ntags-find.el: splits msg into \n-delimited strings, and passes them on to ntags-find-filter"
  (n-trace "*ntags-find-filter-parser %s)" msg)
  (if ntags-find-filter-parser-leftover
      (setq msg (concat ntags-find-filter-parser-leftover msg))
    )
  (let(
       newline
       )
    (while (setq newline (string-match "\n" msg))
      (ntags-find-filter (substring msg 0 newline))
      (setq msg (substring msg (1+ newline)))
      )
    (if (string= msg "")
        (setq ntags-find-filter-parser-leftover nil)
      (setq ntags-find-filter-parser-leftover msg)
      )
    )
  )

(defun ntags-find-filter( msg )
  (n-trace (concat "Rcv:  " msg))
  (let(
       (cmd (substring msg 0 (min 1 (length msg))))
       (rest	(if (< 3 (length msg))
                    (substring msg 2)
                  ""))
       )
    (n-trace "ntags-find-filter: %s" msg)
    (cond
     ((string= msg "")
      nil
      )
     ((equal cmd "F")	; file name
      (setq ntags-find-tmp-fn (n-host-name-xlate rest (system-name)))
      )
     ((equal cmd "O")	; offset into the file
      (setq ntags-find-hits (cons (cons ntags-find-tmp-fn rest) ntags-find-hits))
      )
     ((equal cmd "T")   ; tag database update done; update nclass-browser repository
      (require 'nclass-browser)
      (nclass-browser-load "new")
      )
     ((equal cmd "X")	; end-of-data
      (if ntags-find-reference-mode
          (ntags-find-reference-show ntags-find-hits)

	(require 'ntags-sort)
        (setq ntags-find-hits (ntags-sort ntags-find-hits))

	(if ntags-find-synchronous
	    (setq ntags-find-done t)
	  (ntags-find-file)
	  )
        )
      )
     ((equal cmd "E")
      (cond
       ((string-match "\\.\\([^\\.]+\\)$" ntags-find-token)
        (n-trace "tags: couldn't find %s" ntags-find-token)      ;; couldn't find a.b.c
        (setq ntags-find-token (n--pat 1 ntags-find-token))     ;; so look for c alone
        (n-trace "ntags-find: now searching for %s" ntags-find-token)
        (ntags-find-where-is-defn ntags-find-token)
        )
       ((not (ntags-find-backstop ntags-find-token))
        (setq ntags-find-filter-parser-leftover nil);; don't allow errors to linger
        (message "tags: %s" msg)
        )
       )
      )
     (t (message "Malformed command string '%s' received from ntags db" msg))
     )
    )
  )

(defun ntags-sort-hits()
  )
(defun ntags-find-backstop-goto-ext-ddl(token)
  (let(
       ddl
       (dbtype (getenv "extdbtype"))
       suffix
       )
    (setq suffix (if (and dbtype (string= dbtype "oracle"))
		     "ora"
		   "mssql"
		   )
	  ddl (n-host-to-canonical (concat "$ext/pso/$extdataset/V0/CreateAtLarge." suffix))
	  )
    (if (not (or
	      (file-exists-p ddl)
	      (progn
		(setq ddl (n-host-to-canonical (concat "$extInstall/largesoft/install/V0/CreateAtLarge." suffix)))
		(file-exists-p ddl)
		)
	      )
	     )
	nil
      (n-file-find ddl)
      (goto-char (point-min))
      (n-s token t)
      )
    )
  )
(defun ntags-find-backstop(token)
  (cond
   ((n-modes-lispy-p)
    (if (save-excursion
	  (goto-char (point-min))
	  (n-s (concat "^(defun " token "("))
	  )
	(progn
	  (goto-char (point-min))
	  (n-s (concat "^(defun " token "("))
	  t
	  )
      (require 'nelisp)
      (nelisp-help token)
      )
    )
   ((eq major-mode 'njavascript-mode)
    (cond
     ((save-excursion
	(goto-char (point-min))
	(n-s (concat "^function " token "("))
	)
      (goto-char (point-min))
      (n-s (concat "^function " token "("))
      )
     ((save-excursion
        (goto-char (point-min))
        (n-s (concat "^var " token "\\b"))
        )
      (goto-char (point-min))
      (n-s (concat "^var " token "\\b"))
      )
     )
    )
   ((eq major-mode 'nperl-mode)
    (cond
     ((save-excursion
        (goto-char (point-min))
        (n-s (concat "^sub " token "$"))
        )
      (goto-char (point-min))
      (n-s (concat "^sub " token "$"))
      )
     ((file-exists-p (concat token ".pm"))
      (n-file-find (concat token ".pm"))
      )
     )
    )
   ((or
     (eq major-mode 'nruby-mode)
     (eq major-mode 'fundamental-mode)
     )
    (cond
     ((save-excursion
        (goto-char (point-min))
        (or (n-s (concat "^[ \t]*def " token "("))
            (n-s (concat "^[ \t]*attr_accessor[ \t]+" token "$"))
            )
        )
      (goto-char (point-min))
      (n-s (concat "^sub " token "$"))
      )
     ((file-exists-p (concat token ".pm"))
      (n-file-find (concat token ".pm"))
      )
     )
    )
   ((string-match "^al" token)
    (ntags-find-backstop-goto-ext-ddl token)
    )
   )
  )

(defun ntags-find-file--recover-from-stale-hit()
  ;; file has changed.  Search for the token
  (goto-char (point-min))
  (require 'nc)
  (cond
   ((n-modes-lispy-p)
    (if (not (n-s (concat "^(defun " ntags-find-token " *(")))
        (n-s (concat "\\b" ntags-find-token "\\b"))
      )
    (if (string= (nfn-prefix) "n-modes")
        (progn
          (end-of-line)
          (n-r "'" t)
          (forward-char 1)
          )
      )
    )
   ((eq major-mode 'nperl-mode)
    (if (n-s (concat "^sub " ntags-find-token "\\b"))
        (progn
          (forward-line 0)
          (n-s "sub " t)
          )
      (n-s (concat "^my " ntags-find-token "\\b"))
      )
    )
   ((or (eq major-mode 'njavascript-mode)
        (eq major-mode 'nhtml-mode)
        )
    (if (n-s (concat "^function " ntags-find-token "("))
        (progn
          (forward-line 0)
          (n-s "function " t)
          )
      (n-s (concat "^var " ntags-find-token "\\b"))
      )
    )
   ((nc-mode-kin-p)
    (or (n-s (concat "::" ntags-find-token "\\b"))
        (n-s (concat "class[^\n]*" ntags-find-token "\\b"))
        (n-s (concat ntags-find-token "\\b[^\n]*("))
        (n-s (concat "\\b" ntags-find-token "\\b"))
        )
    )
   (t
    (n-s (concat "\\b" ntags-find-token "\\b"))
    )
   )
  )


(defun ntags-find-file--post()
  (cond
   ((n-modes-lispy-p)
    (if (string= (nfn-prefix) "n-modes")
        (progn
          (end-of-line)
          (n-r "'" t)
          (forward-char 1)
          )
      )
    )
   )
  )

(defun ntags-find-file()
  (if (not ntags-find-hits)
      (message "ntags-find-file: no more hits")
    (let(
         fn
         offsetS
         )
      (while (progn
               (setq fn		(n-host-to-canonical (caar ntags-find-hits))
                     offsetS	(cdar ntags-find-hits)
                     ntags-find-hits (cdr ntags-find-hits)
                     )
               (if (and
                    (or (file-readable-p fn)
                        (and (string-match "c:/Users/nelsons/\\(.*\\)" fn)
                             (string-match "^vagrant.*" system-name)
                             (setq fn (nstr-replace-regexp fn "c:/Users/nelsons" "/home/root"))
                             (file-readable-p fn)
                             )
                        ;;(or (not (string= (nfn-suffix fn) "html")) (y-or-n-p (concat "browse " fn "? ")))
                        )
                    )
                   nil
                 (message "ntags-find-file: %s rejected" fn)
                 (setq fn nil)
                 ntags-find-hits
                 )
               )
        )
    
      
      (cond
       ((not fn)
        ;; no readable files were found.   just exit; don't overwrite the message call above
        )
       ;;((string= (nfn-suffixfn) "html")
       ;;(nhtml-browse nil fn)
       ;;)
       ((and n-win
             (string-match ".*\\.\\(hlp\\|HLP\\)$" fn)
             )
        (nsimple-call-process t "n_winhelp" nil
                              "-i"
                              ntags-find-token
                              fn)
        )
       (t
        (if ntags-find-user-repeat
            (let(
                 (n-open-file-in-new-window nil)
                 )
              (if (not ntags-find-old-file-loaded)
                  (nbuf-kill-current))
              
              (n-file-find fn)
              )
          (setq ntags-find-old-file-loaded (get-buffer (file-name-nondirectory fn)))
          (n-file-find fn)
          )
        (goto-char (1+ (string-to-int offsetS)))
        (forward-line 0)
        (if (and (not (looking-at (concat ".*" ntags-find-token ".*")))
                 (not (looking-at "`"))	;; curious beginning to all defns in c:/mysql/Docs/manual.txt.  It's ok.
                 )
            (ntags-find-file--recover-from-stale-hit)
          )
        (ntags-find-file--post)
        )
       )
      )
    )
  )

(setq ntags-find-user-repeat nil)	; is the user making repeated requests for the same token
(setq ntags-find-token nil) ; token being searched for
(setq ntags-find-old-file-loaded nil) ; flag to tell if the new file
                                        ; had already been loaded, and therefore shouldn't
                                        ; be tossed if the user repeats the tag query


(defun ntags-find-where( &optional arg)
  "with arg: menu

To grep thru mail db, use n-rmail option"
  (interactive "P")
  (require 'nelisp)

  (message "1sec: ntags-find-where")
  (sleep-for 1)

  (n-loc-push)
  (if (not
       (string= (n--get-lisp-func-name last-command) "ntags-find-where"))
      (setq ntags-find-hits nil))

  (let(
       (cmd	(if arg
                    (progn
                      (message "h-elp, i-nfo file search, m-an, o-veride db, r-eference, R-i")
                      (read-char)
                      )
                  )
                )
       token
       )
    (cond
     ((not arg)
      (setq token
            (if (and (eq major-mode 'njava-mode) (string= token "super"))
		(progn
		  (require 'nclass-browser)
		  (nclass-browser-get-parent (nc-find-current-code-class-context))
		  )
              (n-grab-token)
              )
            )
      ;;      (if (and	; winhelp doesn't work for me.  Help me! -Nelson
      ;;               n-win
      ;;               (string-match "^[A-Z][a-z][a-zA-Z]*$" token)	; looks like a win32 call
      ;;               (y-or-n-p "call winhelp? ")
      ;;               )
      ;;          (ntags-find-help-nt386 token)
      (ntags-find-where-is-defn token)
      ;;        )
      )
     ((= cmd ?h)
      (ntags-find-help-nt386 (n-grab-token))
      )
     ((= cmd ?i)
      (n-env-grep nil "grep -in " (n-grab-token) " "  "$NELSON_HOME/work/info/elisp*/*elisp*"))
     ((= cmd ?m)
      (require 'nman)
      (nman-dynamic (n-grab-token))
      )
     ((= cmd ?r)
      (setq ntags-find-token (n-grab-token))
      ;; call interactively so this-command will be set (for the filter)
      (call-interactively 'ntags-find-reference)
      )
     ((= cmd ?R)
      (call-interactively 'ri)
      )
     )
    )
  )
(defun ntags-find-help-nt386(token)
  (start-process "n_winhelp" "*Messages*" "n_winhelp"
                 "-i"
                 token
                 "d:\\msvc20\\help\\API32.HLP")
  )

(defun ntags-find-where-is-defn( &optional token)
  "ntags-find.el: grab the item under point and bring up its def'n"
  (setq ntags-find-user-repeat (and
                                (string= (n--get-lisp-func-name last-command) "ntags-find-where")
                                (string= (n--get-lisp-func-name this-command) "ntags-find-where")
                                )
        )

  (if ntags-find-user-repeat
      (ntags-find-file)
    (let(
         cmd
         (context (funcall ntags-find-current-token-class-context))
         )
      (setq ntags-find-hits nil)
      (if (not context)
          (setq context ""))
      (setq ntags-find-old-file-loaded t ; the current file should stay
            ntags-find-token (if token token (n-grab-token))
            cmd (format "%s: %s\n"
                        context
                        ntags-find-token)
            )
      (n-trace "querying tags database: %s" cmd)
      (if (not (get-process "tags-db"))
          (ntags-find-init))
      (process-send-string "tags-db" cmd)
      )
    )
  )

(defun ntags-start-process(name category)
  (save-window-excursion
    (set-buffer (get-buffer-create "t"))
    (cd (n-host-to-canonical "$dp/emacs/tags/"))
    (let(
         (process (n-start-process name
                                   (current-buffer)
                                   "perl"
                                   "$dp/emacs/tags/db.pl"
                                   "-d"
                                   (concat "$NELSON_HOME/tmp/tags/" category)
                                   )
                  )
         )
      (process-kill-without-query process)
      (set-process-filter   process 'ntags-find-filter-parser)
      (set-process-sentinel process 'n-sentinel)
      (n-process-catch-up-maybe)
      )
    )
  )

(defun ntags-find-init()
  "start tag db processes"
  (interactive)
  (message "tag database starting...")
  (ntags-start-process "tags-db" "main")
  ;;(ntags-update)
  )

(defun ntags-setup-for-parser-debug()
  (let(
       (debugFile (concat "$dp/emacs/tags/k." (nfn-suffix)))
       (source (buffer-substring-no-properties (point-min) (point-max)))
       )
    (find-file "$dp/emacs/tags/k.list")
    (delete-region (point-min) (point-max))
    (insert debugFile "\n")
    (save-buffer)
    (nbuf-kill-current)

    (delete-other-windows)
    (find-file "$dp/emacs/tags/parse.pl")

    (n-file-find debugFile)
    (delete-region (point-min) (point-max))
    (insert source)
    (goto-char (point-min))
    )
  )

(defun ntags-reinit()
  (interactive)
  (message "d-debug parser, g-enerate, k-ill, K-ill+restart, m-ain.flist, s-tart, t-ags file, u-pdate")
  (let(
       (command (read-char))
       )
    (cond
     ((eq command ?d)
      (ntags-setup-for-parser-debug)
      )
     ((eq command ?g)
      (if (get-process "tags-db")
	  (kill-process "tags-db"))
      (n-host-shell-cmd-visible (concat (n-host-to-canonical "$dp/emacs/tags/generate.sh")
					" &"
					)
				)
      )
     ((eq command ?k)
      (if (member 'nclass-browser features)
	  (nclass-browser-clear))
      (kill-process "tags-db")
      )
     ((eq command ?K)
      (if (member 'nclass-browser features)
	  (nclass-browser-clear))
      (kill-process "tags-db")
      (nasync-timer 1 'ntags-find-init))
     ((eq command ?m)
      (n-file-find (n-host-to-canonical (concat "$NELSON_HOME/tmp/" "tags/main.flist")))
      )
     ((eq command ?s)
      (ntags-find-init)
      )
     ((eq command ?t)
      (n-file-find (n-host-to-canonical (concat "$NELSON_HOME/tmp/" "tags/main.tags")))
      )
     ((eq command ?u)
      (ntags-update)
      )
     )
    )
  )

(defun ntags-find-mouse( arg)
  "call ntags-find-where-is-defn via mouse"
  (interactive)
  (save-excursion                       ; I can get away with this because it is the filter which actually
                                        ; goes to the new buffer
    (x-mouse-set-point arg)
    (ntags-find-where-is-defn)
    )
  )
(defun ntags-find-reference()
  (interactive)
  (error "ntags-find-reference: broken")
  (setq ntags-find-reference-output (concat "$dp/emacs/tags/"
                                            "hits/"
                                            ntags-find-token
                                            ".files"
                                            )
        )
  (if (file-exists-p ntags-find-reference-output)
      (progn
        (n-file-find ntags-find-reference-output)
        (setq n-grab-file-go-by-lines nil)
        )
    (setq ntags-find-reference-mode t)
    (let(
         (cmd	(format "%s %d\n" ntags-find-token 0))
         (process	(get-process  "reference-tags-db"))
         )
      (if (not process)
          (setq process (ntags-start-process "reference-tags-db" "ref")))
      (process-send-string process cmd)
      )
    )
  )
(defun ntags-find-reference-show(hits)
  (error "ntags-find-reference-show: broken")
  (setq ntags-find-reference-mode nil)
  (n-file-find ntags-find-reference-output)
  (setq n-grab-file-go-by-lines nil)
  (while hits
    (insert (format "%s:%s\n" (caar hits) (cdar hits)))
    (setq hits (cdr hits))
    )
  (save-buffer)
  (goto-char (point-min))
  )

(defun ntags-remember-for-update()
  (let(
       (f (n-host-to-canonical (buffer-file-name)))
       )
    (save-window-excursion
      (save-excursion
        (set-buffer (get-buffer-create "new.flist"))
        (insert "," f "\n")
        )
      )
    )
  )
(defun ntags-purge(overriddenFile shouldBeThere buffer)
  (set-buffer buffer)
  (if (not
       (or
        (prog1
            (n-s overriddenFile)
          (forward-line 0)
          )
        (n-r overriddenFile)
        )
       )
      (if (and (not n-not-nelson)
               shouldBeThere
               )
          ;;(y-or-n-p (format "ntags-purge: could not find %s in %s.  Continue " overriddenFile (buffer-file-name))
          (message "ntags-purge: could not find %s in %s.  Adding..." overriddenFile (buffer-file-name))
        )
    (forward-line 0)
    (delete-region (point)
                   (progn
                     (end-of-line)
                     ;; careful here: if the following file has already been purged,
                     ;; then there will follow a blank line which must be preserved.
                     ;; So search for either a blank line or a file name:
                     (n-s "^\\(\\([a-zA-Z]:\\)?/.*\\)?$" 'eof)
                     (forward-line 0)
                     (forward-char -1)
                     (point)
                     )
                   )
    )
  )
(defun ntags-update()
  (save-window-excursion
    (if (and
         (get-process "tags-db")
         (get-buffer "new.flist")
         )
        (progn
          (if (not (get-buffer "main.flist"))
              (find-file-noselect (n-host-to-canonical "$TMP/tags/main.flist")))
          (if (not (get-buffer "main.classes"))
              (find-file-noselect (n-host-to-canonical "$TMP/tags/main.classes")))
          (if (not (get-buffer "main.tags"))
              (find-file-noselect (n-host-to-canonical "$TMP/tags/main.tags")))

          (set-buffer (get-buffer "new.flist"))
          (goto-char (point-min))

          (while (not (eobp))
            (setq overriddenFile (n-get-line))
            (forward-line 1)
            (ntags-purge overriddenFile t "main.flist")
            (ntags-purge overriddenFile t "main.tags")
            (ntags-purge overriddenFile nil "main.classes")
            (set-buffer "new.flist")
            )

          (let(
               (newFiles (buffer-substring-no-properties (point-min) (point-max)))
               (fileList (concat "$NELSON_HOME/tmp/tags/new.flist"))
               )
            (set-buffer "main.flist")
            (goto-char (point-max))
            (insert newFiles)

            (save-some-buffers t)
            (kill-buffer "main.classes")
            (kill-buffer "main.flist")
            (kill-buffer "main.tags")

            (set-buffer "new.flist")
            (write-file fileList)
            (kill-buffer nil)

            (process-send-string (get-process "tags-db")
				 "N new\n"
				 )
            )
          )
      )
    )
  )

(defun ntags-find-where-is-defn-sync(token &optional contextFile)
  "ntags-find.el: return the filename and offset of the definition of TOKEN.  If the optional argument CONTEXTFILE is non-null, use it for sorting relevance of multiple definitions"
  (let(
       (ntags-find-synchronous t)
       (ntags-find-done nil)
       done
       (n 0)
       )
    (ntags-find-where-is-defn token)
    (sleep-for 0 20)
    (while (not ntags-find-done)
      (sleep-for 0 10)
      (setq n (1+ n))
      )
    (if ntags-find-hits
	(car ntags-find-hits))
    )
  )
;;(ntags-find-where-is-defn-sync "Element")

(defun n-x7()
  (interactive)
  (setq ntags-find-token  "printf")
  (call-interactively 'ntags-find-reference)
  )
;;(ntags-find-fn-from-number 1)
(defun ntags-find-fn-from-number(fnNo)
  (save-window-excursion
    (find-file (n-host-to-canonical "$TMP/tags/main.flist"))
    (goto-char (point-min))
    (goto-line (1+ fnNo))
    (prog1
	(n-get-line)
      (bury-buffer)
      )
    )
  )
