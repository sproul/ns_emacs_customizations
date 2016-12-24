(provide 'nmenu-edit)
(defvar nmenu-edit-mode-map nil)
(defun nmenu-edit-mode-meat()
  (interactive)
  (setq
   case-fold-search t
   )

  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (insert "nmenu-edit-mode-meat beginning\n")
    )
  (make-local-variable 'indent-line-function)
  (setq major-mode 'nmenu-edit-mode
        mode-name "nmenu-edit mode"
        n-indent-tab 8
        n-indent-in "{"
        n-indent-out "}"
        indent-line-function	'n-indent
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	".*ht"	'n-complete-replace	"ht$" "http://www.@@.com/@@")
                 )
                )
        )
  (if (not nmenu-edit-mode-map)
      (setq nmenu-edit-mode-map (make-sparse-keymap)))
  (use-local-map nmenu-edit-mode-map)
  (define-key nmenu-edit-mode-map "\M-\"" 'nmenu-edit-2-lines)
  (define-key nmenu-edit-mode-map "\M-c" 'nmenu-edit-compile)
  )
(defun nmenu-edit-2-lines-prep-for-new-key()
  (n-s "[^ \t]" t)
  (delete-char -1)
  (insert "@@")
  (forward-line 0)
  (n-complete-leap)
  )

(defun nmenu-edit-2-lines( &optional arg)
  (interactive "P")
  (require 'n-2-lines)
  (save-restriction
    (cond
     ;; If arg, then a subcategory is desired.
     (arg
      (n-narrow-to-line)
      (n-2-lines)
      (forward-line -1)
      (save-restriction
	(n-narrow-to-line)
	(if (n-s "http:")
	    (progn
	      (forward-word -1)
	      (delete-region (point) (point-max))
	      )
	  )
	)
      (end-of-line)
      (just-one-space)
      (insert "@@\n{")

      (forward-line 1)
      (nmenu-edit-2-lines-prep-for-new-key)
      (insert "@@")
      (end-of-line)
      (insert "\n}")
      (goto-char (point-min))
      (widen)
      (n-indent-region)
      (n-complete-leap)
      )
     (t
      (n-2-lines)
      (forward-line 0)

      (nmenu-edit-2-lines-prep-for-new-key)
      )
     )
    )
  )
(defun nmenu-edit-compile-generate-comment(target)
  (cond
   ((string-match "https?://\\([^/]*\\)" target)
    (n--pat 1 target)
    )
   (t
    target	;; crude -- but the target itself can serve as its own comment
    )
   )
  )

(defun nmenu-edit-compile()
  (interactive)
  (require 'n-prune-buf)
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       )
    (nmenu-go-from-menu-data-to-lisp-data)
    (delete-region (point-min) (point-max))

    (insert data)
    (tabify (point-min) (point-max))

    ;; get data onto same line as comment, e.g., change
    ;;
    ;; 	e euro course on java, includes struct, but spread out over lots o' pages
    ;;				browse http://www.xs4all.nl/~mpdeboer/scriptie/
    ;;
    ;; to
    ;;
    ;; 	e euro course on java, includes struct, but spread out over lots o' pages	browse http://www.xs4all.nl/~mpdeboer/scriptie/
    ;;
    ;;
    (goto-char (point-min))
    (replace-regexp "\n\t+\\([0-9a-zA-Z_][0-9a-zA-Z_]\\)" "\t\\1")

    (goto-char (point-min))
    (replace-regexp "[ \t]*$" "")

    (n-prune-buf "^[0-9a-zA-Z_][0-9a-zA-Z_]")

    (goto-char (point-min))
    (replace-regexp "^[ \t]*#.*\n" "")

    ;; pull left braces up onto 'parent' lines to distinguish them from normal choice lines
    (goto-char (point-min))
    (replace-regexp "\n\t*{" " {")

    ;; gen a comment for those choices which don't have one already
    (goto-char (point-min))
    (while (n-s "^[ \t]*[^ \t]\t+\\([^\t\n{]+\\)$")
      (forward-line 0)
      (forward-word 1)
      (insert " " (nmenu-edit-compile-generate-comment (n--pat 1)))
      )

    ;; replace {...} with LISP for sub lists
    (goto-char (point-min))
    (replace-regexp "\\([ \t]*[0-9a-zA-Z_]\\)[ \t]*\\(.*\\) {" "\\1 (list \"\\2\"")
    (goto-char (point-min))
    (replace-regexp "^[\t ]*}[\t ]*$" "))")

    ;; add quotes and cons' to targets and comments
    (goto-char (point-min))
    (replace-regexp "^\\([ \t]*[^ \t][ \t]+\\)\\([^\t\n]+\\)\t+\\([^\t\n]+\\)$"
		    "\\1(cons \"\\2\" \"\\3\"))")

    ;; add cons and LISP '?' char notation to choice letters
    (goto-char (point-min))
    (replace-regexp "^\\([ \t]*\\)\\([^ \t][ \t\n]\\)" "\\1(cons ?\\2")

    (goto-char (point-min))
    (insert "(setq " (nfn-prefix) "\n" "(list\n")
    (goto-char (point-max))
    (insert "\n\t)\n\t)\n")
    (nelisp-compile)
    (nbuf-kill-current)
    (exit-recursive-edit)
    )
  )
