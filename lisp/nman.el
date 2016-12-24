(provide 'nman)
                                        ;
                                        ; nman-dirs lists the set of directories containing
                                        ; man files which I will draw from.  The first node
                                        ; of each entry tells whether the man file requires
                                        ; formatting.
(setq nman-dirs	(list
                 (list t	"c:/downloads/man.raw")
                 )
      )
(defun nman-formatIt( dirCb) (car  dirCb))
(defun nman-dir-name( dirCb) (cadr dirCb))


(defun nman-db-init(&optional skipItIfItAlreadyExists)
  "initialize the db of formatted man pages"
  (interactive)

  (n-for 'nman-refresh nman-dirs)
  )

(setq nman-format nil)

(defun nman-refresh( dirCb )
  "refresh fast man db for DIR"
  (setq nman-format (nman-formatIt dirCb))
  (n-xdired (nman-dir-name dirCb)
            "[^\n]*\\.[0-9a-zA-Z]+"
            'nman-get
            '(lambda(fn) (not (file-symlink-p fn)))
            )
  )

(defun nman-get( fn)
  "get FN, and place the result in an identically-named file in nman-nDir.
If nman-format, format the file before writing it"
  (n-zap "ks")
  (if nman-format
      (call-process "nroff" nil t nil "-man" fn)
    (n-file-read fn)
    )
  (nuke-nroff-bs)
  (n-file-write (current-buffer) (concat n-local-man
					 (file-name-nondirectory fn)
					 ".man")
		)
  (kill-buffer  (current-buffer))
  )

(defun nuke-nroff-bs ()
  (interactive "*")
  (goto-char (point-min))
  (n-s "^NAME")
  (forward-line 0)
  (delete-region (point) (point-min))
  
  ;; Nuke underlining and overstriking (only by the same letter)
  (goto-char (point-min))
  (while (search-forward "\b" nil t)
    (let* ((preceding (char-after (- (point) 2)))
	   (following (following-char)))
      (cond ((= preceding following)
	     ;; x\bx
	     (delete-char -2))
	    ((= preceding ?\_)
	     ;; _\b
	     (delete-char -2))
	    ((= following ?\_)
	     ;; \b_
	     (delete-region (1- (point)) (1+ (point)))))))

  ;; Nuke headers: "MORE(1) UNIX Programmer's Manual MORE(1)"
  (goto-char (point-min))
  (while (re-search-forward "^ *\\([A-Za-z][-_A-Za-z0-9]*([0-9A-Z]+)\\).*\\1$" nil t)
    (replace-match ""))

  ;; Nuke footers: "Printed 12/3/85	27 April 1981	1"
  ;;    Sun appear to be on drugz:
  ;;     "Sun Release 3.0B  Last change: 1 February 1985     1"
  ;;    HP are even worse!
  ;;     "     Hewlett-Packard   -1- (printed 12/31/99)"  FMHWA12ID!!
  ;;    System V (well WICATs anyway):
  ;;     "Page 1			  (printed 7/24/85)"
  ;;    Who is administering PCP to these corporate bozos?
  (goto-char (point-min))
  (while (re-search-forward
	  (cond ((eq system-type 'hpux)
		 "^[ \t]*Hewlett-Packard\\(\\| Company\\)[ \t]*- [0-9]* -.*$")
		((eq system-type 'usg-unix-v)
		 "^ *Page [0-9]*.*(printed [0-9/]*)$")
		(t
		 "^\\(Printed\\|Sun Release\\) [0-9].*[0-9]"))
	  nil t)
    (nsimple-kill-line)
    )

  (goto-char (point-min))
  (while (n-s "^Sybase Confidential")
    (nsimple-kill-line))

  ;; Crunch blank lines
  (goto-char (point-min))
  (replace-regexp "\n+" "\n")

  ;; Nuke blanks lines at start.
  (goto-char (point-min))
  (skip-chars-forward "\n")
  (delete-region (point-min) (point))

  ;; if arg, tabify to compress output byte size
  (tabify (point-min) (point-max))
  )

;; below is my interface to the official man.el
(setq
 Man-notify	'aggressive
 Man-mode-hook	'nman-dynamic-2
 )
(require 'man)

(defun nman-dynamic(topic)
  (setq nman-dynamic-topic topic)
  (if (boundp 'Man-getpage-in-background)
      (Man-getpage-in-background topic)
    (manual-entry topic)
    (nman-dynamic-2)
    )
  )

(defun nman-dynamic-2()
  (let(
       (newManFile	(concat n-local-man nman-dynamic-topic ".man"))
       )
    (if (file-exists-p newManFile)
        (message "%s already exists" newManFile)
      (write-file newManFile)
      )
    )
  )
