(provide 'nez)
(defvar nez-mode-map nil)
(defun nez-call-self(&optional before after offsetCol offsetLines )
  (end-of-line)
  (insert "\nez -x EZheader from $dp/emacs/lisp/nez.el ")
  (nfly-insert (buffer-file-name))
  (insert " ")
  )
(defun nez-mode-meat()
  (interactive)
  (setq
   case-fold-search t
   n-comment-boln "{"
   comment-start "{"
   n-comment-end "}"
   )

  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (insert "nez-mode-meat beginning\n")
    )
  (make-local-variable 'indent-line-function)
  (setq major-mode 'nez-mode
        mode-name "nez mode"
        n-indent-tab 8
        n-indent-in "[^\n(]*)$\\|if \\|while \\|end else\\|else\\|else if\\|for \\|begin\\|case \\|foreach"
        n-indent-out "end"
        indent-line-function	'n-indent
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"^[^ \t]*($"	'n-complete-dft	")\n{\n@@\n}\n")
                 (list	"^[ \t]*a$"	'n-complete-replace	"a$" "Array: @@[@@](@@)\n@@")
                 (list	"^[ \t]*c$"	'n-complete-replace	"c$" "x = _log(oCaller, \"@@\");@@")
                 (list	"^[ \t]*e$"	'n-complete-replace	"e$" "end else begin\n@@\n")
                 (list	"^[ \t]*E$"	'n-complete-replace	"E$" "end else if @@ then begin\n@@\n")
                 (list	"^[ \t]*f$"	'n-complete-dft	"or @@ = @@0 to @@ begin\n@@\nend;\n")
                 (list	"^[ \t]*i$"	'n-complete-dft	"f @@ then begin\n@@\nend;\n")
                 (list	".*\\bmp$"	'n-complete-replace	"mp" "MarketPosition@@")
                 (list	".*=N$"	'n-complete-replace	"\\([^a-zA-Z0-9_]\\)\\([a-zA-Z0-9_]*\\)=N$" "\\1\\2=\" + NumToStr(\\2, 3)@@ + \", @@")
                 (list	"^[ \t]*w$"	'n-complete-dft	"hile @@ begin\n@@\nend;\n")
                 (list	"^[ \t]*v$"	'n-complete-dft	"ariable: @@(@@)")
         (list	"^[ \t]*x$"	'n-complete-replace	"x$" "variable: x(0);@@")
         (list	"^[ \t]*X$"	'nez-trace)
         (list	"^[ \t]*2$"	'n-complete-dft	">&1")
         )
        )
        )
  (if (not nez-mode-map)
      (setq nez-mode-map (make-sparse-keymap)))
  (use-local-map nez-mode-map)
  (define-key nez-mode-map " " 'n-complete-or-space)
  (define-key nez-mode-map "\C-a" 'nsimple-back-to-indentation)
  (define-key nez-mode-map "\C-c\C-d" 'nez-debug)
  (define-key nez-mode-map "\C-x " 'nez-toggle-bp)
  (define-key nez-mode-map "\M-\C-g" 'nez-get)
  (define-key nez-mode-map "\M-\C-j" 'nez-put)
  (define-key nez-mode-map "\M-c" 'nez-test)
  )
(defun nez-debug()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (looking-at "#!/bin/sh -x")
        (insert "#!/bin/sh\n")
      (insert "#!/bin/sh -x\n")
      )
    (nsimple-delete-line)
    )
  )

(defun nez-test()
  (interactive)
  (if (string-match "/Strategy/\\(.*\\)$" (buffer-file-name))
      (let(
	   (baseName (n--pat 1 (buffer-file-name)))
	   )
	(n-file-find "$HOME/work/ts/src/midnight")
	(goto-char (point-min))
	(n-s "% " t)
	(delete-region (point) (progn
				 (end-of-line)
				 (point)
				 )
		       )
	(insert baseName)
	)
    )
  (call-interactively 'nmidnight-compile)
  )

(defun nez-toggle-bp( &optional arg)
  (interactive "P")
  )
(defun nez-xfer(op &optional functionType)
  (if (not functionType)
      (setq functionType ""))
  (save-some-buffers t)
  (require 'nfn)
  (let(
       (fn	(buffer-file-name))
       )
    (require 'nshell)
    (nsimple-call-process t (nshell-get-explicit-shell-file-name) nil "ez_xfer.sh" op fn functionType)
    )
  )

(defun nez-put( &optional forTheFirstTime)
  (interactive "P")
  (nsimple-copy-region-as-kill (point-min) (point-max))
  (if forTheFirstTime
      (nez-xfer "put1" (if (string-match "/Function/" (buffer-file-name))
			   (progn
			     (message "What type (n_U_meric/T__rueFalse/S__tring? ")
			     (char-to-string (read-char))
			     )
			 )
		)
    (nez-xfer "put")
    )
  )

(defun nez-get-prep-cutbuffer()
 (nstr-kill "{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Error loading document

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

This document is password protected.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}")
  )

(defun nez-get()
  (interactive)
  (let( 
       (place	(point))
       )
    (nez-get-prep-cutbuffer)
    (nez-xfer "get")
    
    
    (other-window 1);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    (delete-region (point-min) (point-max))
    (yank)
    (goto-char place)
    (message "Fresh ts copy")
    )
  )
(defun nez-get-inputs()
  (save-restriction
    (widen)
    (save-excursion
      (goto-char (point-min))
      (if (n-s "\\b[iI]nputs?: *\\([^;]*\\);")
	  (n--pat 1))
      )
    )
  )
(defun nez-do-variable-x-if-needed()
  (n-loc-push)
  (save-restriction
    (widen)
    (narrow-to-region (point) (point-min))
    (goto-char (point-min))
    (if (not (n-s "variable: x(0);"))
	(insert "variable: x(0);\n"))
    )
  (n-loc-pop)
  )
(defun nez-trace()
  (nez-do-variable-x-if-needed)
  
  (end-of-line)
  (forward-char -1)
  (or (looking-at "X")
      (error "nez-trace: expected X"))
  (delete-char 1)
  
  (let(
       (data (nez-get-inputs))       
       (case-fold-search	t)
       )
    (or data
	(error "nez-trace: no inputs"))
    
    (insert "x = _log(oCaller, \"")
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data)
      
      (goto-char (point-min))
      (replace-regexp "\n" " ")
      
      (goto-char (point-min))
      (replace-regexp " +" " ")
      
      (goto-char (point-min))
      (replace-regexp ", *" "###")
      
      (goto-char (point-min))
      (insert "###")
      
      (goto-char (point-min))
      (replace-regexp "#\\([a-zA-Z0-9_]+\\)(numeric\\(Ref\\)?)" "#\\1=\" + NumToStr(\\1, 3) + \", ")
      
      (goto-char (point-min))
      (replace-regexp "#\\([a-zA-Z0-9_]+\\)(String\\(Ref\\)?)" "#\\1=\" + \\1 + \", ")
      
      (goto-char (point-min))
      (replace-regexp "###" "")
      (replace-regexp " \\+ \", $" "")
      
      (goto-char (point-max))
      )
    (insert ");")
    )
  )
(defun nez-file-copied-hook(oldFileName newFileName)
  (goto-char (point-min))
  (let(
       (oldFunctionName (nfn-prefix oldFileName))
       (newFunctionName (nfn-prefix newFileName))
       )
    (if (and
         oldFunctionName
         newFunctionName
         )
        (progn
          (n-trace "oldFunctionName is %s, newFunctionName is %s"
                   oldFunctionName
                   newFunctionName)
          (goto-char (point-min))
          (replace-regexp (concat "\\b" oldFunctionName)
                          newFunctionName
                          )
          )          
      )
    )
  )