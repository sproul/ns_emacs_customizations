(provide 'n-host)
(setq n-host-defaultDrive nil)
(setq n-host-home (getenv "HOME")
      n-host-home (nstr-replace-regexp n-host-home "\\\\" "/")
      )

(defvar n-host-translation-to-canon nil)
(defvar n-host-translation-from-canon nil)

(setq n-host-platform-information
      (list
       (list "unix"		nil	(list "sh" "-i" "-L"))
       (list "nt386"		nil	(list "cmd"))
       (list "alphavms"		nil	nil)
       (list "axposf"		nil	(list "csh"))
       (list "dce_axposf"	nil	(list "csh"))
       (list "dce_hp800"	t	(list "csh"))
       (list "hp800"		t	(list "csh"))
       (list "dce_ncr"		t	(list "csh"))
       (list "dce_rs6000"	t	(list "csh"))
       (list "dce_sun4"		nil	(list "csh"))
       (list "dce_sun_svr4"	t	(list "csh"))
       (list "ncr"		t	(list "csh"))
       (list "rs6000"		t	(list "csh"))
       (list "sun4"		nil	(list "csh"))
       (list "sun_svr4"		t	(list "csh"))
       (list "unixware"		nil	(list "csh"))
       (list "vms"		nil	nil)
       )
      )
(defmacro n-host-file-set(file-name-variable expression)
  (list 'setq file-name-variable (list 'n-host-to-canonical expression))
  )

;;(n-host-to-canonical "/cygdrive/z/shared/p4/Tools/selenium/")
;;(n-host-to-canonical "$P4ROOT/Tools/selenium/")

;;if emacs is running on a PC,
;;we will have to convert to the unix canonical file format (e.g.,
;;using forward slashes) for internal purposes.

