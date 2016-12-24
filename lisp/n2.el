(provide 'n2)
(defun n-load-mine()
  "re-load all of my LISP routines"
  (n-trace "check point 5.31")
  (n-load "n-")
  (n-load "nstr")
  (require 'cl)
  (n-load "n-host.el")
  (n-load "n-grab")
  (n-load "nfn")
  (n-load "nfly")
  (n-load "n-file")
  (n-load "nsimple.el")
  (n-trace "check point 5.32")
  (n-load "n-local.el")
  (n-trace "check point 5.325")
  ;;(byte-recompile-directory "$dp/emacs/lisp/")
  (n-trace "check point 5.33")
  (n-trace "all lisp byte compiled")
  (n-load "nterminal")
  (n-load "nasync")
  (n-load "nlog")
  (n-load "n1")
  (n-load "n3")
  (n-load "n4")
  (n-load "n5")
  (n-load "n6")
  (n-load "n7")
  (n-load "n-complete")
  (n-load "n-loc")
  (n-load "n-indent")
  (n-load "nlist")
  (n-load "nkeys-database")
  (n-load "n-env")
  (n-load "n-recursive")
  (if n-win
      (progn
	;; for unknown reasons, if I don't load this, dired doesn't show directories
	(n-load "files")
	)
    )
  (n-load "n-modes")
  (n-load "ntoken")
  (n-load "nfly-cycle")
  (n-load "nset")
  (n-load "nbuf")
  (n-trace ".emacs check point 5.4")
  (n-load "n-grab")
  (n-load "nc")
  (n-load "njava")
  (n-load "nlog")
  (n-load "nsh")
  )

;;(defun n-load-files-in-dir(dir)
;;  (cd dir)
;;  (let(
;;       (load-path (append load-path (list dir)))
;;       (fns (directory-files
;;             (n-host-from-canonical dir)
;;             )
;;            )
;;       )
;;    (while fns
;;      (if (and
;;           (not (file-directory-p (car fns)))
;;           (string-match "\\(.*\\)\\.el$" (car fns))
;;           )
;;          (progn
;;            (n-load (n--pat 1 (car fns)))
;;            )
;;        )
;;      (setq fns (cdr fns))
;;      )
;;    )
;;  )


(setq n-load-cnt 0)

(defun n-load(name)
  (n-trace "n-load %s" name)
  (load name)
  )

(defvar n-locs nil
  "*loc stack"
  )

;;(defun n-reg-cmd()
;;  "do a register command" (interactive)
;;  (message "enter reg cmd: g-Grab-region, o-pOp-to-reg-loc, p-Put-reg-contents, t-oken, u-pUsh-pt-to-reg")
;;  (let(
;;       (cmd (read-char))
;;       )
;;    (cond
;;     ((= cmd ?g) (call-interactively 'copy-to-register))
;;     ((= cmd ?o) (call-interactively 'register-to-point))
;;     ((= cmd ?p) (call-interactively 'insert-register))
;;     ((= cmd ?t) (n-reg-cmd-token))
;;     ((= cmd ?u) (call-interactively 'point-to-register))
;;     (t
;;      (error "%c is not a reg cmd"))
;;     )
;;    )
;;  )
;;
;;(defun n-reg-cmd-token()
;;  (let(
;;       (cmd     (progn
;;		  (message "p-ut, g-rab")
;;		  (read-char)
;;		  )
;;		)
;;       token
;;       )
;;    (cond
;;     ((eq cmd ?g)
;;      (copy-to-register ?t
;;			(progn
;;			  (skip-chars-backward (n-grab-token-chars))
;;			  (point)
;;			  )
;;			(progn
;;			  (skip-chars-forward (n-grab-token-chars))
;;			  (point)
;;			  )
;;			)
;;      )
;;     ((eq cmd ?p)
;;      (insert-register ?t))
;;     )
;;    )
;;  )
(defun n-beep()
  (beep)
  )
(defun n-flash( &optional msg)
  "get the user's attention" (interactive)
  (n-beep)
  (if msg
      (batch-attention (format "Attention: %s" msg))
    (batch-attention "Attention!")
    )
  )
(defun n-r(regexp &optional arg)
  "same as (re-search-backward REGEXP (point-min) t)"
  (if (re-search-backward regexp (point-min) t)
      t
    (if arg
	(if (equal arg 'bof)
	    (goto-char (point-min))
	  (error "n-r didn't see %s in %s" regexp (buffer-name))
	  )
      )
    nil
    )
  )

(defun n-s(regexp &optional arg)
  (if (condition-case()
	  (re-search-forward regexp (point-max) t)
	(error nil)
	)
      t
    (cond
     ((or
       (eq 'eof arg)
       (and (integerp arg) (= arg 1))   ; obsolete, should just use 'eof
       )
      (goto-char (point-max))
      )
     (arg
      (error "n-s didn't see %s in %s" regexp (buffer-name))
      )
     )
    )
  )

(defun n-s-cnt(regexp)
  (let(
       (cnt     0)
       )
    (while (n-s regexp)
      (setq cnt (1+ cnt))
      )
    cnt
    )
  )

(defun n-booltoa( bool)
  "convert a bool to a string rep"
  (if bool
      "t"
    "nil"
    )
  )

(defun n-erase-buffer( &optional buf)
  (save-excursion
    (if buf
	(set-buffer buf))
    (erase-buffer)
    )
  )

(defun n-trim( str)
  (string-match "\\([ 	]*\\)\\(.*\\)" str)
  (setq str (substring str (match-beginning 2)
                       (match-end 2)
                       )
        )
  )

(defun n-extract-token( str)
  "return STR's first token"
					;  (n-print (concat "n-extract-token( " str ")\n"))
  (n-trim str)
  (if (string-match "[^ 	\n]+" str)
      (substring str (match-beginning 0) (match-end 0))
    )
  )

(defun n-token( str )
  "return STR's first token"
  (let( token )
					;    (n-print (concat "(n-token \"" str "\" )\n"))
    (n-trim str)
    (setq token (n-extract-token str))
    token
    )
  )

(defun n-beyond-token( str)
  "return what's left of STR after its first token and surrounding space have been removed"
  (n-trim str)
  (if (string-match "\\([^ 	\n]+\\)[ 	\n]*\\(.*\\)" str)
      (substring str (match-beginning 2) (match-end 2))
    )
  )

(defun n-text-to-tokens( str)
  "split STR up into a list of tokens"
  (interactive)

  (let(
       (list    nil)
       token
       )
    (while (and str (setq token (n-token str)))
      (setq str (n-beyond-token str))
					;     (n-print (concat token "\n"))
      (setq list (cons token list))
      )
    (reverse list)
    )
  )

(defun n-shorten-mode-line(&optional buf)
  (if (not buf)
      (setq buf (current-buffer)))
  (save-excursion
    (set-buffer buf)
    (setq mode-line-format
	  (list (purecopy "")
		'mode-line-modified
		'mode-line-buffer-identification
		(purecopy "   ")
		'global-mode-string
		(purecopy "   %[(")
		'mode-name 'minor-mode-alist "%n" 'mode-line-process
		(purecopy ")%]----")
		(purecopy '(-3 . "%p"))
		(purecopy "-%-")))
    )
  )
