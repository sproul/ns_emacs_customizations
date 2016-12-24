(provide 'n19)
(defun n19-bisect-sees-failure()
  (interactive)
  
  (save-window-excursion
    (shell)
    (prog1
        (y-or-n-p "failure")
      (kill-buffer)
      )
    )
  )

(global-set-key "\M-\C-s" 'n19-bisect-sees-failure)
;;(error ": n19")

(defun n19-bisect(fn)
  ;; method to eval LISP code in portions, checking for a condition in order to narrow down the source of some problem
  ;; to prepare for this:
  ;;    0.) edit $dp/bin/e so that it calls emacs 20x; this way we can exit the current image and automatically restart.
  ;;    1.) implement n19-bisect-sees-failure
  ;;    2.) insert at the start of the suspicious area:
  ;;            (n19-bisect "/cygdrive/c/users/nelsons/dp/emacs/lisp/x.el")
  ;; [Note that code here can't assume my stuff's loaded, since it may be being used to debug the loading of my stuff.]
  ;; 
  (if fn
      (find-file fn))
  (goto-char (point-min))
  (if (not (n-s ";;n19-bisect"))
      (progn
        (insert ";;n19-bisect\n")
        (goto-char (point-max))
        (insert "\n;;n19-bisect\n")
        )
    )
  (goto-char (point-min))
  (while t
    (save-restriction
      (narrow-to-region (progn
                          (n-s ";;n19-bisect\n" t)
                          (forward-line -1)
                          (point) 
                          )
                        (progn
                          (n-s ";;n19-bisect\n" t)
                          (n-s ";;n19-bisect\n" t)
                          (point)
                          )
                        )
      (nelisp-bp "narrowed to the region under suspicion" "n19.el" 58);;;;;;;;;;;;;;;;;
      (forward-line (- (/ (count-lines (point-min) (point-max)) 2)))
      (if (not (looking-at "\n*("))
          (progn
            (message "Aimed for midpoint.  Reposition point so the eval won't fail...")
            (recursive-edit)
            )
        )
      (nelisp-bp "should be at midpoint now" "n19.el" 69);;;;;;;;;;;;;;;;;
      
      (save-window-excursion
        (eval-region (point-min) (point))
        )
      (insert "\n;;n19-bisect\n")
      
      (if (not (n19-bisect-sees-failure))     ;; failure is in the first half?
          (goto-char (point-min)))
      
      (n-s ";;n19-bisect" t) 
      (nsimple-delete-line)
      (save-buffer)
      (goto-char (point-min))
      )
    )
  )
;; (n19-bisect "/cygdrive/c/users/nelsons/dp/emacs/lisp/nkeys.el")

