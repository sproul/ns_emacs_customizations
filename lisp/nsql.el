(provide 'nsql)
(require 'nshell)
(defvar nsql-break-point-mode nil)

(make-variable-buffer-local 'nsql-columnNames)
(setq-default nsql-columnNames nil)

(make-variable-buffer-local 'nsql-query-line-mode)
(setq-default nsql-query-line-mode t)

(make-variable-buffer-local 'nsql-separator)
(setq-default nsql-separator "|")

(if (not (boundp 'nsql-interactive-mode-map))
    (setq nsql-interactive-mode-map (make-sparse-keymap)))
(setq nsql-update-line nil)


(defun nsql-mode-meat()
  (save-excursion
    (nmidnight-mode)
    )
  (setq major-mode 'nsql-mode
        mode-name "nmidnight sql mode"
	;;n-complete-dirty-hook 'nsql-dirty-hook
        )
  (let(
       (map		(copy-tree (current-local-map)))
       )
    (define-key map "\M-\"" 'nsql-2-lines)
    (define-key map "\M-`" 'nsql-where-am-i)
    (define-key map "\M-b" 'nsql-backward-word)
    (define-key map "\M-c" 'nsql-get-current-table-contents)
    (define-key map "\M-d" 'nsql-kill-word)
    (define-key map "\M-e" 'nsql-goto-log)
    (define-key map "\M-f" 'nsql-forward-word)
    (define-key map "\M-k" 'nsql-delete)
    (define-key map "\M-o" 'nsql-loc-pop)
    (define-key map "\M-u" 'nsql-loc-push)
    ;;(define-key map "\M-w" 'nsql-find-where)
    (define-key map "\C-cc" 'nsql-configure)
    (define-key map "\C-m" 'nsql-insert-or-update)
    (define-key map "\C-w" 'nsql-delete-region-cmd)
    (define-key map "\C-x " 'nsql-toggle-break-point-mode)
    (define-key map "\C-xd" 'nsql-find-duplicate-key)
    (use-local-map map)
    )
  (setq tab-width 2)
  (let(
       (fn (n-host-to-canonical (buffer-file-name)))
       )
    (if (and
	 (string-match "/ct_" fn)
	 (not (string-match "settings$" (buffer-file-name)))
	 (not (string-match "set$" (buffer-file-name)))
	 ;;(not (string-match "sql_out/.*/ct_.*" fn))
	 )
	(setq nsql-separator "\t"))
    )
  (nsql-set-columnNames)
  )
(defun nsql-toggle-break-point-mode()
  (interactive)
  (setq  nsql-break-point-mode (not  nsql-break-point-mode ))
  (message "nsql-break-point-mode is %s"
	   (if nsql-break-point-mode "on" "off")
	   )
  )

(defun nsql-set-columnNames()
  (setq nsql-columnNames (nsql-get-column-names)) 
  )

(defun nsql-interactive-mode-meat()
  (setq major-mode 'nsql-interactive-mode
        mode-name "sql interactive mode"
        )
  (let(
       (map		(make-sparse-keymap))
       )
    (define-key map "\C-m" 'nsql-interactive-select-or-enter)
    (define-key map "\M-c" 'nsql-interactive-run)
    (use-local-map map)
    ) 
  (if (and (equal (point-min) (point-max))
	   (string-match "pre\\..*.sql$" (buffer-name))
	   )
      (progn
	(insert "update alwf_work_item set activity_id=720@@, locked_by_user_id=null, reviewer_user_id = null, doc_is_locked = 0 where (document_id in ('ER0000000@@'))")
	)
    )
  )

(defun nsql-interactive-select-or-enter()
  "if the current line contains a single token, assume it is a table name and execute a select * from this table.  Otherwise just insert a carriage return"
  (interactive)
  (if (and (looking-at "$")
	   (save-excursion
	     (forward-line 0)
	     (and
	      (looking-at "[a-z0-9A-Z_]+$")
	      (not (looking-at "^go$"))
	      )
	     )
	   )
      (nsql-grab-and-select)
    (nsimple-newline-and-indent)
    )
  )
(defun nsql-grab-and-select()
  (interactive)
  (let(
       (table (n-grab-token))
       )
    (nsql-goto-baseline-query-output table t)
    (nsql-get-current-table-contents)
    )
  )
(defun nmidnight-regen-ddl()
  (n-host-shell-cmd-visible "cd $ext/pso/$extdataset/V0; perl -w $ext/pso/standard/tools/adjust_ddl.pl $ext")
  )

(defun nsql-advance-to-the-next-sql()
  (let(
       done
       (maxJump 4) ;; don't advance more than this many lines
       (lineCnt 0)
       )
    (while (not done)
      (setq lineCnt (1+ lineCnt))
      (forward-line 1)
      (if (and (not (eobp))
	       (or (looking-at "#")
		   (looking-at "--")
		   (looking-at "^$")
		   )
	       )
	  nil
	(setq done t)
	)
      (if (> lineCnt maxJump)
	  (progn
	    (forward-line (- lineCnt))
	    (setq done t)
	    )
	)
      )
    )
  )

(defun nsql-execute-shell-command()
  (save-restriction
    (narrow-to-region (progn
			(forward-line 0)
			(n-s "^#!" t)
			(point)
			)
		      (progn
			(end-of-line)
			(point)
			)
		      )
    (nshell-execute-line)
    )
  )


(defun nsql-interactive-run(&optional arg queries)
  "execute the sql statement on the line under point"
  (interactive "P")
  (save-some-buffers t)
  (let(
       (silentMode (not (null queries)))
       )
    (if (and (integerp arg) (= arg 3))
	(progn
	  (setq arg nil
		nsql-query-line-mode (not nsql-query-line-mode)
		)
	  )
      )

    (if (and (buffer-file-name) (string-match "CreateAtLarge.add.ora" (buffer-file-name)))
	(nmidnight-regen-ddl)
      (if (not queries)
	  (setq queries (cond
			 (arg
			  (buffer-substring-no-properties (point-min) (point-max))
			  )
			 (nsql-query-line-mode
			  (n-get-line)
			  )
			 (t
			  (buffer-substring-no-properties (progn
					      (if (not (n-r "^[ \t]*$"))
						  (goto-char (point-min))
						)
					      (point)
					      )
					    (progn
					      (forward-line 1)
					      (if (not (n-s "^[ \t]*$"))
						  (goto-char (point-max))
						)
					      (point)
					      )
					    )
			  )
			 )
		)
	)

      (if (string-match "^#" queries)
	  (setq queries (substring queries 1)))

      (if (string-match "^!" queries)
	  (nsql-execute-shell-command)
	(let(
	     (temporary (n-host-to-canonical (concat n-local-tmp "query")))
	     )
	  (if (eq arg t)
	      (delete-region (point-min) (point-max)))

	  ;;(setq queries (nstr-replace-regexp queries "^[ \t]*go[ \t]*$" ""))
	  ;;(setq queries (nstr-replace-regexp queries ";[ \t]*$" ""))
	  ;;(setq queries (nstr-replace-regexp queries "\n" " "))

	  (setq queries (nstr-trim queries))
	  (if (string= "" queries)
	      (setq queries (buffer-substring-no-properties (point-min) (point-max))))

	  (set-buffer (find-file-noselect temporary))
	  (delete-region (point-min) (point-max))
	  (insert queries)
	  (require 'n-prune-buf)
	  (n-prune-buf "^#")
	  (n-prune-buf "^[ \t]*$")
	  (save-buffer)
	  (kill-buffer (current-buffer))
	  (n-file-find (concat n-local-tmp "midnight.sql"))
	  (delete-region (point-min) (point-max))
	  (insert "sh $dp/bin/interactive_sql.sh")
	  (insert " " temporary)
	  (if silentMode
	      (insert " silentMode"))
	  (nsql-log queries)
	  )
	(insert "\n")
	(nmidnight-compile)
	(setq nsql-columnNames nil)
	)

      (other-window 1)
      (nsql-advance-to-the-next-sql)
      )
    )
  )

(defun nsql-get-keys(tableName)
  (cond
   ((string= tableName "albr_organization_br")		(list "br_instance_id"))
   ((string= tableName "alco_background_process")	(list "bkg_process_name"))
   ((string= tableName "alco_user")			(list "user_login"))
   ((string= tableName "alwf_appl_parameters")		(list "parm_name"))
   (t
    (if (not (boundp 'nsql-tables-to-keys))
	(n-load (concat "data/nsql-" (getenv "extprj") "-tables-to-keys"))
      )
    (let(
	 (value (assoc tableName nsql-tables-to-keys))
	 )
      (if value
	  (cdr value))
      )
    )
   )
  )

(defun nsql-qualify-query-for-update-or-deletion--add-clause(query whereClauseAdded value columnName)
  ;;(nelisp-bp "nsql-qualify-query-for-update-or-deletion--add-clause" (concat "/" value "/") 167)
  (cond
   ((string= value "")
    (setq value "NULL")
    )
   ((and (not (string-match "^-?[0-9\\.]+$" value))
	 (not (string-match "^['\"].*['\"]$" value))
	 )
    (setq value (concat "'" value "'"))
    )
   )
  (concat query
	  (if whereClauseAdded " and " " ")
	  columnName "=" value)
  )
(defun nsql-qualify-query-for-update-or-deletion()
  (save-excursion
    (save-restriction
      (widen)
      (let(
	   (columnNames (nsql-set-columnNames))
	   values
	   (line (if nsql-update-line nsql-update-line (n-get-line)))
	   (query (concat "select * from " (nsql-get-table-name)))
	   (keyColumns (nsql-get-keys (nsql-get-table-name)))
	   whereClauseAdded
	   )
	(setq values (nsql-split-into-values line
					     (if (string-match "|" line) "|" nsql-separator)
					     )
	      query (nstr-replace-regexp query (concat (format "%c" 13) "$") "")
	      )
	(if (not (string-match " where " query))
	    (setq query (concat query " where"))
	  (setq query (nstr-replace-regexp query " where .*" " where "))
	  )
	(if (not keyColumns)
	    (setq query (nsql-qualify-query-for-update-or-deletion--add-clause query
									       nil
									       (car values)
									       (car columnNames)
									       )
		  )
	  (while (and keyColumns columnNames)
	    (let(
		 (value (car values))
		 (columnName (car columnNames))
		 )
	      (if (nsql-column-member columnName keyColumns)
		  (progn
		    (setq query (nsql-qualify-query-for-update-or-deletion--add-clause query
										       whereClauseAdded
										       value
										       columnName))
		    (setq whereClauseAdded t)
		    (delete columnName keyColumns)
		    )
		)
	      )
	    (setq columnNames (cdr columnNames))
	    (setq values (cdr values))
	    )
	  )
	query
	)
      )
    )
  )
(defun nsql-delete( &optional arg)
  "delete the current row from the database"
  (interactive "P")
  (setq nsql-update-line nil)

  (cond
   ((and
     (not arg)
     (save-excursion
       (forward-line 0)
       (looking-at (concat ".*" nsql-separator))
       )
     (y-or-n-p "delete from database? ")
     )
    (nsql-delete-line)
    )
   ((not arg)
    (nsimple-kill-line arg)
    )
   (t
    (while (and (progn
		  (forward-line 0)
		  (not (looking-at "[ \t]*$"))
		  )
		(nsql-delete-line)
		)
      )
    )
   )
  )
(defun nsql-execute()
  (nsimple-copy-region-as-kill (point-min) (point-max))
  (let(
       (trace (find-file-noselect (nsql-log-fn)))
       (input (buffer-substring-no-properties (point-min) (point-max)))
       )
    (nsql-log input)

    (save-buffer)

    (message "Executing %s" input)
    (call-process-region (point-min) (point-max) (nshell-get-explicit-shell-file-name) t trace t "ex_isql")

    (save-window-excursion
      (set-buffer trace)

      (save-excursion
	(forward-word -1)
	(message (n-get-line))
	)
      )
    )
  )

(defun nsql-delete-line()
  (save-window-excursion
    (save-restriction
      (delete-region (progn
		       (forward-line 0)
		       (point)
		       )
		     (progn
		       (n-s "[^/]" t)
		       (forward-char -1)
		       (point)
		       )
		     )
      (require 'n-2-lines)
      (n-2-lines-vanilla)

      (save-excursion
	(forward-line -1)
	(insert "//")
	)

      (narrow-to-region (progn
			  (forward-line 0)
			  (point)
			  )
			(progn
			  (forward-line 1)
			  (point)
			  )
			)
      (if nsql-break-point-mode
	  (nelisp-bp "nsql-delete-line" "nsql.el: before ex_exportFilter" 307))
      (call-process-region (point-min) (point-max) (nshell-get-explicit-shell-file-name) t t t "ex_exportFilter")
      (if nsql-break-point-mode
	  (nelisp-bp "nsql-delete-line" "nsql.el: after ex_exportFilter" 307))
      (goto-char (point-min))
      (let(
	   (deletion (nsql-qualify-query-for-update-or-deletion))
	   )
	(delete-region (point-min) (point-max))
	(insert deletion)
	)
      (goto-char (point-min))
      (replace-regexp "select.*from" "delete")
      (nsql-execute)
      )
    )
  )
(defun nsql-get-table-name(&optional fn)
  (if (not fn)
      (setq fn (n-host-to-canonical (buffer-file-name))))
  (cond
   ((string-match "/\\([^/]+\\)\\.txt" fn)
    (let(
         (name    (n--pat 1 (buffer-file-name)))
         )
      (if (string-match "/pso/" fn)
          (setq name (concat "al" name)))

      (if (not (string= name "aler_pso"))
          (setq name (nstr-replace-regexp name "_pso$" "")))
      (if (and
           (string-match "^alct_" name)
           (not (string-match "settings$" name))
           (not (string-match "set$" name))
           (not (string-match "url$" name))
           )
          (setq name "alct_control_defn"))
      name
      )
    )
   ((save-restriction
      (widen)
      (save-excursion
	(goto-char (point-min))
        (n-s "select.*from[ \t]+\\([a-zA-Z_0-9]+\\)")
        )
      )
    (n--pat 1)
    )
   (t
    (error "nsql-get-table-name: you should be doing mc-z in java mode to get  njava-goto-corresponding-db-table()")
    (nfn-prefix fn)
    )
   )
  )

(defun nsql-insert(multipleLines)
  (if (not multipleLines)
      (nsql-insert-line)
    (let(
	 cmd
	 done
	 )
      (message "insert rows into the database? (y/n/a-ll)")
      (setq cmd (read-char))
      (if (eq cmd ?n)
	  (error "nsql-insert: "))
      (while (not done)
	(forward-line 0)
	(if (not (eq cmd ?a))
	    (if (looking-at "[ \t]*$")
		(setq done t))
	  (while (and (not done)
		      (or (looking-at "^[ \t]*$")
			  (looking-at "^//")
			  )
		      )
	    (forward-line 1)
	    (end-of-line)
	    (if (eobp)
		(setq done t)
	      (forward-line 0)
	      )
	    )
	  )
	(if (not done)
	    (nsql-insert-line))
	)
      )
    )
  )
(defun nsql-insert-line()
  (save-excursion
    (forward-line 0)
    (if (looking-at "//")
	(delete-char 2))
    )

  (save-window-excursion
    (save-restriction
      (let(
	   (line (n-get-line))
	   )
	(forward-line 1)
	(insert line "\n")
	(forward-line -1)
	)
      (narrow-to-region (progn
			  (forward-line 0)
			  (point)
			  )
			(progn
			  (forward-line 1)
			  (point)
			  )
			)
      (if nsql-break-point-mode
	  (nelisp-bp "nsql-insert-line" "nsql.el: before ex_exportFilter" 376))
      (call-process-region (point-min) (point-max) (nshell-get-explicit-shell-file-name) t t t "ex_exportFilter")
      (if nsql-break-point-mode
	  (nelisp-bp "nsql-insert-line" "nsql.el: before ex_importFilter" 377))
      (call-process-region (point-min) (point-max) (nshell-get-explicit-shell-file-name) t t t "ex_importFilter" (nsql-get-table-name))
      (if nsql-break-point-mode
	  (nelisp-bp "nsql-insert-line" "nsql.el: after ex_importFilter" 377))
      (nsql-execute)
      (goto-char (point-max))
      t
      )
    )
  )
(defun nsql-loc-pop()
  "nsql wrapper for the location popper"
  (interactive)
  (setq nsql-update-line nil)
  (n-loc-pop)
  )
(defun nsql-get-col-text(&optional srcColName)
  (if srcColName
      (nsql-goto-col-by-name srcColName))
  (save-restriction
    (n-narrow-to-line)
    (let(
	 (begin (point))
	 (end (progn
		(if (n-s nsql-separator)
		    (forward-char -1)
		  (end-of-line)
		  )
		(point)
		)
	      )
	 )
      (buffer-substring-no-properties  begin end)
      )       
    )
  )

(defun nsql-set-col-text(srcColName val)
  (if srcColName
      (nsql-goto-col-by-name srcColName))
  (save-restriction
    (n-narrow-to-line)
    (let(
	 (begin (point))
	 (end (progn
		(if (n-s nsql-separator)
		    (forward-char -1)
		  (end-of-line)
		  )
		(point)
		)
	      )
	 )
      (delete-region begin end)
      (insert val)
      )       
    )
  )

(defun nsql-delete-column-text(&optional saveToKill)
  (save-restriction
    (n-narrow-to-line)
    (let(
	 (begin (point))
	 (end (progn
		(if (n-s nsql-separator)
		    (forward-char -1)
		  (end-of-line)
		  )
		(point)
		)
	      )
	 )
      (if saveToKill
	  (kill-region begin end)
	(delete-region begin end)
	)       
      )       
    )
  )
(defun nsql-goto-col(col)
  (forward-line 0)
  (while (and (not (= col (nsql-what-col)))
	      (not (looking-at "$"))
	      )
    (nsql-forward-word)
    )
  (= col (nsql-what-col))
  )
(defun nsql-goto-col-by-name(colName)
  (forward-line 0)
  (while (and (not (string= colName (nsql-what-col-name)))
	      (not (looking-at "$"))
	      )
    (nsql-forward-word)
    )
  (string= colName (nsql-what-col-name))
  )
(defun nsql-kill-word( &optional arg)
  "kill a word; with optional ARGUMENT non-nil, kill all text for the current column"
  (interactive "P")
  (if (not arg)
      (nsimple-kill-word 1)
    (nsql-delete-column-text t)
    )
  )

(defun nsql-loc-push(&optional arg)
  "nsql wrapper for the location pusher"
  (interactive "P")
  (if (not arg)
      (progn
	(setq nsql-update-line (n-get-line))
	(n-loc-push)
	)
    (message "d-elete column, p-ush columns")
    (setq arg (read-char))
    
    (cond
     ((= arg ?p)
      (nsql-push-all-of-a-particular-column)
      )
     ((= arg ?d)
      (n-loc-clear)
      (let(
	   (del	(y-or-n-p "delete column's contents? "))
	   (col	(nsql-what-col))
	   )
	(goto-char (point-min))
	(while (not (eobp))
	  (nsql-goto-col col)
	  (if del
	      (nsql-delete-column-text))
	  (n-loc-push)
	  (forward-line 1)
	  (end-of-line)
	  )
	(n-loc-reverse)
	(n-loc-pop)
	)
      )
     )
    )
  )

(defun nsql-delete-region-cmd( &optional arg)
  (interactive "P")
  (if arg
      (call-interactively 'nsql-delete-region)
    (call-interactively 'kill-region)
    )
  )

(defun nsql-delete-region(&optional beg end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (let(
	   (keycol (progn
		     (goto-char (point-min))
		     (nsql-where-am-i)
		     )
		   )
	   (id1 (n-grab-number))
	   (id2 (progn
		  (goto-char (point-max))
		  (forward-word -1) ;; just in case there's an empty line at the EOF
		  (forward-line 0)
		  (n-grab-number)
		  )
		)
	   sql
	   )
	(setq sql (format "delete %s where (%s >= %d) and (%s <= %d)" 
			  (nsql-get-table-name)
			  keycol
			  id1
			  keycol
			  id2
			  )
	      )
	(if (y-or-n-p (format "%s? " sql))
	    (save-restriction
	      (narrow-to-region (point) (point))
	      (insert sql)
	      (nsql-execute)
	      )
	  )
	)
      )
    )
  )

(defun nsql-silly-fixup()
  ;; goes to hell if we are on last line w/ no newline -- add one if nec.n
  (save-excursion
    (end-of-line)
    (if (eobp)
	(insert "\n"))
    )
  )


(defun nsql-insert-or-update( &optional arg)
  "either insert the current row, or if a location in the current row was recently pushed (see nsql-loc-push), then just update the changed columns"
  (interactive "P")
  (nsql-silly-fixup)
  (let(
       (onData (save-excursion
		 (forward-line 0)
		 (looking-at (concat ".*" nsql-separator))
		 )
	       )
       )
    (cond
     ((and onData
	   (n-loc-on-current-line)
	   (nsql-update)
	   )
      (nsql-loc-pop)
      (n-next-line 1)
      (nsql-loc-push)
      t
      )
     ((and onData
	   (nsql-insert arg)
	   )
      (setq nsql-update-line nil)
      )
     (t
      (setq nsql-update-line nil)
      (insert "\n")
      )
     )
    )
  )
(defun nsql-update()
  (save-window-excursion
    (let(
	 (update (nsql-qualify-query-for-update-or-deletion))
	 (update-setting (nsql-update-make-setting))
	 )
      (setq update (nstr-replace-regexp update "select.*from" "update"))
      (setq update (nstr-replace-regexp update " where " (concat update-setting " where ")))
      (save-restriction
	(narrow-to-region (point) (point))
	(insert update)
	(nsql-execute)
	(goto-char (point-max))
	)
      (n-next-line 1)
      )
    t
    )
  )
(defun nsql-goto-baseline-query-output-cmd()
  (interactive)
  (nsql-goto-baseline-query-output (nsql-get-table-name) t)
  )

(defun nsql-get-baseline-query-output-fn(tableName)
  (nfn-clean (concat "$SQLOUT/sql_out/$extdb.$extdbserver.$extdbuser.$extdbtype"
		     "/"
		     (nstr-replace-regexp tableName "^al" "")
		     ".txt"
		     )
	     )
  )

(defun nsql-goto-baseline-query-output(&optional tn evenIfItDoesntExist)
  (if (not tn)
      (setq tn	(nsql-get-table-name)))

  (let(
       fn
       )
    (or tn (error "nsql-goto-baseline-query-output: "))
    (setq fn (nsql-get-baseline-query-output-fn tn))
    (if (or evenIfItDoesntExist
	    (and (file-exists-p fn)
		 (not (string= fn
			       (n-host-to-canonical (buffer-file-name))
			       )
		      )
		 )
	    )
	(progn
          (nelisp-bp "nsql-goto-baseline-query-output" "nsql.el" 841);;;;;;;;;;;;;;;;;
	  (if (not (file-exists-p (file-name-directory fn)))
	      (n-file-md-p (file-name-directory fn)))
	  (n-file-find fn)
	  )
      )
    )
  )
(defun nsql-patch-up-truncated-names(table perhapsTruncatedNames)
  (let(
       name
       names
       perhapsTruncatedColumnName
       )
    (while perhapsTruncatedNames
      (setq perhapsTruncatedColumnName (car perhapsTruncatedNames)
	    perhapsTruncatedNames      (cdr perhapsTruncatedNames)
	    name (cond
		  ((and
		    (string= table "alcc_sic_code")
		    (string= perhapsTruncatedColumnName "SIC_")
		    )
		   "sic_code"
		   )
		  (t perhapsTruncatedColumnName)
		  )
	    name (nstr-downcase name)
	    names (cons name names)
	    )
      )
    (nreverse names)
    )
  )

(defun nsql-get-column-names()
  (save-window-excursion
    (let(
	 pushed
	 )
      (condition-case nil
	  (progn
	    (if (string-match "/\\([^/]+\\)\\.txt$" (n-host-to-canonical (buffer-file-name)))
		(progn
		  (setq pushed (nsql-goto-baseline-query-output))
		  )
	      )
	    (prog1
		(save-excursion
		  (widen)
		  (goto-char (point-min))
		  (if (n-s nsql-separator)
		      (nsql-patch-up-truncated-names (nsql-get-table-name)
						     (nsql-split-into-values (n-get-line))
						     )
		    )
		  )		 
	      (if pushed
		  (n-file-pop))
	      )
	    )
	(error nil)
	)
      )
    )
  )

(defun nsql-data-type-is-char(table columnIndex)
  (let(
       (x (eval (intern-soft (concat "nsql-char-data-type-vector-" table))))
       )
    (if (or (not x) 
	    (<= (length x) columnIndex)
	    )
	nil
      (elt x columnIndex)
      )
    )
  )

(defun nsql-package-literal(columnIndex value)
  (cond
   ((or
     (not value)
     (string= value "")
     )
    (setq value "NULL")
    )
   ((string= value "NULL")
					; no-op
    )
   ((or (not (string-match "^[-0-9\\.]+$" value))
	(nsql-data-type-is-char (nsql-get-table-name) columnIndex)
	)
    (if (not (string-match "^['\"].*['\"]$" value))
	;; double quotes for SQL's digestion
	(setq value (nstr-replace-regexp value "'" "''") 
	      value (concat "'" value "'")
	      )
      )
    )
   )
  value
  )

(defun nsql-update-make-setting()
  (save-excursion
    (let(
	 (values    (nsql-split-into-values (n-get-line)     ))
	 (oldValues (nsql-split-into-values nsql-update-line ))
	 setting
	 (columnIndex 0)
	 (columnNames (nsql-set-columnNames))
	 )
      (while columnNames
	(let(
	     (value    (car values))
	     (oldvalue (car oldValues))
	     s
	     )
	  (setq s	       (concat "'" value "'=='" oldvalue "'?"))
	  ;;(n-trace (concat "nsql-update-make-setting: " s))
	  (if (not (string= value oldvalue))
	      (progn
		(if setting
		    (setq setting (concat setting ","))
		  (setq setting " set")
		  )
		(setq setting (concat setting " " (car columnNames) "=" (nsql-package-literal columnIndex value)))
		)
	    )
	  (setq columnNames (cdr columnNames)
		values      (cdr values)
		oldValues   (cdr oldValues)
		columnIndex (1+ columnIndex)
		)
	  )
	)
      (if (not setting)
	  (error "nsql-update-make-setting: no changes"))
      (nstr-replace-regexp setting "\\\\" "\\\\\\\\") ; double backslashes
      )
    )
  )
(defun nsql-2-lines-extrapolate-arithmetic-patterns()
  (save-restriction
    (widen)
    (forward-line 0)
    (let(
	 current
	 newCurrent
	 parent
	 grandparent
	 bigNumberPrefix
	 interveningZeros
	 )
      (setq parent (save-excursion
		     (forward-line -1)
		     (nsql-split-into-values (n-get-line))
		     )
	    grandparent (save-excursion
			  (forward-line -2)
			  (nsql-split-into-values (n-get-line))
			  )
	    current (nsql-split-into-values (n-get-line) nsql-separator t)
	    )
      (setq parentID (car parent)
	    grandparentID (car grandparent)
	    currentID (car current)
	    )
      
      (cond
       ((string-match "^[0-9]+$" parentID)
	;;  if the parent is over 100,000,000, then ignore the initial 5 digits to avoid overflow;
	;;	just increment by 1 to simplify the problem
	(cond
	 ((string-match "^\\([0-9][0-9][0-9][0-9][0-9]\\)\\(0*\\)\\([1-9][0-9][0-9][0-9]+\\)" parentID)
	  (setq increment 1
		bigNumberPrefix (n--pat 1 parentID)
		interveningZeros (n--pat 2 parentID)
		parentID        (n--pat 3 parentID)
		parentID    (string-to-int parentID)
		)
	  )
	 (grandparentID
	  (setq parentID (string-to-int parentID)
		grandparentID (string-to-int grandparentID)
		increment (- parentID grandparentID)
		)
	  (if (or (= increment 0) (= 13 grandparentID))
	      (setq increment 1))
	  )
	 (t
	  (setq parentID (string-to-int parentID)
		increment 1
		)
	  )
	 )
	(setq currentID (if (not bigNumberPrefix)
			    (format "%d" (1+ (string-to-int currentID)))
			  (if (not interveningZeros)
			      (setq interveningZeros ""))
			  (format "%s%s%d"bigNumberPrefix 
				  interveningZeros
				  (1+ parentID)
				  )
			  )
	      )
	)
       )
      (setq newCurrent (append (list currentID) (cdr current)))
      
      (forward-line 0)
      (delete-region (point)
		     (progn
		       (end-of-line)
		       (point)
		       )
		     )
      (setq newCurrent (nstr-join newCurrent nsql-separator))
      
      (setq newCurrent (nstr-replace-regexp newCurrent "^NULL" "")
	    newCurrent (nstr-replace-regexp newCurrent "NULL$" "")
	    newCurrent (nstr-replace-regexp newCurrent "|NULL|" "||")
	    newCurrent (nstr-replace-regexp newCurrent "|NULL|" "||") ;; again to get consecutives
	    )
      
      (insert newCurrent)
      )
    )
  )

(defun nsql-2-lines( &optional arg)
  "duplicate the current row"
  (interactive "p")
  (save-restriction
    (require 'n-2-lines)
    (n-2-lines arg t)

    (save-excursion
      (goto-char (point-min))
      (require 'nbig)
      (if (looking-at "[0-9]")
	  (let(
	       (n (nbig-grab))
	       )
	    (setq n (nbig-add n 1))
	    (delete-region (point) (progn
				     (n-s "[^0-9]" t)
				     (forward-char -1)
				     (point)
				     )
			   )
	    (insert (nbig-get n))
	    )
	)
      (widen)
      )
    )
  )

(defun nsql-what-col()
  (save-excursion
    (save-restriction
      (narrow-to-region (point)
			(progn
			  (forward-line 0)
			  (point)
			  )
			)
      (let(
	   (col 0)
	   )
	(while (n-s nsql-separator)
	  (setq col (1+ col))
	  )
	col
	)

      )
    )
  )

(defun nsql-what-col-name(&optional colNumber)
  (if (not colNumber)
      (setq colNumber (nsql-what-col)))
  ;;(if (not nsql-columnNames)		;; somehow nsql-columnNames was getting corrupted, so now I always regenerate
  (nsql-set-columnNames)
  ;;)

  (setq name 	     (if nsql-columnNames
			 (elt nsql-columnNames colNumber)
		       "(column name not available)"
		       )
	)
  )



(defun nsql-where-am-i()
  "tell me what column point is on"
  (interactive)
  (let(
       (name (nsql-what-col-name))
       cmt
       )
    (setq cmtCons (assoc (concat (nsql-get-table-name) "." name)
			 (n-database-load "n-data-extensity-dd")
			 )
	  cmt	(if cmtCons (concat ": " (cdr cmtCons)) "")
	  )
    (save-window-excursion
      (if (get-buffer "*Messages*")
	  (progn
	    (set-buffer (get-buffer "*Messages*"))
	    (delete-region (point-min) (point-max))
	    )
	)
      )
    (message "%s %s%s"
	     (n-what-line-make-string)
	     name
	     cmt
	     )
    )
  )

(defun nsql-at-beginning-of-column()
  (or (eq (point) (save-excursion
		    (forward-line 0)
		    (point)
		    )
	  )
      (progn
	(forward-char -1)
	(prog1
	    (looking-at nsql-separator)
	  (forward-char 1)
	  )
	)
      )
  )
(defun nsql-forward-word( &optional arg)
  "advance one column's width"
  (interactive "P")
  (cond
   (arg
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (switch-to-buffer "*Messages*")
    (other-window 1)
    )
   ((nsql-at-beginning-of-column)
    (if (not (n-s nsql-separator))
	(forward-word 1))
    )
   (t
    (forward-word 1)
    )
   )
  (nsql-where-am-i)
  )
(defun nsql-backward-word()
  "go backwards one word; tell me what column point is on"
  (interactive)
  (forward-word -1)
  (nsql-where-am-i)
  )
(defun nsql-find-duplicate-key()
  (interactive)
  (let(
       duplicate
       (data (buffer-substring-no-properties (point-min) (point-max)))
       )
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data)
      (require 'n-prune-buf)
      (n-prune-buf-v nsql-separator)
      
      (goto-char (point-min))
      (replace-regexp (concat nsql-separator ".*") "")
      
      (nsort-buf)
      (goto-char (point-min))
      (forward-line 1)
      (while (not (eobp))
	(if (string= (n-get-line)
		     (save-excursion
		       (forward-line -1)
		       (n-get-line)
		       )
		     )
	    (progn
	      (setq duplicate (n-get-line))
	      (goto-char (point-max))
	      )
	  )
	
	(end-of-line)
	(if (not (eobp))
	    (forward-char 1))
	)
      (delete-region (point-min) (point-max))
      )
    
    (if (not duplicate)
	(message "cannot find duplicate key")
      (goto-char (point-min))
      (n-s (concat "^" duplicate nsql-separator) t)
      (message "%s is a duplicate key" duplicate)
      )
    )
  )
(defun nsql-get-current-table-contents()
  "replace the current buffer contents with the contents of the table in the database"
  (interactive)
  (if (nsql-get-table-name)
      (let(
	   (table  (nsql-get-table-name))
	   (q (concat "select * from " (nsql-get-table-name)))
	   (qf (n-host-to-canonical n-local-tmp))
	   )
	(if (nbuf-read-only-p)
	    (n-file-toggle-read-onlyness))
	(widen)
	(delete-region (point-min) (point-max))
	(insert q "\n")
	(message "querying %s..." table)
	(call-process-region (point-min) (1- (point-max)) (nshell-get-explicit-shell-file-name) nil t nil "ex_isql" "keepheader")

	(goto-char (point-max))
	(if (n-r "|")
	    (progn
	      (forward-line 1)
	      (delete-region (point) (point-max))
	      )
	  )

	(if (not (string= nsql-separator "|"))
	    (progn
	      (goto-char (point-min))
	      (replace-regexp "|" nsql-separator)
	      )
	  )

	(message "Done.")
	)
    (nmidnight-compile)
    (setq nsql-columnNames nil)
    )
  )

(defun nsql-push-all-of-a-particular-column()
  (if (y-or-n-p "push all the instances of the current column? ")
      (let(
	   (col (nsql-what-col))
	   )
	(goto-char (point-max))
	(forward-line 0)

	(while (not (bobp))
	  (save-restriction
	    (n-narrow-to-line)
	    (if (nsql-goto-col col)
		(n-loc-push))
	    )
	  (forward-line -1)
	  )
	)
    )
  )
(defun nsql-bad-foreign-key-cmd()
  (interactive)
  (let(
       tableToBeAltered
       colFrom
       colTo
       tableReferredTo
       query
       )
    (or (progn
	  (n-s "[ \t]*REFERENCES" t)
	  (prog1
	      (n-r "ALTER TABLE" t)
	    (forward-word 2)
	    )
	  )
	(error "nsql-bad-foreign-key: can't find s.t.")
	)
    (or (looking-at " *\\([0-9a-zA-Z_]+\\)")
	(error "nsql-bad-foreign-key: cannot find tableToBeAltered")
	)
    (setq tableToBeAltered (n--pat 1))

    (or (n-s "FOREIGN KEY (\\([0-9a-zA-Z_]+\\))")
	(error "nsql-bad-foreign-key: cannot find colFrom")
	)
    (setq colFrom (n--pat 1))

    (or (n-s "[ \t]*REFERENCES \\([0-9a-zA-Z_]+\\)")
	(error "nsql-bad-foreign-key: cannot find tableReferredTo")
	)
    (setq tableReferredTo (n--pat 1))

    (setq colTo (cond
		 ((save-excursion
		    (n-r "REFERENCES" t)
		    (n-s "REFERENCES [0-9a-zA-Z_]+(\\([0-9a-zA-Z_]+\\))")
		    )
 		  (n--pat 1)
		  )
		 ((n-s "conflict occurred in database '[^']+', table '\\([0-9a-zA-Z_]+\\)', column '\\([0-9a-zA-Z_]+\\)'.")
		  (n--pat 2)
		  )
		 (t
		  colFrom
		  )
		 )
	  )

    (nsql-bad-foreign-key tableReferredTo
			  tableToBeAltered
			  colFrom
			  colTo
			  )
    )
  )
;;(nsql-bad-foreign-key "albr_template" "albr_defn" "template_id")
;;(nsql-bad-foreign-key "alwf_activity" "alwf_wi_history" "activity_id")
;;(nsql-bad-foreign-key "alwf_activity" "alwf_notification_setup" "activity_id")
;;(nsql-bad-foreign-key "alwf_activity" "alwf_work_item" "activity_id")
(defun nsql-bad-foreign-key(tableReferredTo tableToBeAltered colFrom &optional colTo)
  (if (not colTo)
      (setq colTo colFrom))
  (let(
       (query (format "select distinct %s from %s where %s not in (select %s from %s)"
		      colFrom
		      tableToBeAltered
		      colFrom
		      colTo
		      tableReferredTo
		      )
	      )
       )
    (save-restriction
      (narrow-to-region (point) (point))
      (insert query)
      (nsql-execute)
      (delete-region (point-min) (point-max))
      )
    (nsql-goto-log)
    )
  )
(defun nsql-grab-query-output(name)
  (let(
       (fn (nsql-get-baseline-query-output-fn name))
       )
    ;;(if (not (file-exists-p (file-name-directory fn)))
    ;;(n-file-md-p  (file-name-directory fn)))

    (if (file-exists-p (file-name-directory fn))
        (progn
          (setq name (nstr-replace-regexp name "^al" ""))
          (cond
           ((n-file-exists-p name)
            name
            )
           ((n-file-exists-p fn)
            fn
            )
           ((save-window-excursion
              (n-file-find "$NELSON_BIN/can/tables.sql")
              (save-excursion
                (goto-char (point-min))
                (prog1
                    (n-s (concat " al" name "$"))
                  (bury-buffer)
                  )
                )
              )
            (set-buffer (find-file-noselect fn))
            (nsql-get-current-table-contents)
            fn
            )
           )
          )
      )
    )
  )
(defun nsql-drop-constraint( &optional arg)
  (interactive "P")
  (if arg
      (nsql-drop-all-constraints)
    (let(
	 constraint
	 table
	 )
      (or (looking-at ".*constraint '*\\([0-9a-zA-Z_]+\\)")
	  (error "nsql-drop-constraint: no constraint")
	  )
      (setq constraint (n--pat 1))
      
      (or (n-s ", table '\\([0-9a-zA-Z_]+\\)")
	  (error "nsql-drop-constraint: no table")
	  )
      (setq table (n--pat 1))
      (setq query (format "alter table %s drop constraint %s" table constraint))
      (save-restriction
	(narrow-to-region (point) (point))
	(insert query)
	(nsql-execute)
	(delete-region (point-min) (point-max))
	)
      (switch-to-buffer (get-buffer-create "sql"))
      )
    )
  )
(defun nsql-delete-all-rows()
  (interactive)
  (let(
       (table (n-grab-token))
       )
    (if (y-or-n-p (format "delete all rows in %s? " table))
	(save-restriction
	  (setq query (format "delete %s" table))
	  (narrow-to-region (point) (point))
	  (insert query)
	  (nsql-execute)
	  (delete-region (point-min) (point-max))
	  )
      )
    )
  )
(defun nsql-drop-all-constraints()
  (let(
       (table (n-grab-token))
       )
    (error "nsql-drop-all-constraints: not implemented")    
    )
  )
(defun nsql-find-where-rule-data()
  (widen)
  (n-narrow-to-line)
  (forward-line 0)
  
  (let(
       (defnId	(n-grab-token))
       instanceId
       (templateId (nsql-get-col-text "template_id"))
       )
    (if (not (string= templateId ""))
	(progn
	  (find-file "br_template.txt")
	  (widen)
	  (goto-char (point-min))
	  (if (not (n-s (concat "^" templateId "|")))
	      (progn
		(find-file "br_template_pso.txt")
		(widen)
		(goto-char (point-min))
		)
	    )
	  (forward-line 0)
	  (n-narrow-to-line)
	  )
      )
    
    (find-file "br_instance.txt")
    (widen)
    (goto-char (point-min))    
    (n-s (concat "^\\(-?[0-9]+\\)|" defnId "|") t)
    (setq instanceId (concat "|"
			     (n--pat 1)
			     "|"
			     )
	  )
    (n-narrow-to-line)
    (forward-line 0)
    
    (find-file "br_parameter.txt")
    (widen)
    (narrow-to-region 
     (progn
       (goto-char (point-min))
       (n-s instanceId t)
       (forward-line 0)
       (point)
       )
     (progn
       (goto-char (point-max))
       (n-r instanceId t)
       (end-of-line)
       (point)
       )
     )
    )
  )
(defun nsql-find-where( &optional arg)
  (interactive "P")
  (if (and arg
	   (y-or-n-p "edit key database harvesting script? ")
	   (progn
	     (n-file-find "$NELSON_BIN/ex_keys_harvest.pl")
	     (recursive-edit)
	     (n-env-load-table-info t)
	     )
	   )
      t
    (let(
	 (val	(n-grab-token))
	 (col	(nstr-downcase (nsql-what-col-name)))
	 (table	(nsql-get-table-name))
	 foreign-keys-to-tables
	 ftable
	 )
      (if (not (boundp 'nsql-tables-to-foreign-keys-to-tables))
	  (n-load (concat "data/nsql-" (getenv "extprj") "-tables-to-foreign-keys-to-tables")))
      (setq foreign-keys-to-tables (cdr (assoc table nsql-tables-to-foreign-keys-to-tables)))
      (setq ftable                 (cdr (assoc col   foreign-keys-to-tables)))
      (cond
       ((and
	 (string=  table "albr_defn")
	 (string=  (nsql-what-col-name) "rule_defn_id")
	 )
	(nsql-find-where-rule-data)
	)
       ((string= val "")
	(n-file-find "$ext/largesoft/install/V0/CreateAtLarge.mssql")
	(goto-char (point-min))
	(n-s (concat "\\b" table "\\b") t)
	)     
       ((and (not ftable)
	     (string= table "alwf_work_item")
	     (string= col "business_object_id")
	     )
	(setq ftable "aler_expense_report")
	(nsql-goto-table-file ftable val)
	)
       ((not ftable)
	(ntags-find-where)
	)
       (t
	(nsql-goto-table-file ftable val)
	)
       )
      )
    )
  )

(defun nsql-goto-table-file(table &optional valueToSearchFor)
  (n-loc-push)
  (let(
       (fn (nstr-replace-regexp table "^al\\(.*\\)" "\\1.txt"))
       )
    (setq fn (concat default-directory fn))
    
    (if (and
	 (not (file-exists-p fn))
	 (string-match "/[vV][0-9\\.]+/data/.*/" fn)
	 )
	(setq fn (nstr-replace-regexp fn "/pso/[^/]+/[vV][0-9b\\.]+/data/[^/]+/" "/largesoft/install/V0/data/default/"))
      )
    (if (not (file-exists-p fn))
	(progn
	  (find-file fn)
	  (nsql-get-current-table-contents)
	  )
      ) 
    
    (find-file fn)
    (widen)
    (if valueToSearchFor
	(progn
	  (setq valueToSearchFor (nstr-replace-regexp valueToSearchFor "//.*" ""))
	  (goto-char (point-min))
	  ;; first only look at the left justified IDs, which are usually the primary keys
	  (if (not (n-s (concat "^" valueToSearchFor "\\b")))
	      (n-s (concat "\\b" valueToSearchFor "\\b")
		   t
		   )
	    )
	  )
      )
    )
  )
(defun nsql-column-member(columnName keyColumns)
  (nstr-case-insensitive-member columnName keyColumns)
  )
(defun nsql-log-fn()
  (nfn-clean "$dp/data/log.sql.$extdb.$extdbserver.$extdbtype" )
  )


(setq nsql-goto-log-raw-mode (n-database-get "nsql-goto-log-raw-mode")
      nsql-goto-log-raw-mode (and nsql-goto-log-raw-mode
				  (string= nsql-goto-log-raw-mode "t")
				  )
      )

(defun nsql-goto-log( &optional arg)
  (interactive "P")
  (if arg
      (progn
	(setq nsql-goto-log-raw-mode (not nsql-goto-log-raw-mode))
	(n-database-set "nsql-goto-log-raw-mode" 
			(if nsql-goto-log-raw-mode "t" "nil")
			)
	)
    )
  (find-file (concat (nsql-log-fn)
		     (if nsql-goto-log-raw-mode ".raw" "")
		     )
	     )
  (goto-char (point-max))
  )
(defun nsql-log(query)
  (save-window-excursion
    (let(
	 (nsql-goto-log-raw-mode nil)
	 )
      (nsql-goto-log)
      (goto-char (point-max))
      (insert query "\n")
      ;;(insert "\n" (current-time-string) "\n" query "\n")
      (bury-buffer)
      )
    ) 
  )
(defun nsql-reload(quick)
  (nsql-goto-log)
  (nbuf-kill-current)
  
  (nmidnight-ext-run (concat "ex_load " quick))
  )
(defun nsql-compress-output()
  (interactive)
  (message "removing extra white space...")
  
  (require 'n-prune-buf)
  (n-prune-buf "^//")
  
  (goto-char (point-min))
  (replace-regexp "//[^|]*" "")
  
  (goto-char (point-min))
  (replace-regexp "[ \t]*|[ \t]*" "|")
  
  (goto-char (point-min))
  (replace-regexp "[ \t]+$" "")
  
  (goto-char (point-min))
  (replace-regexp "^[ \t]+" "")
  
  (message "Done.")
  )

(defun nsql-goto-table-controller-entry(&optional table activate)
  (interactive)
  (if (not table)
      (setq table (nsql-get-table-name))
    )
  (n-file-find "$ext/pso/$extdataset/V0/TableController.cfg")
  (goto-char (point-min))
  (if (n-s (concat "^" table))
      (forward-line 0)
    (goto-char (point-max))
    (insert table "=USE_DATA_FILE\n")
    (forward-line -1)
    (message "new entry")
    )
  (if activate
      (progn
	(forward-line 0)
	(if (looking-at "#")
	    (delete-char 1))
	)
    )
  )

(defun nsql-suppress-table-conversion()
  (interactive)
  (let(
       (table (nsql-get-table-name))
       )
    (if (not table)
	(setq table (n-grab-token)))
    (nsql-goto-table-controller-entry table t)
    
    (setq table (nstr-replace-regexp table "^al" ""))
    (n-host-shell-cmd (concat "touch $ext/pso/$extdataset/V0/Data/$extdataset/"
			      table
			      ".txt"
			      )
		      )
    )
  )
(defun nsql-split-into-values(line &optional separator dontTrimWhite dontInsertNULLs)
  (setq line (nstr-replace-regexp line "^[ \t]*//" ""))
  
  (if dontInsertNULLs
      (error "nsql-split-into-values: not working due to nstr-split: absorbs empty tokens"))
  
  (if (not separator)
      (setq separator nsql-separator))
  (if (and (not dontInsertNULLs)
	   (string-match (concat nsql-separator "$") line)
	   )
      (setq line (concat line "NULL"))
    )
  
  (if (not dontInsertNULLs)
      (progn
	;; run sub twice to catch the case "|||"
	(setq line (nstr-replace-regexp line
					(concat nsql-separator        nsql-separator)
					(concat nsql-separator "NULL" nsql-separator)
					)
	      )
	(setq line (nstr-replace-regexp line
					(concat nsql-separator        nsql-separator)
					(concat nsql-separator "NULL" nsql-separator)
					)
	      )
	)
    )
  
  (let(
       (values (nstr-split line separator (not dontTrimWhite)))
       clean
       )
    (while values
      (setq 
       clean1 (car values)
       clean1 (nstr-replace-regexp clean1 "//.*" "")
       clean (cons clean1 clean)
       values (cdr values)
       )
      )
    (nreverse clean)
    )
  )
(defun nsql-create-empty-import-file()
  (interactive)
  (let(
       (name (n-grab-token))
       )
    (setq name (nstr-replace-regexp name "^al" ""))
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (n-host-shell-cmd (format "touch $ext/pso/$extdataset/V0/Data/$extdataset/%s.txt"
			      name
			      )
		      )
    (n-host-shell-cmd (format "echo al%s=USE_DATA_FILE >> $ext/pso/$extdataset/V0/TableController.cfg"
			      name
			      )
		      )
    (other-window 1)
    )
  )
(defun nsql-configure-rule-sequence-change()
  (let(
       (ruleType (concat (nsql-get-col-text "br_event_id")
			 "|"
			 (nsql-get-col-text "bus_obj_type_id")
			 )
		 )
       (threshold "0")
       execution_seq
       (sql "")
       (change 1)
       )
    (read-string (format "Add %d to instances of type %s starting w/ rule sequence: " change ruleType)
		 threshold
		 )
    (setq threshold (string-to-int threshold))
    (save-excursion
      (goto-char (point-min))
      (while (n-s ruleType)
	(setq execution_seq (string-to-int
			     (nsql-get-col-text "execution_seq")
			     )
	      )
	(if (>= execution_seq threshold)
	    (progn
	      (setq execution_seq (+ change execution_seq)
		    sql (concat sql
				"update albr_instance set execution_seq=" 
				execution_seq
				" where br_instance_id="
				(nsql-get-col-text "br_instance_id")
				"\n"
				)
		    )
	      (nsql-set-col-text "execution_seq" (int-to-string execution_seq))
	      )
	  )
	)
      )
    (nstr-kill sql)
    (message "seq col updated -- update SQL in kill")
    )
  )
(defun nsql-configure()
  (interactive)
  (let(
       (cmd (progn
	      (message "g-enerate keys, q-uery subset, Q-uery all, r-ule operation")
	      (read-char)
	      ))
       )
    (cond
     ((= cmd ?g)
      (n-env-load-table-info t)
      )
     ((= cmd ?r)
      (setq cmd (progn
		  (message "m-igrate rule, s-equence change")
		  (read-char)
		  )
	    )
      (cond
       ((= cmd ?m)
	(forward-line 0)
	(next-migrate-rule)
	)
       ((= cmd ?s)
	(nsql-configure-rule-sequence-change)
	)
       )
      )
     ((= cmd ?q)
      (setq cmd (progn
		  (message "d-yn table query, m-t, q-uery unqueried, r-ule table query")
		  (read-char)
		  )
	    )
      (cond
       ((= cmd ?q)
	(n-env-query-all-tables t)
	)
       ((= cmd ?d)
	(n-env-query-dyn-tables)
	)
       ((= cmd ?m)
	(n-env-query-table "almt_extension")
	(n-env-query-table "almt_bob_type_list_member")
	(n-env-query-table "almt_bob_type")
	(n-env-query-table "almt_bob_tables")
	(n-env-query-table "almt_bob_elements")
	)
       ((= cmd ?r)
	(n-env-query-rule-tables)
	)
       )
      )
     ((= cmd ?Q)
      (n-env-query-all-tables nil)
      )

     )
    )
  )

