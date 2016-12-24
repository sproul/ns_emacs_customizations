(provide 'n4)
(defun n-max-strlen( strings )
  "given a list of strings, this routine evals to the max len"
  (let(
       (maxLen	0)
       )
    (while strings
      (let(
           (len	(length (car strings)))
           )
        (if (> len maxLen)
            (setq maxLen len))
        )
      (setq strings (cdr strings))
      )
    maxLen
    )
  )

(defun n-warn( msg from)
  (message "%s - hit a key" msg)
  (read-char)
  )


(setq n-tmpNameSeed 0)

(defun n-tmpName()
  "get a temp name, unique to this session"
  (setq n-tmpNameSeed (1+ n-tmpNameSeed))
  (make-temp-name (format "%d." n-tmpNameSeed))
  )

(defun n-tmpFileName()
  "get a temp file name, unique to the session"
  (format "/tmp/%s" (n-tmpName))
  )

(defun n-show-changes()
  "run diff on the current file and the opposing view's version of it
(which view it is that is compared to is determined by the variable 
       n-show-changes-opposing-versions)"
  (interactive)
  (if (not (buffer-file-name))
      (error "No file associated with the current buffer."))
  (n-show-changes-fn (buffer-file-name))
  )

(setq n-env-op nil)	; true if n-env-op-domain is being called

(defun n-unnil( l1)
  (let(
       l2
       )
    (while l1
      (if (car l1)
          (setq l2 (append l2 (list (car l1))))
        )
      (setq l1 (cdr l1))
      )
    l2
    )
  )

(defun n-parent-dir( fn)
  "return the name of the immediate parent of FN"
  (if (not (string-match "/\\([^/]+\\)/[^/]+$" fn))
      (error "n-parent-dir cannot parse %s" fn))
  (n--pat 1 fn)
  )

(defun n-plat-from-dir(dir)
  (let(
       (platRegexp	"[^/]+/\\([^/]+\\)/") 
       )
    (cond
     ((string-match (concat "/users/[^/]+/[^/]+/" platRegexp) dir)
      (n--pat 1 dir))
     ((string-match (concat "/build/[^/]+/" platRegexp) dir)
      (n--pat 1 dir))
     ((string-match (concat "/project/[^/]+/" platRegexp) dir)
      (n--pat 1 dir))
     ((string-match (concat "/csi/main2?/" platRegexp) dir)
      (n--pat 1 dir))
     ((string-match "[^/]+/\\([^/]+\\)/$" dir)
      (n--pat 1 dir))
     (t
      (error "n--plat-from-dir: cannot find plat in %s" dir))
     )
    )
  )
(defun n-spot()
  (cons	(point)
	(n-get-line))
  )
(defun n-spot-goto( nspot)
  (let(
       (pnt	(car nspot))
       (line	(cdr nspot))
       )
    (if (= 1 (point))
	(if (n-s (concat "^" line "$"))
	    (message "identical line matched")
	  (goto-char pnt)
	  (message "went to same offset")
	  )
      )
    )
  )
(defun n-sleep()
  (interactive)
  (n-sleep-for 2)
  )
(defun n-read-number(&optional prompt dft oneDigitOnly)
  (string-to-int
   (if oneDigitOnly
       (progn
	 (message prompt)
	 (char-to-string
	  (read-char)
	  )
	 )
     (read-string prompt (if dft
			     (format "%d" dft))
		  )
     )
   )
  )
(setq n-sleep 5)
(defun n-sleep-for(&optional units)
  (interactive)
  (if (not units)
      (setq units 2))
  (sleep-for (* n-sleep units))
  )
(defun n-owner(&optional fn)
  (if (not fn)
      (setq fn (buffer-file-name)))
  (n-tmpBuf)
  (call-process "ls" nil t nil "-l" fn)
  (goto-char (point-min))
  (n-s " " t)
  (forward-word 1)
  (n-s "[ \t]*\\([^ \t]*\\)" t)
  (prog1
      (n--pat 1)
    (kill-buffer (current-buffer))
    )
  )
(defun n-tmpBuf()
  (set-buffer (get-buffer-create (n-tmpName)))
  )

