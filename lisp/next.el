(provide 'next)
;; This module helps in the creation of new rules.  It automatically allocates object IDs and updates the global core group Bob ID recordkeeping.  In general, it deposits you in each rule table in sequence; create a row which satisfies your needs, ignoring those columns which are dependent on previously defined tables.  Then this module will find the row or rows which lack primary keys; it assigns primary keys and updates other columns whose settings can be automatically determined.
;;
;;
(setq next-global-bobid_usage "$dev/docs/pso/Standard/coregroup_bobid_usage.txt")
(setq next-my-bobid_usage     "$dp/data/bobid_usage.txt")

(defun next-maybe-edit-bobids-file()
  (if (y-or-n-p "edit my bobids? ")
      (progn
	(n-file-find next-bobid_usage)
	(recursive-edit)
	)
    )
  )

(defun next-use-my-bobids()
  (save-window-excursion
    (setq next-bobid_usage next-my-bobid_usage)
    (next-maybe-edit-bobids-file)
    )
  )

(defun next-use-global-bobids()
  (save-window-excursion
    (setq next-bobid_usage next-global-bobid_usage)
    (n-file-find next-bobid_usage)
    (if (not (n-file-writable-p next-bobid_usage))
	(progn
	  (nsyb-cm "get")
	  (n-file-toggle-read-onlyness)
	  )
      )
    (next-maybe-edit-bobids-file)
    )
  )

(defun next-alloc-bobid(&optional table)
  (save-window-excursion
    (if (not table)
	(setq table (nsql-get-table-fn)))
    (n-file-find next-bobid_usage)
    (goto-char (point-max))
    (require 'nbig)
    (let(
	 (next-object-name	(n-database-get "next-object-name" t))
	 (global-coregroup-IDs	(string= next-bobid_usage next-global-bobid_usage))
	 next-universal-bobid
	 )
      (setq next-universal-bobid	(if (not global-coregroup-IDs)
					    (progn
					      (goto-char (point-max))
					      (forward-line -1)
					      (nbig-add (nbig-grab) 1)
					      )
					  (if (n-r (concat next-object-name
							   ".*nsproul"
							   )
						   )
					      (progn
						(forward-line 0)
						(nbig-add (nbig-grab) 1)
						)
					    )
					  (n-r "nsproul" t)
					  (forward-line 0)
					  (nbig-add (nbig-grab) 20)
					  )
	    )
      (end-of-line)
      (insert "\n" (format "%s|%-25s|%-32s|nsproul"
			   (nbig-get next-universal-bobid)
			   table
			   (if global-coregroup-IDs
			       next-object-name
			     (concat (nsimple-env-expand "$extdataset") "." next-object-name)
			     )
			   )
	      )
      (n-database-set (concat "bobid-" table)
		      (nbig-get next-universal-bobid)
		      )
      next-universal-bobid
      )
    )
  )
(defun next-do-data-file-maybe-copy(srcDir table destFn)
  (let(
       (srcFn	(concat srcDir "/" table ".txt"))
       )
    (if (n-file-exists-p srcFn)
	(progn
	  (n-file-copy srcFn destFn nil)
	  (nsyb-cm "add")
	  (message "Copied from %s" srcFn)
	  t
	  )
      )
    )
  )

(defun next-retrieve-data(srcTable srcCol pkey)
  (save-window-excursion
    (let(
	 (fn (concat "$ext/pso/$extdataset/V0/Data/$extdataset/" srcTable "_pso.txt"))
	 )
      (if (n-file-exists-p fn)
	  (n-file-find fn)
	(setq fn (nstr-replace-regexp fn "_pso.txt" ".txt"))
	(if (n-file-exists-p fn)
	    (n-file-find fn)
	  (error "next-retrieve-data: ")
	  )	
	)
      
      (goto-char (point-min))
      (n-s (concat "^" pkey "|") t)
      (nsql-get-col-text srcCol)
      )
    )
  )

(defun next-do-data-file-fill-in-dependent-field(destCol srcTable &optional srcCol)
  (if (not srcCol)
      (setq srcCol destCol))
  (nsql-goto-col-by-name destCol)
  (nsql-delete-column-text)
  (insert (next-retrieve-data srcTable
			      srcCol
			      (n-database-get (concat "bobid-" srcTable) t)
			      )
	  )
  )

(defun next-do-data-file-fill-in-current-timestamp(col)
  (nsql-goto-col-by-name col)
  (nsql-delete-column-text)
  (insert (n-month-day "sql"))
  )

(defun next-do-data-file-fill-in-dependent-field-parameters()
  (goto-char (point-min))
  (if (n-s "^[0-9]")
      (error "next-do-data-file-fill-in-dependent-field-parameters: it appears that there exist rows in this file's narrowed region which have their own primary keys (i.e., they dont pertain to the current set of changes, which violates an assumption of this module (which, e.g., allows it to reset the parameter sequence for all of the visible rows))")
    )
  
  (let(
       (param_order 0)
       )
    (while (not (eobp))
      (next-do-data-file-fill-in-dependent-field "br_instance_id" "br_instance")
      
      (nsql-goto-col-by-name "param_order")
      (nsql-delete-column-text)
      (insert (format "%d" param_order))
      (setq param_order (1+ param_order))
      )
    )
  )

(defun next-do-data-file-fill-in-dependent-fields()
  (let(
       (table	(nsql-get-table-name))
       )
    (cond
     ((string= table "albr_defn")
      (next-do-data-file-fill-in-dependent-field "template_id" "br_template")
      (next-do-data-file-fill-in-dependent-field "class_name"  "br_template")
      (next-do-data-file-fill-in-current-timestamp "rule_created_date")
      )
     ((string= table "albr_instance")
      (next-do-data-file-fill-in-dependent-field "rule_defn_id" "br_defn")
      )
     ((string= table "albr_organization_br")
      (next-do-data-file-fill-in-dependent-field "br_instance_id" "br_instance")
      )
     ((string= table "albr_parameter")
      (next-do-data-file-fill-in-dependent-field-parameters)
      )
     )
    )
  )

(defun next-set-pkey()
  (goto-char (point-min))
  (if (not (n-s "^|"))
      (error "next-do-data-file: could not find empty pkey"))
  (forward-line 0)
  (insert (nbig-get (next-alloc-bobid)))
  
  (while (n-s "^|")
    (forward-line 0)
    (insert (nbig-get (next-alloc-bobid)))
    )
  )

(defun next-do-data-file(table)
  (let(
       (mine	(concat "$ext/pso/$extdataset/V0/Data/$extdataset/" table))
       )
    (if (string= "br_template" table)
	(setq mine (concat mine "_pso")))
    (setq mine (concat mine ".txt"))
    (if (not (n-file-exists-p mine))
	(cond
	 ((next-do-data-file-maybe-copy "$ext/largesoft/install/V0/data/base"    table mine))
	 ((next-do-data-file-maybe-copy "$ext/largesoft/install/V0/data/qa"      table mine))
	 ((next-do-data-file-maybe-copy "$ext/largesoft/install/V0/data/default" table mine))
	 (t (error "next-do-data-file: "))
	 )
      )
    (n-file-find mine)
    (if (not (n-file-writable-p))
	(n-file-toggle-read-onlyness))
    
    (cond
     ((string= table "br_organization_br") ;; dont need to recursively edit this file...
      (goto-char (point-max))
      (forward-word -1)
      (n-2-lines)
      
      ;; delete primary key
      (forward-line 0)
      (nsql-delete-column-text)
      )
     (t
      (recursive-edit)
      )
     )
    
    (save-restriction
      ;; this is for br_parameter -- it is a nice simple occasion to know that the lines which need to be modified are all of the lines which remain in the narrowed region.  The assumption here is that all the modifications pertaining to the new rule will be at the end of the file.
      (narrow-to-region (progn     
			  (goto-char (point-min))
			  (n-s "^|" t)
			  (forward-line 0)
			  (point)
			  )
			(point-max)
			)
      (next-do-data-file-fill-in-dependent-fields)
      (next-set-pkey)
      )
    )
  )


(defun next-set-up-br()
  (interactive)
  (require 'nbig)
  (n-database-possibly-set "next-object-name")
  (next-do-data-file "br_template")
  (next-do-data-file "br_defn")
  (next-do-data-file "br_instance")
  (next-do-data-file "br_organization_br")
  (next-do-data-file "br_parameter")
  )
