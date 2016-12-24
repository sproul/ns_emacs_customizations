(provide 'nmenu)
(defvar nmenu-aborted nil)
(setq nmenu-backed-out nil)
(setq nmenu-to-clipboard-mode nil)

(defun nmenu-get-file-name-stem(name)
  (let(
       (suffix	(if (string-match "\\([^_]*\\)_.*$" name)
                    (n--pat 1 name)
                  name
                  )
                )
       )
    (concat "$dp/emacs/lisp/data/n-data-menu-" suffix)
    )
  )
(defun nmenu-go-to-source(target)
  (let(
       (stem (n-host-to-canonical (nmenu-get-file-name-stem nmenu-name)))
       file-name
       )
    (cond
     ((file-exists-p (concat stem ".menu"))
      (find-file     (concat stem ".menu"))
      )
     ((file-exists-p (concat stem ".dat"))
      (find-file     (concat stem ".dat"))
      )
     ((file-exists-p (concat stem ".el"))
      (find-file     (concat stem ".el"))
      )
     (t
      (error "nmenu-go-to-source: ")
      )
     )
    )
  (if (string= (file-name-nondirectory (buffer-file-name)) "n-data-menu-nbuf-shortcuts.el")
      (progn
        (goto-char (point-min))
        (n-s (concat " n-data-menu-nbuf-shortcuts_" n-env "$") t)
        (n-s "\"" t)
        )
    (if target
        (progn
          (goto-char (point-min))
          (if (n-s (nre-make-pattern (concat target "$")))
              (nsimple-back-to-indentation))
          )
      )
    )
  (recursive-edit)
  )
(defun nmenu-goto-data-file(name)
  (let(
       (file-name name)
       )
    (if (not (file-exists-p file-name))
        (setq file-name (concat (nmenu-get-file-name-stem name) ".dat")))
    (if (file-exists-p file-name)
        (progn
          (find-file file-name)
          (nsort-buf)
          t
          )
      )
    )
  )

(defun nmenu-exists(name)
  (or (file-exists-p name)
      (file-exists-p (concat (nmenu-get-file-name-stem name) ".dat"))
      (file-exists-p (concat (nmenu-get-file-name-stem name) ".el"))
      )
  )
(defun nmenu-construct-list-from-data()
  (let(
       (hot-keys "0123456789abcdefghijklmnopqrstuvwxyz")
       lineNumber
       value
       )
    (goto-char (point-min))
    (forward-line (length hot-keys))
    (setq lineNumber (1- (n-what-line)))
    (while (and (> lineNumber 0)
                (not (bobp))
                )
      (forward-line -1)
      (setq lineNumber	(1- lineNumber)
            value	(cons
                         (cons
                          (elt hot-keys lineNumber)
                          (n-get-line)
                          )
                         value
                         )
            )
      )
    value
    )
  )

(defun nmenu-get-val(name)
  (if (not (string-match "^nbuf-shortcuts_" name))
      (n-database-load (concat "n-data-menu-" name))
    (n-load "data/n-data-menu-nbuf-shortcuts.el")
    (let*(
          (shortcuts-name       (concat "n-data-menu-" name))
          (lst                 (intern-soft shortcuts-name))
          )
      (if lst
          (eval lst)
        n-data-menu-nbuf-shortcuts-common
        )
      )
    )
  )

(defun nmenu-list(src)
  (cond
   ((stringp src)
    (setq nmenu-name src)
    (let(
         (val (nmenu-get-val nmenu-name))
         )


      (save-window-excursion
        (if val
	    val
          (if (nmenu-goto-data-file nmenu-name)
              (nmenu-construct-list-from-data))
          )
        )
      )
    )
   (t src)
   )
  )
(defun nmenu-choose(prompt &optional src inputCharacter default list)
  "present PROMPT to the user, along with a menu from the
menu variable SRC (which can be a string naming a menu
variable"
  (setq nmenu-backed-out nil)
  (setq nmenu-to-clipboard-mode nil)

  (if (not src)
      (setq src prompt))
  (setq nmenu-aborted nil)
  (if (not list)
      (setq list (nmenu-list src)))
  (setq list (nmenu-resolve-list-items list))

  (require 'nmini)
  (let(
       (nmenu-from-minibuffer	(nmini-p))
       saved-minibuffer
       value
       )
    (condition-case nil
        (unwind-protect
            (save-window-excursion
              (if nmenu-from-minibuffer
                  (progn
                    (setq saved-minibuffer (buffer-substring-no-properties (point-min) (point-max)))
                    (other-window 1)
		    ;;			  (require 'nmini)
                    ;;                    (nmini-maximize)
                    )
                )
              (switch-to-buffer (get-buffer-create "*menu*"))
              (delete-other-windows)
              (setq value (nmenu-choose-prompt prompt list inputCharacter default))
              (if (not nmenu-to-clipboard-mode)
                  value
                (nstr-clipboard-win-only
                 (nstr-replace-regexp value "\\([-a-z_A-Z0-9]+:\\)http" "http")
                 )
                nil
                )
              )
          (nbuf-kill "*menu*")
          (if nmenu-from-minibuffer
              (insert saved-minibuffer)
            )
          )
      (quit
       (setq nmenu-aborted t)
       nil
       )
      )
    )
  )
(defun nmenu-message(string &rest arguments)
  (let(
       (string2	(apply 'format string arguments))
       )
    (goto-char (point-min))
    (delete-region (point) (progn
                             (end-of-line)
                             (point)
                             )
                   )
    (insert string2)
    )
  )
(defun nmenu-choose-prompt(prompt list2 &optional inputCharacter default)
  (let(
       cmd
       rc
       z
       )
    (setq rc
          (catch 'nmenu-choose
            (loop

             (if (buffer-file-name)
                 (error "nmenu-choose-prompt: should be a tmp buf w/ no file behind it, but I see %s"  (buffer-file-name)))
             (erase-buffer)
             (if (not inputCharacter)
                 (nmenu-dsp prompt list2))

             (if inputCharacter
                 (setq cmd inputCharacter)
               (condition-case nil
                   (setq cmd (read-char))
                 (error
                  (throw 'nmenu-choose nil)
                  )
                 )
               )
             (setq inputCharacter	nil
                   elt		(assoc cmd list2)
                   nmenu-backed-out	(or
                                         (= 127 cmd)  ; backspace
                                         (= 4   cmd)  ; backspace under win cygwin X windows, where backspace seems to be unstoppably mapped to Ctrl-D
                                         )
                   )
             (if (eq cmd 11) ; ^K
                 (setq nmenu-to-clipboard-mode t)
               (cond
                (nmenu-backed-out
                 (throw 'nmenu-choose nil)
                 )
                ;;((and (listp elt) (= 1 (length elt)))
                ((and (listp elt)
                      (cdr elt)
                      (stringp (cdr elt))
                      )
                 (throw 'nmenu-choose (cdr elt))
                 )
                ((and (listp elt)
                      (cdr elt)
                      (cddr elt)
                      (stringp (cddr elt))
                      )
                 (throw 'nmenu-choose (cddr elt))
                 )
                ((and elt
                      (listp elt)
                      (stringp (cadr elt))        ; submenu prompt
                      (listp (cddr elt))          ; submenu
                      (consp (caddr elt))         ; submenu entry 1
                      )
                 (setq z (nmenu-choose-prompt (cadr elt) (cddr elt)))
                 (if (stringp z)
                     (throw 'nmenu-choose z))
                 )
                ((and elt
                      (listp elt)
                      (stringp (cadr elt))        ; related file 1
                      (listp (cdr elt))           ; set of related files
                      (stringp (caddr elt))       ; submenu entry 2
                      )
                 ;;(message "%s - %s" (prin1-to-string this-command) (prin1-to-string last-command))
                 ;;(sleep-for 3)
                 (if (or (eq last-command 'n-complete-beginning-of-buffer)
                         (eq last-command this-command)
                         )
                     ;; cycle the set of related files so we get the next one on the next try
                     (setcdr elt (nlist-cycle (cdr elt)))
                   )
                 (throw 'nmenu-choose (cadr elt))
                 )
                ((or (= cmd ?)
                     (= cmd ?,)
                     (and (>= cmd 1) (<= cmd 26))	; control key?
                     (>= cmd 176)               ; meta key?
                     (< cmd 0)                ; meta key?
                     )
                 (n-ungetc cmd)
                 (throw 'nmenu-choose nil)
                 )
                ((or (= cmd ?.)
                     (= cmd ? )
                     (= cmd 127)
                     )
                 (throw 'nmenu-choose default)
                 )
                ((= cmd ??)
                 (save-window-excursion
                   (nmenu-go-to-source prompt)
                   (throw 'nmenu-choose (nmenu "" nmenu-name))
                   )
                 )
                (t	(nmenu-message "?"))
                )
               )
       )
            )
          )
    rc
    )
  )

(defun nmenu-get-item-data(elt)
  (if (nmenu-item-is-commented-single elt)
      (nmenu-get-data-from-commented-single elt)
    (cdrelt)
    )
  )

(defun nmenu-item-is-commented-single(elt)
  (and (listp (cdr elt))
       (stringp (nmenu-get-data-from-commented-single elt))
       (stringp (nmenu-get-comment-from-commented-single elt))
       )
  )

(defun nmenu-get-data-from-commented-single(elt)
  (cddr elt)
  )
(defun nmenu-get-comment-from-commented-single(elt)
  (cadr elt)
  )


(defun nmenu-dsp(prompt list2)
  (message "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
  (let(
       (hook (if (and
                  (symbolp(car list2))
                  (fboundp (car list2))
                  )
                 (prog1
                     (car list2)
                   (setq list2 (cdr list2))
                   )
               )
             )
       isSublist
       isCommentedSingle
       elt
       )
    (if prompt
        (insert prompt "\n"))
    (while list2
      (setq elt	(car list2)
            list2		(cdr list2)
	    isCommentedSingle	(nmenu-item-is-commented-single elt)
	    isSublist		(and (listp (cdr elt))
				     (not isCommentedSingle)
				     )
	    )
      (insert (char-to-string (car elt)) "  ")
      (cond
       (isCommentedSingle
	(insert (nmenu-get-comment-from-commented-single elt))
	(if (> (current-column) 40)
	    (insert "\n"))
	(indent-to-column 40)
	(insert " " (nmenu-get-data-from-commented-single elt))
	)
       (isSublist
	(insert (cadr elt))
	)
       (t
        (insert (cdr elt))
	)
       )

      (insert "\n")
      )
    )
  )
(defun nmenu-go-from-menu-data-to-lisp-data()
  (let(
       (here (buffer-file-name))
       )
    (find-file (nstr-replace-regexp here "\\.menu$" ".el"))
    )
  )

(defun nmenu-highlight-point(on)
  (save-window-excursion
    (other-window 1)
    (forward-line 0)
    (nterminal-highlight on)
    )
  )

(defun nmenu-brief(prompt src &optional default)
  (nmenu-highlight-point t)
  (let(
       (cmd (progn
	      (if default
		  (setq prompt (concat prompt " (" default ")")))
	      (message prompt)
	      (read-char)
	      )
	    )
       )
    (prog1
	(if (eq cmd ??)
	    (nmenu prompt src nil default) ;; display menu
	  (nmenu prompt src cmd default)
	  )
      (nmenu-highlight-point nil)
      )
    )
  )
(defun nmenu-mode-toggle-prompt(mode-variable)
  "This routine can be used to construct a prompt to change the variable."
  (if mode-variable
      "end"
    "begin"
    )
  )
(defun nmenu-choose-shortcut-fileOffsetCons(&optional cmd)
  (let(
       (x (nmenu nil (concat "nbuf-shortcuts_" n-env) cmd))
       fn
       offset
       )
    (if (string-match "\\(.*\\):\\([0-9]+\\)$" x)
        (setq fn (nre-pat 1 x)
              offset (nre-pat 2 x)
              )
      (setq fn x
            offset nil
            )
      )
    (cons fn offset)
    )
  )
(defun nmenu-choose-shortcut-file(&optional cmd)
  (car (nmenu-choose-shortcut-file cmd))
  )
(defun nmenu-choose-shortcut-java-object(&optional cmd)
  (let(
       (fn (nmenu-choose-shortcut-file cmd))
       )
    (or (string-match "/\\([^/]*\\)\\.java$" fn)
        (error "nmenu-choose-shortcut-java-object: you have to pick a java file in this context, not %s" fn)
        )
    (n--pat 1 fn)
    )
  )
(defun nmenu-resolve-list-items(list)
  (let(
       (list1 list)
       list2
       key-val-pair
       key
       val
       )
    (while list1
      (setq key-val-pair (car list1)
            list1       (cdr list1)
            key         (car key-val-pair)
            val         (cdr key-val-pair)
            )
      (if (listp val)
          (if (string= "first_file_that_exists" (car val))
              (setq val (n-file-first-file-that-exists val))
            )
        )
      (setq list2 (cons (cons key val)
                        list2
                        )
            )
      )
    (nreverse list2)
    )
  )
