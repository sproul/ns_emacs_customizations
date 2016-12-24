(provide 'nperl)
(require 'nre)
(setq nperl-mode-map (make-sparse-keymap))

(defun nperl-mode-meat()
  (interactive)
  (modify-syntax-entry ?$ ".")
  (make-local-variable 'indent-line-function)
  (require 'nc)
  (setq major-mode 'nperl-mode
        mode-name "nperl mode"
        ntags-find-current-token-class-context 'nc-find-current-token-class-context
        n-indent-tab 2
        n-indent-in "{"
        n-indent-out "}"
        indent-line-function	'n-indent
        n-get-include-name 	'nperl-get-include-name
        n-looking-at-include-p 	'nperl-looking-at-include-p
        n-get-includes-list 	'nperl-get-includes-list
        ntags-enabled t
	n-comment-boln "# "
	comment-start "# "
	n-comment-end ""
	nclass-browser-method-pruning-function 'nperl-method-pruning-function
	)
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"^[ \t]+s$"	'nperl-self-set)
                 (list	"^s$"	'n-complete-dft	"ub @@\n{\n\tmy($@@) = @_;\n}\n")
                 (list	"^[ \t]*c$"	'n-complete-replace	"c"	"print \"@@\\\\n\";\n") ;; utility::Log(\"@@\");")
                 (list	"^[ \t]*ce$"	'n-complete-replace	"ce"	"print STDERR \"@@\\\\n\";\n")
                 (list	".*[^a-zA-Z\._]d$"	'n-complete-replace	"d$"	"defined @@")
                 (list	"^[ \t]*e$"	'n-complete-dft	"lse\n{\n@@\n}\n")
                 (list	"^[ \t]*i$"	'n-complete-dft	"f (@@)\n{\n@@\n}\n")
                 (list	"^[ \t]*E$"	'n-complete-replace	"E"	"elsif (@@)\n{\n@@\n}\n")
                 (list	"^[ \t]*f$"	'n-complete-dft	"or (@@)\n{\n@@\n}\n")
                 (list	"^[ \t]*for ($"	'n-complete-dft	"my $j = 0; $j < @@; $j++")
                 (list	"^[ \t]*F$"	'n-complete-replace	"F"	"foreach my $@@ (@@)\n{\n@@\n}\n")
                 (list	"^[\t ]*L$"	'nperl-add-tracing)
                 (list	"^p$"	'nperl-package)
                 (list	".*\";c$"	'n-complete-replace	";c" " if $__Trace_ConformingToCharacteristics;")
                 (list	".*\";p$"	'n-complete-replace	";p" " if $__Trace_ProposeNotes;")
                 (list	".*\";t$"	'n-complete-replace	";t" " if $__trace;")
	 (list	".*\";r$"	'n-complete-replace	";x" " if $__Trace_XGen;")
	 (list	".*[^\\$]self$"	'n-complete-replace	"self$"	"$self->{\"@@\"}@@")
	 (list	".*\\bsu$"	'nperl-do-SUPER)
	 (list	".*\\bu$"	'n-complete-replace	"u$" "\" . nutil::ToString($@@) . \"@@")
	 (list	"^[ \t]*w$"	'n-complete-dft	"hile (@@)\n{\n@@\n}\n")
	 (list	"^[ \t]*we$"	'nperl-hash-loop)
	 )
        )
	)
  (use-local-map nperl-mode-map)

  (if (eq 1 (point-max))
      (progn
	(if (string-match "/\\([^/]+\\)\\.pm$" (buffer-file-name))
	    (insert "package "
		    (n--pat 1 (buffer-file-name))
		    ";\n"
		    )
	  )
	(insert "use strict;
use diagnostics;

@@

1;
# test with: cd " (n-host-to-canonical (file-name-directory (buffer-file-name))) ";perl -w " (file-name-nondirectory (buffer-file-name)) "; @@\n")
	(goto-char (point-min))
	(n-complete-leap)
	)
    )
  (define-key nperl-mode-map "}" 'nperl-right-brace)
  ;;(define-key nperl-mode-map "\C-g" 'nperl-debug)
  (define-key nperl-mode-map " " 'n-complete-or-space)
  (define-key nperl-mode-map "\C-a" 'nsimple-back-to-indentation)
  (define-key nperl-mode-map "\C-cb" 'nperl-goto-backup)
  (define-key nperl-mode-map "\C-cS" 'nc-stringify)
  (define-key nperl-mode-map "\C-ci" 'nc-show-includes)
  (define-key nperl-mode-map "\C-j" 'nc-join-lines)
  (define-key nperl-mode-map "\C-xo" 'nperl-make-function-into-method)
  ;;(define-key nperl-mode-map "\M-/" 'n-comment-routine)
  (define-key nperl-mode-map "\M-c" 'nperl-test)
  (define-key nperl-mode-map "\M-'" 'nperl-2-lines)
  (define-key nperl-mode-map "\M-\C-d" 'nperl-makeDefun)
  (define-key nperl-mode-map "\C-cg" 'nperl-gen-set-and-get-methods)
  (define-key nperl-mode-map "\C-xc" 'nperl-call-to-kill)
  (define-key nperl-mode-map "\"" 'nsimple-programming-enter-double-quote)
  (define-key nperl-mode-map "'" 'nsimple-programming-enter-single-quote)
  (define-key nperl-mode-map "`" 'nsimple-programming-enter-backwards-quote)
  )


(defun nperl-test()
  (interactive)
  (save-some-buffers t)
  (cond
   ((and (buffer-file-name) (string-match "apin2c.pl" (buffer-file-name)))
    (n-host-shell-cmd-visible "generate")
    )
   (t

    (require 'nmidnight)
    (if (and (not (eq major-mode 'emacs-lisp-mode))
	     (save-excursion
	       (goto-char (point-min))
	       (n-s "^# test with:")
	       )
	     )
        (save-excursion
          (goto-char (point-max))
          (n-r "^# test with:" t)
          (n-s "^# test with:" t)
          (delete-other-windows)
          (nsimple-split-window-vertically)
          (nshell); (file-name-directory (buffer-file-name))
          (nshell-clear)
          (other-window 1)
	  
	  (require 'n-mv-line)
          (n-mv-line)
          )
      (nmidnight-compile)
      )
    )
   )
  )

(defun nperl-debug()
  (interactive)
  ;; this routine hangs emacs for me, until I kill perldb.
  ;; If you make this work, please contact me. -Nelson
  (setq n-gdb-target-program (n-host-to-canonical (buffer-file-name)))
  (perldb (concat
           "perl -I"
           (n-host-to-canonical "~/usr/local/lib/perl")
           " "
           (file-name-nondirectory n-gdb-target-program)
           )
          )
  )
(defun nperl-get-include-name()
  (let(
       (name (if (nperl-looking-at-include-p)
                 (n--pat 1)
               "")
             )
       )
    (setq name (nstr-replace-regexp name "::" "/"))
    (setq name (concat name ".pm"))
    )
  )
(defun nperl-looking-at-include-p()
  (save-excursion
    (forward-line 0)
    (or
     (looking-at "^use[ \t]+\\([:0-9a-zA-Z_]+\\)\\([ \t]+-[0-9a-zA-Z_]+\\)*[ \t]*;[ \t]*$")
     (looking-at "^require[ \t]+\\([:0-9a-zA-Z_]+\\)\\([ \t]+-[0-9a-zA-Z_]+\\)*[ \t]*;[ \t]*$")
     )
    )
  )
                                        ; (nperl-get-includes-list)
(defun nperl-get-includes-list()
  (let(
       (perl-includes (getenv  "PERL5LIB"))
       )
    (or perl-includes (error "nperl-get-includes-list: "))
    (setq perl-includes (nstr-replace-regexp perl-includes ";" "/ "))
    (setq perl-includes (nstr-replace-regexp perl-includes "\\\\" "/"))
    (setq perl-includes (concat perl-includes "/"))
    (nstr-split perl-includes)
    )
  )



(defun nperl-narrow-to-hash-entry()
  (let(
       (beginBoundary "{")
       (endBoundary   "}")
       )
    (narrow-to-region (progn
			(n-r beginBoundary t)
			(point)
			)
		      (progn
			(n-s endBoundary t)
			(point)
			)
		      )
    )
  t
  )

(defun nperl-dumper-get(fn keyList)
  (save-window-excursion
    (n-file-find fn)
    (save-restriction
      (widen)
      (goto-char (point-min))
      (let(
	   data
	   key
	   isHash
	   )
	(while (and keyList
		    (setq key (car keyList))
		    (cond
		     ((string-match "=>" key)   ;; qualified intermediate node hash key
		      (if (n-s (concat key ",?$"))
			  (nperl-narrow-to-hash-entry)
			)
		      )
		     (t					;; unqualified leaf hash key
		      (goto-char (point-min))
		      (if (n-s (concat "'" key "' =>"))   
			  (progn
			    (skip-chars-forward " \t\n")
			    (setq data (if (looking-at "'")
					   (buffer-substring-no-properties (progn
							       (forward-char 1)
							       (point)
							       )
							     (progn
							       (n-s "[^\\\\]'" t)
							       (forward-char -1)
							       (point)
							       )
							     )
					 (buffer-substring-no-properties (point)
							   (progn
							     (forward-sexp 1)
							     (point)
							     )
							   )
					 )
				  )
			    (setq data (nstr-replace-regexp data "[ \t\n]+" " ")
				  data (nstr-replace-regexp data "^[ \t\n]+" "")
				  )
			    )
			)
		      )
		     )
		    )
	  (setq keyList (cdr keyList))
	  )
	data
	)
      )
    )
  )
(defun nperl-dumper-get-list(fn keyList)
  (let(
       (data (nperl-dumper-get fn keyList))
       )
    (if data
	(progn
	  (setq data (nstr-replace-regexp data "^\\[ " "")
		data (nstr-replace-regexp data " \\]$" "")
		data (nstr-replace-regexp data "," " ")
		)
	  (nstr-split data)
	  )
      )
    )
  )
(defun nperl-dumper-get-int-list(fn keyList)
  (let(
       (l1 (nperl-dumper-get-list fn keyList))
       )
    (if l1
	(progn
	  (nlist-funcall l1 'string-to-int)
	  )
      )
    )
  )

;;(nperl-dumper-get-list "~/work/adyn.com/httpdocs/teacher/data/base" (list "'id' => 2" "map/German"))
;;(nperl-dumper-get-int-list "~/work/adyn.com/httpdocs/teacher/data/base" (list "'id' => 1" "map/German"))
;;(nperl-dumper-get "~/work/adyn.com/httpdocs/teacher/data/base" (list "'id' => 2" "French"))

(defun nperl-file-copied-hook(oldFileName newFileName)
  (goto-char (point-min))
  (if (n-s "^package [0-9a-zA-Z_\\.]+;$")
      (progn
	(forward-line 0)
 	(forward-char 1)
	(delete-region (point) (progn
				 (end-of-line)
				 (point)
				 )
		       )
	(nperl-package)
	)
    ) 
  )
(defun nperl-package()
  (let(
       (f (nfn-prefix (file-name-nondirectory (buffer-file-name))))
       )
    (end-of-line)
    (insert "ackage " f ";\n")
    )
  )
(defun nperl-makeDefun( &optional arg)
  (interactive "P")
  (if arg
      (nsimple-downcase-word)
    (let(
	 (name	(n-grab-token))
	 (callingObject (save-excursion
			  (if (n-r "[^_A-Za-z0-9]")
			      (progn
				(forward-char -1)
				(looking-at "->")
				)
			    )
			  )
			)
	 (args	(save-excursion
		  (buffer-substring-no-properties (progn
                                                    (n-s "(" t)
                                                    (point)
                                                    )
                                                  (progn
                                                    (n-s ")" t)
                                                    (forward-char -1)
                                                    (point)
                                                    )
                                                  )
		  )
		)
	 (returnValue	(save-excursion
			  (save-restriction
			    (n-narrow-to-line)
			    (if (n-r "[ \t]")
				(progn
				  (narrow-to-region (point) (point-min))
				  (nsimple-back-to-indentation)
				  (if (looking-at "\\(.*\\) =$")
				      (n--pat 1))
				  )
			      )
			    )
			  )
			)
	 (loc	(point-marker))
	 )
      (setq args (nstr-replace-regexp args "\\\\[%@]\\([0-9a-zA-Z_]+\\)" "$\\1Ref")
	    args (nstr-replace-regexp args "\\$__" "$")
	    )
      (if returnValue
	  (setq returnValue (nstr-replace-regexp returnValue "^my " "")))
      (if callingObject
	  (setq args (concat "$self"
			     (if (not (string= args "")) ", " "")
			     args
			     )
		)
	)
      (if (string-match "::\\(.*\\)" name)
	  (setq name (n--patname 1)))
      (forward-line 1)
      (insert "sub " name "\n{\n  ")
      (if (not (string= args ""))
	  (insert "my(" args ") = @_;\n  "))
      (if returnValue
	  (insert "\n  return " returnValue ";\n"))
      (insert "}\n")
      
      (call-interactively 'nsimple-kill-region) ;;  (point) (marker-position loc))
      (message "defun for %s in kill" name)
      )
    )
  )
(defun nperl-make-function-into-method-but-not-in-generate_grammatical_reference_pl(fName)
  (if (get-buffer "generate_grammatical_reference.pl")
      (progn
	(set-buffer "generate_grammatical_reference.pl")
	(save-excursion
	  (goto-char (point-min))
	  (replace-regexp (concat "\\$self->" fName)
			  (concat "$__g->" fName)
			  )
	  )
	)
    )
  )
(defun nperl-mv-function-from-generate_grammatical_reference_pl-to-method-in-generic_grammar_pm(generate_grammatical_reference_pl-lineNo)
  (save-window-excursion
    (n-file-find "~/work/adyn.com/httpdocs/teacher/generate_grammatical_reference.pl")
    (goto-line (string-to-int
		generate_grammatical_reference_pl-lineNo)
	       )
    (nsimple-kill-function)
    
    (n-file-find "~/work/adyn.com/httpdocs/teacher/generic_grammar.pm")
    (goto-char (point-min))
    (n-s "^sub" t)
    (forward-line -1)
    (insert "\n")
    (yank)
    )
  )
(defun nperl-make-function-into-method-adjust-references(fName)
  (n-env-grep-goto)
  (goto-char (point-min))
  (let(
       (dcl (concat "sub " fName))
       (generate_grammatical_reference_pl-dcl (concat "work/adyn.com/httpdocs/teacher/generate_grammatical_reference.pl:\\([0-9]+\\):sub " fName))
       generate_grammatical_reference_pl-lineNo
       )
    (if (not (n-s dcl))
	(progn
	  (n-env-grap-meat fName)
	  (if (not (y-or-n-p "Grep ok? "))
	      (recursive-edit))
	  )
      )
    (nperl-mv-function-stop-passing-lang-arg fName)
    
    ;; if routine had been a static call, get rid of the class designations:
    (nre-rm-class-designation-from-each-call fName)	
    
    (require 'n-prune-buf)
    (n-prune-buf (concat "self->" fName))
    
    (goto-char (point-min))
    (if (n-s generate_grammatical_reference_pl-dcl)
	(setq generate_grammatical_reference_pl-lineNo (n--pat 1))
      (n-s dcl t)
      )
    (nsimple-delete-line)
    (n-env-replace-regexp-based-on-env-grep-output fName 
						   (concat "$self->" fName)
						   )
    (if generate_grammatical_reference_pl-lineNo
	(nperl-mv-function-from-generate_grammatical_reference_pl-to-method-in-generic_grammar_pm 
	 generate_grammatical_reference_pl-lineNo
	 )
      )
    )
  )
(defun nperl-mv-function-stop-passing-lang-arg----rm-lang-arg-dcl(fName)
  (n-env-grep-goto)
  
  ;; first, rm the lang arg dcl, if it exists
  (goto-char (point-min))
  (n-s (concat ":sub " fName) t)
  (forward-line 0)
  (or (n-grab-file)
      (error "nperl-mv-function-stop-passing-lang-arg----rm-lang-arg-dcl: "))
  (forward-line 2)
  (if (and (looking-at "[ \t]+my(")  ; has some args
	   (n-s "my(")
	   (looking-at "\\$lang\\b")
	   )
      (progn
	(delete-region (point) (progn (n-s "\\$lang" t)
				      (point)
				      )
		       )
	(if (looking-at ")")	; was $lang the only arg?
	    ;; don't do nsimple-delete-line cuz we're working off of line numbers from the
	    ;; grep buffer which would be thus disrupted
	    (delete-region (progn (forward-line 0)  
				  (point)
				  )
			   (progn (end-of-line)
				  (point)
				  )
			   )
	  (or (looking-at ",")
	      (error "nperl-mv-function-stop-passing-lang-arg: oops")
	      )
	  (delete-region (point) (progn (n-s ", *" t)
					(point)
					)
			 )
	  )
	t
	)
    )
  )

;;(nperl-mv-function-stop-passing-lang-arg----rm-lang-arg-dcl "getImperfectStem")

(defun nperl-mv-function-stop-passing-lang-arg(fName)
  (save-window-excursion
    (if (nperl-mv-function-stop-passing-lang-arg----rm-lang-arg-dcl fName)
	(nre-rm-arg-from-each-call fName 0))
    )
  )

;;(nre-rm-arg-from-each-call "getImperfectStem" 0)

(defun nperl-make-function-into-method( &optional arg)
  (interactive "P")
  (nc-beginning-of-defun)
  (let(
       (fName (save-excursion
		(forward-word -1)
		(n-grab-token)
		)
	      )
       )
    (forward-line 1)
    (nsimple-back-to-indentation)
    (if (looking-at "my(")
	(progn
	  (n-s "(" t)
	  (insert "$self, ")
	  )
      (insert "my($self) = @_;\n")
      (indent-according-to-mode)
      )
    
    (if (not arg)
	(save-excursion
	  (goto-char (point-min))
	  (replace-regexp (concat "\\b" fName "\\b")
			  (concat "$self->" fName)
			  )
	  
	  (goto-char (point-min))
	  (replace-regexp (concat "^sub .self->" fName)
			  (concat "sub " fName)
			  )
	  
	  (goto-char (point-min))
	  (replace-regexp (concat "\\(print \".*\\).self->" fName)
			  (concat "\\1" fName)
			  )
	  
	  (goto-char (point-min))
	  (replace-regexp "\\$self->\\$self->" "$self->")
	  )
      (nperl-make-function-into-method-adjust-references fName)
      (nperl-make-function-into-method-but-not-in-generate_grammatical_reference_pl fName)
      )
    )
  )

(defun nperl-gen-set-and-get-methods()
  (interactive)
  (let(
       (var	(progn
		  (forward-line 0)
		  (n-s "[;=]" t)
		  (forward-word -1)
		  (n-grab-token)
		  )
		)
       stem
       type
       )
    (or (string-match "\\([\\$%@]\\)\\(.*\\)" var)
	(error "nperl-gen-set-and-get-methods: can't parse %s" var))
    (setq type (n--pat 1 var)
	  stem (n--pat 2 var)
	  )
    
    ;; likely we are processing a series of vars.  Push a loc on the next line to facilitate this:
    (save-excursion
      (forward-line 1)
      (n-loc-push)
      )
    
    (and (n-s (concat "Get" stem))
	 (error "nperl-gen-set-and-get-methods: Get%s already defined" stem))
    (and (n-s (concat "Set" stem))
	 (error "nperl-gen-set-and-get-methods: Set%s already defined" stem))
    
    (cond
     ((string= type "$")
      (setq methods (concat "sub Get" stem "\n{\n  return " var ";\n}\n\n"
			    "sub Set" stem "\n{\n  my($val) = @_;\n  " var " = $val;\n}\n\n"
			    )
	    )
      ;; now update all accesses to this var to use the new routines
      (goto-char (point-min))
      (n-s (concat "\\$" stem "\\b") t)   ;; advance past dcl
      (save-restriction
	(narrow-to-region (point) (point-max))
	
	(replace-regexp (concat "\\$" stem " *= *\\(.*\\);")
			(concat "Set"    stem "(\\1);")
			)
	(goto-char (point-min))
	(replace-regexp (concat "\\$" stem "\\b")
			(concat "Get"    stem "()")
			)
	)
      )
     ((string= type "@")
      (setq methods (concat "sub Get" stem "\n{\n  my($x) = @_;\n  return $" stem "[$x];\n}\n\n"
			    "sub Set" stem "\n{\n  my($x, $val) = @_;\n  $" stem "[$x] = $val;\n}\n\n"
			    )
	    )
      ;; now update all accesses to this var to use the new routines
      (goto-char (point-min))
      (n-s (concat "@" stem "\\b") t)   ;; advance past dcl
      (save-restriction
	(narrow-to-region (point) (point-max))
	
	(replace-regexp (concat "\\$" stem "\\[\\(.*\\)\\] *= *\\(.*\\);")
			(concat "Set"    stem "(\\1, \\2);")
			)
	(goto-char (point-min))
	(replace-regexp (concat "\\$" stem "\\b\\[\\(.*\\)\\]")
			(concat "Get"    stem "(\\1)")
			)
	)
      )
     ((string= type "%")
      (setq methods (concat "sub Get" stem "\n{\n  my($key) = @_;\n  return $" stem "{$key};\n}\n\n"
			    "sub Set" stem "\n{\n  my($key, $val) = @_;\n  $" stem "{$key} = $val;\n}\n\n"
			    )
	    )
      ;; now update all accesses to this var to use the new routines
      (goto-char (point-min))
      (n-s (concat "%" stem "\\b") t)   ;; advance past dcl
      (save-restriction
	(narrow-to-region (point) (point-max))
	
	(replace-regexp (concat "\\$" stem "{\\(.*\\)} *= *\\(.*\\);")
			(concat "Set"    stem "(\\1, \\2);")
			)
	(goto-char (point-min))
	(replace-regexp (concat "\\$" stem "\\b{\\(.*\\)}")
			(concat "Get"    stem "(\\1)")
			)
	)
      )
     (t
      (error "nperl-gen-set-and-get-methods: unrecognized type %s" type)
      )
     )
    
    ;; insert the get and set methods
    (n-s "^sub" t)
    (forward-line 0)
    (insert methods)
    )
  )
(defun nperl-add-tracing()
  (widen)
  (let(
       (file (nfn-prefix))
       (fName (n-defun-name t))
       (args (nperl-get-args))
       )
    (forward-line 0)
    (n-s "^[ \t]*L[ \t]*$" t)
    (just-one-space)
    (delete-char -2)
    (if (not args)
	(setq args ""))
    (insert "print \"")
    (if (not (string-match "^\\(generic_grammar\\|grammar\\)$" file))
	(insert file "::")
      )
    (insert fName "(" args ")@@\\n\";")
    
    (n-r "@@" t)
    (delete-char 2)
    )
  )
(defun nperl-get-args()
  (save-restriction
    (widen)
    (save-excursion
      (n-r "^{" t)
      (forward-line 1)
      (if (looking-at "[ \t]*my(\\(\$self,? *\\)?\\(.*\\)) = @_;")
	  (n--pat 2)
	)
      )
    )
  )
(defun nperl-right-brace()
  (interactive)
  (n-complete-self-insert-command)
  (indent-according-to-mode)
  )
(defun nperl-do-SUPER()
  (nsimple-back-to-indentation)
  (or (n-s "\\bsu$")
      (error "nperl-do-SUPER: "))
  (delete-char -2)
  (insert "$self->SUPER::@@"
	  (n-defun-name)
	  "("
	  (nperl-get-args)
	  ");\n  @@"
	  )
  (goto-char (point-min))
  (n-complete-leap)
  )
(defun nperl-goto-backup()
  (interactive)
  (if (not (string-match "c:/users/nsproul/work/adyn.com/httpdocs/teacher/" (buffer-file-name)))
      (call-interactively 'nhtml-browse)
    (let(
	 (bfn (nstr-replace-regexp (buffer-file-name) "c:/users/nsproul/work/adyn.com/httpdocs/teacher/" "d:/old/teacher/"))
	 )
      (or (file-exists-p bfn)
	  (error "nperl-goto-backup: cannot find %s" bfn))
      (n-file-find bfn)
      )
    )
  )
(defun nperl-method-pruning-function(showData showMethods)
  (require 'n-prune-buf)

  (save-excursion
    (goto-char (point-min))
    (replace-regexp "^sub \\([0-9a-zA-Z_]+\\)\n{\n[ \t]*my\\(([^)]+)\\) = @_;" "sub \\1\\2")
    )
  (n-prune-buf-v "^\\(my \\|sub \\)")
  (if (not showData)
      (progn
	(n-prune-buf "^my")
	)
    )
  (if (not showMethods)
      (progn
        (n-prune-buf "^sub ")
        )
    )
  )
(defun nperl-self-set()
  (save-restriction
    (end-of-line)
    (widen)
    (forward-char -1)
    (or (looking-at "s")
	(error "nperl-self-set: "))
    (delete-char 1)

    (if (looking-at "\\(\\$?\\([a-zA-Z0-9_]+\\)\\)")
	(progn
	  (n-loc-push)
	  (insert "$self->{\"@@" (n--pat 2) "\"} = ")
	  (if (looking-at "\\$?[a-zA-Z0-9_]+[),]")
	      (progn
		(n-s "[),]" t)
		(delete-char -1)
		(delete-horizontal-space)
		(insert ";\n\t@@")
		)
	    (n-loc-pop)
	    (forward-line 0)
	    )
	  )
      (insert "$self->{\"@@\"}@@")
      (forward-line 0)
      (n-complete-leap)
      )
    )
  )
(defun nperl-call-to-kill()
  (interactive)
  (save-excursion
    (let(
	 (fName (progn
		  (end-of-line)	; in case we're right at the "sub"
		  (n-r "^sub \\([^\n]+\\)" t)
		  (n--pat 1)
		  )
		)
	 (callingObject "")
	 (args (progn
		 (forward-line 2)
		 (nsimple-back-to-indentation)
		 (if (looking-at "my(\\(.*\\)) = @_")
		     (n--pat 1))
		 )
	       )
	 )
      (if (string-match "^\\$self\\b\\(, ?\\)?\\(.*\\)" args)
	  (setq callingObject "$@@self->"
		args (n--pat 2 args)
		)
	)
      (nstr-kill (format "%s%s(%s)" callingObject fName args))
      (if (string= callingObject "")
	  (setq nsimple-yanker (list 'nperl-call-to-kill-yanker
				     (nfn-prefix)	;; this is the class name
				     )
		)
	)
      )
    )
  )
(defun nperl-call-to-kill-yanker(packageName)
  (if (not (string= packageName (nfn-prefix)))
      (insert packageName "::"))
  (yank)
  )
(defun nperl-hash-loop()
  (end-of-line)
  (forward-char -2)
  (if (not (looking-at "we"))
      (error "my expectations have been confounded"))
  (delete-char 2)
  (let(
       (hashVariable (save-excursion
		       (if (not (n-r "%\\([0-9a-zA-Z_]+\\)"))
			   ""
			 (n--pat 1)
			 )
		       )
		     )
       (keyVariable "key")
       (valueVariable "value")
       )
    (if (string-match "\\(.*\\)To\\([A-Z].*\\)" hashVariable)
	(setq keyVariable (n--pat 1 hashVariable)
	      valueVariable (n--pat 2 hashVariable)
	      )
      )
    (insert "while ((@@$" keyVariable " $@@" valueVariable ") = each %" hashVariable + ")")
    )
  )

(defun nperl-2-lines()
  (interactive)
  (cond
   ((save-excursion
      (forward-line 0)
      (looking-at "[ \t]*\\(els\\)?if (\\$year eq \"\\([0-9]+\\)\")")
      )
    (let(
         (year (string-to-int (nre-pat 2)))
         (line  (n-get-line))
         (clause (progn
                   (forward-line 1)
                   (buffer-substring-no-properties (point) (progn
                                                             (forward-sexp 1)
                                                             (point)
                                                             )
                                                   )
                   )
                 )
         )
      (forward-line 1)
      (insert line "\n")
      (forward-line -1)
      (nsimple-back-to-indentation)
      (if (looking-at "if ")
          (insert "els"))

      (save-restriction
        (n-narrow-to-line)
        (goto-char (point-min))
        (replace-regexp (int-to-string year)
                        (int-to-string (1+ year))
                        )
        )
      (forward-line 1)

      (insert clause "\n")
      (forward-sexp -1)
      (forward-line 1)
      (nsimple-back-to-indentation)
      )
    )
   ((and (string= (file-name-nondirectory (buffer-file-name)) "accounts.pl")
         (save-excursion
           (nsimple-back-to-indentation)
           (looking-at "p(\"\\([0-9]+\\)\",")
           )
         )
    (end-of-line)
    (insert "\n p(\"" (int-to-string (1+ (string-to-int (n--pat 1)))) "\", @@, \"@@\");")
    (indent-according-to-mode)
    (forward-line 0)
    (n-complete-leap)
    )
   (t
    (require 'n-2-lines)
    (call-interactively 'n-2-lines)
    )
   )
  )

