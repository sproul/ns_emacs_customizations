(provide 'nbuf)
(setq
 nbuf-list nil
 nbuf-cycle-list nil
 nbuf-cycle-visible-buffers nil
 nbuf-cycle-rejects nil
 kill-buffer-query-functions nil
 )

(if (not (boundp 'Buffer-menu-buffer-column))
    (setq Buffer-menu-buffer-column 4))
(setq n-data-menu-nbuf-shortcuts_buildcommon-test "war")

(defun nbuf-menu-refresh-line()
  (forward-line 0)
  (forward-char 1)
  (let ((buffer-read-only nil))
    (delete-char 1)
    (insert " ")
    (forward-line 1))
  )

(defun nbuf-menu( &optional batch)
  "prepare a list of buffers to work on"
  (interactive "P")
  (delete-other-windows)
  (nbuf-get-list)

  (goto-char (point-min))
  (forward-line 1)

  (if batch
      (kill-buffer nil)
    ;; usually the user will want to immediately select a file using
    ;; a hot key.  If he enters a period, he wants to stay a bit
    ;; longer.  Otherwise, go to the file associated with the hot key.
    (message "enter hot key to edit")
    (let(
         (hot-key	(nsimple-read-char))
         )
      (cond
       ((eq hot-key ?.)
        nil)
       ((nbuf-edit-n hot-key)
        t)
       (t
        (n-ungetc hot-key))
       )
      )
    )
  )

(defun nbuf-edit-n(key)
  (goto-char (point-min))
  (if (n-s (format "[ \t]%c[ \t]" key))
      (nbuf-edit))
  )
(defun nbuf-edit-n-command()
  "edit the buffer on the corresponding line  of the buffer list"
  (interactive)
  (nbuf-edit-n last-command-event)
  )


(defun nbuf-prune()
  "n1.el:  get rid of annoying system buffers in buff-menu mode"
  (goto-char (point-min))
  (if n-pre-emacs23
      (nsimple-delete-line 2))

  (require 'n-prune-buf)
  (n-prune-buf "0.macro")
  (n-prune-buf "^....\\*")
  (n-prune-buf "Shell\\([ \t]\\|:run\\)")

  ;;(n-prune-buf " Fundamental[ \t]*$")
  )
(defun nbuf-massage()
  (goto-char (point-min))
  (while (n-s "^....\\([^ \t]+\\) +...... Dired")
    (end-of-line)		; takes us to where the dir listing should be
    (let(
         (bufname       (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
         )
      (if (not (string-match "\.\.\.$" bufname))
          (insert (nbuf-get-dir bufname))
        )
      )
    )

  ;; shorten annoyingly long remote file names
  (goto-char (point-min))
  (replace-regexp "/remote/" "/")

  (goto-char (point-min))
  (replace-regexp (getenv "HOME") "~")

  (nbuf-massage-add-hot-keys-and-properties)

  (message "")
  (goto-char (point-max))
  (delete-char -1)
  (goto-char (point-min))
  )
(defun nbuf-massage-add-hot-keys-and-properties()
  "replace the size column with a set of hot keys, i.e., single characters
any of which can be entered to immediately edit the associated file"

  (untabify (point-min) (point-max))
  (goto-char (point-min))



  ;;(if n-pre-emacs23
  ;;(replace-regexp "^\\(........................[^\t ]*[ \t]*[0-9]+\\) *" "\\1!! ")
  (replace-regexp "$" "\t!!")
  ;;)
  
  
  
  (goto-char (point-min))
  (let(
       name
       name-start
       name-end
       (j	0)
       (hot-keys "0123456789abcdefghijklmnopqrstuvwxyz")
       hot-keys-max
       )
    (setq hot-keys-max (length hot-keys))
    (while (n-s "!!")
      (delete-char -2)
      (setq name-start (goto-char (+ (progn (forward-line 0) (point))
				     Buffer-menu-buffer-column
				     )
				  )
	    name-end (progn
		       (n-s "....................[^\t ]*[ \t]*[0-9]+")
		       (forward-word -1) ;; retreat over length
		       (n-r "[^ \t]" t)
		       (forward-char 1)
		       (point)
		       )	
	    name (buffer-substring-no-properties name-start name-end)
	    )
      (put-text-property name-start
			 name-end
			 'buffer-name
			 name
			 )
      
      (if (< j hot-keys-max)
	  (progn
	    (delete-horizontal-space)
	    (let(
		 (hot-key-column	24)
		 )
	      (if (< (current-column) hot-key-column)
		  (indent-to-column hot-key-column)
		(insert " ")             
		)
	      )
	    
	    (insert (format "%c " (elt hot-keys j)))
	    (delete-region (point) (progn
				     (forward-word 1)
				     (point)
				     )
			   )
	    
	    (setq j (1+ j))
	    )
	)
      )
    )
  (goto-char (point-min))
  (replace-regexp "!!" "  ")
  )

(defun nbuf-get-dir( bufName)
  "given BUFNAME, its directory"
  (let(
       (cBuf	(current-buffer))
       dir
       )
    (set-buffer bufName)
    (setq dir default-directory)
    (set-buffer cBuf)
    dir
    )
  )

(defun nbuf-lpr()
  "print the buffer named on the line"
  (interactive)
  (save-window-excursion
    (set-buffer (Buffer-menu-buffer t))
    (n-lpr-buf)
    )
  (next-line 1)
  )

(defun nbuf-del-file()
  "in bufed, delete the current file"
  (interactive)
  (forward-line 0)
  (forward-char 40)
  (let(
       (fn	(buffer-substring-no-properties (point)
                                  (progn
                                    (end-of-line)
                                    (point))
                                  )
                )
       )
    (if (n-file-delete-cmd fn)
        (progn
          (toggle-read-only)
          (nsimple-kill-line)
          (toggle-read-only))
      )
    )
  )

(defun nbuf-kill-from-bufed()
  "like Buffer-menu-delete, 'cept it won't prompt for confirmation if the buf's been modified"
  (interactive)
  (Buffer-menu-not-modified)
  (Buffer-menu-delete)
  )

(defun nbuf-compile-lisp()
  "compile the lisp buffer"
  (interactive)
  (set-buffer (Buffer-menu-buffer t))
  (save-buffer)
  (nelisp-load-file)
  (set-buffer "*Buffer List*")
  (nbuf-menu-refresh-line)
  )

(defun nbuf-save()
  "like Buffer-menu-save, 'cept it acts immediately"
  (interactive)
  (Buffer-menu-save)
  (Buffer-menu-execute)
  )

(defun nbuf-del-buf( &optional arg)
  "delete the buffer"
  (interactive "p")
  (if (integerp arg)
      (while (> arg 0) (nbuf-del-buf) (setq arg (1- arg)))
    (save-window-excursion
      (nbuf-edit)
      (not-modified)
      (kill-buffer (current-buffer))
      )
    (toggle-read-only)
    (nsimple-delete-line)
    (toggle-read-only)
    )
  )
(defun nbuf-cite()
  (interactive)
  (save-window-excursion
    (let(
         (fn	(buffer-file-name (Buffer-menu-buffer t)))
         )
      (nlog)
      (forward-line 1)
      (insert "\t" fn "\n")
      (nbuf-kill-current)
      )
    )
  )


;;(nbuf-get-list "\\.el")
(defun nbuf-get-list(&optional pat)
  "assemble a list of all buffers, optionally matching PATTERN"
  (buffer-menu nil)
  
  (toggle-read-only)
  (nbuf-prune)
  (nbuf-massage)
  (toggle-read-only)
  
  (goto-char (point-min))
  (setq nbuf-list nil)
  (while (not (eobp))
    (condition-case nil
	(let(
	     (bn (buffer-name
		  (Buffer-menu-buffer t)
		  ))
	     )
	  (if (or (not pat)
		  (string-match pat bn)
		  )
	      (setq nbuf-list (cons bn nbuf-list))
	    )
	  )
      (error nil)
      )
    (forward-line 1)
    )
  (setq nbuf-list (nreverse nbuf-list))
  )

(defun nbuf-cycle( &optional arg)
  "switch to a recently edited buffer which is not visible.  Repeatedly executing this command will allow you to cycle through the buffers you have edited most recently"
  (interactive "P")
  (if arg
      (n-split-and-flip)
    
    ;;(nbuf-cycle-dump "entering")
    (or (string= (n--get-lisp-func-name last-command) "nbuf-cycle")
	(nbuf-cycle-init)
	)
    
    (let(
	 possibleNextBuffer
	 )
      (while (and
	      nbuf-cycle-list
	      (progn
		(setq possibleNextBuffer (car nbuf-cycle-list)
		      nbuf-cycle-list (cdr nbuf-cycle-list)
		      nbuf-cycle-rejects	(cons possibleNextBuffer nbuf-cycle-rejects)
		      )
		(or
		 ;; reject buffers which are easily accessible
		 ;; too often I'm not where point ends up if I ^x^l: (string= possibleNextBuffer ".nlog")
		 ;;(string-match "^midnight" possibleNextBuffer)
		 (string-match "^RMAIL" possibleNextBuffer)
		 (nbuf-is-visible possibleNextBuffer)
		 (progn
		   (set-buffer possibleNextBuffer)
		   (eq (point-max) 1)        ; empty buffer
		   )
		 )
		)
	      )
	)
      (if (not possibleNextBuffer)
	  (message "nbuf-cycle: no eligible buffers")
	(let(
	     (rejects	nbuf-cycle-rejects)
	     )
	  (while rejects
	    (switch-to-buffer (car rejects))
	    (setq rejects (cdr rejects))
	    )
	  )
	(switch-to-buffer possibleNextBuffer)
	)
      )
    ;;(nbuf-cycle-dump "leaving")
    )
  )
(defun nbuf-cycle-init()
  ;; initialize nbuf-cycle-visible-buffers 
  
  ;;(sleep-for 1)
  
  (setq nbuf-cycle-rejects nil
        nbuf-cycle-visible-buffers nil
        )
  (let(
       (startingBuffer	(current-buffer))
       )
    (walk-windows '(lambda(window)
		     (setq nbuf-cycle-visible-buffers (cons (buffer-name (window-buffer window))
							    nbuf-cycle-visible-buffers
							    )
			   )
		     ;;(n-trace "visible: %s" (buffer-name))
		     )
		  'ignore_minibuffer
		  )
    )
  
  
  
  
  
  
  (let(
       (visible-buffers	nbuf-cycle-visible-buffers)
       )
    (while visible-buffers
      ;;(n-trace "init result: visible buffer:%s" (car visible-buffers))
      (setq visible-buffers (cdr visible-buffers))
      )
    )
  
  
  
  
  
  (save-window-excursion
    (nbuf-menu t)
    )
  (setq nbuf-cycle-list nbuf-list)
  )

(defun nbuf-is-visible(buffer)
  (let(
       (visible-buffers	nbuf-cycle-visible-buffers)
       )
    ;;(n-trace "checking the visibility of %s" buffer)
    (while (and visible-buffers
                (not (string= buffer (car visible-buffers)))
                )
      ;;(n-trace "%s != %s" buffer (car visible-buffers))
      (setq visible-buffers (cdr visible-buffers))
      )
    visible-buffers
    )
  )
(defun nbuf-cycle-dump(where)
  (n-trace "nbuf-cycle-dump %s (in %s)--------------------------------------------------------------------"
           where (buffer-name))
  (n-trace-list "nbuf-list" nbuf-list)
  (n-trace-list "nbuf-cycle-visible-buffers" nbuf-cycle-visible-buffers)
  (n-trace-list "nbuf-cycle-rejects" nbuf-cycle-rejects)
  (n-trace "\n")
  )
(defun nbuf-edit()
  "edit the buffer"
  (interactive)
  (switch-to-buffer (Buffer-menu-buffer t))
  )

(defun nbuf-kill-all(pat)
  (save-window-excursion
    (let(
	 (bufs (nbuf-get-list pat))
	 )
      (while bufs
	(kill-buffer (car bufs))
	(setq bufs (cdr bufs))
	)
      )
    )
  )
(defun nbuf-kill-current( &optional arg)
  "kill current buffer"
  (interactive "P")
  (cond
   ((and (string= (buffer-name) "*Backtrace*") (y-or-n-p "kill emacs? "))
    (kill-emacs)
    )
   ((and (string= (buffer-name) "*Process List*") (y-or-n-p "kill all processes? "))
    (n-process-kill-em-all)
    )
   (t
    (widen)
    (let(
         (quitFile        "~/work/bu/quit")
         (oldFile         (buffer-file-name))
         )
      (if arg
          (nbuf-kill-current-undo quitFile)
        (if (and
             oldFile
             (not
              (or
               (not (buffer-modified-p))
               (string= (buffer-name) "*scratch*")
               (string= (buffer-name) ".nlog")
               (string= (buffer-name) ".p")
               )
              )
             )
            (progn
              (setq
               nbuf-kill-current-oldFileSize  (point-max)
               nbuf-kill-current-oldFileName  (buffer-file-name)
               )
              (append-to-file (point-min) (point-max) (n-host-to-canonical quitFile))
              )
          )
        (nbuf-kill-w-hooks (current-buffer))
        )
      
      )
    
    ;; if this command executes as part of a series of buffer cycle calls,
    ;; update the appropriate recordkeeping
    (if (and
         (string= (n--get-lisp-func-name this-command) "nbuf-kill-current")
         (string= (n--get-lisp-func-name last-command) "nbuf-cycle")
         )
					;)
        (progn
          (setq this-command 'nbuf-cycle)
          (call-interactively 'nbuf-cycle)
          )
      )   
    )
   )
   )

(setq nbuf-kill-hook nil)
(make-variable-buffer-local 'nbuf-kill-hook)

(defun nbuf-post-for-kill( obj &rest args)
  "given OBJ, request that when the current buffer is exited using
n-kill-current-buf, (FUNC &rest ARGS) be executed, or kill-buffer OBJ"
  (if (stringp obj)
      (setq nbuf-kill-hook (append nbuf-kill-hook (list obj)))
    (setq nbuf-kill-hook (append nbuf-kill-hook (list (append (list obj) args))))
    )
  )

(defun nbuf-kill-w-hooks(buffer)
  (while nbuf-kill-hook
    (if (stringp (car nbuf-kill-hook))
	(progn
	  (nbuf-kill (car nbuf-kill-hook))
	  )
      (apply (caar nbuf-kill-hook) (cdar nbuf-kill-hook))
      )
    (setq nbuf-kill-hook (cdr nbuf-kill-hook))
    )
  (nbuf-kill buffer)
  )
(defun nbuf-kill(  &optional bufArg writeItFirst)
  "kill BUF, optionally specify an additional arg to have the buffer written first"
  (save-excursion
    (if (not bufArg)
	(setq bufArg (current-buffer)))
    (let(
	 buf  bufName
	      )
      (if (stringp bufArg)
	  (setq bufName bufArg
		buf     (if (get-buffer bufName) (get-buffer bufName))
		)
	(setq bufName   (buffer-name bufArg)
	      buf               bufArg
	      )
	)
      (if buf
	  (progn
	    (if writeItFirst
		(n-file-write buf)
	      (if (buffer-modified-p buf)
		  (progn
		    (set-buffer buf)
		    (not-modified)
		    (message ""))
		)
	      )
	    (n-locs-kill bufName)
	    (kill-buffer buf)
	    )
	)
      )
    )
  )
(setq nbuf-kill-current-oldFileSize 0)
(setq nbuf-kill-current-oldFileName "unknown")

(defun nbuf-kill-current-undo(quitFile)
  (let(
       (oldData (progn
		  (find-file quitFile)
		  (goto-char (- (point-max) nbuf-kill-current-oldFileSize))
		  (buffer-substring-no-properties
		   (progn
		     (forward-char 1)
		     (point)
		     )
		   (point-max)
		   )
		  )
		)
       )
    (nbuf-kill (current-buffer))
    (n-file-find nbuf-kill-current-oldFileName)
    (goto-char (point-min))
    (insert oldData)
    (kill-region (point) (point-max))
    )
  )
(defun nbuf-read-only-p()
  (condition-case nil
      (progn
        (barf-if-buffer-read-only)
        nil
        )
    (error t)
    )
  )