(defun n-host-to-canonical-or-cygwin(&rest args)
  (nfn-cygwin (apply 'n-host-to-canonical args))
  )

(defun n-host-to-canonical(&optional fn quoteIfSpacesAreEmbedded shouldInsertResult)
  (if (not fn)
      (progn
        (setq fn (buffer-substring-no-properties (point-min) (point-max))
              shouldInsertResult t
              )
        (delete-region (point-min) (point-max))
        )
    )
  (save-match-data
    (setq fn (nstr-replace-regexp fn "\\\\" "/"))
    (setq fn (nstr-replace-regexp fn ".*//cygdrive" "/cygdrive"))



    (setq fn (nstr-replace-regexp fn ".*~/" "$HOME/"))
    (setq fn (nstr-replace-regexp fn "\\.u/" ".us.oracle.com/"))
    (setq fn (nstr-replace-regexp fn ".*~/" (concat n-host-home "/")))
    ;;(setq fn (nstr-replace-regexp fn ".*~$" "$HOME"))




    (setq fn (nstr-replace-regexp fn (format "%c$" 13) ""))	;; fancy way to say "^M$"

    (if (and (string-match "^//\\([A-Z][^/]*\\)/" fn)
             (n-file-exists-p (concat (getenv "P4ROOT") "/" (n--pat 1 fn)))
             )
        (nstr-replace-regexp fn "^//[^/]+/" (concat "$P4ROOT/" (n--pat 1 fn)))
      )
    (setq fn (cond
              ((not fn)
               ""
               )
              ((string-match "^https?://" fn)
               (if (string-match "\\$" fn)
                   (error "n-host-to-canonical: uh-oh -- I assumed that I wouldn't do variables in an http URL"))
               fn
               )
              (t
               ;;call n-host-name-xlate even if we are on unix, to take advantage of the
               ;;name cleanup that happens in that routine.
               (n-host-name-xlate fn
                                  "unix"
(if n-host-defaultDrive
                                      n-host-defaultDrive
                                    (nfn-drive default-directory)
                                    )
                                  )
               )
              )
          )
    (if (and quoteIfSpacesAreEmbedded
             (string-match " " fn)
             )
        (setq fn (concat "'" fn "'"))
      )

    (if (eq system-type 'cygwin)
        (setq fn (nstr-replace-regexp fn "^\\([a-zA-Z]\\):" "/cygdrive/\\1"))
      (setq fn (nfn-mixed fn))
      )

    (if shouldInsertResult
        (insert fn))
    fn
    )
  )

(defun n-host-to-canonical-dirs(dirs &optional omitNonexistent)
  (let(
 canonical-dirs
       dir
       )
    (while dirs
      (setq dir (n-host-to-canonical (car dirs)))
      (if (or
           (not omitNonexistent)
           (file-exists-p dir)
           )
          (setq canonical-dirs (cons
                                dir
                                canonical-dirs
                                )
                )
        )
      (setq dirs (cdr dirs))
      )
    (nreverse canonical-dirs)
    )
  )
(defun n-host-from-canonical(fn)
  (if (not fn)
      ""
    (n-host-name-xlate fn
                       (if n-win "nt386" "unix")
                       (if n-host-defaultDrive
                           n-host-defaultDrive
                         (nfn-drive default-directory)
                         )
                       )
    )
  )


(defun n-host-platform-shell-program()
  (caddr (assoc (n-host-plat) n-host-platform-information))
  )

;; development environment information
;;	at any given time, we have a single target platform,
;;	which determines the value of several parameters
;;	related to building programs:
;;
(setq n-host-development-environment-db
      (list
       (list "win32"		"o7"	"rdebug" 	"\n")
       )
      )

;; name
;; shell-process
(defvar n-host-bufs nil)

(setq n-host-primary	(cond
                         (n-win "sh")
                         (t "-")
                         )
      )

(setq n-host-information
      (list
       (list "o7"		"win32"		nil)
       )
      )
(defun n-host-devo-cycle()
  "move the shell to the next host in the ring"
  (interactive)
  (setq n-host-development-environment-db (nlist-cycle n-host-development-environment-db))
  (message "%s env" (n-host-devo-env))
  )

(defun n-host-from-plat( plat)
  (cadr (assoc plat n-host-development-environment-db)))
(defun n-host-devo-env()
  (caar n-host-development-environment-db))
(defun n-host-compile-machine()
  (cadar n-host-development-environment-db))
(defun n-host-debugger-invocation()
  (caddar n-host-development-environment-db))

(defun n-host-plat(&optional host)
  "given HOST, get plat"
  (if (not host)
      (setq host (n-host-current)))
  (cadr (assoc host n-host-information)))

(defun n-host-supports-clearcase(&optional host)
  (if (not host)
      (setq host (n-host-current)))
  (error "n-host-supports-clearcase: info has been removed from n-host-information")
  (caddr (assoc host n-host-information)))

(defun n-host-eocmd-char-from-host(host)
  (let(
       (cc	  (elt (assoc (n-host-plat host)
                              n-host-development-environment-db
                              )
                       3
                       )
                  )
       )
    (if cc
        cc
      "\n"	; a reasonable dft
      )
    )
  )
(setq n-host-pw-sign "Password:")

(if n-emacs-initing
    (setq n-host-list nil)
  (defvar n-host-list nil
    "list of entries corresponding to the hosts which I am logged into.
Each entry is a list containing several entries:
	host name
	the current directory of the session on that host
	the character that host interprets as a cmd delimiter"
    )
  )
(make-variable-buffer-local 'n-host-list)


(defun n-host-needs-explicit-env-init-p()
  (if (or ;;;;;;;;; (string-match "WIN-NE5FEVOO387.*" system-name)
       n-win
       (not (n-file-exists-p "$HOME/.profile")) ;; haven't yet run $dp/init/setup
       )
      (progn
        (message "n-host-needs-explicit-env-init-p says we need explicit env init on this host")
        t
        )
    (progn
      (message "n-host-needs-explicit-env-init-p says we do not need explicit env init on this host")
      nil
      )
    )
  )

(defun n-host-possible-explicit-env-init()
  (condition-case nil      ;; causes an error on emacs 23
      (progn
        (if (n-host-needs-explicit-env-init-p)
            ;; don't use $HOME/.profile in the following in case
            ;; we haven't yet run $dp/init/setup on this host:
            (n-host-shell-cmd "# n-host-needs-explicit-env-init-p says init explicitly for aliases:\n. $dp/home/.alias")
          ;;(n-host-shell-cmd "# n-host-needs-explicit-env-init-p says init explicitly:\n. $dp/home/.profile")
          (n-host-shell-cmd "# n-host-needs-explicit-env-init-p says no need to init explicitly")
          )
        (n-host-shell-cmd "cd $dp/bin")
        )
    (error nil)
  )
  )

(defun n-host-add-shell(&optional host user init name)
  "add a new shell buffer logged into HOST as USER"
  (let(
       (new-shell-buffer-name	            (n-host-gen-shell-name host user))
       )
    (n-host-shell-save)
    (if (not host)
        (setq host n-host-primary))
    (if (not user)
        (setq user (user-login-name)))
    (if (get-buffer new-shell-buffer-name)
        (switch-to-buffer (get-buffer new-shell-buffer-name))
      (shell)
      ;;bad
      (setq nshell--nested nil)
      (nbuf-post-for-kill 'n-host-kill-shell-buf)
      (setq n-host-bufs (append
                         (list
                          (list
                           new-shell-buffer-name
                           (get-buffer-process (current-buffer))
                           )
                          )
                         n-host-bufs
                         )
            )
      ;;(set-process-filter (get-buffer-process (current-buffer)) 'nshell-filter)
      (rename-buffer (n-host-buf-name))
      (n-host-possible-explicit-env-init)
      (n-host-login host)
      (if (not (string= user (user-login-name)))
          (progn
            (if (n-host-running-on-NT host)
                (error "n-host-add-shell: su not supported on NT"))
            
            (setq n-host-add-shell-user user)
            ;; wait for the prompt -- which I assume contains the name of the
          ;; host -- and then execute the callback
          (nasync-wait-for (nshell-prompt host) 'n-host-add-shell-2)
          )
      )
    )
  )
)
(defun n-host-add-shell-2()
  (n-host-su n-host-add-shell-user)
  )
(defun n-host-running-on-NT(hostName)
  (or (string= host "sh") (string= hostName "nt386"))
  )
(defun n-host-execute-su(&optional user)
  (if (or (not user)
          (string= user "root")
          )
      (setq user "root")
    )
  (n-host-shell-cmd (format "su %s" user))
  (sleep-for 1)
  
  (if (string= user "root")
      (n-host-shell-cmd (concat (n-host-getpw) "\n") t))
  (message "")
  
  (n-host-init user)
  ;;(n-host-increment-current-shell-depth)
  )
(defun n-host-su(user)
  (n-host-shell-cmd-visible "chmod 664 $NELSON_HOME/.bashrc")
  
  (n-host-execute-su)
  (if (and user (not (string= user "root")))
      (progn
        (n-sleep-for 1)
        (n-host-execute-su user)
        )
    )
  (save-window-excursion
    (nshell)
    (goto-char (point-max))
    )
  )

(setq n-host-cd--patch-emacs23-cd-absolute--done nil)
(defun n-host-cd--patch-emacs23-cd-absolute()
  ;; to fix odd problem where my navigating dirs on socrates leads to a permission denied exception (in the code commented out below)
  (defun cd-absolute (dir)
    "Change current directory to given absolute file name DIR."
    ;; Put the name into directory syntax now,
    ;; because otherwise expand-file-name may give some bad results.
    (setq dir (file-name-as-directory dir))
    ;; We used to additionally call abbreviate-file-name here, for an
    ;; unknown reason.  Problem is that most buffers are setup
    ;; without going through cd-absolute and don't call
    ;; abbreviate-file-name on their default-directory, so the few that
    ;; do end up using a superficially different directory.
    (setq dir (expand-file-name dir))
    (if (not (file-directory-p dir))
        (if (file-exists-p dir)
            (error "%s is not a directory" dir)
          (error "%s: no such directory" dir))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;(unless (file-executable-p dir)
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; (error "Cannot cd to %s:  Permission denied" dir))
      (setq default-directory dir)
      (setq list-buffers-directory dir)))
  (setq n-host-cd--patch-emacs23-cd-absolute--done t)
  )


(defun n-host-cd( dir &optional tellHost knownDir)
  "set shell-buf's current directory to DIR"
  (if (and (not n-pre-emacs23)
           (not n-host-cd--patch-emacs23-cd-absolute--done)
           )
      (n-host-cd--patch-emacs23-cd-absolute)
    )
  (n-host-goto-shell nil)
  (n-host-set-current-wd dir)
  (if tellHost
      (n-host-shell-cmd
       (cond
        ((n-host-vms-p)
         (format "set def %s" (n-host-vmsify dir))
         )
        (t
         (setq dir (n-host-name-xlate dir (n-host-current)))
         (format "cd %s" dir)
         )
        )
       )
    )
  (if knownDir
      (if (string= dir "/cygdrive/c/")
          (message "n-host-cd: not changing buf dir")
        (cd (n-host-name-xlate dir (system-name)))
        )
    )
  )

                                        ; string containing the name of the host on which EMACS was originally
                                        ; started
(defun n-host-current()
  (if n-host-bufs
      (save-window-excursion
        (set-buffer (n-host-buf-name))
        (caar n-host-list))
    (system-name)
    )
  )
(defun n-host-current-wd()
  (cadar n-host-list))
(defun n-host-current-eocmd-char()
  (if n-host-list
      (caddar n-host-list)
    "\n")
  )
(defun n-host-current-shell-depth()
  (cadddr (car n-host-list))
  )

(defun n-host-set-current-wd( dir)
  "set the working directory of the current host to DIR"
  (if n-host-list
      (setcar (cdar n-host-list)
              (if n-win
                  (n-host-name-xlate dir "nt386")
                )
              )
    )
  )
(defun n-host-set-current-shell-depth( depth)
  "set the working directory of the current host to DIR"
  (setcar n-host-list
          (list
           (n-host-current)
           (n-host-current-wd)
           (n-host-current-eocmd-char)
           depth
           )
          )
  )
(defun n-host-increment-current-shell-depth()
  (n-host-set-current-shell-depth (1+ (n-host-current-shell-depth)))
  )
(defun n-host-decrement-current-shell-depth()
  (n-host-set-current-shell-depth (1- (n-host-current-shell-depth)))
  )
(defun n-host-shell-cmd-visible(input &optional clear no-save-of-prior-file)
  (delete-other-windows)
  (nsimple-split-window-vertically)
  (if no-save-of-prior-file
      (setq nshell-no-save-of-prior-file t))
  (nshell)
  (if clear
      (nshell-clear))
  (if input
      (n-host-shell-cmd input))
  (other-window 1)
  )
(defun n-host-shell-cmd-visibly-transform(cmd)
  (n-host-shell-cmd-visible
   (concat cmd " < "
           (buffer-file-name)
           " > "
           (buffer-file-name)
           ".tmp; mv "
           (buffer-file-name)
           ".tmp "
           (buffer-file-name)
           )
   )
  (sleep-for 1)
  (n-file-refresh-from-disk)
  )

(defun n-host-shell-cmd( input &optional silent )
  "log input and send it to the shell process"
  (n-trace "%s" input)
  (save-window-excursion
    (nshell)
                                        ;(set-buffer (n-host-buf-name))
    (goto-char (point-max))
    (if silent
        (process-send-string  (n-host-buf-process) input)
      (insert input)
      (funcall (nkeys-binding "\C-m"))
      )
    )
  )
(defun n-host-goto-base()
  "set shell to the host where emacs was originally started"
  (if (and
       n-host-list

       ;; if running on NT, then ALL the shells are in the background.  in
       ;;this case, NT.sh eliminates the need for this job control
       (not n-win)
       )
      (n-host-shell-cmd "~"))
  )


(defun n-host-goto( host)
  "n7: set HOST to be the current host in the shell.  Assumes shell
is in base session"
  (process-send-string  (n-host-buf-process)
                        (format (if n-win "switch %s\n" "%%?%s\n")
                                host
                                )
                        )
  (let(
       (dir	(n-host-current-wd))
       )
    (if dir
        (n-host-cd dir))
    )
  (message "%s is current host." host )
  )
(defun n-host-cycle( &optional arg)
  "move the shell to the next host in the ring"
  (interactive "P")
  (if arg
      (progn
        (bury-buffer (current-buffer))
        (n-host-cycle-bufs)
        )
    (n-host-set-current-wd default-directory)
    (n-host-goto-base)
    (setq n-host-list (nlist-cycle n-host-list))
    (n-host-goto (n-host-current))
    )
  (if (and (n-host-current-wd)
           (file-exists-p (n-host-current-wd))
           )
      (cd (n-host-current-wd))
    )
  )
(defun n-host-login-cmd( &optional arg)
  "rlogin.
if ARG, create a new buffer"
  (interactive "P")
  (let(
       (host	(nmenu "host" "hosts"))
       )
    (if arg
        (n-host-add-shell host)
      (n-host-login host)
      )
    )
  )
(setq n-host-login-on_shell_start-called nil)

(defun n-host-login(host)
  (if n-win
      (if n-host-login-on_shell_start-called
          (message "No 2nd call to login-on_shell_start...")
        ;;(n-host-shell-cmd "on_shell_start.sh &")
        (setq n-host-login-on_shell_start-called t)
        )
    )
  (if (and
       (not (string= "-" host))
       (not (string= "sh" host))
       )
      (progn
        (n-host-goto-base)
        (message "login %s..." host)
        (n-host-shell-cmd (format "rlogin %s" host))
        )
    )
  (setq n-host-list (append (list
                             (list
                              host
                              default-directory
                              (n-host-eocmd-char-from-host host)
                              1		;; initial shell-depth
                              )
                             )
                            n-host-list)
        )
  (if (and (not n-win)
           (not (string= n-local-situation "whitelight"))
           )
      (nasync-timer 1 'n-host-login2))
  )

(defun n-host-login2()
  (save-excursion
    (forward-line 0)
    (if (looking-at n-host-pw-sign)
        (n-host-pw))
    ;;    (if (string= "leopard" (n-host-current))
    ;;        (progn
    ;;          (n-sleep-for 2)
    ;;          (n-host-su "root")
    ;;          (n-sleep-for 2)
    ;;          (n-host-shell-cmd "dce_login cell_admin -dce-")
    ;;          (n-sleep-for 2)
    ;;          (n-host-init)
    ;;          )
    ;;      )
    )
  )
(defun n-host-pw()
  (interactive)
  (n-host-shell-cmd (format "%s" (n-database-get "host-pw" t)))
  )
(defun n-host-del( &optional arg)
  "exit the current host
if ARG, remove all record of the last login.

This latter function is necessary because there's no way to ck
whether the rlogin succeeds, and if n-host-login is invoked by
accident on a string which isn't a host, n-host's recordkeeping
and the actual set of active sessions will be out of sync.  In
that case, the user should invoke this routine with an arg, and
thus restore the previous situation."
  (interactive "P")
  (if (and (= 1 (length n-host-list))
           (= 1 (length n-host-bufs))
           )
      (error "Can't exit the base host."))
  (if (not arg)
      (let(
           (depth	(n-host-current-shell-depth))
           )
        (while (> depth 0)
          (n-host-shell-cmd (if (n-host-vms-p) "logoff" "exit"))
          (n-sleep-for 1)
          (setq depth (1- depth))
          )
        )
    )
  (setq n-host-list (cdr n-host-list))
  (if n-host-list
      (n-host-goto (n-host-current))
    (setq n-host-bufs (cdr n-host-bufs)
          )
    (kill-buffer (current-buffer))
    (n-host-goto-shell nil)
    )
  )
(defun n-host-vms-p(&optional host)
  (if (not host)
      (setq host (n-host-current)))
  (or (string= "vms" (n-host-plat host))
      (string= "alphavms" (n-host-plat host))
      )
  )
(defun n-host-vmsify(fn)
  (let(
       vdir
       (base	(file-name-nondirectory fn))
       (dirspec	(or (string-match "/$" fn)
                    (and (file-directory-p fn)
                         (setq fn (concat fn "/"))
                         )
                    )
                )
       )
    (setq vdir (file-name-directory fn))
    (if (not vdir)
        base
      (setq vdir (nstr-replace-regexp vdir
                                      "/remote/conn\\([0-9]+\\)/"
                                      "remote_pokey_conn\\1:["
                                      )
            vdir (nstr-replace-regexp vdir "/\\([A-Z]\\)" "/$\\1")
            vdir (nstr-replace-regexp vdir "/$" "")
            vdir (nstr-replace-regexp vdir "/" ".")
            vdir (concat vdir "]")
            )
      (if dirspec
          vdir
        (concat vdir base)
        )
      )
    )
  )

(defun n-host-init(&optional user)
  (interactive "P")
  (if (string= user "root")
      (progn
        ;;(y-or-n-p "ready to bash -i")
        (n-host-shell-cmd (format "bash -i"))
        (setq nshell--nested t)
        (n-sleep-for 1)
        )
    )
  ;;(y-or-n-p "ready to p")
  ;;
  ;;
  ;;
  ;; this doesn't run on initial m-s (to my surpise)
  ;;(n-host-shell-cmd "p")



  )

(defun n-host-edit-init-file( &optional arg)
  "edit the file responsible for initializing the shell environment (e.g., under csh, .cshrc)"
  (interactive "P")
  (let(
       cmd
       )
    (if (and (not arg)
             (string= system-name "o5")
             )
        (setq cmd ?b)
      (setq arg t)
      )

    (if arg
        (setq cmd (progn
                    (message "b-.bashrc, m-artokenv, p-ost, P-.profile")
                    (read-char)
                    )
              )
      )

    (n-file-find (cond
                  ((= cmd ?b) "$NELSON_HOME/.bashrc")
                  ((= cmd ?m) "$P4ROOT/P2/tools/main/devsetup/martok/martokenv.sh")
                  ((= cmd ?p) "$NELSON_HOME/settings/post.profile")
                  ((= cmd ?P) "$NELSON_HOME/.profile")
                  )
                 )
    )
  )
(defun n-host-buf-name()
  (caar n-host-bufs)
  )
(defun n-host-buf-process()
  (cadar n-host-bufs)
  )
(defun n-host-goto-shell(&optional bufname)
  (if bufname
      (let(
           (sentry	(n-host-buf-name))
           (buf  	(get-buffer bufname))
           (possibleHit	t)
           )
        (if (not buf)
            (error "n-host-goto-shell: "))
        (while (and
                (not (equal buf (current-buffer)))
                (progn
                  (n-host-cycle-bufs)
                  (if (string= sentry (n-host-buf-name))
                      (setq possibleHit nil)
                    t
                    )
                  )
                )
          )
        possibleHit
        )
    (progn
      (if n-host-bufs
          (progn
            (if (get-buffer (n-host-buf-name))
                (progn
                  (switch-to-buffer (n-host-buf-name))
                  )
              (n-host-kill-shell-buf)
              )
            )
        (n-host-add-shell n-host-primary nil t)
        (process-send-string nil "todo.ls\n")
        )
      )
    )
  )

(defun n-host-shell-save()
  (if  n-host-bufs
      (setcar n-host-bufs (list
                           (n-host-buf-name)
                           (n-host-buf-process)
                           )
              )
    )
  )
(defun n-host-cycle-bufs()
  (n-host-shell-save)
  (setq n-host-bufs (nlist-cycle n-host-bufs))
  (n-host-goto-shell nil)
  )
(defun n-host-gen-shell-name(host user)
  (concat "Shell-"
          (cond
           (host		(concat host "-"))
           (n-host-primary	(concat n-host-primary "-"))
           (t "")
           )
          (if user
              user
            (user-login-name)
            )
          )
  )
(defun n-host-kill-shell-buf()
  (nshell-save)
  (setq n-host-su-from nil)
  ;;(n-host-goto-shell nil)
  (setq n-host-bufs (cdr n-host-bufs))
  )
(setq n-host-su-from nil)
(defun n-host-su-cmd( &optional user host)
  "become the super user"
  (interactive)
  ;;(if (not host)
  ;;(setq host (if user
  ;;n-host-primary
  ;;(nmenu "host" "hosts")
  ;;)
  ;;)
  ;;)
  (if (not user)
      (setq user (nmenu "user" "users" nil "root")))

  (if (not host)
      (progn
        (n-host-su user)
        )
    (let(
         name
         )
      (setq name	(n-host-gen-shell-name host user))
      (save-window-excursion
        (if (not
             (string= (n--get-lisp-func-name this-command) "n-host-su"))
            (setq n-host-su-from (n-host-buf-name)))
        (if (get-buffer name)
            (n-host-goto-shell name)
          (n-host-add-shell host user)
          )
        )
      )
    )
  (if
      (string= (n--get-lisp-func-name this-command) "n-host-su-cmd")
      (nshell))
  )
(defun n-host-su-exit()
  (if n-host-su-from
      (save-window-excursion
        (n-host-goto-shell n-host-su-from)
        (setq n-host-su-from nil)
        )
    )
  )


(defun n-host-name-xlate(fn host &optional defaultDrive)
  "translate FN to a form acceptable to HOST.  HOST can be a host name or 'unix' or 'nt386'"
  (let ((data (match-data)))
    (unwind-protect
        (progn
          ;;(n-trace "n-host-name-xlate %s %s" fn host)

          (if (and (functionp 'nsimple-env-expand)
                   (not (file-exists-p fn))
                   )
              (setq fn (nsimple-env-expand fn))
            )

          ;;simplify the problem by converting to forward slashes.  Undo later, if appropriate.
          ;; No-op, except if it is a PC file
          (setq fn (nstr-replace-regexp fn "\\\\" "/"))

          ;;"//" embedded in a file name: throw away preceding characters, unless we are at boln:
          (if (string-match ".+\\(//.*\\)" fn)
              (setq fn (n--pat 1 fn)))

          ;;if a drive can be extracted from the file path, make it the default
          (if (nfn-drive fn)
              (setq defaultDrive (nfn-drive fn)))

          (setq fn (nstr-replace-regexp fn ".*\\$HOME" n-host-home))
          (setq fn (nstr-replace-regexp fn ".*%HOME%"  n-host-home))
          (setq fn (nstr-replace-regexp fn ".*~/" (concat n-host-home "/")))

	  ;;remove anything preceding a disk drive
	  (if (string-match ".*/\\([a-zA-Z]:.*\\)" fn)
	      (progn
		(setq fn (n--pat 1 fn))
		(setq fn (nstr-replace-regexp fn "^\\(.:\\)\\([^/]\\)" "\\1/\\2"))
		)
	    )

	  ;;make into a full path name
	  (if (and (not (string= fn ""))
		   (not (eq ?/ (elt fn 0)))
		   (or (>= 1 (length fn))
		       (not (eq ?: (elt fn 1)))
		       )
		   )
	      (setq fn (concat
			(nstr-replace-regexp default-directory "\\\\" "/")
			fn)
		    )
	    )
	  (setq fn (cond
		    ((and n-win (string= "sh" host))
                     (setq fn (n-host-name-xlate-nt386 fn "nt386" defaultDrive))
                     (nstr-replace-regexp fn "\\\\" "/")
                     )
                    (n-win
                     (setq fn (n-host-name-xlate-nt386 fn host defaultDrive))
                     )
                    (t
                     (n-host-name-xlate-unix fn host)
                     )
                    )
                )
          fn
          )
      (store-match-data data)
      )
    )
  )
;;(n-host-name-xlate "$dp/bin" "nt386")
;;(n-host-name-xlate-nt386 "$dp/bin" "nt386" nil)

(defun n-host-name-xlate-nt386(fn host defaultDrive)
  ;;(if (string-match "^/cygdrive" fn)
  ;;(setq fn (nstr-replace-regexp fn "/cygdrive/\\(.\\)/" "\\1:/")
  ;;fn (nstr-replace-regexp fn "/" "\\\\")
  ;;)
  ;;)

  ;;"///" embedded in a file name: throw away preceding characters, keep "//"
  ;;(if (string-match ".*/\\(//.*\\)" fn)
  ;;(setq fn (n--pat 1 fn)))

  ;;"~" embedded in a file name: throw away preceding characters
  ;;but ignore ~/\d, a common pattern for file names which have been mangled to 8.3
  (if (string-match ".*\\(~\\([^0-9].*\\)\\)" fn)
      (setq fn (n--pat 1 fn)))

  (if (string-match "^/\\(cc\\)?view/conn\\([^/_]+\\)_\\([^/_]+\\)_vu/calm/conn/ocs\\(.*\\)$" fn)
      (setq fn (format "//siberia/view/conn%s_%s_vu/calm/conn/ocs%s"
                       (n--pat 2 fn)
                       (n--pat 3 fn)
                       (n--pat 4 fn)
                       )
            )
    )
  (let(
       (fn-host		(car (nfn-parse fn)))
       (fn-subdir	(cdr (nfn-parse fn)))
  )
    (if fn-host
        (setq fn (format "//%s%s" fn-host fn-subdir))
      (setq fn fn-subdir)
      )
    )
  (cond
   ((string= "nt386" host)
    (setq fn (nstr-replace-regexp fn "^/remote/\\([^/]+\\)/" "//\\1/")
          fn (nstr-replace-regexp fn ".*~/" "$HOME/")
          fn (nstr-transform n-host-translation-from-canon fn)
          )
    fn
    )
   ((string= "unix" host)
    (setq fn (nstr-transform n-host-translation-to-canon fn)
          )
    )
   (t	fn)
   )
  (if (and defaultDrive
           (not (string-match "^//" fn))
           (not (nfn-drive fn))	; no drive specification
           )
      (setq fn (format "%c:%s" defaultDrive fn))
    )
  (if (string= "nt386" host)
      (setq fn (nstr-replace-regexp fn "/" "\\\\")))
  (if (n-host-local-PC-drive (nfn-drive fn))
      (nstr-downcase fn)
    fn
    )
  ;;(n-trace "n-host-name-xlate returning %s" fn)
  fn
  )

(defun n-host-local-PC-drive(fn)
  t
  )

(defun n-host-name-xlate-unix(fn host)
  ;;see if there is a ~ or root / in there
  (if (string-match ".*/\\([~/].*\\)" fn)
      (setq fn (n--pat 1 fn)))
  (cond
   ((and
     (string-match "^/view/" fn)
     (not (n-host-supports-clearcase host))
     )
    (nstr-replace-regexp fn "^/view/" "/ccview/")
    )
   ((and
     (string-match "^/ccview/" fn)
     (n-host-supports-clearcase host)
     )
    (nstr-replace-regexp fn "^/ccview/" "/view/")
    )
   ((and
     (not (string= "pokey" host))
     (string-match "^/conn[1-9]/\\|^/conn1[4]/" fn)
     )
    (concat "/remote" fn)
    )
   ((and
     (string= "cyprus" host)
     (string-match "^/remote/cyprus[0-9]/" fn)
     )
    (nstr-replace-regexp fn "^/remote" "")
    )
   ((string-match "^/auto/" fn)
    (substring fn 5)
    )
   ((and
     (not (file-readable-p fn))
     (string= (buffer-name) "RMAIL")
     (n-host-temporary-clear-case-summary-name-fix-up fn)
     )
    n-host-temporary-clear-case-summary-name-fix-up-fn
    )
   ((and
     (not (file-readable-p fn))
     (not (string-match "^[a-zA-Z]:\\|^/remote/" fn))
     (file-readable-p      (concat "/remote" fn))
     )
    (concat "/remote" fn)
    )
   ((and
     (not (string-match "^/opt/" fn))
     (not (file-readable-p fn))
     (file-readable-p (concat "/remote/leopard1/" fn))
     )
    (concat "/remote/leopard1/" fn)
    )
  
   (t	fn)
   )
  )
(defun n-host-shell-local-cmd(host cmd)
  (let(
       (cHost	(n-host-current))
       )
    (if (string= cHost host)
        (setq rshcmd "")
      (if (or
           (string= cHost "pokey")
           (string= host "pokey")
           )
          (setq rshcmd (concat "rsh -n " host))
        (setq rshcmd (format "rsh -n pokey rsh -n %s " host))
        )
      )
    (n-host-shell-cmd (format "%s %s" rshcmd cmd))
    )
  )
(defun n-host-init-shells2()
  (n-host-goto-shell
   (n-host-gen-shell-name n-host-primary "conadmin")
   )
  (n-host-login "morris")               ;joebob
  (nasync-timer 8 'n-host-su "conadmin")
  )
(defun n-host-temporary-clear-case-summary-name-fix-up(fn)
  (if (save-excursion
        (n-s " new binaries and libraries are in \\(conn[a-z]*_nightly_vu\\)")
        )
      (let(
           (project	(n--pat 1))
           )
        (setq n-host-temporary-clear-case-summary-name-fix-up-fn
              (concat "/view/" project "/calm/conn/ocs/" fn)
              )
        )
    )
  )

(defun n-host-canon-translation(from to &optional delete)
  (cond
   ((and delete
         (stringp delete)
         (string= delete "delete_all")
         )
    (setq n-host-translation-to-canon nil
          n-host-translation-from-canon nil
          )
    )
   (delete
    (setq
     n-host-translation-to-canon   (nstr-assoc from n-host-translation-to-canon   'delete)
     n-host-translation-from-canon (nstr-assoc to   n-host-translation-from-canon 'delete)
     )
    )
   (t
    (setq n-host-translation-to-canon (cons
                                       (cons from to)
                                       n-host-translation-to-canon
                                       )
          n-host-translation-from-canon (cons
                                         (cons to from)
                                         n-host-translation-from-canon
                                         )
          )
    )
   )
  )
(defun n-host-getpw(&optional host user)
  (if (not host)
      (setq host system-name))
  (setq host (nstr-replace-regexp host "\\.plumtree\\.com" ""))
  (if (not user)
      (setq user host))
  (n-file-find "$dp/data/.n")
  (goto-char (point-min))
  (prog1
      (if (n-s (concat "^" host "\t" user "\t\\(.*\\)"))
          (n--pat 1))
    (nbuf-kill-current)
    )
  )
;;(message (n-host-to-canonical "sdf//dsatests/stratus_ftx/testcase"))
;;(n-host-to-canonical "//dsatests/stratus_ftx/testcase")
;;(n-host-to-canonical "//socrates/unixhome/nelsons/shared/p4/P2/")
;;(n-host-to-canonical "/cygdrive/c/profile")
;;(n-host-to-canonical "/cygdrive/c/Program Files")
