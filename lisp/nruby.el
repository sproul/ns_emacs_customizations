(if (not (boundp 'nruby-mode))
    (defun nruby-mode()
      (setq mode-name "nruby")
      (nruby-mode-hook)
      )
  )

(defun nruby-mode-hook()
  (n-load "ri-ruby.el")
  (local-set-key "\C-cw" 'ri-ruby-show-args)
  (local-set-key "	" 'n-complete-leap)
  ;;(local-set-key "\M-w" 'ri)
  (local-set-key "\M-w" 'ntags-find-where)
  ;;(local-set-key "\M-/" 'ri-ruby-complete-symbol)
  (local-set-key "\M-/" 'nsimple-dabbrev-expand)
  (local-set-key "\C-\M-a" 'n-env-grap)
  (local-set-key "\C-\M-e" 'nelisp-scratch-init)
  (local-set-key "\C-j" 'nruby-join-lines)
  (local-set-key "\C-m" 'nruby-reindent-then-newline-and-indent)
  (local-set-key "\"" 'nsimple-programming-enter-double-quote)
  (local-set-key "'" 'nsimple-programming-enter-single-quote)
  (local-set-key "`" 'nsimple-programming-enter-backwards-quote)

  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	".*\\bT$" 'n-complete-replace "T" "true@@")
                 (list	"^A$" 'nruby-make-argv-processor)
                 (list	".*\\bF$" 'n-complete-replace "F" "false@@")
                 (list	"^[ \t]*Test_channel.analyze_channel(.*)[lh]" 'nruby-channel-test-debug-setup)
                 (list	"^[ \t]*Test_channel.analyze_channel(.*)-" 'nruby-channel-test-debug-rm)
                 (list	"^[ \t]*i$"	'n-complete-dft	"f @@\n@@\nend\n@@")
                 (list	".* = 123\\(4\\(5\\(6\\(7\\(89?\\)?\\)?\\)?\\)?\\)?$"	'nruby-expand-placeholders)
                 (list	"^[ \t]*\\([^ \t]+\\)($"	'n-complete-replace	"^\\([ \t]*\\)\\([^ \t]+\\)($" "\\1def \\2(@@)\n@@\nend\n@@")
                 (list	"^esx="	'n-complete-dft	"`expand_host_name $1`.chomp\n@@")
                 (list	".*\\bA$"	'n-complete-dft	"RGV@@[@@]@@.length@@")
                 (list	"^host="	'n-complete-dft	"`expand_host_name $1`.chomp\n@@")
                 (list	"^c$"	'nruby-class-skeleton)
                 (list	"^lm="	'n-complete-dft	"`expand_lm_host_name $1`.chomp\nif lm==\"\"\nexit\n end\n@@")
                 (list	"^lms="	'n-complete-dft	"$1\n\nfor lm in `expand_lm_host_name $lms`; do\n@@\ndone\n")
                 (list	"^vc="	'n-complete-dft	"`expand_vc_host_name $1`.chomp\n@@")
                 (list	"^[ \t]*a$"	'n-complete-dft	"ttr_accessor :@@")
                 (list	"^[ \t]*C$"	'n-complete-replace "C"	"case @@\nwhen @@\n@@\nwhen @@\n@@\nelse\n@@\nend\n@@")
                 (list	"^[ \t]*c$"	'n-complete-replace "c"	"puts @@")
                 (list	"^[ \t]*-$"	'nruby-default-stuff)
                 (list	"^[ \t]*l$"	'nruby-log)
                 (list	"^[ \t]*puts s$"	'n-complete-replace "puts s"	"puts sprintf(\"@@\", @@)@@")
                 (list	"^[ \t]*puts .*\";$"	'nruby-add-trace-conditional)
                 (list	"^[ \t]*e$"	'n-complete-dft	"lse\n@@")
                 (list	"^[ \t]*E$"	'n-complete-replace	"E"	"elsif @@\n@@")
                 (list	"^[ \t]*elsif $"	'nruby-repeat-if-clause)
                 (list	"^[ \t]*i$"	'n-complete-dft	"f @@\n@@\nend\n@@")
                 (list	"^[ \t]*I$"	'n-complete-replace	"I" "initialize(@@)\n@@\nend\n@@")
                 (list	".*\\.e$"	'n-complete-dft	"ach{|@@| @@}\n@@")
                 (list	".*\\.ep$"	'n-complete-replace "ep"	"each_pair{|@@, j| @@}\n@@")
                 (list	".*\\.ew$"	'n-complete-replace "ew"	"each_with_index{|@@, @@| @@}\n@@")
                 (list	".*\\.EP$"	'nruby-make-each-block nil "pair")
                 (list	".*\\.EW$"	'nruby-make-each-block nil "with_index")
                 (list	".*\\.E$"	'nruby-make-each-block)
                 (list	".*\\.G$"	'nruby-make-class-var)
                 (list	".*\\.re$"	'n-complete-replace "e$"	"reverse_each{|| @@}\n@@")
                 (list	".*\\.RE$"	'nruby-make-each-block "reverse_")

                 (list	".*[`\"].*#$"	'nruby-make-interpolation)
                 (list	"^[ \t]*W$"	'n-complete-replace "W"	"while @@ do\nend\n@@")
                 (list	".*\\.D$"	'n-complete-replace ".D"	" do |@@|\n@@\nend\n@@")
                 (list	"^[ \t]*w$"	'n-complete-dft	"hile @@ { @@ }")
                 (list	".*\\bs$"	'n-complete-dft	"elf.@@")
                 (list	".*\\.ep$"	'n-complete-replace "ew"	"each_pair{|@@, j| @@}\n@@")
                 (list	"^q$"	'n-complete-replace "q"	"require '@@'\n@@")
                 (list	"^Q$"	'n-complete-replace "Q"	"require_relative '@@'\n@@")
                 (list	".*U::LOG_a$"	'n-complete-replace "U::LOG_a[A-Z]*" "U::LOG_ALWAYS@@")
                 (list	".*U::LOG_d$"	'n-complete-replace "U::LOG_d[A-Z]*" "U::LOG_DEBUG")
                 (list	".*U::LOG_i$"	'n-complete-replace "U::LOG_i[A-Z]*" "U::LOG_INFO@@")
                 (list	".*U::LOG_w$"	'n-complete-replace "U::LOG_w[A-Z]*" "U::LOG_WARNING@@")
                 (list	".*U::LOG_e$"	'n-complete-replace "U::LOG_e[A-Z]*" "U::LOG_ERROR@@")
                 )
                )
        )
  (setq ri-ruby-script (n-host-to-canonical "$dp/bin/ruby/ri-emacs.rb")
        ri-ruby-program "/bin/ruby"  ; need 1.8
        )
  (if (or
       (not indent-line-function)
       (eq 'n-oop indent-line-function)
       (eq 'n-indent indent-line-function)
       )
      (setq n-indent-tab 8

            n-indent-in "[^\n \t(]+)$\\|if \\|.* do\\b\\|while \\|for \\|rescue\\|ensure\\b\\|else\\b\\|elsif\\b\\|begin\\|when \\|case\\|def \\|class \\|module \\|div("

            n-indent-out "end\\b\\|else\\b\\|ensure\\b\\|elsif \\|rescue\\b\\|when\\|div_endj \\|form_end"
            indent-line-function	'n-indent
            )
    )
  (setq mode-name "nRuby"
        major-mode 'nruby-mode
        n-comment-boln "# "
        )
  )

(defun nruby-expand-placeholders()
  (n-s "= " t)
  (while (not(eolp))
    (insert "$")
    (forward-char 1)
    (insert ", ")
    )
  (delete-char -2)
  (call-interactively (nkeys-binding "\C-m"))
  )

(defun nruby-guess-block-vars(token)
  (save-excursion
    (if (and (string= "" token)
             (progn
       (forward-line 0)
               (or
                (looking-at "[ \t]*\\([^\\.()]*\\)(")  ; routine call
                (looking-at ".*[\\.]\\([^\\.()]*\\)(")  ; method call
                (looking-at ".*[\\.]\\([^\\.()]*\\)")  ; method call, no parens or args
                (looking-at "[ \t]*\\(.*\\)")
                )
               )
             )
        (setq token (nre-pat 1))
      )
    )

  (if (string-match ".*\\[\"\\(.*\\)\"\\]" token)
      (setq token (nre-pat 1 token)))
  (cond
   ((or
     (string-match "\\(.*\\)\\.all_by_\\(.*\\)" token)
     (string-match "\\(.*\\)_by_\\(.*\\)" token)
     (string-match"\\(.*\\)_to_\\(.*\\)" token)
     )
    (let(
         (val (n--pat 1 token))
         (key (n--pat 2 token))
         )
      (if (string-match "\\(.*\\)_to_\\(.*\\)" token)
          (setq xyz val ; flip 'em, _to_ has reverse sense from _by_
                val key
                key xyz
                )
        )
      (setq val (nstr-downcase val))
      (if (string-match "\\(.*\\)ies$" val)
          (setq val (concat (n--pat 1 val) "y")))
      (if (string-match "\\(.*\\)s$" val)
          (setq val (n--pat 1 val)))
      (if (string-match "\\.\\([^\\.]+\\)$" val)
          (setq val (n--pat 1 val)))
      (if (string-match "_\\([^\\_]+\\)$" val)
          (setq val (n--pat 1 val)))
      (concat key ", " val)
      )
    )
   ((string-match "\\(.*\\)ies$" token)
   (setq token (concat (n--pat 1 token) "y"))
    )
   ((or
     (string-match "read\\(.*\\)s" token)
     (string-match "\\(.*\\)s$" token)
     )
    (let(
         (val (n--pat 1 token))
         )
      (if (string-match "\\.\\([^\\.]+\\)$" val)
          (setq val (n--pat 1 val)))
      (if (string-match "_\\([^\\_]+\\)$" val)
          (setq val(n--pat 1 val)))
      val
      )
    )
   ((string-match "\\(.*\\)_list$" token)
    (setq token (n--pat 1 token))
    )
   (t (concat "@@" token))
   )
  )


(defun nruby-make-each-block(&optional prefix flavor)
  (if (not prefix)
      (setq prefix ""))
  (if flavor
      (setq flavor (concat "_" flavor))
    (setq flavor "")
    )
  (end-of-line)
  (delete-region (point) (progn
                           (n-r "\\." t)
                      (point)
                           )
                 )
  (let(
       (block-vars (nruby-guess-block-vars (n-grab-token)))
       )
    (if (string= (concat "_" "with_index") flavor)
        (setq block-vars (concat block-vars ", j")))
    (end-of-line)
    (insert "." prefix "each" flavor " do | " block-vars " |\n")
    (indent-according-to-mode)
    (insert "@@\nend")
    (indent-according-to-mode)
    (insert "\n")
    (indent-according-to-mode)
    (insert "@@\n")
    (goto-char (point-min))
    (n-complete-seek)
    )
  )

(defun nruby-make-interpolation()
  (end-of-line)
  (cond
   ((save-excursion
      (forward-char -2)
      (looking-at "=#")
      )
    (let(
         (token (save-excursion
                  (forward-char -3)
                  (nruby-grab-expr)
                  )
                )
         )
      (end-of-line)
      (insert "{@@" token "}@@")
      )
    )
   ((save-excursion
      (forward-char -4)
      (looking-at "=\\\\\"#")
      )
    (let(
         (token (save-excursion
                  (forward-char -5)
                  (nruby-grab-expr)
                  )
                )
         )
      (end-of-line)
      (insert "{@@" token "}\\\"@@")
      )
    (insert "{@@}@@")
    )
   ((save-excursion
      (forward-char -3)
      (looking-at "\\\\\"#")
      )
    (insert "{@@}\\\"@@")
    )

   (t
    (insert "{@@}@@")
    )
   )


  (goto-char (point-min))
  (n-complete-seek)
  )

(defun nruby-grab-expr()
  (if (looking-at "\\]")
      (buffer-substring-no-properties (1+ (point))
                                      (progn
                                        (n-r "\\[" t)
                                        (skip-chars-backward (n-grab-token-chars))
                                        (point)
                                        )
                                      )
    (n-grab-token (concat (n-grab-token-chars) "\\."))
    )
  )

(defun nruby-add-trace-conditional()
  (save-restriction
    (widen)
    (cond
     ((save-excursion
        (goto-char (point-min))
        (n-s "^\\$trace = ")
        )
      (n-complete-replace ";" " if $trace\n@@")
      )
     (
      (save-excursion
        (goto-char (point-max))
        (and
         (n-r "attr_accessor :verbose")
         (n-r "^class \\([a-zA-Z_0-9]*\\)" t)
         )
        )
      (n-complete-replace ";"
                          (concat
                           " if "
                           (nre-pat 1)
                           ".verbose\n@@"
                           )
                          )
      )
     (t
      (message "t-add $trace dcl, v-add verbose field to last class")
      (let(
           (cmd (read-char))
           )
        (cond
         ((eq cmd ?t)
          (goto-char (point-min))
          (insert "$trace = false # true\n")
          )
         ((eq cmd ?v)
          (goto-char (point-max))
          (n-r "^class " t)
          (narrow-to-region (point) (progn
                                      (n-s "^end" t)
                                      (point)
                                      )
                            )
          (goto-char (point-min))
          (if (not (n-s "class << self"))
              (progn
                (goto-char (point-max))
                (n-open-line)
                (insert "	class << self\n")
                (forward-line -1)
                )
            )
          (forward-line 1)
          (insert "		attr_accessor :verbose\n")
          )
         )
        )
      )
     )
    )
  )
(defun nruby-propose-new-field(fld cls)
  (if (y-or-n-p (format "Add new field %s to class %s " fld cls))
      (progn
        (n-other-window)
        (goto-char (point-min))
        (n-s (concat "class " cls) t)
        (forward-line 1)
        (insert "        attr_accessor :" fld "\n")
        )
    )
  )
(defun nruby-repeat-if-clause()
  (save-restriction
    (widen)
    (let(
         if-clause
         )
      (save-excursion
        (setq if-clause     (progn
                              (n-r "^[ \t]*if \\(.*\\)" t)
                              (nre-pat 1)
                              )
              )
        )
      (end-of-line)
      (insert if-clause)
      )
    )
  )
(defun nruby-current-class-name()
  (save-restriction
    (widen)
    (save-excursion
      (n-r "^class " t)
      (n-s " " t)
      (n-grab-token)
      )
    )
  )

(defun nruby-current-method-name()
  (save-excursion
    (n-r "\\bdef \\(.*\\)(" t)
    (nre-pat 1)
    )
  )

(defun nruby-log()
  (save-restriction
    (widen)
    (end-of-line)
    (delete-char -1)
    (insert "U.log(\"" (nruby-current-class-name) "." (nruby-current-method-name) ": @@\") if U.log_level<=U::LOG_@@")
    (forward-line 0)
    (n-complete-leap)
    )
  )
(defun nruby-reindent-then-newline-and-indent()
  (interactive)
  (let(
       (in-comment      (nruby-in-comment-p))
       )
    (call-interactively 'reindent-then-newline-and-indent)
    (if in-comment
        (insert n-comment-boln))
    )
  )
(defun nruby-in-comment-p()
  (save-excursion
    (nsimple-back-to-indentation)
    (looking-at "#")
    )
  )
(defun nruby-class-skeleton()
  (end-of-line)
  (insert "lass @@"
          (capitalize
           (nstr-replace-regexp (nfn-prefix)
                                "-"
                                "_"
                                )
           )
          " < @@\n\tdef initialize(@@)\n\t\t@@\n\tend\n\tclass << self\n\t\t@@\n\tend\nend\n"
          )
  (goto-char (point-min))
  (n-complete-leap)
  )
(defun nruby-channel-test-debug-rm()
  (forward-line 0)
  (save-restriction
    (n-narrow-to-line)
    (replace-regexp ", Bar::LOW" "")    ; maybe left over from earlier debug sessions
    (replace-regexp ", Bar::HIGH" "")   ;       "
    (replace-regexp "; return" "")      ;       "
    (replace-regexp ")-" ")")
    )
  )
(defun nruby-channel-test-debug-setup()
  (save-restriction
    (forward-line 0)
    (n-s ")" t)
    (or (looking-at "[hl]")
        (error "nruby-channel-test-debug-setup: ")
        )
    (forward-line 0)
    (narrow-to-region (point)
                      (progn
                        (end-of-line)
                        (point)
                        )
                      )
    (nruby-channel-test-debug-rm)
    (forward-line 0)
    (replace-regexp ")l" ", Bar::LOW)")
    (replace-regexp ")h" ", Bar::HIGH)")
    (widen)
    (nruby-channel-test-move-to-line-1-of-tests)
    )
  )
(defun nruby-channel-test-move-to-line-1-of-tests()
  (let(
       (line (nsimple-delete-line))
       )
    (n-r "first test marker" t)
    (forward-line 1)
    (insert line "\n")
    (forward-line -1)
    (end-of-line)
    )
  )
(defun nruby-channel-test-mark-to-be-done-later()
  (nsimple-back-to-indentation)
  (insert "#")
  (nruby-channel-test-move-to-line-1-of-tests)
  )

(defun nruby-find-case-clause()
  (save-excursion
    (if (n-r "case \\(.*\\)")
        (nre-pat 1)
      )
    )
  )

(defun nruby-default-when-code--process-arg(case-clause when-clause)
  (let(
       (op (progn
             (message "arg processing: m-ode, n-umeric-class-field, s-tring-class-field")
             (read-char)
             )
           )
       (var (progn
              (if (string-match "^\"-\\([0-9a-zA-Z_]+\\)\"" when-clause)
                  (nre-pat 1)
                )
              )
            )
       )
    (cond
     ((string= op "m")
      (setq var (concat var "_mode"))
      (insert var " = true")
      (nruby-add-class-var var)
      )
     ((or (string= op "i")
          (string= op "f")
          )
      (insert "j += 1\n")
      (indent-according-to-mode)
      (insert var " = ARGV[j].to_" op "\n")
      (nruby-add-class-var var)
      )
     )
    (t
     (error "nruby-default-when-code--process-arg: could not interpret when-clause %s" when-clause)
     )
    )
  )


(defun nruby-default-when-code()
  (let(
       (when-clause (nre-pat 1))
       (case-clause    (nruby-find-case-clause))
       )
    (cond
     ((string-match "^\\(arg\\|ARGV\\[.*\\]\\)" case-clause)
      (nruby-default-when-code--process-arg)
      )
     )
    (message when-clause)
    (end-of-line)
    )
  )

(defun nruby-default-stuff()
  (save-restriction
    (widen)
    (nsimple-back-to-indentation)
    (or (looking-at "-") (error "nruby-field-add: where am I?"))
    (delete-char 1)
    (cond
     ((save-excursion
        (forward-line -1)
        (nsimple-back-to-indentation)
        (looking-at "when \\(.*\\)")
        )
      (nruby-default-when-code)
      )
     )
    )
  )
(defun nruby-make-class-var()
  (save-excursion
    (save-restriction
      (widen)
      (n-s "\\.G" t)
      (delete-char -2)
      (if (or (looking-at " = false")
              (looking-at " = nil")
              (looking-at "$")
              )
          (delete-region (point) (progn
                                   (end-of-line)
                                   (point)
                                   )
                         )
        (error "nruby-make-class-var: not sure what to make of the stuff remaining to the right")
        )
      (let(
           (class-name      (nruby-find-closest-class-name))
           (old-var-name    (n-grab-token))
           new-var-name
           )
        (setq new-var-name (nstr-replace-regexp old-var-name "^\\$" ""))
        (nsimple-delete-line)

        (goto-char (point-min))
        (nre-replace-word old-var-name
                          (concat class-name "." new-var-name)
                          )

        (goto-char (point-min))

        (n-s (concat "class " class-name) t)
        (save-restriction
          (narrow-to-region (point) (progn
                                      (n-s "^end" t)
                                      (point)
                                      )
                            )
          (goto-char (point-min))
          (if (and (not (n-s "class << self"))
                   (y-or-n-p "add class var/procs area")
                   )
              (progn
                (n-s "^end" t)
                (forward-line -1)
                (end-of-line)
                (insert "\n")
                (indent-according-to-mode)
                (insert "class << self")
                )
            )
          (insert "\n")
          (indent-according-to-mode)
          (insert "attr_accessor :" new-var-name)
          )
        )
      )
    )
  )

(defun nruby-find-closest-class-name()
  (save-excursion
    (save-restriction
      (widen)
      (if (n-r "^class \\(.*\\)")
          (nre-pat 1))
      )
    )
  )
(defun nruby-join-lines( &optional arg)
  (interactive "P")
  (nsimple-join-lines-programmatic "end")
  )
(defun nruby-make-argv-processor()
  (delete-char 1)
  (let(
       (class-name      (nruby-current-class-name))
       )
    (insert "j = 0
while ARGV.size > j do
        arg = ARGV[j]
        case arg
        when \"-@@\"
                " class-name ".@@ = @@
        when \"-@@\"
                j = j + 1
                @@ = ARGV[j]
        else
                raise \"did not understand \\\"#{ARGV[j]}\\\"\"
                break
        end
        j += 1
end
" class-name ".@@
")
    )
  (goto-char (point-min))
  (n-complete-leap)
  )
