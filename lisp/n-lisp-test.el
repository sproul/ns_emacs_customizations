(provide 'n-lisp-test)
;; steps: reset the variables at the top of the file.
;; 		n-lisp-test-init: binds m-c to n-lisp-test, m-e to n-lisp-debug
;; 		n-lisp-test executes the lisp and runs go.sh
;;              (the shell output should be visible)
;;              	(if trouble:) n-lisp-test-debug
;;                      	splits the screen between the test/debug file and *Messages*
;; 		n-lisp-test-init arg: (^um-c) resets key bindings
;;              
(setq n-lisp-test-function  '(lambda()
                               (goto-char (point-min))
                               (while (not (eobp))
                                 ;; WHAT I AM TESTING:
                                 (nci-indent)
                                 (forward-line 1)
                                 )
                               (save-buffer)
                               )
      )
(setq n-lisp-test-target "nci")
(setq n-lisp-test-debug-file (concat "~/z/Dropbox/emacs/lisp/test/" n-lisp-test-target "/function.c"))
;;(n-lisp-test-init)
(defun n-lisp-test-init( &optional arg)
  "initialize the lisp unit test"
  (interactive "P")
  (if arg
      (n-load "nkeys")
    (global-set-key "\M-c" 'n-lisp-test)
    (global-set-key "\M-e" 'n-lisp-test-debug)
    )
  )

(defun n-lisp-test( &optional arg)
  "execute the lisp unit test"
  (interactive "P")
  (if arg
      (n-lisp-test-init t)
    (set-buffer (get-buffer-create "*Messages*"))
    (erase-buffer)
    (cd "~/z/Dropbox/emacs/lisp/test/" n-lisp-test-target "/"))
  (let(
       (files	(directory-files "."))
       inputFile
       outputFile
       )
    (while files
      (setq inputFile	(car files)
	    files	(cdr files)
	    )
      (if (string-match "\\(.*\\)\\.in$" inputFile)
	  (progn
	    (setq prefix	(n--pat 1 inputFile)
		  outputFile	(concat prefix ".out")
		  )
	    ;; a problem with loading the file after copying over it:
	    ;; emacs needs to know whether to reload the file.
	    ;; Avoid this problem by explicitly kicking the file
	    ;; out of memory:
	    (n-file-push outputFile)
	    (nbuf-kill-current)
	    (set-buffer "*Messages*")
	    
	    (copy-file inputFile outputFile t)
	    
	    (n-file-push outputFile)
	    (funcall n-lisp-test-function)
	    (n-file-pop)
	    )
	)
      )
    (set-buffer "*Messages*")
    (nshell t)	; go to the test directory
    (nshell-clear)
    (n-host-shell-cmd "go.sh")
    )
  )
(defun n-lisp-test-debug( &optional arg)
  "debug the lisp unit test"
  (interactive "P")
  (if (or arg (not n-lisp-test-debug-file))
      (setq n-lisp-test-debug-file (nfly-read-fn "debug file: ")))
  (find-file n-lisp-test-debug-file)
  (delete-other-windows)
  (split-window-vertically)
  (switch-to-buffer (get-buffer-create "*Messages*"))
  (erase-buffer)
  (other-window 1)
  (n-loc-push)
  )
