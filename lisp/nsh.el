(provide 'nsh)
(defvar nsh-mode-map nil)
(defun nsh-call-self(&optional before after offsetCol offsetLines )
  (end-of-line)
  (insert "\nbx ")
  (nfly-insert (buffer-file-name))
  (insert " ")
  )
(defun nsh-mode-setup-kbd-map()
  ;;(if (not nsh-mode-map)
  (progn
    (setq nsh-mode-map (make-sparse-keymap))
    (define-key nsh-mode-map " " 'n-complete-or-space)
    (define-key nsh-mode-map "`" 'n-complete-self-insert-command)
    (define-key nsh-mode-map ")" 'nsh-close-paren)
    (define-key nsh-mode-map "\C-a" 'nsimple-back-to-indentation)
    (define-key nsh-mode-map "\C-j" 'nsh-join-lines)
    (define-key nsh-mode-map "\C-c\C-d" 'nsh-debug)
    (define-key nsh-mode-map "\C-cS" 'nc-stringify)
    (define-key nsh-mode-map "\C-x " 'nsh-toggle-bp)
    (define-key nsh-mode-map "\C-x\C-e" 'nsh-evaluate-last-expression)
    (define-key nsh-mode-map [(meta c)] 'nsh-test)
    (define-key nsh-mode-map "\"" 'nsimple-programming-enter-double-quote)
    (define-key nsh-mode-map "'" 'nsimple-programming-enter-single-quote)
    (define-key nsh-mode-map "`" 'nsimple-programming-enter-backwards-quote)
    )
  ;;)
  (use-local-map nsh-mode-map)
  nsh-mode-map
  )

(defun nsh-mode-meat()
  (interactive)
  (setq
   n-comment-boln "#"
   comment-start "#"
   n-comment-end nil
   )

  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (progn
        (insert "#!/bin/bash\n")
        (save-buffer)
        (n-file-chmod "a+x")
        (cond
         ((and (nfn-prefix)
               (string-match "^sensu\." (nfn-prefix))
               )
          (insert ". sensu.inc\n")
          )
         )
        (insert "ruby -wS " (file-name-nondirectory (buffer-file-name)) ".rb \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8\" \"$9\"\nexit")
        (forward-line -1)
        (replace-regexp "\\.sh\\.rb" ".rb")
        (forward-line 0)
        )
    )

  (modify-syntax-entry ?$ ".")
  (make-local-variable 'indent-line-function)
  (setq major-mode 'nsh-mode
        mode-name "nsh mode"
        n-indent-tab 8



        n-indent-in "[^\n \t(]+)$\\|if \\|while \\|else\\|elif\\|for \\|{\\|case \\|foreach"


        n-indent-out "endif\\|fi\\b\\|else\\|done\\|}\\|elif\\|esac\\|;;"
        indent-line-function	'n-indent
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list "^bx $" 'nsh-prepare-for-debug-by-setting-initial-args)
                 (list	".*/d$"	'n-complete-replace	"/d" "[0-9]@@")
                 (list	".*\\bc\\.[0-9]$"	'n-complete-replace	"f\\.\\([0-9]\\)" "awk '{ print $\\1 }'@@")
                 (list	".*\\bf\\.l$"	'n-complete-replace	"f\\.\\([1-9]\\)" "awk '{ print $\\1 }'@@")
                 (list	".*`.*`X$"	'nsh-execute-backticks-and-substitute-output-for-expression)
                 (list	".*/s$"	'n-complete-replace	"/s" "[ \\\\t]@@")
                 (list	".*/w$"	'n-complete-replace	"/w" "[0-9a-zA-Z_]@@")
                 (list	"^[^ \t]*($"	'n-complete-dft	")\n{\n\t@@\n}\n")
                 (list	".*()$"	'nsh-extract-to-separate-script)
                 (list	"^[ \t]+-\\(.\\)?$"	'nsh-default-whatever)
                 (list	"^.*[^ ]!!!$"	'nsh-if-fails-exit-region)
                 (list	"^.*[^ ]!!$"	'nsh-if-succeeds-then)
                 (list	"^.*[^ ]!$"	'nsh-if-fails-exit)
                 (list	"^.*[^ ]!!q$"	'nsh-if-succeeds-quietly-then)
                 (list	"^.*[^ ]!q$"	'nsh-if-fails-quietly-exit)
                 (list	"^.*[^ ]!w$"	'nsh-if-which-fails-then)
                 (list	"^.*[^ ]!wi$"	'nsh-if-which-fails-then-install)
                 (list	".*>0$"	'n-complete-replace ">0"	"> /dev/null 2>&1@@")
                 (list	".*2>0$"	'n-complete-replace "2>0"	"2> /dev/null@@")
                 (list	".*: error: u$"	'nsh-complete-unrecognized)
                 (list	"^\\.c$"	'n-complete-replace "c"	" cache $0 $*\n")
                 (list	"^esx=$"	'n-complete-dft	"`expand_host_name $1`\n@@")
                 (list	"^host=$"	'n-complete-dft	"`expand_host_name $1`\n@@")
                 (list	"^c=$"	'n-complete-replace	"c=" "shift\nconfig=`escape \"\$*\"`\n@@")
                 (list	"^ru$"	'n-complete-replace	"ru" (concat "ruby -w $dp/bin/ruby/" (file-name-nondirectory (buffer-file-name)) "@@.rb\nexit@@"))
                 (list	".*=t$"	'nsh-make-tmp-file-code)
                 (list	".*\"|n"	'n-complete-replace	"|n$" " | lm.q.no_sql\n@@")
                 (list	"^lm="	'n-complete-dft	"`expand_lm_host_name $1`\nif [ -z \"$lm\" ]; then\n exit\n fi\n@@")
                 (list	"^lms="	'n-complete-dft	"$1\n\nfor lm in `expand_lm_host_name $lms`; do\n@@\ndone\n")
                 (list	"^vc="	'n-complete-dft	"`expand_vc_host_name $1`\n@@")
                 (list	"^[ \t]*c$"	'n-complete-dft	"ase @@ in\n@@)\n;;\n*)\n@@\n;;\nesac\n")
                 (list	"^[ \t]*cE$"	'n-complete-replace	"cE" "cat <<EOF | @@\n@@\nEOF\n")
                 (list	"^[ \t]*u$"	'nsh-unsupported-so-exit)
                 (list	".*\\bds.s$"	'n-complete-replace "ds.s" "date '+%Y-%m-%e'@@")
                 (list	".*\\bds.st$"	'n-complete-replace "ds.st" "date '+%Y.%m.%e.%H.%M'@@")
                 (list	"^[ \t]*e$"	'n-complete-dft	"lse\n@@")
                 (list	"^[ \t]*ef$"	'nsh-cannot-find-file-or-dir)
                 (list	"^[ \t]*er$"	'nsh-error-complete)
                 (list	"^[ \t]*E$"	'n-complete-replace	"E"	"elif [ @@ ]; then\n@@")
                 (list	"^[ \t]*C$"	'nsh-make-echo)
                 (list	".* E$"	'nsh-echo-this-line)
                 (list	"^[ \t]*f$"	'n-complete-dft	"or @@f in @@; do\n@@\ndone\n")
                 (list	"^[ \t]*i$"	'n-complete-dft	"f [ @@ ]; then\n@@\nfi\n@@")
                 (list  "^[ \t]*I$"     'n-complete-replace     "I"	"if @@; then\n@@\nfi\n@@")
                 (list	"^[ \t]*l$"	'n-complete-replace	"l"	"elif [ @@ ]; then\n@@\n")
                 (list	"^exit$"	'nsh-call-self)
                 (list	".*| w$"		'n-complete-replace	"| w"	"|\nwhile read fn; do\n@@\ndone\n")
                 (list	"^[ \t]*ssh$"		'n-complete-dft	" -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 @@")
                 (list	"^[ \t]*W$"		'n-complete-replace	"W"	"while read fn; do\n\ndone\n")
                 (list	".*`lm$"		'n-complete-dft	".q.scalar @@$lm \"@@select @@ from @@ where @@\"@@\")")
                 (list	".*lm.q.s$"		'n-complete-dft	" @@$lm \"@@select @@ from @@ where @@\"@@ | lm.q.no_sql@@")
                 (list	".*lm.q$"		'n-complete-dft	" @@$lm \"@@select @@ from @@ where @@\"@@ | lm.q.no_sql@@")
                 (list	"^[ \t]*w$"	'nsh-expand-to-while)
                 (list	"^[ \t]*fj$"	'n-complete-replace "fj" "for (( j = @@0; j < @@; j++ )); do\n@@\ndone\n")
                 (list	"^[ \t]*2$"	'n-complete-dft	">&1")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) D$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) D" "if [ ! -d \"$\\1\" ]; then\necho \"$0: error: could not find directory \\\\\"\\1\\\\\"\" 1>&2\nexit 1\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) F$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) F" "if [ ! -f \"$\\1\" ]; then\necho \"$0: error: could not find file \\\\\"\\1\\\\\"\" 1>&2\nexit 1\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) n$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) n" "if [ -n \"$\\1\" ]; then\n@@\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) F$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) F" "if [ ! -f \"$\\1\" ]; then\necho \"$0: error: could not find file \\\\\"\\1\\\\\"\" 1>&2\nexit 1\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) X$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) X" "if [ ! -x \"$\\1\" ]; then\necho \"$0: error: could not executable file \\\\\"\\1\\\\\"\" 1>&2\nexit 1\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) Z$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) Z" "if [ -z \"$\\1\" ]; then\necho \"$0: error: value expected for \\\\\"\\1\\\\\", but saw nothing\" 1>&2\nexit 1\nfi\n@@\n")
                 (list	"^[ \t]*\\([a-zA-Z0-9_]*\\) z$"	'n-complete-replace "^[ \t]*\\([a-zA-Z0-9_]*\\) z" "if [ -z \"$\\1\" ]; then\n@@\nfi\n@@\n")
                 )
                )
        )
  (nsh-mode-setup-kbd-map)
  )

(defun nsh-unsupported-so-exit()
  (end-of-line)
  (widen)
  (delete-char -1)
  (n-loc-push)
  (let(
       (switch-expression (progn
                            (n-r "^[ \t]*case \\(.*\\) in"t)
                            (nre-pat 1)
                            )
                          )
       (diagnosis       "unsupported")
       what
       )
    (setq switch-expression (nstr-replace-regexp switch-expression "\"" "")
          what     (nstr-replace-regexp switch-expression "[`'\"\\$]" "")
          )
    (cond
     ((string-match "^[0-9]$" what)
      (setq what "argument")
      )
     ((string-match "^host" what)
      (setq diagnosis "unsupported")
      )
     )
    (n-loc-pop)
    ;;(insert "*)")
    ;;(nsimple-newline-and-indent)
    (insert "echo \"$0: error: " diagnosis " " what " " switch-expression "\" 1>&2")
    (nsimple-newline-and-indent)
    (insert "exit 1")
    (indent-according-to-mode)
    
    ;;(nsimple-newline-and-indent)
    ;;(insert ";;")
    )
  )

(defun nsh-expand-to-while()
  (let(
       (templ (if (and (save-excursion
                         (forward-line 0)
                         (looking-at "w$")
                         )
                       (eq (save-restriction
                             (widen)
                             (n-what-line)
                             )
                           2
                           )
                       )
                  "hile [ -n \"$1\" ]; do
                        case \"$1\" in
                                -@@)
                                        @@
                                ;;
                                *)
                                        break
                                ;;
                esac
                        shift
                done
                @@
"
                "hile [ @@ ]; do\n@@\ndone\n@@"
                )
              )
       )
    (n-complete-dft templ)
    )
  )

(defun nsh-ck-for-other-trap()
  (save-restriction
    (widen)
    (let(
         (other-trap-line-no (save-excursion
                               (goto-char (point-min))
                               (if (n-s "^[ \t]*trap ")
                                   (n-loc-push)
                                 )
                               )
                             )
         )
      (if other-trap-line-no
          (insert (format "# Note, there is another trap in this script (m-o to go there), so commenting this one out: "))
        )
      )
    )
  )

(defun nsh-make-tmp-file-code()
  (end-of-line)
  (nelisp-assert-looking-behind "=t")
  (delete-char -1)
  (let(
       (tmp_var_name    (save-excursion
                          (forward-char -1)
                          (n-grab-token)
                          )
                        )
       )
                                        ;     (tmp_path        (concat "${TMP-/tmp}/" (file-name-nondirectory (buffer-file-name)) ".$$." (int-to-string (point))))    ; add point to avoid name collisions
                                        ;     )
                                        ;  (save-excursion
                                        ;    (save-restriction
                                        ;      (widen)
                                        ;      (if (search-backward tmp_path nil t)
                                        ;          (progn
                                        ;            (error "nsh-make-tmp-file-code: oops, name collision, should almost never happen")
                                        ;            )
                                        ;        )
                                        ;      )
                                        ;    )
                                        ;  (insert tmp_path "\n")
    (insert "`mktemp`\n")
    (nsh-ck-for-other-trap)
    (indent-according-to-mode)
    (insert "trap \"rm $" tmp_var_name "\" EXIT\n@@")
    )
  (goto-char (point-min))
  (n-complete-seek)
  )

(defun nsh-debug()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (looking-at "#!/bin/bash -x")
        (insert "#!/bin/bash\n")
      (insert "#!/bin/bash -x\n")
      )
    (nsimple-delete-line)
    )
  )

(defun nsh-test()
  (interactive)
  (require 'nmidnight)
  (let(
       (midnightFile (save-excursion
                       (goto-char (point-max))
                       (if (n-r "^# test in \\(.*\\)")
                           (nre-pat 1)
                         )
                       )
                     )
       )
    (cond
     ((string-match "/bin/cron/" (buffer-file-name))
      (n-host-shell-cmd-visible "cron.update.sh")
      )
     (midnightFile
      (n-file-find midnightFile)
      (delete-other-windows)
      (nmidnight-compile)
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
      ;; (nshell (file-name-directory (buffer-file-name)))
      (nshell)

      (nshell-clear)
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
(defun nsh-evaluate-last-expression()
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

(defun nsh-toggle-bp( &optional arg)
  (interactive "P")
  (cond
   (arg
    (if (y-or-n-p "rm all bp's in current file? ")
	(save-excursion
	  (goto-char (point-min))
	  (while (n-s "^[ \t]*echo nsh-bp .*read __xxxxxx__")
	    (nsimple-delete-line)
	    )
	  )
      )
    )
   (t
    (forward-line 0)
    (if (looking-at "nsh-bp ")
	(nsimple-kill-line)
      (progn
	(insert
	 (format "echo nsh-bp \"%s:%d: %s;;;;;;;;;;;;;;;;;;\"; read __xxxxxx__\n"
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
(defun nsh-gen-cygwin-fn-mapping-script()
  (interactive)
  (let(
       (cmdName (n-grab-token))
       newScriptFn
       )
    (setq newScriptFn  (concat "$NELSON_BIN/cygwin_file_conversion_wrappers/" cmdName))
    (if (n-file-exists-p newScriptFn)
        (error "nsh-gen-cygwin-fn-mapping-script: exists already"))
    (n-file-find newScriptFn)
    (insert "$NELSON_BIN/cygwin_file_conversion_wrappers/convert_cygwin_file_names

convert_from_cygwin_file_names \"")
    (n-loc-push)
    (insert cmdName"\" $*

")
    (n-loc-pop)
    )
  )
(defun nsh-join-lines( &optional arg)
  (interactive "P")
  (nsimple-join-lines-programmatic "fi" "end" "}")
  )

(defun nsh-last-assignment(variable)
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
(defun nsh-check-for-potential-suexec-violation()
  (if (and (save-excursion
             (goto-char (point-min))
             (looking-at ":")
             )
           (y-or-n-p "nsh-check-for-potential-suexec-violation: looks like you are headed for trouble -- switch to #!/bin/bash?")
           )
      (progn
        (delete-char 1)
        (insert "#!/bin/bash")
        )
    )
  )
(defun nsh-file-copied-hook(oldFile fn)
  (save-excursion
    (goto-char (point-max))
    (if (n-r "^exit$")
        (progn
          (forward-line 1)
          (save-restriction
            (n-narrow-to-line)

            (replace-regexp (file-name-nondirectory oldFile)
                            (file-name-nondirectory fn)
                            )
            )
          )
      )
    )
  )
(defun sh-mode()
  (nsh-mode-meat)
  )
(defun nsh-close-paren()
  (interactive)
  (insert ")")
  (if (save-excursion
        (nsimple-back-to-indentation)
	(looking-at "[-|\\$a-zA-Z0-9_\\*\\.]+)$")
        )
      (progn
        (insert "\n;;")
        (indent-according-to-mode)
        (n-open-line)
        (indent-according-to-mode)
        )
    )
  )
(defun nsh-if-fails-quietly-exit()
  (nsh-if-fails-exit t)
  )
(defun nsh-if-fails-exit-region()
  (save-restriction
    (widen)
    (end-of-line)
    (nsimple-delete-backwards-if "!!!")
    (goto-char (point-min))
    (while (not (eobp))
      (end-of-line)
      (nsh-if-fails-exit nil)
      (nsh-join-lines)
      (end-of-line)
      )
    (nsh-if-fails-exit nil)
    )
  )
(defun nsh-if-fails-exit(&optional quietly)
  (nsimple-back-to-indentation)
  (insert "if ! ")
  (let(
       (cmd (buffer-substring-no-properties (point) (progn
                                                      (end-of-line)
                                                      (nsimple-delete-backwards-if "!")
                                                      (point)
                                                      )
                                            )
            )
       )
    (if quietly
        (insert " > /dev/null 2>&1"))
    (insert "; then\n")
    (indent-according-to-mode)
    (setq cmd (nstr-replace-regexp cmd "\"" ""))
    (insert "echo \"$0: " cmd " failed, exiting...\" 1>&2\n")
    (indent-according-to-mode)
    (insert "exit 1\n")
    (insert "fi")
    (indent-according-to-mode)
    (insert "\n")
    (indent-according-to-mode)
    )
  )
(defun nsh-cannot-find-file-or-dir()
  (end-of-line)
  (n-loc-push)
  (let(
       bash-file-op-char
       bash-file-op
       target
       )
    (save-excursion
      (widen)
      (n-r "^[ \t]*if \\[ -\\([dxfrw]\\) \\(.*\\) \\]; then" t)
      (setq bash-file-op-char (string-to-char (nre-pat 1))
            target (nre-pat 2)
            )
      )
    (cond
     ((eq bash-file-op-char ?d) (setq bash-file-op "find directory"))
     ((eq bash-file-op-char ?f) (setq bash-file-op "find file"))
     ((eq bash-file-op-char ?r) (setq bash-file-op "find readable file"))
     ((eq bash-file-op-char ?w) (setq bash-file-op "find writable file"))
     ((eq bash-file-op-char ?x) (setq bash-file-op "find executable file"))
     (t (error "nsh-cannot-find-file-or-dir: unsupported bash-file-op-char %d" bash-file-op-char))
     )
    (n-loc-pop)
    (delete-char -2)
    (insert "else")
    (indent-according-to-mode)
    (insert "\necho $0: error: could not " bash-file-op " at " target ", exiting... 1>&2")
    (indent-according-to-mode)
    (insert "\nexit 1")
    (indent-according-to-mode)
    (forward-line 1)
    )
  )
(defun nsh-tmp-file-make()
  (save-excursion
    (n-open-line)
    (indent-according-to-mode)
    (insert "t=")
    (nsh-make-tmp-file-code)
    )
  )
(defun nsh-if-which-fails-then()
  (end-of-line)
  (nre-delete-by-regexp "!.?" t)
  (nsimple-back-to-indentation)
  (insert "if ! which ")
  (end-of-line)
  (insert " > /dev/null 2>&1; then\n"
          "	@@\n"
          "fi\n")
  (n-indent-push-to-match-line1 (point-min) (point-max))
  (goto-char (point-min))
  (n-complete-leap)
  )
(defun nsh-if-which-fails-then-install()
  (end-of-line)
  (nelisp-assert-looking-behind "!wi")
  (delete-char -1)
  (nsh-if-which-fails-then)
  (let(
       (cmd (save-excursion
              (buffer-substring-no-properties (progn
                                                (n-r " which " t)
                                                (n-s " which " t)
                                                (point)
                                                )
                                              (progn
                                                (n-s ";" t)
                                                (forward-char -1)
                                                (point)
                                                )
                                              )
              )
            )
       )
    (save-restriction
      (n-narrow-to-line)
      (insert "(\n"
              "        @@\n"
              ") > $t 2>&1\n"
              "if ! which " cmd "; then\n"
              "        echo $t \"$0: installing " cmd " failed, exiting...\" 1>&2\n"
              "        exit 1\n"
              "fi")
      (n-indent-push-to-match-line1 (point-min) (point-max))
      (goto-char (point-min))
      (n-complete-leap)
      )
    )
  )
(defun nsh-if-succeeds-quietly-then()
  (nsh-if-succeeds-then t)
  )
(defun nsh-if-succeeds-then(&optional quietly)
  (end-of-line)
  (nre-delete-by-regexp "!!.?" t)
  (nsimple-back-to-indentation)
  (insert "if ")
  (end-of-line)
  (if quietly
      (insert " > /dev/null 2>&1"))
  (insert "; then\n")
  (indent-according-to-mode)
  (insert "@@\n")
  (insert "fi")
  (indent-according-to-mode)
  (goto-char (point-min))
  (n-complete-leap)
  )
(defun nsh-echo-this-line()
  (save-excursion
    (end-of-line)
    (nelisp-assert-looking-behind " E")
    (delete-char -2)

    (save-restriction
      (widen)
      (let(
           (line (n-get-line 'remove-leading-whitespace))
           indentation-equalizer ;; point of this var is to introduce spaces following the command (i.e., token number one) so the arguments line up withcounterparts in the echo statement:
           )
        (forward-line 0)
        (cond
         ((string-match "^if ! " line)
          (n-s "if ! " t)
          (insert " ") ;; "if !  " is even w/ "echo \""
          (setq line (nstr-replace-regexp line "if ! \\(.*\\); then" "\\1")
                indentation-equalizer ""
                )
          )
         ((string-match "^if " line)
          (n-s "if" t)
          (insert " ") ;; "if    " is even w/ "echo \""
          (setq line (nstr-replace-regexp line "if \\(.*\\); then" "\\1")
                indentation-equalizer "  "
                )
          )
         (t
          (setq indentation-equalizer "      ")
          )
         )
        (forward-line 0)
        (indent-according-to-mode)
        (narrow-to-region (point)
                          (progn
                            (insert line)
                            (point)
                            )
                          )
        (nsimple-back-to-indentation)
        (insert "echo \"")
        (replace-regexp "\"" "\\\\\"")
        (end-of-line)
        (insert "\"\n")
        (widen)

        (nsimple-back-to-indentation)
        (narrow-to-region (point) (progn
                                    (end-of-line)
                                    (point)
                                    )
                          )
        (forward-line 0)
        (if (n-s " ")
            (insert indentation-equalizer))
        )
      )
    )
  )
(defun nsh-default-whatever(&optional flavor)
  (end-of-line)
  (n-r "-" t)
  (setq flavor (buffer-substring-no-properties (1+ (point))
                                               (save-excursion
                                                 (end-of-line)
                                                 (point)
                                                 )
                                               )
        )
  (delete-region (point) (progn
                           (end-of-line)
                           (point)
                           )
                 )
  (save-restriction
    (widen)
    (cond
     ((save-excursion
        (forward-line -1)
        (nsimple-back-to-indentation)
        (looking-at "--?\\([0-9a-zA-Z_]+\\))$")
        )
      (let(
           (option-name  (nre-pat 1))
           )
        (cond
         ((string= flavor "v")       ;; "variable" mode, where we are getting a value from the command line
          (insert "shift\n")
          (indent-according-to-mode)
          (insert option-name "=\"$1\"")
          )
         (t                     ;; "mode" mode
          (insert option-name "_mode=yes")
          )
         )
        (save-excursion
          (if (and (n-r "^[^ \t]")
                   (looking-at "while \\[ -n \"\\$1\" \\]; do$")
                   ;;(= 2 (n-what-line))
                   )
              (cond
               ((string= flavor "v")
                (insert option-name "=''\n")
                )
               (t
                (insert option-name "_mode=''\n")
                )
               )
            )
          )
        )
      )
     )
    )
  )
(defun nsh-default-whatever(&optional flavor)
  (end-of-line)
  (n-r "[_-]" t)
  (setq flavor (buffer-substring-no-properties (1+ (point))
                                               (save-excursion
                                                 (end-of-line)
                                                 (point)
                                                 )
                                               )
        )
  (delete-region (point) (progn
                           (end-of-line)
                           (point)
                           )
                 )
  (save-restriction
    (widen)
    (cond
     ((save-excursion
        (forward-line -1)
        (nsimple-back-to-indentation)
        (looking-at "--?\\([0-9a-zA-Z_]+\\))$")
        )
      (let(
           (option-name  (nre-pat 1))
           )
        (cond
         ((string= flavor "v")       ;; "variable" mode, where we are getting a value from the command line
          (insert "shift\n")
          (indent-according-to-mode)
          (insert option-name "=\"$1\"")
          )
         (t                     ;; "mode" mode
          (insert option-name "_mode=yes")
          )
         )
        (save-excursion
          (if (and (n-r "^[^ \t]")
                   (looking-at "while \\[ -n \"\\$1\" \\]; do$")
                   ;;(= 2 (n-what-line))
                   )
              (cond
               ((string= flavor "v")
                (insert option-name "=''\n")
                )
               (t
                (insert option-name "_mode=''\n")
                )
               )
            )
          )
        )
      )
     )
    )
  )
(defun nsh-case-var()
  (save-excursion
    (if (n-r "\\bcase \"?\\$\\([0-9a-zA-Z_]+\\)\"? ")
        (nre-pat 1))
    )
  )
(defun nsh-complete-unrecognized()
  (end-of-line)
  (widen)
  (insert "nrecognized ")
  (let(
       (case-var (nsh-case-var))
       )
    (if case-var
        (progn
          (insert case-var " \"" "$" case-var "\"@@, so exiting")
          (forward-line 0)
          (n-complete-leap)
          )
      )
    )
  )
(defun nsh-error-complete()
  (save-restriction
    (widen)
    (cond
     ((save-excursion
        (forward-line -1)
        (looking-at "[ \t]*if \\[\\( *!*\\) -\\([dfhrs]\\) \\(.*\\) \\]; then$")
        )
      (let(
           (bash_test_inverted  (string= " !" (nre-pat 1)))
           (bash_test  (nre-pat 2))
           (fn  (nre-pat 3))
           (cwd_context "")
           )
        (setq fn (nstr-replace-regexp fn "[`'\"]" ""))
        (end-of-line)
        (delete-char -2)
        ;;(if (not (nfn-full-path-p fn))
        ;;    (setq cwd_context " from `pwd`"))
        (insert "echo \"$0: error: "
                (cond
                 ((string= "s" bash_test)
                  (if bash_test_inverted "empty file"  "non-empty file")
                  )
                 (t
                  (if bash_test_inverted "could not find" "found")
                  )
                 )
                (cond
                 ((string= bash_test "h") " symbolic link")
                 ((string= bash_test "d") " directory")
                 (t "")
                 )
                ;;" \\\"" fn "\\\"" cwd_context "\" 1>&2\n"
                " \\\"" fn "\\\"\" 1>&2\n"
                )
        (indent-according-to-mode)
        (insert "exit 1")
        (n-r "error: " t)
        (n-s ": " t)
        )
      )
     ((save-excursion
        (forward-line -1)
        (looking-at "[ \t]*if \\[ -\\([nz]\\) \"\\$\\(.*\\)\" \\]; then$")
        )
      (let(
           (bash_test  (nre-pat 1))
           (var  (nre-pat 2))
           )
        (end-of-line)
        (delete-char -2)
        (insert "echo \"$0: error: ")
        (if (string= bash_test "n")
            (insert "did not expect a value for \\\"" var "\\\" but saw \\\"$" var "\\\"\" 1>&2\n")
          (insert "expected a value for \\\"" var "\\\" but saw nothing\" 1>&2\n")
          )
        (indent-according-to-mode)
        (insert "exit 1")
        (n-r "error: " t)
        (n-s ": " t)
        )
      )
     ((save-excursion
        (forward-line -1)
        (looking-at "[ \t]*\\*)$")
        )
      (let(
           (unrecognized_case_var  (save-excursion
                                     (n-r "^[ \t]*case \\(.*\\) in" t)
                                     (nre-pat 1)
                                     )
                                   )
           unquoted_case_expr
           )
        (setq unquoted_case_expr      (nstr-replace-regexp unrecognized_case_var "\"" ""))

        (end-of-line)
        (delete-char -2)
        (insert "echo \"$0: error: did not recognize @@"
                unquoted_case_expr
                " \\\"" unquoted_case_expr "\\\"\" 1>&2\n"
                )
        (indent-according-to-mode)
        (insert "exit 1")
        (n-r "did not" t)
        )
      )
     (t
      (end-of-line)
      (delete-char -2)
      (insert "echo \"$0: error: @@\" 1>&2\n")
      (indent-according-to-mode)
      (insert "exit 1\n")
      (forward-line -3)
      (n-complete-leap)
      )
     )
    )
  )
(defun nsh-extract-to-separate-script()
  (widen)
  (narrow-to-region (progn
                      (forward-line 0)
                      (point)
                      )
                    (point-max)
                    )
  (let(
       (routine-name     (buffer-substring-no-properties (point) (progn
                                                                   (n-s "(" t)
                                                                   (forward-char -1)
                                                                   (point)
                                                                   )
                                                         )
                         )
       (script-contents (buffer-substring-no-properties (progn
                                                          (forward-line 2)
                                                          (point)
                                                          )
                                                        (progn
                                                          (n-s "^}" t)
                                                          (forward-line -1)
                                                          (point)
                                                          )
                                                        )
                        )
       script-name
       )
    (setq script-name (concat routine-name ".sh"))
    (delete-region (progn
                     (n-s "^}" t)
                     (forward-line 1)
                     (point)
                     )
                   (point-min)
                   )
    (widen)
    (goto-char (point-min))
    (replace-regexp (concat "\\b" routine-name "\\b")
                    script-name
                    )
    (n-file-find script-name)
    (or (looking-at "ruby")
        (error "nsh-extract-to-separate-script: is this not a new file?")
        )
    (nsimple-delete-line)
    (insert script-contents)
    (goto-char (point-min))
    (replace-regexp "return " "exit ")
    (n-indent-region)
    )
  )
(defun nsh-execute-backticks-and-substitute-output-for-expression()
  (end-of-line)
  (forward-char -2)
  (or (looking-at "`X")
      (error "nsh-execute-backticks-and-substitute-output-for-expression: where am I?")
      )
  (delete-char 2)
  (save-restriction
    (let(
         (back-tick-expr  (progn
                            (narrow-to-region (1- (point))
                                              (progn
                                                (n-r "`" t)
                                                (delete-char 1)
                                                (point)
                                                )
                                              )
                            (buffer-substring-no-properties (point-min) (point-max))
                            )
                          )
         pgm
         pgm_args
         )
      (if (not (string-match "^\\([^ ]*\\) \\(.*\\)" back-tick-expr))
          (setq pgm back-tick-expr
                pgm_args nil
                )
        (setq pgm (nre-pat 1 back-tick-expr)
              pgm_args (nre-pat 2 back-tick-expr)
              )
        (setq pgm_args  (nstr-split pgm_args))
        )
      (delete-region (point-min) (point-max))
      (apply 'call-process pgm nil t nil pgm_args)
      ;; chomp if appropriate
      (save-excursion
        (forward-char -1)
        (if (looking-at "\n")
            (delete-char 1))
        )
      )
    )
  )
(defun nsh-make-echo()
  (delete-char 1)
  (save-restriction
    (widen)
    (insert "echo \"")
    (if (looking-at "$")
        (progn
          (insert "\"")
          (forward-char -1)
          )
      (n-narrow-to-line)
      (replace-regexp "\"" "\\\\\"")
      (end-of-line)
      (insert "\"")
      )
    )
  )
(defun nsh-prepare-for-debug-by-setting-initial-args()
  (save-restriction
    (save-excursion
      (widen)

      (let(
           (invocation (progn
                         (or (looking-at "bx \\(.*\\)")
                             (error "nsh-prepare-for-debug-by-setting-initial-args: ")
                             )
                         (nre-pat 1)
                         )
                       )
           unorthodox_structure_I_will_step_away_from
           args
           assignee
           (settings "")
           last-setting-pt
           )
        (setq args (cdr   ;; to skip $0
                    (nstr-split invocation)
                    )
              )
        (goto-char (point-min))
        (n-s "\\${?1" t)
        (forward-line 0)
        (while args
          (if (not (looking-at "\\([a-zA-Z0-9_]*\\)=\\${?[0-9]"))
              (setq args nil
                    unorthodox_structure_I_will_step_away_from t
                    )     ;; some unorthox structure here, maybe processing in *.inc?  Just forget it...
            (setq assignee (nre-pat 1)
                  settings (concat settings
                                   assignee
                                   "=\""
                                   (car args)
                                   "\"\n"
                                   )
                  args (cdr args)
                  last-setting-pt (point)
                  )
            (forward-line 1)
            )
          )
        (if unorthodox_structure_I_will_step_away_from
            (message "cannot find the args to set for debug")
          (n-loc-push)
          (delete-other-windows)
          (nsimple-split-window-vertically)
          (nshell)
          (nshell-clear)
          (insert settings)
          (nshell-send-input)
          (n-other-window)
          (insert settings)
          (goto-char last-setting-pt)
          (forward-line 1)
          )
        )
      )
    )
  )
