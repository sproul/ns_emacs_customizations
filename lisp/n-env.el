(provide 'n-env)
(n-load "n-env-vars-to-substitute")

(make-variable-buffer-local 'n-next-error-called-already)
(setq-default n-next-error-called-already nil)

;; I don't know where the trailing slash is coming from...
(setenv "HOME" (nstr-replace-regexp (n-host-to-canonical "$HOME")
                                    "[\\\\/]$"
                                    ""
                                    )
        )

(setq n-env (n-database-get "n-env" nil nil "sensu"))

(setq n-env-reading-from-local-variables nil)

(defun n-env-set()
  "choose a set of environment settings"
  (interactive)
  (let(
       (newenv  (nmenu nil "environment"))
       )
    (if newenv
        (progn
          (setq n-env newenv)
          (n-database-set "n-env" n-env)
          (n-env-init)
          )
      )
    )
  )

(defun n-env-set-domain-file-list()
  (if (intern-soft (concat "n-data-menu-nbuf-shortcuts_" n-env))
      ;;(insert (concat "n-data-menu-nbuf-shortcuts_" n-env))n-data-menu-nbuf-shortcuts_monitor_ui
      (let(
           (file-names (progn
                         (n-load "data/n-data-menu-nbuf-shortcuts")
                         (eval
                          (intern-soft (concat "n-data-menu-nbuf-shortcuts_" n-env))
                          )
                         )
                       )
           )
        (n-zap "*k-domain-file-list")
        (while file-names
          (if (stringp (cdar file-names))
              (insert (cdar file-names) "\n"))
          (setq file-names (cdr file-names))
          )
        )
    ;; here is where n-env-domain-file-list gets set.  Not sure it jis in use, so commented out for now (since this code was sorting random bufferse)
    ;; (goto-char (point-min))
    ;; (replace-regexp "/[^/]*$" "")
    ;; (require 'n-prune-buf)
    ;; (n-prune-duplicates)
    ;;
    ;; (goto-char (point-min))
    ;; (setq n-env-domain-file-list nil)
    ;; (while (not (eobp))
    ;; (setq n-env-domain-file-list (cons
    ;; (n-host-from-canonical
    ;; (concat (n-get-line) "/*[chlp]")
    ;; )
    ;; n-env-domain-file-list)
    ;; )
    ;; (forward-line 1)
    ;; )
    )
 )


(defun n-env-grep(stackIt &rest args)
  (let(
       process
       (argument        (apply 'concat args))
       )
    (n-env-grep-get-midnight stackIt)
    (erase-buffer)
    (setq nmidnight-tmp t)
    (setq process (get-buffer-process (current-buffer)))
    (if (not (and process
		  (equal 'run (process-status process))
		  )
	     )
	(let(
	     (cmd "sh $dp/bin/g.sh")
	     )
	  (delete-region (point-min) (point-max))
	  (if n-win
	      (setq cmd (concat  "c:/init/do_sh.bat " cmd)))
	  (insert cmd)
	  (nmidnight-compile)
	  (funcall (nkeys-binding "\C-m"))
	  (setq process (get-buffer-process (current-buffer)))
          )
      )
    (erase-buffer)
    (setq n-next-error-called-already   nil)
    (process-send-string process (concat n-env " " argument "\n"))
    (message (concat n-env " " argument))
    (sleep-for 1)
    (goto-char (point-min))
    )
  )

(setq  n-env-grep-stack-len 0)

(defun n-env-grep-get-midnight(stackIt)
  (if stackIt




      ;; I'm not sure about this scheme -- maybe I should rename the buffer to get it out of the way, and leave all the code always referring to midnight.grep?





      (setq  n-env-grep-stack-len (1+  n-env-grep-stack-len))
    )
  (require 'nmidnight)
  (let(
       (bn (format midnight-grep-output-buffer n-env-grep-stack-len))
       )
    (n-file-find (concat n-local-tmp bn))
    )

  (if (and (not (buffer-file-name))
	   (y-or-n-p "no buf -- looks like I have one of those bogus phantom buffers on my hands.  Refresh?")
	   )
      (n-file-refresh-from-disk)
    )
  (or (buffer-file-name) (error "n-env-grep-get-midnight: no buffer filename"))

  (nmidnight-find-output-file (buffer-file-name) t)
  ;;jeez!
  ;;(nmidnight-push-output-file)
  )
(defun n-igrep()
  "grep in some include dirs"
  (interactive)
  (let(
       (token   (n-grab-token))
       )
    (grep
     (format "%s /usr/include/*.h /usr/include/sys/*.h /remote/conn5/csi/project/oahu/distrib/generic/include/*.h" token))
    )
  )

(defun n-env-grep-goto( &optional arg new-n-g)
  "go to the grep buffer; if optional ARGUMENT non-nil, copy grep output above point in the source buffer to the grep buffer"
  (interactive "P")
  (if arg
      (let(
           (search-output (buffer-substring-no-properties (progn
                                                            (goto-char (point-max))
                                                            (forward-line -1)
                                                            (end-of-line)
                                                            (n-r ":" t)
                                                            (end-of-line)
                                                            (point)
                                                            )
                                                          (progn
                                                            (if (or (n-r "^[0-9]")
                                                                    (n-r "^[^:]*$")
                                                                    )
                                                                (progn
                                                                  (if (and (not new-n-g)
                                                                           (looking-at "^\\(.* \\)?g \\([^ ]*\\)")
                                                                           )
                                                                      (setq new-n-g (nre-pat 2))
                                                                    )
                                                                  (forward-line 1)
                                                                  )
                                                              (goto-char (point-min))
                                                              (if (and (not new-n-g)
                                                                       (looking-at "^\\(.* \\)?g \\([^ ]*\\)")
                                                                       )
                                                                  (setq new-n-g (nre-pat 2))
                                                                )
                                                              )
                                                            (point)
                                                            )
                                                          )
                          )
           (directory (nstr-replace-regexp (n-host-to-canonical default-directory)
                                           "~"
                                           (n-host-to-canonical "$HOME")
					   )
                      )
	   )
        (if new-n-g
            (setq n-g new-n-g))
	(n-env-grep-goto)
	(delete-region (point-min) (point-max))
	(insert search-output)
	(goto-char (point-min))
        
        (replace-regexp "^\\([a-zA-Z]\\):" "/cygdrive/\\1")
        (goto-char (point-min))
        
	(replace-regexp "^\\([^/]\\)" (concat directory "\\1"))
	(goto-char (point-min))
	)
    )
  (require 'nmidnight)
  (find-file (concat n-local-tmp midnight-grep-output-buffer))
  )

(defun n-env-replace-regexp()
  (require 'nelisp)
  (let(
       (command	(progn
                  (message "environment: q-query, r-replace")
                  (read-char)
                  )
                )
       )
    (n-trace "lisp? %c" command)
    (call-interactively
     (cond
      ((= command ?q)
       (if (n-modes-lispy-p)
           'nelisp-domain-replace-regexp-query
         'n-env-domain-replace-regexp-query)
       )
      ((= command ?r)
       (if (n-modes-lispy-p)
           'nelisp-domain-replace-regexp
         'n-env-domain-replace-regexp
         )
       )
      )
     )
    )
  )
(defun n-env-replace-regexp-based-on-env-grep-output(&optional old new)
  (switch-to-buffer midnight-grep-output-buffer)
  
  (goto-char (point-min))
  (if (looking-at "/bin/grep$")
      (nsimple-delete-line))
  
  (let(
       (default	(if (not n-g)
                    ""
                  ;; this pattern won't work for a string
                  ;; ending with consecutive double quotes
                  (if (string-match "^\"?\\(.*[^\"]\\)\"?$" n-g)
                      (n--pat 1 n-g)
                    ""
                    )
                  )
         )
       )
    (if (and (not old)
	     (not new)
	     )
	(setq old (read-string "replace: " default)
	      new (read-string "with: " old)
	      )
      )
    (if (and case-replace case-fold-search)
        (setq old (nstr-downcase old)))
    
    (nre-act-on-hits-in-grep-buffer '(lambda()
				       (n-narrow-to-line)
				       (forward-line 0)
				       (replace-regexp old new)
				       )
				    )
    )
  )
(defun n-env-grap(&rest args)
  (interactive "P")
  (if (n-modes-lispy-p)
      (call-interactively 'nelisp-grap)
    (call-interactively 'n-env-grap-meat)
    )
  )
(defun n-env-grap-meat( &optional arg stackIt)
  "n-env-grep on the token under point in the current grep domain"
  (interactive "P")
  (n-loc-push)
  (setq n-g (cond
	     ((and arg (stringp arg))
	      arg
	      )
	     (arg
	      (read-string "Search for: ")
	      )
	     (t (n-grab-token))
	     )
	)
  (if (and n-g (not (string= n-g "")))
      (progn
	(n-env-domain-env-grep stackIt)
	)
    (message "no search string entered")
    )
  )
(defun n-env-grap-stacked(&optional arg)
  "push the current grep; do another one (not implemented)"
  (interactive)
  (n-env-grap arg t)
  )
(defun n-env-debug-decorate(bugIndex)
  (delete-other-windows)
  (goto-char (point-min))
  (nsimple-split-window-vertically)
  
  (n-s (concat "jLinks\\[" bugIndex "\\]=['\"]?") t)
  
  (other-window 1)
  (n-s (concat ">" bugIndex "<") t)
  )
(defun n-env-grap-highgate_API-to-highgate_API_case_label()
  (let(
       (api     (n-grab-token))
       )
    (concat 
     "case "
     (nstr-replace-regexp api "^hg" "api")
     "_meth"
     )
    )
  )

(defun n-env-domain-env-grep(stackIt)
  "n-env-grep on n-g in the current grep domain"
  (interactive)
  (if (not n-g)
      (error "n-g isn't set, so there's nothing to grep"))
  (let(
       (grepArgs        (list stackIt n-g))
       )
    (save-some-buffers t)               ; save all bufs
    (apply 'n-env-grep grepArgs)
    )
  )
(defun n-env-ext-adjust-setting-weblogic(var val)
  (let(
       (wfn (n-host-to-canonical "$extInstall/AppServer/weblogic.properties"))
       )
    (if (and (string= var "server")
	     (string-match "\\(.*\\):1521" val)
	     )
	(setq val (n--pat 1 val))
      )
    (n-trace "  n-env-ext-adjust-setting-weblogic: %s: %s=%s" wfn var val)
    
    (n-file-replace-regexp wfn
			   (concat "\\(=\\|,\\)" var "=\\(['\"]?\\)[^\"',\n]*")
			   (concat "\\1" var "=\\2" val)
			   )
    (n-file-replace-regexp wfn
			   (concat "^" var "=.*")
			   (concat var "=" val)
			   )
    )
  )  

(defun n-env-ext-adjust-setting-ext-cfg-update(var val)
  (n-trace "  n-env-ext-adjust-setting-ext-cfg-update: %s: %s=%s" n-env-ext-config var val)
  (if (not (n-file-replace-regexp n-env-ext-config
				  (concat "^" var "=.*") 
				  (concat var "=" val)
				  )
	   )
      (progn
	(find-file n-env-ext-config)
	(goto-char (point-max))
	(forward-line 0)
	(if (not (looking-at "$"))
	    (progn
	      (end-of-line)
	      (insert "\n")
	      )
	  )
	(insert var "=" val "\n")
	)
    )
  )


(defun n-env-get-ext-config()
  (let(
       (fn (n-host-to-canonical  "$extInstall/largesoft/util/Extensity.cfg"))
       )
    (if (file-exists-p fn)
	fn
      )
    )
  )
(setq n-env-ext-config (n-env-get-ext-config))


(defun n-env-ext-adjust-setting-ext-cfg(var val)
  (n-trace "  n-env-ext-adjust-setting-ext-cfg %s=%s" var val)
  (n-env-ext-adjust-setting-ext-cfg-update var val)
  (if (cond
       ((string= var "db")
	(setq var "dbName")
	)
       ((string= var "server")
	(setq var "dbServer")
	(if (string= "oracle" (getenv "extdbtype"))
	    (if (not (string-match ":[0-9]+$" val))
		(setq val (concat val ":1521")))
	  (if (string-match "\\(.*\\):[0-9]+$" val)
	      (setq val (n--pat val 1)))
	  )
	t
	)
       ((or
	 (string= var "dbPassword")
	 (string= var "dbType")
	 (string= var "dbUser") 
	 )
	t
	)
       (t 
	nil)
       )
      (progn
	(n-env-ext-adjust-setting-ext-cfg-update (concat "online."  var) val)
	(n-env-ext-adjust-setting-ext-cfg-update (concat "offline." var) val)
	)
    )
  )

(defun n-env-ext-adjust-setting(var val)
  (n-trace " n-env-ext-adjust-setting %s=%s" var val)
  (n-env-ext-adjust-setting-weblogic var val)
  
  (if n-env-ext-config
      (n-env-ext-adjust-setting-ext-cfg var val))
  
  (n-env-ext-adjust-setting-ext-config-cfg var val)
  )

(defun n-env-ext-adjust-setting-ext-config-cfg(var val)
  (n-trace "  n-env-ext-adjust-setting-ext-config-cfg %s=%s" var val)
  (cond
   ((string= var "dbPassword")
    (setq var "password"))
   )
  
  (n-file-replace-regexp "$extInstall/largesoft/install/Config.cfg"
			 (concat "^to\\." var "=.*")
			 (concat "to."    var "=" val)
			 )
  )

(defun n-env-read-values-from-file(fn)
  (let(
       (n-env-reading-from-local-variables t)
       )
    (find-file (nsimple-env-expand fn))
    (goto-char (point-min))
    (while (not (eobp))
      (if (looking-at "set \\([0-9a-zA-Z_]+\\)=\\(.*\\)")
	  (save-excursion
	    (n-env-set-variable (n--pat 1) (n--pat 2) t))
	)
      (forward-line 1)
      )
    )
  )
(defun n-env-set-variable-propogate-to-sub-processes()
  (let(
       (variableSettingCmdString (format "%s=\"%s\";export %s;" variable value variable))
       (processList (process-list))
       cmd
       name
       process
       )
    (setq variableSettingCmdString (concat variableSettingCmdString "\n"))
    (while processList
      (setq process (car processList)
	    name (process-name process)
	    cmd (nstr-join (process-command process)
			   " "
			   )
	    )
      (cond
       ((or
	 (string-match "local_build.sh" name)
	 (string-match "local_build.sh" cmd)
	 )
	t
	)
       ((string-match "^shell" name)
	(condition-case nil
	    (process-send-string process variableSettingCmdString)
	  (error nil)
	  )
	)
       )
      (setq processList (cdr processList))
      )
    )
  )
(defun n-env-prompt-for-variable-value(variable &optional oldValue)
  (if (nmenu-exists variable)
      (nmenu variable)
    (read-string (concat variable ": ") oldValue)
    )
  )

(defun n-env-set-variable-extrel(val)
  (let(
       (oldInstall (getenv "extInstall"))
       )
    (if (string-match "^\\(.*\\)\\.[^\\.]+$" oldInstall)
	(setq oldInstall (n--pat 1 oldInstall))
      )
    (n-env-set-variable "extInstall" (concat oldInstall
					     "."
					     value
					     )
			)
    (if (not (string= "" val))
	(progn
	  ;; make sure appropriate settings go to the config files in the correct install tree
	  (n-env-set-variable "extdb"      (getenv "extdb"))
	  (n-env-set-variable "extdbpw"    (getenv "extdbpw"))
	  (n-env-set-variable "extdbtype"  (getenv "extdbtype"))
	  (n-env-set-variable "extdbserver"(getenv "extdbserver"))
	  (n-env-set-variable "extserver"  (getenv "extserver"))
	  )
      )
    )
  )
(defun n-env-set-variable(variable &optional valueParm noCascade)
  (error "n-env-set-variable: unused..................................")
  (n-trace "n-env-set-variable %s=%s" variable valueParm)

  (if (string= variable "extInstall")
      (setq valueParm (cond
		       ((and (string= (getenv "extserver") "PLATINUM")
			     (string= (getenv "extprj") "Rel5_0")
			     )
			"d:/Rel5_0"
			)
		       ((and (string= (getenv "extserver") "GRIFFIN")
			     (string= (getenv "extprj") "Rel4_2")
			     )
			"d:/Customers/$extset/4.29"
			)
		       (t valueParm)
		       )
	    )
    )

  (let(
       (oldValue (getenv variable))
       (value valueParm)
       setToOracle
       )
    (if (not value)
	(setq value	(n-env-prompt-for-variable-value variable oldValue))
      )
    (setq value (nsimple-env-expand value))
    (if (not (string= value oldValue))
	(setenv variable value))

    (setq value (nstr-replace-regexp value "\\\\" "/"))
    ;;(n-trace "n-env-set-variable: %s=%s" variable value)

    (if (not (string= value oldValue))
	(n-env-set-variable-propogate-to-sub-processes))

    (if (not n-env-reading-from-local-variables)
	(progn
	  (n-file-replace-regexp "$dp/data/local_variables.bat"
				 (concat "^set " variable "=[^,\n]*")
				 (concat  "set " variable "=" value)
				 (concat  "set " variable "=" value "\n")
				 )
	  )
      )
    (cond
     ((string= variable "extdb")
      (n-env-ext-adjust-setting "db" value)
      (n-env-set-variable-gen-extolddb value)
      )
     ((string= variable "extdbpw")
      (n-env-set-variable "extolddbpw" value)
      (n-env-ext-adjust-setting "dbPassword" value)
      )
     ((string= variable "extdbserver")
      (n-env-set-variable "extolddbserver" value)
      (n-env-ext-adjust-setting "server" value)
      )
     ((string= variable "extdataset")
      (n-env-set-variable "extdatasetdir" value)
      (n-env-set-variable "DATA_SETS" (concat value ",qa,base"))
      )
     ((string= variable "extdbtype")
      (n-env-set-variable "extolddbtype" value)
      (n-env-set-variable "extsqlpath" (nsimple-env-expand (concat "$" value "_bin")) noCascade)
      (n-env-ext-adjust-setting "dbType" value)
      (cond
       ((or
	 (string= value "mssql")
	 (string= value "sybase")
	 )
	(n-env-set-variable "extdbuser" "sa")
	(n-env-set-variable "extdbpw" "")

	(let(
	     (dbserver (getenv "extdbserver"))
	     )
	  (if (string-match "\\(.*\\):" dbserver);; make sure extensity.cfg doesn't get the ':1521'
	      (progn
		(setq dbserver (n--pat 1 dbserver))
		(n-env-set-variable "extdbserver" dbserver)
		)
	    )
	  )
	)
       ((string= value "oracle")
	(n-env-set-variable "extdbuser" (getenv "extdataset")) ;;"system"
	(n-env-set-variable "extdbpw"   (getenv "extdataset")) ;;"manager"
	(n-env-set-variable "extdb"	(system-name))	;;"ORCL"

	(let(
	     (dbserver (getenv "extdbserver"))
	     )
	  (if (not (string-match ":" dbserver)) ;; make sure extensity.cfg gets the ':1521'
	      (progn
		(setq dbserver (concat dbserver ":1521"))
		(n-env-set-variable "extdbserver" dbserver)
		)
	    )
	  )
	)
       )
      )
     ((string= variable "extdbuser")
      (n-env-set-variable "extolddbuser" value)
      (n-env-ext-adjust-setting "user"   value)
      (n-env-ext-adjust-setting "dbUser" value)
      )
     ((string= variable "extInstall")
      (setq n-env-ext-config (n-env-get-ext-config))
      (n-env-set-variable "EXT_HOME" value)
      )
     ((string= variable "ext")
      (n-env-set-variable "extconversion" "Rel42ToRel50")
      (n-env-set-variable "EXT_ROOT" value)
      (n-env-set-variable "CLASSPATH"
			  (concat ".;"
				  (concat (getenv "JAVA") "/lib/classes.zip")
				  )
			  ;;(concat value ";"
			  ;;value "/3rdparty/classes.zip;"
			  ;;value "/3rdparty/3rdparty.zip;"
			  ;;value "/ext.zip;"
			  ;;value "/3rdparty/3rdpclient.zip;"
			  ;;value "/3rdparty/3rdpcompile.zip;"
			  ;;value "/3rdparty/3rdpmobile.zip;"
			  ;;value "/3rdparty/3rdpoffline.zip;"
			  ;;value "/3rdparty/jprintf.zip;"
			  ;;value "/3rdparty/3rdpserver.zip;"
			  ;;value "/3rdparty/3rdpserverdomestic.zip"
			  ;;"."
			  ;;)
			  )
      )
     ((string= variable "extprj")
      (if (not noCascade)
	  (progn
	    (let(
		 (extOldValue (getenv "ext"))
		 )
	      (n-env-set-variable "ext"
				  ;;(if (string-match (concat "/" oldValue "$")
				  ;;	   extOldValue
				  ;;   )
				  ;;(nstr-replace-regexp extOldValue oldValue value)
				  (concat (getenv "dev") "/" value)
				  ;;)
				  noCascade
				  )
	      )
	    (n-env-set-variable "extInstall" (concat "c:/" value))
	    (n-env-set-variable "extdataset" (getenv "extset"))
	    (n-env-set-variable "extdb"      (getenv "extset"))
	    (n-env-set-variable "exturldir" value)
	    (n-env-set-variable "extrel" (cond
					  ((string= value "Rel3_1") "318")
					  (t "")
					  )
				)
	    ;; ex_list_all_dbs.pl-defaults-begin
	    (n-env-set-variable "extport" "7001")
	    (n-env-set-variable "extbuild" "182")
	    (n-env-set-variable "exthttpport" "80")
	    (n-env-set-variable "extserver" (getenv "COMPUTERNAME"))
	    (n-env-set-variable "extdbserver" (getenv "COMPUTERNAME"))
	    (n-env-set-variable "extdbtype" "mssql")
	    (n-env-set-variable "extjvm" "jview")
	    (if (string= value "Rel3_1")
		(n-env-set-variable "extdatasetdir" "data_Rel3_1")
	      )
	    ;; ex_list_all_dbs.pl-defaults-end
	    )
	)
      ;;(nelisp-bp "n-env-set-variable" "n-env.el" 574);;;;;;;;;;;;;;;;;
      (n-env-load-table-info)
      )
     ((string= variable "extrel")
      (if (not (string= value ""))
	  (n-env-set-variable-extrel value)
 	)
      )
     ((string= variable "extserver")
      (n-env-ext-adjust-setting "host" value)		; weblogic.properties only
      ;;(nelisp-bp value "n-env.el" 637);;;;;;;;;;;;;;;;;
      (n-env-ext-adjust-setting "appServer" value)	; extensity.cfg only
      )
     ((string= variable "extport")
      (n-env-ext-adjust-setting "weblogic.system.listenPort" value) ; weblogic.properties only
      (n-env-ext-adjust-setting "portNumber" value)	; extensity.cfg only
      )
     ((string= variable "extset")
      (if (get-buffer "midnight.sql")
	  (kill-buffer "midnight.sql"))
      (if (string-match "\\(.*\\)_oracle$" value)
	  (progn
	    (setq value		(n--pat 1 value)
		  setToOracle	t
		  )
	    )
	)

      (if (string-match "^\\([0-9a-zA-Z_]+[^0-9]\\)\\([0-9]+\\)$" value)
	  (let(
	       (client (n--pat 1 value))
	       (majorVersion (string-to-int (n--pat 2 value)))
	       )
	    (cond
	     ((eq majorVersion 2 ) (n-env-set-variable "extprj" "Rel2_0"))
	     ((eq majorVersion 3 ) (n-env-set-variable "extprj" "Rel3_1"))
	     ((eq majorVersion 4 ) (n-env-set-variable "extprj" "Rel4_2"))
	     ((eq majorVersion 5 ) (n-env-set-variable "extprj" "Rel5_0"))
	     ((eq majorVersion 56) (n-env-set-variable "extprj" "Rel5_6_Patch"))
	     )
	    (n-env-set-variable "extdataset" client)
	    )
	)
      (if setToOracle
	  (n-env-set-variable "extdbtype" "oracle"))
      (if (and
	   (string= "local_variables.bat" value)
	   (not n-env-reading-from-local-variables)
	   )
	  (n-env-read-values-from-file "$dp/data/local_variables.bat")
	)
      )
     )
    (if (string= variable "extset")
	(progn
	  (require 'nelisp)
	  (nelisp-load-file (n-host-to-canonical "$dp/emacs/lisp/data/n-data-menu-nfly-shortcuts.el"))
	  )
      )

    value
    )
  ;;(nelisp-bp "n-env-set-variable" (concat variable " 2") 427 -1);;;;;;;;;;;;;;;;;
  )
(defun n-env-load-table-info-1()
  (load (nsimple-env-expand "data/nsql-$extprj-tables-to-keys"))
  (load (nsimple-env-expand "data/nsql-$extprj-tables-to-foreign-keys-to-tables.el"))
  (load (nsimple-env-expand "data/nsql-$extprj-char-data-vectors.el"))
  )
(defun n-env-set-variable-gen-extolddb(val)
  (let(
       (n	(if (string-match "\\([0-9]\\)$" val)
		    (n--pat 1 val)
		  )
		)
       )
    (if n
	(n-env-set-variable "extolddb" (nstr-replace-regexp val
							    (concat n "$")
							    (format "%d" (1- (string-to-int n)))
							    )
			    )
      )
    )
  )
(defun n-env-load-table-info(&optional forceRegen showErrors)
  (if (not forceRegen)
      (if showErrors
	  (n-env-load-table-info-1)
	(condition-case nil
	    (progn
	      (n-env-load-table-info-1)
	      )
	  (error (if (y-or-n-p "looks like one of the keys ELISP files is missing.  Regen? ")
		     (setq forceRegen t))
		 )
	  )
	)
    )
  (if forceRegen
      (progn
	(n-host-shell-cmd-visible "ex_generate_keys_db")
	(n-host-shell-cmd-visible "ex_database_types_generate.sh")
	(sleep-for 2)
	(n-env-load-table-info nil t) ;; try again, but this time show errors
	)
    )
  )
(defvar n-g nil
  "*pattern to be searched for")

(defun n-env-grep-for-n-g( fN)
  "search FN for the pattern described in n-g"
  (if (not n-g)
      (error "n-g must be set to the pattern to be searched for"))
  (save-excursion
    (let(
	 (buf   (get-buffer (file-name-nondirectory fN)))
	 fileAlreadyIn
	 )
      (if (and buf
	       (equal (buffer-file-name buf) fN)
	       )
	  (progn
	    (setq fileAlreadyIn t)
	    (set-buffer buf)
	    )
	(find-file fN)
	)
      (goto-char (point-min))
      
      (while (re-search-forward n-g (point-max) t)
	(n-print "%s:%d:%s\n"
		 fN
		 (count-lines (point-min) (point))
		 (n-get-line) 
		 )
	)
      (if (not fileAlreadyIn)
	  (kill-buffer (current-buffer)))
      )
    )
  )

(if (file-exists-p "c:/INIT_NEMACS")
    (let(
	 (host 			  (nstr-replace-regexp
				   n-local-world-name
				   "\n$"
				   ""
				   )
				  )
	 )
      (n-env-set-variable "extserver"   host)
      (n-env-set-variable "extdbserver" host)
      (delete-file "c:/INIT_NEMACS")
      )
  )
(defun n-env-cycle-client-arg()
  (let(
       next
       )
    (cond
     ((or
       (not (getenv "extclientarg"))
       (string= (getenv "extclientarg") "")
       )
      (setq next "-saveNomadic")
      )
     ((string= (getenv "extclientarg") "-saveNomadic")
      (setq next "-nomadic")
      )
     ((string= (getenv "extclientarg") "-nomadic")
      (setq next "")
      )
     (t
      (error "n-env-cycle-client-arg: ")
      )
     )
    (message "(setenv \"extclientarg\" \"%s\")" next)
    (setenv "extclientarg" next)
    )
  )
(defun n-env-is-whitelight()
  (n-file-exists-p "~/highgate")
  )
;;(defun n-env-url-hook(url)
;;  (let(
;;       x
;;       )
;;    (cond
;;     ((and (string-match "\\([^\\.]+\\).com" url)
;;	   (require 'nshell)
;;	   (setq x (n--pat 1 url)
;;		 x (nstr-call-process nil nil (nshell-get-explicit-shell-file-name) (n-host-to-canonical "$NELSON_BIN/gp") x)
;;		 )
;;	   )
;;      (nstr-kill x)
;;      )
;;     )
;;    )
;;  )

(defun n-env-browse( &optional arg)
  (interactive "P")

  (let(
       (url (if arg
		(n-grab-token-in-file "$dp/emacs/lisp/data/n-data-menu-browse.menu"
				      nil
				      " \t\n"
				      )
	      (nmenu "browse")
	      )
	    )
       )
    (if url
	(progn
          (require 'njava)
	  (nhtml-browse nil url)
	  )
      )
    )
  )
(defun n-env-bkgproc()
  (n-host-shell-cmd (format "ex_bg %s %s start"
			    (nmenu "bkgprocs")
			    (getenv "extport")
			    )
		    )
  )
(defun n-env-query-table(table &optional queryOnlyTablesWeHaveNoResultsFor)
  (message "Going to %s..." table)
  (save-window-excursion
    (require 'nsql)
    (n-file-find (nsql-get-baseline-query-output-fn table))
    (if (or (not queryOnlyTablesWeHaveNoResultsFor)
	    (= (point-min) (point-max))
	    )
	(progn
	  (nsql-get-current-table-contents)
	  (n-file-save-cmd)
	  )
      )
    (kill-buffer (current-buffer))
    )
  )

(defun n-env-query-dyn-tables()
  (n-env-query-table "alwf_work_item")
  (n-env-query-table "aler_expense_report")
  (n-env-query-table "aler_expense_line_item")
  (n-env-query-table "aler_line_allocation")
  (n-env-query-table "alco_cost_center")
  (n-env-query-table "alco_project_number")
  (n-env-query-table "alco_user")
  (n-env-query-table "alco_background_process")
  )

(defun n-env-query-rule-tables()
  (n-env-query-table "albr_instance")
  (n-env-query-table "albr_organization_br")
  (n-env-query-table "albr_parameter")
  (n-env-query-table "albr_template")
  (n-env-query-table "albr_defn")
  (n-env-query-table "albr_parameter_template")
  )

(defun n-env-query-all-tables(queryOnlyTablesWeHaveNoResultsFor)
  (cond
   ((string= system-name "o5")
    (n-file-find "$NELSON_HOME/work/event_horizon/site/db/table_list.dat")
    )
   (t
    (n-file-find "$NELSON_BIN/can/tables.sql")
    )
   )
  (goto-char (point-min))
  (while (progn
	   (end-of-line)
	   (not (eobp))
	   )
    (forward-line 0)
    (or (looking-at ".... \\(.*\\)")
        (looking-at "\\([^ \n]*\\)\n")
	(error "n-env-query-all-tables: ")
	)
    (setq table (n--pat 1))
    (n-env-query-table table queryOnlyTablesWeHaveNoResultsFor)
    (forward-line 1)
    )
  (message "Done querying tables.")
  )
(defun nsql-get-table-fn()
  (nstr-replace-regexp (nsql-get-table-name)
		       "^al"
		       ""
		       )
  )
(defun n-env-init()
  (n-env-set-domain-file-list)
  (cond
   ((string= n-env "monroe")
    (setenv "extdbserver" "o5")
    (setenv "extdb" "monroe_test")
    (setenv "extdbtype" "ms")
    (setenv "extdbuser" "sa")
    (setenv "extdbpw" "sa72")
    )
   ((string= n-env "teacher")
    ;;set extpw=hhhhh/
    ;;set extdb=teacher
    ;;set extdbtype=mysql
    ;;set extInstall=c:\override
    
    (setenv "extdb" "teacher")
    (setenv "extdbtype" "mysql")
    (setenv "extpw" "p")
    )
   )
  
  ;; turn off auto-save
  (setq auto-save-interval 0
        auto-save-timeout 0
        )
  )
(defun n-env-add-file-to-shortcuts--goto-data-start()
  (goto-char (point-min))
  (if (not (n-s (concat "^(setq n-data-menu-nbuf-shortcuts_" n-env "$")))
      (progn
        (goto-char (point-max))
        (insert "\n(setq n-data-menu-nbuf-shortcuts_" n-env "\n"
                "(append\n"
                "(list\n"
                ")\n"
                "n-data-menu-nbuf-shortcuts-common\n"
                ")\n"
                ")\n"
                )
        (call-interactively 'n-indent-region)
        (goto-char (point-min))
        (n-s (concat "^(setq n-data-menu-nbuf-shortcuts_" n-env "$") t)
        )
    )

  (n-s "(list" t)
  (forward-line 0)
  )

(defun n-env-add-file-to-shortcuts()
  (interactive)
  (let(
       (fn (buffer-file-name))
       )
    (n-file-find "$dp/emacs/lisp/data/n-data-menu-nbuf-shortcuts.el")
    (widen)

    (n-env-add-file-to-shortcuts--goto-data-start)

    (save-restriction
      (narrow-to-region (point) (progn
                                  (forward-sexp 1)
                                  (point)
                                  )
                        )
      (n-narrow-to-region (progn
                            (goto-char (point-min))
                            (forward-line 1)
                            (point)
                            )
                          (progn
                            (goto-char (point-max))
                            (forward-line 0)
                            (point)
                            )
                          )
      (goto-char (point-min))
      (replace-regexp "^[ \t]*" "")
      (goto-char (point-min))

      (insert "\t(cons ?@@ \"")
      (nfly-insert fn)
      (insert "\")\n")

      (forward-line -1)
      (n-s "@@" t)
      (delete-char -2)
      (recursive-edit)
      )
    (bury-buffer)

    (n-delete-window)
    )
  )
(defun n-env-use-expr(envVarName &optional rootOnly envVarValue)

  (let(
       (possibleRootRegexp (if rootOnly "^" ""))
       )

    (if (and envVarValue
             (not (string= "" envVarValue))
             )
        (progn
          (goto-char (point-min))
          (replace-regexp (concat possibleRootRegexp envVarValue)
                          envVarName
                          )
          )
      ;;(n-trace "n-env-use-var-name(envVarName:%s [%s])" (prin1-to-string envVarName) envVarValue)
      )
    )
  )
(defun n-env-use-var-name(envVarName &optional rootOnly)
  (let(
       (possibleRootRegexp (if rootOnly "^" ""))
       (treatAsEnvVar	t)
       (envVarValue (getenv envVarName))
       )
    (if (and envVarValue
             (not (string= "" envVarValue))
             )
        (progn
          (setq envVarValue (nstr-replace-regexp envVarValue "\\\\" "/"))
          (goto-char (point-min))
          (replace-regexp (concat possibleRootRegexp envVarValue "\\([a-zA-Z0-9_]\\)")
                          (concat "${" envVarName "}\\1")
                          )

          (goto-char (point-min))
          (replace-regexp (concat possibleRootRegexp envVarValue)
                          (concat "$" envVarName)
                          )

          (goto-char (point-min))
          ;; try one last time, but first cygpath --mixed:
          (setq envVarValue (nstr-replace-regexp envVarValue "/cygdrive/\\([a-zA-Z]\\)" "\\1:"))
          (replace-regexp (concat possibleRootRegexp envVarValue)
                          (concat "$" envVarName)
                          )

          (cond
           ((and (boundp 'str-context-mode) (eq str-context-mode 'nperl-mode))
            (goto-char (point-min))
            (replace-regexp (concat "\\$" envVarName)
                            (concat "$ENV{'" envVarName "'}")
                            )
            )
           ((and (boundp 'str-context-mode) (eq str-context-mode 'nruby-mode))
            (goto-char (point-min))
            (replace-regexp (concat "\\$" envVarName)
                            (concat "#{ENV['" envVarName "']}")
                            )
            )
           )
          )
      )
    )
  )

(defun n-env-use-var-names(&optional useTilde elide)
  (save-excursion

    (goto-char (point-min))
    (replace-regexp "~/" (concat n-host-home "/"))

    ;;(n-env-use-var-name "SYSTEM_BUILD_HOME")
    (let(
         (x n-env-vars-to-substitute)
         )
      (while x
        (n-env-use-var-name (car x) t)
        (setq x (cdr x))
        )
      )
    (goto-char (point-min))
    )
  (or (< (point-min) (point-max))
      (error "n-env-use-var-names: no data"))

  ;;(n-trace "n-env-use-var-names ends w/: %s" (buffer-substring-no-properties (point-min) (point-max)))
  (buffer-substring-no-properties (point-min) (point-max))
  )
(defun n-env-use-var-names-str(str &optional useTilde elide)
  (nstr-buf str 'n-env-use-var-names useTilde elide)
  )
(defun n-env-project-make(&optional project-name)
  (if (not project-name)
      (setq project-name (progn
                           (end-of-line)
                           ;; make it work if we are running while sitting on a line like (setq n-data-menu-nbuf-shortcuts_json_flattener -- here we want json_flattener
                           (nstr-replace-regexp (n-grab-token) ".*_" "")
                           )
            )
    )
  (nstr-kill project-name)
  (n-file-find "$dp/emacs/lisp/data/n-data-menu-environment.el")
  (n-s "cons" t)
  (message "kill contains %s" project-name)
  (recursive-edit)
  (nelisp-compile)
  )
;;(n-env-use-var-names-str "z:/abc")
;;(n-env-use-var-names-str "c:/downloads/")
;;(n-env-use-var-names-str "/opt/WebSphere/AppServer/logs/server1/")