(if (boundp 'n-is-xemacs) (error ": already been here"))
(setq n-is-xemacs (eq window-system 'mswindows))
(setq n-pre-emacs23 (string< emacs-version "23"))
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

(if (not (getenv "NELSON_HOME"))
    (setenv "NELSON_HOME" (getenv "HOME")))

(if n-is-xemacs
    (setq zmacs-regions nil	;; without this, the region is generally not active unless you explicitly select it
          font-lock-use-colors nil	;; disable syntax coloring
          font-lock-auto-fontify nil
          )
  (global-font-lock-mode nil)
  (setq-default global-font-lock-mode nil)
  )

(if (not (boundp 'system-name))
    (setq system-name (getenv "COMPUTERNAME")))

(setq n-emacs-initing 	t)
(setq debug-on-error 	t
      
      ;;n-wacky-file-component-divider indicates the use of an emacs which uses backslashes
      ;;internally to separate file components.
      ;;Congruent emacs sets system-type to 'win32, so will not set
      ;;this boolean.
      n-win		(or
                         (eq system-type 'Windows-NT)
                         (eq system-type 'windows-nt)
                         (eq system-type 'cygwin)
                         )
      )

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq debug-on-error t)

(setq file-name-buffer-file-type-alist
      '(
        ("[:/].*config.sys$" . nil)		; config.sys text
        ("[:/].*midnight$" . nil)
        ("[:/]tags$" . nil) 		; Emacs TAGS file
        (".*" . t)	 			; everything else: binary
        )
      )

(if (not (boundp 'n-batch))
    (setq n-batch nil))
(setq visible-bell t
      debug-on-error t
      n-not-nelson nil;;; (not (string-match "nelsons?\\|adyn\\|n?sproul" (getenv "USER")))
      )
(let(
     (nelson-home		(getenv "NELSON_HOME"))
     ;;(emacs-version-dir-component (nstr-replace-regexp emacs-version "^\\([0-9]+\\.[0-9]+\\).*" "\\1"))
     )
  (if (not nelson-home)
      (progn
        (setenv "NELSON_HOME" (getenv "HOME"))
        (setq nelson-home	(getenv "NELSON_HOME"))
        )
    )
  (or nelson-home (error "n19: nelson-home environment variable not set"))

  ;; use the following to reveal conflicts:
  ;;(insert (list-load-path-shadows t))
  (setq dp (getenv "dp")
        load-path (append
                   (list
                    (concat "/usr/share/emacs/" (int-to-string emacs-major-version) "." (int-to-string emacs-minor-version) "/lisp/progmodes")  ;; python mode is shadowed by a dbgr module
                    ;;"/usr/share/emacs/23.4/lisp/progmodes"  ;; python mode is shadowed by a dbgr module
                    )
                   load-path
                   (list
                    (concat dp "/emacs/lisp")
                    (concat dp "/emacs/lisp/data")
                    (concat dp "/emacs/added/site-lisp")
                    (concat dp "/emacs/added/site-lisp/dbgr")
                    (concat dp "/emacs/added/site-lisp/dbgr/common")
                    (concat dp "/emacs/added/site-lisp/dbgr/common/buffer")
                    (concat dp "/emacs/added/site-lisp/dbgr/common/init")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/bashdb")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/gdb")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/pydbgr")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/rdebug")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/remake")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/trepan")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/trepanx")
                    (concat dp "/emacs/added/site-lisp/dbgr/debugger/zshdb")
                    (concat dp "/emacs/added/site-lisp/dbgr/lang")
                    )
                   )
        )
  )

(defun nelisp-bp(&optional &rest stuff)
  ;; no-op In case a breakpoint is inserted in some code which is loaded before breakpoint support is enabled
  )

(defun n-insert( str bufSpec)
  "insert STR into BUF"
  (save-excursion
    (let(
         (buf	(if (stringp bufSpec)
                    (get-buffer-create bufSpec)
                  bufSpec
                  )
                )
         )
      (set-buffer buf)
      (insert str)
      )
    )
  )

(setq n-trace-slow t)
(setq n-trace-slow nil)
(defun n-trace(msg &rest args)
  ".emacs: write msg + \n to the trace buffer"
  (let(
       (st (if msg (apply 'format msg args)
             ""
             )
           )
       )
    ;;(if (and args
             ;;(arrayp (car args))
             ;;)
        ;;(setq st (concat st " (arg is array)"))
      ;;)
    (message "%s" st)

    (save-window-excursion
      (set-buffer (get-buffer-create "t"))
      (goto-char (point-max))
      (if (not msg)
          (delete-region (point-min) (point-max))
        (insert st "\n")
        )
      )
    (if n-trace-slow
        (sleep-for 1))
    )
  )

(defun n-trace-list(headerMessage list)
  (n-trace "(n-trace-list %s)" headerMessage)
  (while list
    (n-trace "%s" (car list))
    (setq list (cdr list))
    )
  (n-trace "EOL")
  )

(global-set-key "\C-xe" 'eval-region)

(setq-default tab-width 8)
(setq-default case-fold-search       nil)
(setq-default indent-tabs-mode       nil)
;;(error ": 1111111111111")

(n-trace ".emacs check point 0.1")
(load "simple")
(n-trace ".emacs check point 0.2")
(load "shell")
(n-trace ".emacs check point 4")

(abbrev-mode 1)
                                        ; specially enabled commands
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)

                                        ; disabled commands
(put 'fill-paragraph 'disabled t)
(put 'set-goal-column 'disabled t)

(n-trace ".emacs check point 4.1")
(load "n2")
(n-trace ".emacs check point 5.3")
(defun n-error(&rest arguments)
  (apply 'message arguments)
  (read-char)
  )

;;(error ": 111111444444444441111111")
(n-load-mine)
(n-file-set-hook)
(n-trace ".emacs check point 5.5")

(setq-default indent-line-function 'n-oop)
(n-trace ".emacs check point 6.6")
(n-load "nkeys")
(n-trace ".emacs check point 6.75")
(setq mail-yank-prefix ">>	")

(n-trace ".emacs check point 6.8")
(if (not n-batch)
    (progn
      (n-trace ".emacs check point 6.82")
      ;;(n-file-init)
      ;;(n-trace ".emacs check point 7.7")
      (setq-default make-backup-files nil)
      (setq make-backup-files nil)
      (setq backup-inhibited t)

      (require 'ntags-find)
      (n-trace ".emacs check point 7.9")
      (n-env-init)
      (n-trace ".emacs check point 7.91")
      ;;(setq completion-ignored-extensions nil)	;; buggy in 21.22.1
      ;;                                                
      ;; this causes automatic refresh of changed files:
      ;;                                                
      ;;(if (eq system-type 'gnu/linux)
      (global-auto-revert-mode t)
      ;;)
      
      ;;(condition-case nil
          ;;(cond
           ;;((or
             ;;(string-match "23.1.1"  emacs-version)
             ;;(string-match "23.2.1"  emacs-version)
             ;;)
            ;;(message "n19: emacsserver broken for me in version %s, at least on n-2k4" emacs-version)
            ;;(sleep-for 2)
            ;;)
           ;;((functionp 'server-start)
            ;;(setq server-auth-dir "c:/z")
            ;;(server-start)	 ;; gnu emacs (here's where n-2k4 freezes)
            ;;)
           ;;((functionp 'gnuserv-start) 
            ;;(gnuserv-start)	 ;; xemacs
            ;;)
           ;;(t
            ;;(message "n19 could not find a way to start an emacsclient server")
            ;;(sleep-for 2)
            ;;)
           ;;)
        ;;(error nil)
        ;;)

      (n-trace ".emacs check point 7.92")
      (setq completion-ignored-extensions
            (list ".class" ".o" ".obj" ".svn")
            )
      ;;(n-file-find "$dp/emacs/lisp/nsimple.el") ;; for some unknown reason, doing this fixes that problem where repeated kill commands don't append to the kill ring's current entry.  Why, I have no idea.  -ns 2/14/04
        ;;(n-trace ".emacs checkpoint 7.921")
        ;;(nelisp-compile)
        ;;(nbuf-kill-current)
      (n-trace ".emacs check point 7.93")
      (delete-other-windows)
      (if (n-file-exists-p "$HOME/data/in")
          (n-file-find "$HOME/data/in"))
      (n-trace ".emacs check point 7.94")
      )
  )
(n-trace ".emacs check point 8")
(setq interpreter-mode-alist nil)
(add-to-list 'interpreter-mode-alist '("bash" . nsh-mode))
(if nil
    (setq auto-mode-alist (append
                           (list (cons "/todo\\..*" 'fundamental-mode))
                           auto-mode-alist
                           ))
  )
(setq auto-mode-alist (append
                       (list (cons "/todo\\..*" 'fundamental-mode))
                       (list (cons "\\.ahk$" 'nahk-mode))
                       (list (cons "\\.nlog\\.[^/]*$" 'nlog-mode))
                       (list (cons "\\.js$" 'njavascript-mode))
                       (list (cons "\\.json$" 'njavascript-mode))
                       (list (cons "\\.ps1$" 'nps1-mode))
                       (list (cons "\\.rb$" (if (boundp 'ruby-mode) 'ruby-mode 'nruby-mode-hook)))
                       (list (cons "junit-reports/log.xml$" 'fundamental-mode))
                       (list (cons "post.profile$" 'nsh-mode))
                       (list (cons ".*\\.hbm.xml$" 'nhbm-mode))
                       (list (cons ".*\\.war$" 'archive-mode))
                       (list (cons ".*xml$" 'nant-mode))
                       (list (cons "pix.control$" 'npix-control-mode))
                       (list (cons "\\.inc$" 'nant-mode))
                       (list (cons ".*\\.jsp$" 'njsp-mode))
                       (list (cons "/ahk_abc$" 'nahk-mode))
                       (list (cons ".*\\.ftl$" 'nhtml-mode))
                       (list (cons ".*\\.vm$" 'nhtml-mode))
                       (list (cons "\\.facts$" 'nfacts-mode))
                       (list (cons "\\.st$" 'nst-mode))
                       (list (cons ".*\\.el$" 'emacs-lisp-mode))
                       (list (cons ".*\\.emacs$" 'emacs-lisp-mode))
                       (list (cons "\\.ez$" 'nez-mode))
                       (list (cons "\\.menu$" 'nmenu-edit-mode))
                       (list (cons "\\.htm?l?$" 'nhtml-mode))
                       (list (cons "\\.wsdl$" 'nhtml-mode))
                       (list (cons "\\.qa$" 'nhtml-mode))
                       (list (cons "/ex_run_pre$" 'nsql-interactive-mode))
                       (list (cons "[\\\\/][bt]\\.[0-9][0-9]$" 'nbookkeeping-mode))
                       (list (cons "\\.plsql$" 'nplsql-mode))
                       (list (cons "/largesoft/.*\\.txt$" 'nsql-mode))
                       (list (cons "\\.gar$" 'archive-mode))
                       (list (cons "/pso/.*\\.txt$" 'nsql-mode))
                       (list (cons "/sql_out/.*\\.txt$" 'nsql-mode))
                       (list (cons "/bobid_usage.txt$" 'nsql-mode))
                       (list (cons "midnight.sql$" 'nsql-mode))
                       (list (cons "\\.ora$" 'nsql-interactive-mode))
                       (list (cons "sql$" 'nsql-interactive-mode))
                       (list (cons "\\.oracle$" 'nsql-interactive-mode))
                       (list (cons "\\.mssql$" 'nsql-interactive-mode))
                       (list (cons "\\.py$" 'npython-mode))
                       (list (cons "midnight$" 'nmidnight-mode))
                       (list (cons "elisp-" 'emacs-lisp-mode))
                       (list (cons "\\.cgi$" 'nperl-mode))
                       (list (cons "\\.dcm$" 'ndcm-mode))
                       (list (cons "\\.faq$" 'nhtml-mode))
                       (list (cons "\\.files$" 'nfiles-mode))
                       (list (cons "\\.gdbinit$" 'n-gdbinit-mode))
                       (list (cons "\\.cpp$" 'nc-mode))
                       (list (cons "\\.h$" 'nc-mode))
                       (list (cons "\\.i$" 'nc-mode))
                       (list (cons "\\.inl$" 'nc-mode))
                       (list (cons "\\.java$" 'njava-mode))
                       (list (cons "\\.cs$" 'njava-mode))
                       (list (cons "\\.aspx?$" 'njavascript-mode))
                       (list (cons "\\.pl$" 'nperl-mode))
                       (list (cons "\\.plx$" 'nperl-mode))
                       (list (cons "\\.pm$" 'nperl-mode))
                       (list (cons "\\.ps$" 'nps-mode))
                       (list (cons "\\.record$" 'nrecord-mode))
                       (list (cons "\\.shovel$" 'nshovel-mode))
                       (list (cons "\\.shovel.list$" 'nshovel-list-mode))
                       (list (cons "\\.summary$" 'nsummary-mode))
                       (list (cons "\\.k?sh$" 'nsh-mode))
                       (list (cons "shrc$" 'nsh-mode))
                       (list (cons "midnight.*$" 'nmidnight-mode))
                       (list (cons "scripts/" 'nsh-mode))
                       (list (cons "/\\." 'nsh-mode))  ;; eg, .profile
                       (list (cons "/bin/" 'nsh-mode))
                       (list (cons "bookkeeping\\.[0-9]+$" 'nbookkeeping-mode))
                       (list (cons "info.*elisp-" 'emacs-lisp-mode))
                       auto-mode-alist
                       (list (cons "/teacher/data/[^/\.]+$" 'nteacher-mode))
                       )
      )
(n-trace ".emacs check point 8.1")
(custom-set-faces)
(setq require-final-newline nil)
(setq minibuffer-max-depth nil)
(custom-set-variables '(load-home-init-file t t))
(custom-set-faces)
(load "nelisp")
;;(n19-bisect-sees-failure)
(nshell)
;;(shell)
;;(global-set-key "\M-s" 'shell)
(delete-other-windows)
(setq scroll-preserve-screen-position t)
(setq scroll-conservatively 10)
(setq scroll-margin 7)

(if (and (getenv "COMPUTERNAME")
         (string-match "^\\(n-2k4\\|o8\\)$" (getenv "COMPUTERNAME"))
         )
    ;;(n-file-find "$dp/data/todo"))
    (nlog-cmd)
  )
;;(nterminal-init)
(cond
 ((and (not (n-file-exists-p "$HOME/.init.done"))
       (not (n-file-exists-p "$HOME/.init.done.$COMPUTERNAME"))
       (not (n-file-exists-p "$HOME/.init.done.$HOSTNAME"))
       )
  (if n-win
      (n-file-find "$dp/init/setup3_windows.sh")
    (n-file-find "$dp/init/setup_unix")
    )
  (n-s "init.done_for_this_host" t)
  )
 ((n-file-exists-p "$dp/todo.$COMPUTERNAME")
  (n-file-find "$dp/todo.$COMPUTERNAME")
  )
 )

(remove-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt)

(n-trace ".emacs check point 9")
(setq-default mode-line-format  (list ""
                                      mode-line-modified
                                      'default-directory
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
(setq interpreter-mode-alist nil)       ;; I might regret this -- will break mode identification for files based on line 1 !interpreter
(setq n-emacs-initing 	nil)
(global-font-lock-mode 0)       ;; disable colors
(setq large-file-warning-threshold 100222000)
