(provide 'nps1)
(defvar nps1-mode-map nil)
(defun nps1-call-self(&optional before after offsetCol offsetLines )
  (end-of-line)
  (insert "\nps1 -x ")
  (nfly-insert (buffer-file-name))
  (insert " ")
  )
(defun nps1-mode-setup-kbd-map()
  ;;(if (not nps1-mode-map)
  (progn
    (setq nps1-mode-map (make-sparse-keymap))
    (define-key nps1-mode-map " " 'n-complete-or-space)
    (define-key nps1-mode-map "`" 'n-complete-self-insert-command)
    (define-key nps1-mode-map "\C-a" 'nsimple-back-to-indentation)
    (define-key nps1-mode-map "\C-j" 'nps1-join-lines)
    (define-key nps1-mode-map "\C-c\C-d" 'nps1-debug)
    (define-key nps1-mode-map "\C-cS" 'nc-stringify)
    (define-key nps1-mode-map "\C-x " 'nps1-toggle-bp)
    (define-key nps1-mode-map "\C-x\C-e" 'nps1-evaluate-last-expression)
    (define-key nps1-mode-map [(meta c)] 'nps1-test)
    )
  ;;)
  (use-local-map nps1-mode-map)
  nps1-mode-map
  )

(defun nps1-mode-meat()
  (interactive)
  (setq
   n-comment-boln "#"
   comment-start "#"
   n-comment-end nil
   )

  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (if (string= (nfn-suffix) "cgi")
          (insert "#!/bin/sh\n")
        (insert ":\n")
        )
    )
  (modify-syntax-entry ?$ ".")
  (make-local-variable 'indent-line-function)
  (setq major-mode 'nps1-mode
        mode-name "nps1 mode"
        n-indent-tab 8



        ;;n-indent-in "[^\n \t(]+)$\\|if \\|while \\|else\\|elif\\|for \\|{\\|case \\|foreach"
        ;;n-indent-out "endif\\|fi\\b\\|else\\|done\\|}\\|elif\\|esac\\|;;"


        n-indent-in "{"
        n-indent-out "}"

        indent-line-function	'n-indent
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"^[^ \t]*($"	'n-complete-dft	")\n{\n@@\n}\n")
                 (list	"^[ \t]*c$"	'n-complete-replace	"c" "switch (@@)\n{\n@@\n{\n@@\n}\n@@\n{\n@@\n}\ndefault\n{\n@@\n}\n}\n@@")
                 (list	"^[ \t]*d$"	'n-complete-dft	"o\n{\n@@\n}\nwhile (@@)\n@@")
                 (list	"^[ \t]*e$"	'n-complete-dft	"lse\n{\n@@\n}\n@@")
                 (list	"^[ \t]*E$"	'n-complete-replace	"E"	"else if ( @@ )\n{\n@@\n}\n@@")
                 (list	"^[ \t]*f$"	'n-complete-dft	"oreach($j in @@..@@)\n{\n@@\n}\n@@")
                 (list	"^[ \t]*F$"	'n-complete-dft	"oreach($f in @@, @@)\n{\n@@\n}\n@@")
                 (list	"^[ \t]*i$"	'n-complete-dft	"f ( @@ )\n{\n@@\n}\n@@")
                 (list	"^exit$"	'nps1-call-self)
                 (list	"^[ \t]*w$"	'n-complete-dft	"hile (@@)\n{\n@@\n}\n@@")
                 )
            )
        )
  (nps1-mode-setup-kbd-map)
  )
(defun nps1-debug()
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

(defun nps1-test()
  (interactive)
  (require 'nmidnight)
  (let(
       (midnightFile (save-excursion
		       (goto-char (point-max))
		       (if (n-r "^# test in ")
			   (progn
			     (end-of-line)
			     (n-grab-token)
			     )
			 )
		       )
		     )
       )
    (cond
     (midnightFile
      (n-file-find midnightFile)
      (delete-other-windows)
      ;;(nelisp-bp "nps1-test" "nps1.el<2>..." 78);;;;;;;;;;;;;;;;;
      (nmidnight-compile)
      ;;(nelisp-bp "nps1-test" "nps1.eldone<2>" 80);;;;;;;;;;;;;;;;;
      )
     ((save-excursion
	(goto-char (point-max))
	(or (save-excursion
	      (not (n-r "^exit"))
	      )
	    (and (n-r "^exit")
		 (looking-at "exit 0")
		 )
	    )
	)
      (nmidnight-compile)
      )
     (t
      (save-some-buffers t)
      (delete-other-windows)
      (nsimple-split-window-vertically)

      ;; decided this (cd to `dirname this_buf`) hurts more than it helps...
      ;; (nps1ell (file-name-directory (buffer-file-name)))
      (nps1ell)

      (nps1ell-clear)
      (other-window 1)
      (save-excursion
	(goto-char (point-max))
	(if (n-r "^exit")
	    (progn
	      (forward-line 1)

	      (require 'n-mv-line)
	      (n-mv-line 'all-the-lines)
	      )
	  )
	)
      (other-window 1)
      )
     )
    )
  )
(defun nps1-evaluate-last-expression()
  (interactive)
  (let(
       (token (n-grab-file-get-token))
       value
       )
    (setq value (nsimple-env-expand token)) 

    (if (getenv value)
	(setq value (getenv value)))

    (message "%s" value)
    )
  )

(defun nps1-toggle-bp( &optional arg)
  (interactive "P")
  (cond
   (arg
    (if (y-or-n-p "rm all bp's in current file? ")
	(save-excursion
	  (goto-char (point-min))
	  (while (n-s "^[ \t]*echo nps1-bp .*read __xxxxxx__")
	    (nsimple-delete-line)
	    )
	  )
      )
    )
   (t
    (forward-line 0)
    (if (looking-at "nps1-bp ")
	(nsimple-kill-line)
      (progn
	(insert
	 (format "echo nps1-bp \"%s:%d: %s;;;;;;;;;;;;;;;;;;\"; read __xxxxxx__\n"
		 (buffer-name)
		 (n-what-line)
		 (n-defun-name)
		 )
	 )
	(forward-char 1)
	)
      )
    )
   )
  )
(defun nps1-gen-cygwin-fn-mapping-script()
  (interactive)
  (let(
       (cmdName (n-grab-token))
       newScriptFn
       )
    (setq newScriptFn  (concat "$NELSON_BIN/cygwin_file_conversion_wrappers/" cmdName))
    (if (n-file-exists-p newScriptFn)
        (error "nps1-gen-cygwin-fn-mapping-script: exists already"))
    (n-file-find newScriptFn)
    (insert "$NELSON_BIN/cygwin_file_conversion_wrappers/convert_cygwin_file_names

convert_from_cygwin_file_names \"")
    (n-loc-push)
    (insert cmdName "\" $*

")
    (n-loc-pop)
    )
  )
(defun nps1-join-lines( &optional arg)
  (interactive "P")
  (if (and (not arg)
           (save-excursion
             (nsimple-back-to-indentation)
             (looking-at "fi *$")
             )
           (save-excursion
             (forward-line 1)
             (not (looking-at "[ \t]*$")
                  )
             )
           )
      (progn
        (forward-line 1)
        (nsimple-transpose-lines)
        )
    (call-interactively 'nsimple-join-lines)
    )
  )

(defun nps1-last-assignment(variable)
  (save-match-data
    (save-excursion
      (cond
       ((n-r (concat "\\b" variable "='\\([^']+\\)'"))
        (n--pat 1)
        )
       ((n-r (concat "\\b" variable "=\"\\([^\"]+\\)\""))
        (n--pat 1)
        )
       ((n-r (concat "\\b" variable "=\\(.*\\)"))
        (n--pat 1)
        )
       )
      )
    )
  )
