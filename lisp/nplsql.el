(provide 'nplsql)
(defun nplsql-mode-meat()
  (let(
       (map		(make-keymap))
       )
    (define-key map " " 'n-complete-or-space)
    (define-key map "\C-h" 'nsimple-indent-backspace)
    (define-key map "\M-c" 'nplsql-run)
    (use-local-map map)
    )
  (setq mode-name "PL/SQL"
	indent-line-function 'nsimple-indent
	major-mode 'nplsql-mode
	case-fold-search t
	)
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"^[ \t]c$"	'n-complete-replace "c" "cursor c_@@ is\n                select @@\n                        from @@\n                        where @@;")
                 (list	"^[ \t]*d$"	'n-complete-replace "d" "dbms_output.put_line('@@');")
                 (list	"^e$"	'n-complete-replace "e" "execute ")
                 (list	"^[ \t]*o$"	'n-complete-replace "o" "open c_@@")
                 (list	"^p$"	'n-complete-replace "p" "create or replace PROCEDURE \n        as\nbegin\ndeclare\n        @@\nbegin\n	@@\nend;")
                 )
                )
	)
  (if (= (point-min)
	 (point-max)
	 )
      (progn
	(insert "set serveroutput on;
@@
/
show errors
")
	(n-complete-leap)
	)
    )
  )

(setq nplsql-buffer nil)

(defun nplsql-narrow-to-routine()
  (widen)
  (n-narrow-to-region (progn
			(n-r "^\\(create\\|function\\|procedure\\|CREATE\\|FUNCTION\\|PROCEDURE\\)")
			(point)
			)
		      (progn
			(n-s "^/$" t)
			(forward-line 1)
			(point)
			)
		      )
  )
(defun nplsql-run()
  (interactive)
  (save-some-buffers t)
  (let(
       (data (save-excursion
	       (save-restriction
		 (nplsql-narrow-to-routine)
		 (buffer-substring-no-properties (point-min) (point-max))
		 )
	       )
	     )
       )
    (if (and (not (string-match "^create or replace" data))
	     (not (string-match "^CREATE OR REPLACE" data))
	     )
	(setq data (concat "create or replace " data))
      )
    (setq nplsql-buffer (current-buffer))
    (if (or
	 (not (get-buffer "PL_SQL.midnight"))
	 (not (progn
		(get-buffer-process (switch-to-buffer "PL_SQL.midnight"))
		)
	      )
	 )
	(progn
	  (n-file-find "~/tmp/PL_SQL.midnight")
	  (delete-region (point-min) (point-max))
	  (widen)
	  (insert "sh -c sqlplus_run\n")
	  (nmidnight-compile)
	  (process-send-string nil "set serveroutput on\n")
	  )
      )
    (delete-region (point-min) (point-max))
    
    ;;(insert data)
    (process-send-string nil data)
    
    (process-send-string nil "\n/\nshow errors\n")
    (sleep-for 1)
    (if (n-r "No errors\\.")
	(progn
	  (narrow-to-region (progn
			      (forward-line 0)
			      (point)
			      )
			    (point-max)
			    )
	  (process-send-string nil
		       (concat 
			(n-database-get "nplsql-command" t)
			";\n"
			)
		       )
	  )
      )
    )
  ;;(nsql-interactive-run nil (buffer-substring-no-properties (point-min) (point-max)))
  )
(defun nplsql-next-error()
  (interactive)
  (set-buffer "PL_SQL.midnight")
  (goto-char (point-min))
  (if (n-s "^\\([0-9]+\\)/\\([0-9]+\\)[ \t]")
      (let(
	   (line (string-to-int (n--pat 1)))
	   (col  (string-to-int (n--pat 2)))
	   )
	(widen)
	(forward-line 0)
	(narrow-to-region (point) (point-max))
	
	(switch-to-buffer nplsql-buffer)
	(n-r "^create" t)
	(forward-line (1- line))
	(forward-char (1- col))
	)
    (message "no hits...")
    )
  )
