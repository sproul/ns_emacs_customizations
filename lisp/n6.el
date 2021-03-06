(provide 'n6)

(defun n-report( &rest args )
  "n6: append MSG to the report file"
  (n-file-find "~/work/report")
  (goto-char (point-max))
  (insert (apply 'format args)
          "\n")
  (save-buffer)
  )

(defun n-what-line()
  "what is number of the current line"
  (1+ (count-lines (point-min) ( save-excursion
                                 (forward-line 0)
                                 (point)
                                 )
                   )
      )
  )


(defun n-update-dir-in-file-db()
  "update current dir's files in the ff db"
  (interactive)
  (save-excursion
    (let(
         (dir	default-directory)
         )
      (message "Updating %s's entries in the fast-file db" default-directory )
      (n-rm-dir-from-ff-db dir)
      (n-add-dir-to-ff-db dir)
      )
    )
  )

(defun n-rm-dir-from-ff-db ( dir)
  "rm all of DIR's files from the ff-db"
  (interactive "DDirectory: ")
  (set-buffer n-local-ff-db-bn)
  (goto-char (point-min))
  (if (n-s (concat "^" dir))
      (delete-region (progn
                       (forward-line 0)
                       (point)
                       )
                     (progn
                       (while (looking-at dir)
                         (forward-line 1)
                         )
                       (point)
                       )
                     )
    )
  )

(defun n-add-dir-to-ff-db( dir)
  "add DIR's files to the ff-db (call n-rm-dir-from-ff-db first 
DIR's files out of the ff-db first"
  (interactive "DDirectory: ")
  (n-trace "updating %s in ff-db\n" dir)
  (n-zap "*n-output*")
  (n-xdired-echo-dir-contents dir)
  (set-buffer n-local-ff-db-bn)
  (goto-char (point-max))
  (insert-buffer "*n-output*")
  (save-buffer)
  )

(defun n-lsr-jump-get-base()
  "in an .lsr buffer, retrieve the first line (whcih should hold the current
directory at the time of the .lsr file's creation"
  (save-excursion
    (goto-char (point-min))
    (n-get-line)
    )
  )

(defun n-lsr-jump-R-file( &optional baseDir)
  "browse a file in a listing generated by ls -R, executed
from the directory in n-lsr-jump-dir-base.  Optionally set
that var to DIR."
  (interactive "P")
  (setq baseDir (if baseDir		; if user did ^U before calling
                    (read-file-name "Browse base directory: " )
                  (n-lsr-jump-get-base))
        )
  (let(
       fn dir
          )
    (save-excursion
      (setq fn	(n-get-line)
            dir	(progn
                  (re-search-backward ":" (point-min))
                  (buffer-substring-no-properties
                   (point)
                   (progn
                     (forward-line 0)
                     (point)
                     )
                   )
                  )
            )
      )
    (find-file-other-window (concat n-lsr-jump-dir-base
                                    "/"
                                    dir
                                    "/"
                                    fn))
    )
  )

(defun n-cur-dir()
  "return the current directory associated with the current buffer.
If there's no file associated with the buffer, returns an empty string"
  (let(
       (fn	(buffer-file-name))
       )
    (if fn
        (file-name-directory fn)
      ""
      )
    )
  )

(defun n-dir( dir pat filePrio)
  (let(
       (files	(directory-files dir nil pat))
       )
    (while files
      (insert (format "%s %3d\n" (car files) filePrio))
      (setq files (cdr files))
      )
    )
  )

(defun n-what-line-cmd( &optional arg)
  (interactive "P")
  (let(
       (lineNo (if (not arg)
                   nil
                 (read-number "Enter line to go to, or none to get a citation of this spot")
                 )
               )
       )
    (cond
     ((null arg)
      (message "%s" (n-what-line-make-string))
      )
     ((eq lineNo 0)
      (nstr-kill (concat (n-host-to-canonical (buffer-file-name))
			 ":"
			 (int-to-string (n-what-line))
			 )
		 )
      )
     (t
      (goto-char (point-min))
      (forward-line (1- lineNo))
      )
     )
    )
  )
(defun n-what-line-make-string()
  "say what line point is on, and what is the value of point"
  (let(
       (lastLine (save-excursion
		   (goto-char (point-max))
		   (n-what-line)
		   )
		 )
       (currentLine (n-what-line))
       )
    (setq lastLine (if (= lastLine currentLine)
		       "\""
		     (format "%d" lastLine)
		     )
	  )
    (format "line %d/%s, point=%d" currentLine lastLine (point))
    )
  )
(defun n-defun-name(&optional getCXXclassAndMethod)
  "return name of defun point is within"
  (save-excursion
    (save-restriction
      (widen)
      (cond
       ((eq major-mode 'njava-mode)
	(save-excursion
	  (if (not (n-rv (list
			  (list "\\bpublic\\b")
			  (list "\\bprivate\\b")
			  (list "\\bprotected\\b")
			  )
			 )
		   )
	      (error "n-defun-name: no java match")
	    )
	  (n-s "(" t)
	  (forward-word -1)
	  (n-grab-token)
	  )
	)
       ((eq major-mode 'njavascript-mode)
        (if (n-r "^function \\(.*\\)(")
            (nre-pat 1))
        )
       ((eq major-mode 'nperl-mode)
	(save-excursion
	  (n-r "^sub \\([0-9a-zA-Z_]+\\)" t)
	  (n--pat 1)
	  )
	)
       ((eq major-mode 'nsh-mode)
	(save-restriction
	  (widen)
	  (save-excursion
	    (let(
		 (savedPt (point))
 		 (eofunc (progn
			   (if (n-s "^}")
			       (point))
			   )
			 )
		 (bofunc (progn
			   (if (n-r "^\\([0-9a-zA-Z_]+\\)[ \t]*()[ \t]*$")
			       (point))
			   )
			 )
		 )
	      (if (and eofunc
		       bofunc
		       (<= bofunc savedPt)
		       (>= eofunc savedPt)
		       )
		  (n--pat 1)
		"-"
		)
	      )
	    )
	  )
	)
       (t
	(require 'nc)
	(nc-beginning-of-defun)
	(let(
	     (promising t)
	     )
	  (if (nc-mode-kin-p)
	      (setq promising (n-r "^\t?[^ \n\t].*+("))	; go to the function name, which precedes '('
	    )
	  (forward-line 0)
	  (cond
	   ((not promising)
	    (n-trace "n-defun-name: not promising: need to indent?")
	    nil
	    )
	   (getCXXclassAndMethod
	    (if (looking-at "\\(.*[^0-9a-zA-Z_]\\)?\\([0-9a-zA-Z_]+::[~0-9a-zA-Z_]+\\)[ \t]*(")
		(n--pat 2)
              (nelisp-bp "n-defun-name" "n6.el" 241);;;;;;;;;;;;;;;;;
	      (or (looking-at "^\\(.*[^0-9a-zA-Z_]\\)?\\([~0-9a-zA-Z_]+\\)[ \t\n]*(")
		  (error "n-defun-name:  2")
		  )
              (nelisp-bp "n-defun-name" "n6.el" 245);;;;;;;;;;;;;;;;;
	      (let(
		   (methodName (n--pat 2))
		   )
                (nelisp-bp "n-defun-name" "n6.el" 249);;;;;;;;;;;;;;;;;
		(concat (nc-class-name) "::" methodName)
		)
	      )
	    )
	   (t
	    (cond
	     ((looking-at ".*::") 	(n-s "::" t))
	     ((looking-at "(defun") (n-s "(defun.*(" t) (forward-word -1))
	     ((looking-at "[^(]+(") (n-s "(" t) (forward-word -1))
	     )
	    (n-grab-token)
	    )
	   )
	  )
	)
       )
      )
    )
  )

(defun n-rand( max)
  "returns rand number n, where 0 <= n <= MAX.  Assumes MAX is a power of 2"
  (let(
       (raw	(random))
       )
    (logand raw (1- max))
    )
  )

(defun n-rm-last-component (fn)
  "trunc last comp of FN"
  (if (string-match "/[^/]+/?$" fn)
      (substring fn 0 (match-beginning 0))
    fn
    )
  )

(defun n-rm-objs()
  (let(
       (objs	(nstr-split
                 (n-make-outside-eval "OBJS")
                 )
                )
       )
    (message "rm %s" objs)
    (apply 'call-process "rm" nil (get-buffer "*Messages*") nil objs)
    )
  )

(defun n-implode( l1)
  (delq nil l1)
  )
(defun n-fix-sccsid-inner ()
  (execute-kbd-macro "")
  (if (string-match "^makefile.*$" (buffer-name))
      ;; dunno why the 's are necessary in the next stmt, but whatever...
      (execute-kbd-macro "\M-,Sccsid\M-k# makefile:	Sccsid @(#) %Z% %M% %I% %G%\M-n" nil)
    (execute-kbd-macro "\M-,Sccsid\M-kstatic char Sccsid[] = {\"%Z% %M% %I% %G%\"};\M-n" nil)
    )
  )

(defvar n-id-cnt 0)
(defun n-id()
  "return a unique id string"
  (setq n-id-cnt (1+ n-id-cnt))
  (let(
       (time	(current-time-string))
       )
    (concat (char-to-string (elt time 4))
            (char-to-string (elt time 6))
            (char-to-string (if (eq 32 (elt time 8))
                                ?0
                              (elt time 8)
                              )
                            )
            (char-to-string (elt time 9))
            (char-to-string (elt time 22))
            (char-to-string (elt time 23))
            (format "-%d" n-id-cnt)
            )
    )
  )

(defun n-ungetc( chr)
  (if (and (boundp 'unread-command-events)
           )
      (push chr unread-command-events)
    (setq unread-command-char chr)
    )
  )

(defun n-wait-for-char()
  (n-ungetc (read-char))
  )

(defun n-esc(&optional cmd host)
  (switch-to-buffer-other-window (n-host-buf-name))
  (if host
      (n-host-shell-local-cmd host (concat cmd "\n"))
    (n-host-shell-cmd (concat cmd "\n"))
  )
  )

