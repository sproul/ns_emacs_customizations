(provide 'nmidnight)
(if (not (boundp 'nmidnight-mode-map))
    (setq nmidnight-mode-map (make-sparse-keymap)))
(setq nmidnight-output-stack (nlist-create))
(setq midnight-grep-output-buffer (concat "midnight.grep." n-local-user "." system-name))

(make-variable-buffer-local 'nmidnight-host)
(set-default 'nmidnight-host nil)

(make-variable-buffer-local 'nmidnight-last-host)
(set-default 'nmidnight-last-host nil)

(make-variable-buffer-local 'nmidnight-command)
(set-default 'nmidnight-command nil)

(make-variable-buffer-local 'nmidnight-make-makefile)
(set-default 'nmidnight-make-makefile '(lambda() (error "make-makefile unsupported in this mode")))

(make-variable-buffer-local 'nmidnight-tmp)
(set-default 'nmidnight-tmp nil)

(defun nmidnight-mode-meat()
  (auto-save-mode 0)
  (setq major-mode 'nmidnight-mode
        mode-name "nmidnight mode"
	;;tab-width (string-to-int (n-database-get "c-cpp-java-tab-width" t nil "4"))
        )
  (if (and (string-match "^midnight.local" (buffer-name))
           (= (point-min) (point-max))
           (file-exists-p "local-run.sh")
           )
      (insert "sh ./local-run.sh -v\n")
    )

  (goto-char (point-max))
  (use-local-map nmidnight-mode-map)
  (define-key nmidnight-mode-map "\C-m" 'nmidnight-return)
  (define-key nmidnight-mode-map "\C-cx" 'nmidnight-shovel)
  (define-key nmidnight-mode-map "\C-cz" 'nmidnight-execute)
  (define-key nmidnight-mode-map "\C-xr" 'nmidnight-shell-and-execute-again)
  (define-key nmidnight-mode-map "\M-c" nil)
  (define-key nmidnight-mode-map "\M-t" 'nmidnight-test)
  (define-key nmidnight-mode-map "\M-w" 'nmidnight-ntags-find-where)
  (define-key nmidnight-mode-map "\M-/" nil)
  (define-key nmidnight-mode-map "\M-\C-c" 'nmidnight-rotate)
  (define-key nmidnight-mode-map "\M-\C-z" 'nmidnight-touch-modules-with-undefined-symbols)
  )
(defun nmidnight-compile(&optional arg)
  (interactive "P")
  (setq require-final-newline nil)
  (if (eq major-mode 'nmidnight)
      (setq nshell-error-diagnose-mode nil))

  (let(
       (cmd (if arg (progn
                      (message "1-dir build, j-java tests, J-ava, pt-suite, u-pdate canon")
                      (read-char)
                      )
              )
            )
       )
    (if (not nmidnight-tmp)
        (nbuf-post-for-kill 'save-buffer)
      )

    (require 'nsort)
    (nsort-alphatize-tagged-regions t)
    (save-some-buffers t)
    (let(
         repeat-command	; after the clean, do another build?
         (f (n-host-to-canonical (buffer-file-name)))
         )
      (cond
       ((string-match "/apps.dat$" f) (nmidnight-monitor-test))
       ((string-match "/.nlog.x$" f) (nlog-commit))
       ((string-match "/ahk_abc$" f) (n-host-shell-cmd-visible "ahk"))
       ((string-match "/alln.links$" f) (n-host-shell-cmd-visible "alln.gen"))
       ((string-match "/apps.dat$" f) (n-host-shell-cmd-visible (concat "mon.apps_line_analyze '" (n-get-line) "'")))
       ((string-match "/etc/nginx/.*.conf$" f) (n-host-shell-cmd-visible "ngin.x"))
       ((string-match "/net/slcipaq.us.oracle.com/scratch/pau_logs_selection/tests/\\(.*\\)/.*" f) (nmidnight-compile--config-service-test (nre-pat 1 f)))
       ((and f (string-match "work/adyn.com/httpdocs/\\([^/]*\\)/version$" f))
        (let(
             version
             (product (n--pat 1 f))
             )
          (forward-line 0)
          (if (not (looking-at "\\([0-9]+\\)"))
              (error "nmidnight-compile: expected version number"))
          (setq version (string-to-int (n--pat 1)))
          (setq version (1+ version))
          (kill-word 1)
          (insert (format "%d" version))
          (if (and
               (file-exists-p (format "c:/perl/bin/%s.exe" product))
               (y-or-n-p (format "remove %s.exe"  product))
               )
              (delete-file (format "c:/perl/bin/%s.exe" product))
            )
          )
        )
       ((eq major-mode 'nbookkeeping-mode)
        (n-host-shell-cmd-visible (format "perl -w `cygpath --mixed $NELSON_BIN/perl/accounts.pl` %s"	;  taxes
                                          (nfn-suffix (buffer-file-name))
                                          )
                                  )
        )
       ((and (buffer-file-name)
             (string-match (n-host-to-canonical "$dp/sensu/slc08dtk/etc_sensu_conf.d/.*") (buffer-file-name))
             )
        (n-host-shell-cmd-visible (format "sensu.put_to_server_and_restart %s"   (buffer-file-name)))
        )
       ((and n-win (string= (nfn-suffix) "txt"))
        (n-host-shell-cmd (format "cd %s; /cygdrive/c/WINDOWS/system32/dllcache/wordpad.exe %s &" default-directory (file-name-nondirectory (buffer-file-name))))
        )
       ((and (not (eq major-mode 'nmidnight-mode))
             nshell-error-diagnose-mode
             )
        (nshell-repeat)
        )
       (t
        (cond
         ((eq cmd ?1)
          (if (not (string-match "/p4/P2/" (buffer-file-name)))
              (nmidnight-find-output-file "midnight")
            (nmidnight-find-output-file (concat (nstr-replace-regexp (file-name-directory (buffer-file-name))
                                                                     "/main/cpp/"
                                                                     (nsimple-env-expand "/main/cpp/build/$OS/")
                                                                     )
                                                "midnight"
                                                )
                                        )
 )
          )
         ((eq cmd ?j)
          (nmidnight-find-output-file "$P4ROOT/P2/openkernel/main/midnight" nil "ant JavaCompileTests")
          )
         ((eq cmd ?J)
          (nmidnight-find-output-file "$P4ROOT/P2/openkernel/main/midnight" nil "ant JavaCompile")
          )
         ((eq cmd ?p)
          (nmidnight-grab-and-run-ant-test-suite)
          )
         ((eq cmd ?u)
          (nmidnight-update-canon)
          )
         (t
          (nmidnight-find-output-file (if (nmidnight-p (current-buffer)) (buffer-file-name)))

          (setq repeat-command nil)
          )
         )
        (if nmidnight-command
            (progn
              (if (nmidnight-looks-busy-p)
                  (progn
                    (n-file-refresh-from-disk)
                    (nmidnight-clear-output)
                    (message "revisiting so as to kill apparently busy process...")
                    (nmidnight-compile)
                    )
                (process-send-string nil nmidnight-command)
                (message "%s: %s..." nmidnight-host nmidnight-command)
                (set-marker (process-mark (get-buffer-process (current-buffer))) (point))
                )
              )
          )
        (if repeat-command (nmidnight-compile))
        )
       )
      )
    )
  )
(defun nmidnight-update-canon()
  (save-restriction
    (narrow-to-region (progn
                        (goto-char (point-min))
                        (forward-line 1)
                        (point)
                        )
                      (progn
                        (goto-char (point-max))
                        (point)
                        )
                      )
    (require 'n-prune-buf)
    (n-prune-buf-v "^cp ")
    (let(
         (cp-cmds (buffer-substring-no-properties (point-min) (point-max)))
         )
      (widen)
      (goto-char (point-min))
      (n-host-shell-cmd-visible (concat "cd \"" default-directory "\""))
      (n-other-window)
      (nshell-clear)
      (insert cp-cmds)
      )
    )
  )
(defun nmidnight-clear-output()
  (goto-char (point-min))
  (end-of-line)
  (if (not (eobp))
      (progn
        (forward-line 1)
        (delete-region (point) (point-max))
        )
    )
  )
(defun nmidnight-looks-busy-p()
  (save-excursion
    (goto-char (point-max))
    (forward-line -1)
    (or
     (looking-at "+ diff.canon")
     )
    )
  )

(defun nmidnight-test()
  (interactive)
  (cond
   ((save-excursion
      (goto-char (point-min))
      (or (looking-at "javac .*\\(\\b[^ \t]+\\).java")
	  (looking-at "sh .* ex_javac .*\\(\\b[^ \t]+\\)$")
          )
      )
    (let(
         (directory (n-host-to-canonical default-directory))
         (program (n--pat 1))
         )
      (goto-char (point-min))
      (end-of-line)
      (n-grab-file)
      (delete-other-windows)
      (nsimple-split-window-vertically)
      (n-other-window)
      (nshell)
      (nshell-clear)
      (n-host-shell-cmd (format "cd %s; java -nojit %s&" directory program))
      )
    )
   (t
    (nshell default-directory)
    (nshell-clear)
    (n-host-shell-cmd-visible "./test.sh")
    (n-delete-window)
    )
   )
  )

(defun nmidnight-test-macro()
  (delete-other-windows)
  (nsimple-split-window-vertically)
  (let(
       (fn	(n-host-to-canonical (buffer-file-name)))
       )
    (nshell)
    (n-host-shell-cmd (format "macro -f %s" fn))
    )
  )

(defun nmidnight-rotate()
  (interactive)
  (nlist-rotate nmidnight-output-stack (not
					(string= (n--get-lisp-func-name last-command) "nmidnight-rotate")))
  (nmidnight-find-output-file nil)
  )

(defun nmidnight-push-output-file()
  (let(
       (fn (buffer-file-name))
       )
    (nlist-raise-or-push nmidnight-output-stack fn)
    (n-database-set "last-nmidnight-file" fn)
    )
  )

(defun nmidnight-find-output-file(selectedMidnightFile &optional temporary build-command)
  "if selectedMidnightFile, then use the current file as a new build
file, if appropriate.  otherwise use the build file which has been
already established."
  (if (not (progn    ;; if a build window is currently visible, let's replace it w/ the new one
	     (other-window 1)
	     (eq major-mode 'nmidnight-mode)
	     )
	   )
      (other-window -1)
    )

  (if selectedMidnightFile
      (progn
        (n-file-find selectedMidnightFile)
	(if temporary
	    (progn
	      (setq nmidnight-tmp t)
	      )
	  )
	(if (not nmidnight-tmp)
	    (nmidnight-push-output-file))
        )
    )
  (while (and (not selectedMidnightFile)
    nmidnight-output-stack
              (nlist-current nmidnight-output-stack)
              (file-exists-p (nlist-current nmidnight-output-stack))
              )
    (find-file (nlist-current nmidnight-output-stack))
    (if nmidnight-tmp
        (progn
          (nlist-pop nmidnight-output-stack)
          )
      (setq selectedMidnightFile (buffer-file-name))
      )
    )
  (if (not selectedMidnightFile)
      (if (n-database-get "last-nmidnight-file")
          (n-file-find (n-database-get "last-nmidnight-file"))
        (error "nmidnight-find-output-file:  no previous midnight file")
        )
    )
  (nmidnight-init build-command)
  (delete-region (point) (point-max))
  )

(defun nmidnight-default-command()
  "figure out a default command for the current midnight file (and
insert this command at the file's beginning)"
  (let(
       (name	(file-name-nondirectory (buffer-file-name)))
       )
    (cond
     ((string-match "midnight.\\([^_]+\\)_\\([^_]+\\)" name)
      (cond
       ((string= "nt386" (nfn-plat))
        (let(
             (sybmake		"$NELSON_BIN/$SYBPLATFORM/sybmake")
             (buildFile	"~/work/build")
             )
          (setq command (format "sh %s %s %s %s/%s"
                                sybmake
                                (n--pat 2 name)
                                (n--pat 1 name)
                                buildFile
                                (nfn-proj)
                                )
                )
          )
        )
       (t
        (setq command (format "host %s sybmake %s %s"
                              (n-host-from-plat (nfn-plat))
                              (n--pat 2 name)
                              (n--pat 1 name)
                              )
              )
        )
       )
      )
     ((and
       (string-match "midnight.\\(.*\\)" name)
       (file-exists-p (concat (n--pat 1 name) ".mak"))
       )
      (setq command (format "nmake -f %s.mak" (n--pat 1 name)))
      )
     ((and
       (string-match "midnight.\\(.*\\)" name)
       (file-exists-p (concat (n--pat 1 name) ".java"))
       )
      (setq command (format "javac %s.java" (n--pat 1 name)))
      )
     (t
      (cond
       (n-win
        (setq command "sh t.sh")
        )
       (t
        (setq command "make -j 6 ")
        )
       )
      )
     )
    (goto-char (point-min))
    (insert command "\n")
    (goto-char (point-min))
    command
    )
  )
(defun nmidnight-init(build-command)
  (widen)

  (goto-char (point-min))
  (if (or (not (buffer-file-name))
	  (not (string-match "midnight.grep$" (buffer-file-name)))
	  )
      (setq
       n-next-error-called-already	nil	; records that compile output has not been examined yet
       n-gdb-new-binary			t	; tell gdb to run the new binary
       )
    )
  (if (looking-at "$")
      (nmidnight-default-command))

  (cond
   (build-command
    (setq
     nmidnight-host "local"
     nmidnight-command build-command
     )
    )
   ((looking-at "host \\([^ ]*\\) \\([^\n]*\\)$")
    (setq
     nmidnight-host		(n--pat 1)
     nmidnight-command	(concat (n--pat 2) "\n")
     )
    )
   (t
    (setq
     nmidnight-host	"local"
     nmidnight-command 	(concat
                         (nsimple-env-expand (n-get-line))
                         "\n"
                         )
     )
    )
   )
  (let(
       (shouldStartNewProcess
	;; the need to kill old teacher build processes (which take forever to diff, etc.)
	;; has been a very aggravating one.  Instead of putting up with it, I am instituting a new policy:
	;; if I am in a teacher build, then I will killed the current process unless I see evidence that it has
	;; completed its current mission.  That evidence will be the message "i am done" alone on a line.
	(if (string= (buffer-file-name) "c:/users/nsproul/work/adyn.com/httpdocs/teacher/midnight")
	    (nmidnight-teacher-prep))
	)
       )
    (cond
     ((and nmidnight-last-host
           (not (string= nmidnight-host nmidnight-last-host))
           (get-buffer-process (current-buffer))
           )
      (kill-process (get-buffer-process (current-buffer)))
      (setq shouldStartNewProcess t)
      )
     ((not (get-buffer-process (current-buffer)))
      (setq shouldStartNewProcess t)
      )
     (t
      (setq shouldStartNewProcess nil)
      )
     )
    (setq nmidnight-last-host nmidnight-host)

    (setq nmidnight-command-list (nstr-split nmidnight-command))

    (if shouldStartNewProcess
	(cond
	 ((nmidnight-remote)
	  (n-start-process "rsh" (buffer-name) "rsh" "xcentric" "rsh"
			   nmidnight-host
			   "$NELSON_BIN/nrsh"
			   (n-host-name-xlate default-directory nmidnight-host)
			   )
	  )
	 (t
          (require 'nshell)
          (if (string-match midnight-grep-output-buffer (buffer-name))
              (n-start-process "local-build" (buffer-name) (nshell-get-explicit-shell-file-name) "$dp/bin/g.sh")
            (n-start-process "local-build" (buffer-name) (nshell-get-explicit-shell-file-name))
            (if (equal system-type 'windows-nt)
                (process-send-string nil ". $HOME/.bashrc; echo nmidnight init is done\n" nil nil))
            ;;"$NELSON_BIN/local_build.sh" default-directory
            )
          )
         )
      )
    )
  (goto-char (point-min))
  (if (not (nre-safe-looking-at (concat nmidnight-command "$")))
      (progn
        (nsimple-delete-line 1)
        (insert nmidnight-command)
        )
    (end-of-line)
    )
  (insert "\n")

  (if (not nmidnight-tmp)
      (progn
        ;; record that the current file is the current midnight file.
        (nmidnight-push-output-file)
        (n-database-set "last-nmidnight-file" (buffer-file-name))
        )
    )
  )
(defun nmidnight-remote()
  (and (not (string= nmidnight-host "local"))
       (or
        (not n-host-primary)
        (not (string= nmidnight-host n-host-primary))
        )
       )
  )
(defun nmidnight-shell-and-execute-again()
  (interactive)
  (nshell)
  (delete-other-windows)
  (nshell-repeat)
  )
(defun nmidnight-touch-modules-with-undefined-symbols()
  (interactive)
  (narrow-to-region (progn
                      (goto-char (point-min))
                      (forward-line 1)
                      (point)
                      )
                    (point-max)
                    )
  (require 'n-prune-buf)
  (n-prune-buf-v ".*(.*\\.o$")
  (goto-char (point-min))
  (replace-regexp ".*[/: \t]\\([^/ \t:\\.]+\\)\\.o$" "ntouch $HGPRIVATE/*/*/\\1.cpp")
  (goto-char (point-min))
  (widen)
  (delete-other-windows)
  (nsimple-split-window-vertically)
  (nshell)
  (n-other-window)
  )
(defun nmidnight-p(buffer)
  (set-buffer buffer)
  (or
   (eq major-mode 'nmidnight-mode)
   (eq major-mode 'nsql-mode)
   )
  )

(defun nmidnight-ntags-find-where( &optional arg)
  (interactive "P")
  (if (not (save-excursion
             (forward-line 0)
             (nfn-looking-at)
             )
           )
      (call-interactively 'ntags-find-where)
    (let(
         (ddx (- (save-excursion
                   (end-of-line)
                   (point)
                   )
                 (point)
                 )
              )
         )
      (save-excursion
        (forward-line 0)
        (n-grab-file)
        (end-of-line)
        (forward-char (- ddx))
        (call-interactively 'ntags-find-where)
        )
      )
    )
  )

(defun nmidnight-ext-run(action)
  (n-file-find (concat
		n-local-tmp
		(nstr-upcase
		 (nstr-replace-regexp action "[: \t]" "_")
		 )
		".midnight"))
  (delete-region (point-min) (point-max))
  (require 'nshell)
  (insert (nshell-get-explicit-shell-file-name) " -x " action "\n")
  (setq nmidnight-tmp t)
  (nmidnight-compile)
  ;;(delete-other-windows)
  )
(defun nmidnight-ext-choose()
  (interactive)
  (let(
       (action	    (nmenu "what next?" "action"))
       )
    (cond
     ((and action (string-match "^(" action))

      (require 'npt)

      (eval (car (read-from-string action)))
      )
     (action
      (nmidnight-ext-run action)
      )
     )
    )
  )
(defun nmidnight-ext-install()
  (n-file-find "$NELSON_BIN/ex_install")
  (message "must run ex_install thru the shell")
  )
(defun nmidnight-ext-ADC-tour()
  (n-loc-tour
   "$dev/pso/$extdatasetdir/$extdataset/co_field_attribute.txt"
   "$dev/pso/$extdatasetdir/$extdataset/co_callback_data_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/co_packet_cache_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/co_packet_elem_cache_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/ct_control_defn_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/mt_bob_elements_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/mt_bob_tables_pso.txt"
   "$dev/pso/$extdatasetdir/$extdataset/mt_bob_type_pso.txt"
   (list "$dev/pso/$extdatasetdir/$extdataset/CreateAtLarge.add.ora" "erli_BFRegion")
   )
  )

(defun nmidnight-ext-set-db(d)
  (let(
       s
       )
    (cond
     ((string= d "zerozone_ms")
      (setq s (list "bestfoods" "zerozone" "mssql" "db" "sa" "" "sun" "client" "c:/MSSQL/BINN"))
      )
     (t
      (error "nmidnight-ext-set-db: ")
      )
     )
    ;;(n-env-set-variable "extpw" "hhhhhh!")


    (n-env-set-variable "extdataset" (car s))	(setq s (cdr s))
    (n-env-set-variable "extdbserver" (car s))	(setq s (cdr s))
    (n-env-set-variable "extdbtype" (car s))	(setq s (cdr s))
    (n-env-set-variable "extdb" (car s))	(setq s (cdr s))
    (n-env-set-variable "extdbuser" (car s))	(setq s (cdr s))
    (n-env-set-variable "extdbpw" (car s))	(setq s (cdr s))
    (n-env-set-variable "extjvm" (car s))	(setq s (cdr s))
    (n-env-set-variable "extmedium" (car s))	(setq s (cdr s))
    (n-env-set-variable "extsqlpath" (car s))	(setq s (cdr s))
    )
  )
(defun nmidnight-return()
  (interactive)
  (if (string-match "^midnight.grep." (buffer-name))
      (progn
        (forward-line 0)
        (n-grab-file)
        )
    (process-send-region nil
                         (progn
                           (nsimple-back-to-indentation)
                           (point)
                           )
                         (progn
                           (end-of-line)
                           (insert "\n")
                           (point)
                           )
                         )
    )
  )
(defun nmidnight-execute()
  (interactive)
  (let(
       (data (n-get-line))
       )
    (n-file-find "$HOME/work/adyn.com/httpdocs/teacher/teacher.ini")
    (goto-char (point-max))
    (insert "\n" data "\n")
    (save-buffer)
    )
  )
(defun nmidnight-maybe-harvest-teacher-ini-stuff()
  (goto-char (point-min))

  (goto-char (point-min))
  (if (and (n-s ": teacher.ini: ")
	   (y-or-n-p "harvest teacher.ini stuff? ")
	   )
      (save-window-excursion
	(narrow-to-region (progn
			    (goto-char (point-min))
			    (forward-line 1)
			    (point)
			    )
			  (point-max)
			  )
	(n-prune-buf-v ": teacher.ini: ")
	(goto-char (point-min))
	(replace-regexp ".*tdb::Set" "tdb::Set")
	(setq iniData (buffer-substring-no-properties (point-min) (point-max)))

	(n-file-find "$HOME/work/adyn.com/httpdocs/teacher/teacher.ini")
	(n-prune-buf "^tdb::Set")

	(goto-char (point-max))
	(insert iniData)
	(save-buffer)
	)
    )
  )
(defun nmidnight-teacher-prep()
  (save-restriction
    (let(
	 shouldStartNewProcess
	 iniData
	 )
      (if (not (n-s "^i am done"))
	  (progn
	    (if  (get-buffer-process (current-buffer))
		(kill-process (get-buffer-process (current-buffer))))
	    (setq shouldStartNewProcess t)
	    )
	(setq shouldStartNewProcess nil)
	)
      (nmidnight-maybe-harvest-teacher-ini-stuff)
      shouldStartNewProcess
      )
    )
  )
(defun nmidnight-grab-and-run-ant-test-suite()
  (let(
       (suite	 (buffer-substring-no-properties (progn
                                     (n-r "[^0-9a-zA-Z_\\.]" t)
                                     (forward-char 1)
                                     (point)
                                     )
                                   (progn
                                     (n-s "[^0-9a-zA-Z_\\.]" t)
                                     (n-r "\\." t)
                                     (point)
                                     )
                                   )
                 )
       )
    (n-host-shell-cmd-visible (format "t %s" suite))
    )
  )
(defun nmidnight-shovel()
  (interactive)
  (while (and (n-s "^\\(.*\\)|\\(.*\\)|\\(.*\\)$")
              (let(
                   (form_line  (nre-pat 1))
                   (val  (nstr-trim (nre-pat 2)))
                   (cmt  (nre-pat 3))
                   )
                (if (or (string= "0" val)
                        (string= "0.00" val)
                        (string= "" val)
                        ;;(y-or-n-p (format "propagate \"%s\" for \"%s\" (%s)" val form_line cmt))
                        )
                    t   ; retry
                  (nstr-clipboard-win-only (nstr-replace-regexp val "\\\\n" "\r\n"))
                  (message "Update %s (%s: \"%s\"); next " form_line cmt val)
                  nil   ; terminate the loop
                  )
                )
              )
    )
  )
(defun nmidnight-monitor-test()
  (let(
       (cmd (progn
              (message "c-tlm, d-ebug-current-line, r-estore-apps.dat.bak")
              (read-char)
              )
            )
       (bu-fn (concat (buffer-file-name) ".bak"))
       )
    (cond
     ((eq cmd ?c)
      (n-host-shell-cmd-visible "ctlm")
      )
     ((eq cmd ?d)
      (or (not (n-file-exists-p bu-fn))
          (error ": no overwriting the backup")
          )
      (call-process "cp" nil "t" nil "-p" (buffer-file-name) bu-fn)
      (delete-region (progn
                       (forward-line 0)
                       (point)
                       )
                     (progn
                       (goto-char (point-min))
                       (forward-line 1) ; preserve field name line
                       (point)
                       )
                     )
      (forward-line 1)                  ; skip past the line we are debugging
      (delete-region (point) (point-max))
      (n-file-save-cmd)
      (n-host-shell-cmd-visible "ctlm")
      )
     ((eq cmd ?r)
      (n-host-shell-cmd-visible (format "mv \"%s\" \"%s\"" bu-fn (buffer-file-name)))
      )
     )
    )
  )
(defun nmidnight-compile--config-service-test(test-name)
  (let(
       (dir (concat "/net/slcipaq.us.oracle.com/scratch/pau_logs_selection/tests/"
                    test-name
                    )
            )
       rest_of_url_fn
       )
    (setq rest_of_url_fn (concat dir "/rest_of_url")
          rest_of_url    (n-file-contents rest_of_url_fn)
          )
    (n-host-shell-cmd-visible (concat "bx rest_test_generator.sh.slcipau "
                                      "x "
                                      rest_of_url
                                      )
                              )
    )
  )
