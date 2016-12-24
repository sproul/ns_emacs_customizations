(provide 'n-database)
(setq n-database-file (n-host-to-canonical "$TMP/.2ndatabase$USER"))

;;(n-database-init)
(defun n-database-init()
  (let(
       (done   (file-exists-p n-database-file))
       )
    (if (not done)
        (progn
          (condition-case nil
              (progn
                (setq done (n-file-possibly-create n-database-file))
                )
            (error
             (message "n-database-init failed")
             )
            )
          )
      done
      )
    )
  )

(defun n-database-possibly-set(key)
  (n-database-get "next-object-name" t nil nil t)
  )

(defun n-database-set(key value)
  (save-window-excursion
    (if (n-database-init)
	(progn
          (setq key (n-database-normalize-key key))

	  (if (not value)
	      (setq value ""))
	  (find-file n-database-file)
          (goto-char (point-min))
	  (if (n-s (concat "^" key "="))
	      (nsimple-delete-line 1))
	  (if value
	      (progn
                (goto-char (point-max))
		(insert key "=" value "\n")
		)
	    )
          (save-buffer)
          (kill-buffer nil)
          )
      )
    )
  )
(defun n-database-get(key &optional mustFind database default confirm)
  (n-database-init)
  (setq key (n-database-normalize-key key))
  (if (not database)
      (setq database n-database-file))
  (if (not (file-exists-p database))
      default
    (save-window-excursion
      (let(
           value
           )
        (find-file database)
        (goto-char (point-min))
        (setq value (if (n-s (concat "^" key "=\\(.*\\)"))
                        (n--pat 1)
                      nil
                      )
              )
        (kill-buffer nil)
        (if (and (not value) mustFind)
            (progn
	      (setq value
                    (cond
                     ((and (boundp 'nmenu-exists)
                           default
                           (nmenu-exists default)
                           )
                      (nmenu "" default)
                      )
                     (n-emacs-initing
                      default
                      )
                     (t
		      (read-string (format "enter a value for variable '%s': " key) default)
		      )
                     )
                    )
              (setq confirm nil)	;since I just entered the value manually, spare me the confirmation
              (n-database-set key value)
              )
          )
        (if (not value)
            (setq value default))
	(if confirm
            (setq value (read-string key value)))
	value
        )
      )
    )
  )
(defun n-database-get-by-value(value)
  (if (not (n-database-init))
      nil
    (save-window-excursion
      (let(
           key
           )
        (find-file n-database-file)
        (goto-char (point-min))
        (setq key (if (n-s (concat "^\\([^=]*\\)=" value "$"))
                      (n--pat 1)
                    nil
                    )
              )
        
        ;;(bury-buffer)	stop locking conflicts
        
        
        (save-buffer)
        (kill-buffer nil)
        key
        )
      )
    )
  )

(defun n-database-set-int(key val)
  (n-database-set key (format "%d" val))
  )

(defun n-database-get-int(key)
  (let(
       (val  (n-database-get key))
       )
    (if val
	(string-to-int val)
      )
    )
  )


(defun n-database-load(name)
  (let(
       (current  (intern name))
       value
       )
    (if (not (boundp current))
	(n-load (concat "data/" name))
      )
    (setq value (eval current))
    (if value
	value
      (error "n-database-load %s failed" name)
      )
    )
  )

(defun n-database-get-from-list(key)
  (require 'n-database-list)
  (n-database-list-pop key)
  )

(defun n-database-add-to-list(key val)
  (require 'n-database-list)
  (n-database-list-push key val)
  )
(defun n-database-get-bool(key &optional required)
  (let(
       (val (n-database-get key))
       )
    (if (and required
	     (not val)
	     )
	(progn
	  (setq val (if (y-or-n-p required)
			"t"
		      )
		)
	  (n-database-set-bool key val)
	  )
      )
    
    (and val
	 (string= val "t")
	 )
    )
  )
(defun n-database-set-bool(key val)
  (setq val (if val "t" "f"))
  (n-database-set key val)
  )
(defun n-database-normalize-key(key)
  (require 'nre)
  (nre-unregexpify key)
  )
