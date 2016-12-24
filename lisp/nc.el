(provide 'nc)
(require 'njava)

(defun nc-get-include-name()
  "return include file name listed on line under pt"
  (forward-line 0)
  (n-s "[<\"]" t)
  (buffer-substring-no-properties (point)
		    (progn
		      (n-s "[>\"]" t)
		      (forward-char -1)
		      (point)
		      )
		    )
  )

(defun nc-dcl ()
  "n1.el: proposes and then enters a declaration for the
   C variable under point"
  (interactive)
  (save-excursion
    (let(
	 (token    (n-grab-token))
	 type dcl
         )
      (setq type (read-from-minibuffer (concat "type for " token "? ")))
      (nc-beginning-of-defun)
      (forward-line 1)
      (open-line 1)
      (setq dcl (concat "    " type "\t" token ";"))
      (insert dcl)
      (goto-char (+ pt-saved (length dcl)))
      )
    )
  )
(defun nc-mode()
  (setq nclass-browser-method-pruning-function 'nc-method-pruning-function)
  (setq c-default-style "stroustrup") ;; for alternatives, see c:/downloads/emacs/emacs-20.7.1/lisp/progmodes/cc-styles.el:76
  (c++-mode)
  (setq
   n-comment-boln "// "
   comment-start "//"
   n-comment-end ""
   )
  (nkeys-c-hook (current-local-map))

  (setq ntags-find-current-token-class-context 'nc-find-current-token-class-context
        ntags-enabled t
        tab-width (string-to-int (n-database-get "c-cpp-java-tab-width" t nil "4"))
        )
  (setq n-complete-leap
        (append (list
                 (list "\n[ 	]*;\n"		'forward-char -2)
                 (list "{\n[ 	]*\n"		'nc-leap-back-bracket)
                 (list "\n\n"			'forward-char -1)
                 )
                n-complete-leap-dft
                )
        )
  (setq n-completes
        (append
         nsimple-shared-completes
         (list
          (list	"^[\t ]*c$"	'n-complete-dft	"out << \"@@\" << endl;\n@@")
          (list	".*[^A-Z_a-z]C$"	'n-complete-dft	"S_@@")
          ;;(list	".*($"		'n-complete-dft		") {\n@@\n}\n")
          (list	"^[\t ]*ce$"	'n-complete-dft	"rr << \"@@\" << endl;\n@@")
          (list	"^[\t ]*ci$"	'n-complete-dft	"n >> @@;\n@@")
          (list	".*CS_a$"	'n-complete-replace	"a$"	"FALSE@@")
          (list	".*CS_c$"	'n-complete-replace	"c$"	"CHAR@@")
          (list	".*CS_f$"	'n-complete-replace	"f$"	"FAIL@@")
          (list	".*CS_i$"	'n-complete-replace	"i$"	"INT@@")
          (list	".*CS_l$"	'n-complete-replace	"l$"	"LONG@@")
          (list	".*CS_n$"	'n-complete-replace	"n$"	"NULLTERM@@")
          (list	".*CS_o$"	'n-complete-replace	"o$"	"BOOL@@")
          (list	".*CS_r$"	'n-complete-replace	"r$"	"RETCODE@@")
          (list	".*CS_s$"	'n-complete-replace	"s$"	"SUCCEED@@")
          (list	".*CS_t$"	'n-complete-replace	"t$"	"TRUE@@")
          (list	".*CS_u$"	'n-complete-replace	"u$"	"UNUSED@@")
          (list	".*CS_v$"	'n-complete-replace	"v$"	"VOID@@")
          (list	".*CS_y$"	'n-complete-replace	"y$"	"BYTE@@")
          (list	"public [A-Za-z0-9_]+([^()]+)$"	'nc-complete-constructor nil	)
          (list	".*($"	'n-complete-dft	"@@) {\n\n}")
          (list	"^[\t ]*e$"	'n-complete-dft	"lse {\n\n}")
          (list	"^[\t ]*E$"	'n-complete-replace	"E" "else if (@@) {\n\n}")
          (list	"^[\t ]*d$"	'n-complete-dft	"o {\n\n} while (@@);")
          (list	"^[\t ]*\\(else \\)?i$"	'n-complete-dft	"f (@@) {\n\n}")
          (list	"^[\t ]*f$"	'n-complete-dft	"or (@@) {\n\n}")
          (list	"^[\t ]*j$"	'n-complete-replace	"j" "for (unsigned int j = 0; j < @@; j++) {\n\n}")
          (list	"^[\t ]*L$"	'nc-add-tracing "")
          (list	"^[\t ]*r$"	'n-complete-dft	"eturn @@")
          (list	"^[\t ]*s$"	'n-complete-dft	"witch (@@) {\ncase @@:\nbreak;\ndefault:\n;\n}")
          (list	"^[\t ]*st$"	'n-complete-dft	"ruct @@ {\n\n}")
          (list	"^[\t ]*t$"	'n-complete-dft	"ypedef struct _@@ {\n@@\n} @@;\n")
          (list	"^[\t ]*w$"	'n-complete-dft	"hile (@@) {\n\n}")
          (list	"^m$"	'n-complete-replace	"m" "int main(int argc, char *argv[]) {\n\n\treturn 0;\n}\n")
          (list	"^W$"	'n-complete-replace	"W" "int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine, int nCmdShow) {\n\n\treturn 0;\n}\n")
          (list	".*[ \t][->A-Za-z0-9_]+=n$"
                'n-complete-replace
                "\\(.*[ \t]\\)\\([->A-Za-z0-9_]+\\)=n$"
                "\\1\\2 = \\2->next@@"
                )
          (list	"^[\t ]*for ([A-Za-z0-9_]+ = [->A-Za-z0-9_]+$"
                'n-complete-replace
                "\\(^[\t ]*\\)for (\\([A-Za-z0-9_]+\\) = \\([->A-Za-z0-9_]+\\)"
                "\\1for (\\2 = \\3; \\2; \\2 = \\2->next@@) {\n@@\n}\n"
                )
          (list	"^[\t ]*for (e$"
                'nc-generate-enumerated-for-loop
                nil
                nil
                )
          (list	"^[\t ]*for (\\(int \\)?[a-z]$"
                'n-complete-replace
                "\\(^[\t ]*\\)for (\\(int \\)?\\([a-z]\\)"
                "\\1for (\\2\\3 = 0; \\3 < @@; \\3++"
                )
          (list "\\(^[\t ]*\\)\\(\\(private\\|protected\\|public\\)[ \t]+\\)?\\(static[ \t]+\\)?\\([^ \t]+\\)[ \t]+\\([^ \t]+\\) n$"'nc-new-object)
          )
         )
        )
  )

(defun nc-brace()
  "insert { into C code, indented correctly"
  (interactive)
  (insert "{")
  (indent-according-to-mode)
  )

(defun nc-delete-else()
  "in a C pgm, with point on the first line of an else statement,
this proc will remove the else and any brackets associated with it,
but leave behind statements within"
  (forward-line 0)
  (if (not (looking-at "^[ \t]*else"))
      (error "nc-delete-else called not on an else stmt"))
  (delete-region (point) (progn
                           (n-s "else")
                           (point)
                           )
                 )
  (if (looking-at "[ \t\n]*{")
      (let(
           (elseStart	(point))
           (elseEnd	(progn
                          (nc-goto-block-end)
                          (point)
                          )
                        )
           )
        (nsimple-kill-line)
        (goto-char elseStart)
        (nsimple-kill-line)
        (indent-region elseStart elseEnd nil)
        )
    )
  )

(defun nc-goto-block-end()
  "with point on the first line of some C block, calling this function results
in point moving to the last line of the block"
  (nc-goto-next-bracket)
  (let(
       (bracketCnt	1)
       )
    (while (not (equal bracketCnt 0))
      (setq bracketCnt (+ bracketCnt (nc-goto-next-bracket)))
      )
    )
  )

(defun nc-goto-next-bracket()
  "in a C pgm: move point to the next unquoted { or }; if the
next one is a {, return 1, and if it's a }, return -1.  If neither,
it's an error"
  (let(
       (hit        (n-sv (list
                          (list "{" 1)
                          (list "}" -1)
                          )
                         "cannot find any brackets"
                         )
                   )
       )
    hit
    )
  )

(defun nc-class-name()
  (save-excursion
    (cond
     ;; the trailing [^:]*$ is to be sure to get the innermost class when we see something like ^xxx::yyy::zzz
     ((looking-at "[^0-9a-zA-Z_]\\([0-9a-zA-Z_]+\\)::[^:]*$")
      t
      )
     ((save-restriction
        (save-excursion
          (and (n-r "^[0-9a-zA-Z_]")
               (progn
                 (forward-line 0)
                 (or
                  (looking-at "[^()]*[^a-zA-Z_]\\([0-9a-zA-Z_]+\\)::[^:]*$")
                  (looking-at "\\([0-9a-zA-Z_]+\\)::[^:]*$")
                  )
                 )
               )
          )
        )
      t
      )

     ((save-excursion
        (n-r "^{")
        (n-r "^\\(public \\)?class[ \t\n]+\\([0-9a-zA-Z_]+\\)" t)
        )
      )
     )
    (n--pat 2)
    )
  )

;;(defun nc-goto-header-prototype()
;;  (interactive)
;;  (let(
;;       (header		(nc-header-name))
;;       (function-header	(nc-function-header t))
;;       (function	(n-defun-name))
;;       (class		(nc-class-name))
;;       )
;;    (n-file-find header)
;;    (goto-char (point-min))
;;    (if (n-s (concat function "("))
;;        (forward-line 0)
;;      (n-s (concat "~" class "(") t)
;;      (forward-line 1)
;;      )
;;    (save-restriction
;;      (narrow-to-region (point) (point))
;;      (insert function-header "\n")
;;      (goto-char (point-min))
;;      ;;(if (looking-at "[a-zA-Z_0-9]+$")
;;      ;; evidently the type is on a line by itself.  Don't allow this.
;;      (nsimple-join-lines)
;;      ;;)        
;;      (indent-according-to-mode)
;;      )
;;    )
;;  )

(defun nc-function-header(&optional prepare-for-class)
  (save-excursion
    (let(
         (end	(progn
                  (nc-beginning-of-defun)
                  (forward-line -1)
                  (end-of-line)
                  (point)
                  )
                )
         (begin	(progn
                  (n-rv (list
                         (list "^//" 'forward-line 1)
                         (list "^[ \t]*$" 'forward-line 1)
                         )
                        "nc-function-header: "
                        )
                  (point)
                  )
                )
         function-header
         )
      (setq function-header (buffer-substring-no-properties begin end))
      (if prepare-for-class
          (concat 
           "  "
           (nstr-replace-regexp function-header "[^ \n\t]+::" "")
           ";"
           )
        function-header
        )
      )
    )
  )


;;(nc-header-name "/export/home/nelson/highgate/server/pom/verify.cpp")
(defun nc-header-name(&optional fN)
  "given the name of a C source file, determine the name of the corresponding
header file"
  (if (not fN)
      (setq fN (buffer-file-name)))
  (let(
       (header (nfn-suffix-supplant fN "h"))
       )
    (cond
     ((file-exists-p header)
      header
      )
     ((file-exists-p (nstr-replace-regexp header "highgate/server/\\([^/]+\\)/" "highgate/server/inc/"))
      (nstr-replace-regexp header "highgate/server/\\([^/]+\\)/" "highgate/server/inc/")
      )
     ((file-exists-p (nstr-replace-regexp header "highgate/server/\\([^/]+\\)/.*" "highgate/server/inc/\\1.h"))
      (nstr-replace-regexp header "highgate/server/\\([^/]+\\)/.*" "highgate/server/inc/\\1.h")
      )
     (t
      (error "nc-header-name: ")
      )
     )
    )
  )
;;(insert (prin1-to-string c-style-alist))


(defun nc-indent-settings()
  "set up indentation settings for C src code"
  (interactive)
  (let(
       (offset (string-to-int (n-database-get "c-cpp-java-tab-width" t nil "4")))
       )
    (setq
     c-argdecl-indent 0;offset
     c-brace-offset -5
     c-continued-statement-indent 0;(* 2 offset)
     c-continued-statement-offset  0
     c-indent-level 9;offset
     c-label-offset 0;(- offset)
     )
    (message "c-argdecl-i=%d, c-brace-o=%d, c-continued-statement-i=%d, c-continued-statement-o =%d, c-i-level=%d, c-label-o=%d"
             c-argdecl-indent
             c-brace-offset
             c-continued-statement-indent
             c-continued-statement-offset
             c-indent-level
             c-label-offset
             )
    )
  )
(nc-indent-settings)

(defun nc-kill-block()
  "kill the block whose first line is under point"
  (interactive)
  (let (
        (start	(progn
                  (forward-line 0)
                  (point)
                  )
                )
        (isIf	(looking-at "^[ \t]*if"))
        (end	(progn
                  (nc-goto-block-end)
                  (point)
                  )
                )
        )
    (kill-region start end)
    (if (and isIf (looking-at "[ \t\n]*else"))
        (nc-delete-else)
      )
    )
  )

(defun nc-macro-expand( beg end)
  "c-macro-expand replacement"
  (interactive "r")
  (let(
       (fN	(buffer-file-name))
       (input	(buffer-substring-no-properties beg end))
       (includes (nc-get-includes-text))
       (stdout	(get-buffer-create "*Macroexpansion*")) 
       )
    (n-insert input (n-macro-bufN))
    (n-file-write (n-macro-bufN) (nc-macro-fN))
    (n-erase-buffer stdout)
    (eval (append (list 'funcall ''call-process-region 1 1 "cc" nil stdout t "-E")
                  includes
                  (list (nc-macro-fN))
                  )
          )
    (kill-buffer (n-macro-bufN))
    (switch-to-buffer-other-window stdout)
    (goto-char (point-min))
    (if fN
        (replace-regexp (concat "^# 1 \\\"" (nc-macro-fN) "\\\"")
                        (concat "# 1 \\\"" fN "\\\""))
      (replace-regexp (concat "^# 1 \\\"" (nc-macro-fN) "\\\"") 
                      "")
      )
    (goto-char (point-min))
    (replace-regexp "\n[ 	]*\n[ 	]*\\(\n[ 	]*\\)+" "\n\n") ; rm consecutive white lines
    (goto-char (point-min))
    (delete-file (nc-macro-fN))
    )
  )

(defun nc-macro-fN()
  "file name"
  (expand-file-name (concat "~/" (n-macro-bufN)))
  )

(defun nc-kr-argsp()
  "return t if we are sitting on a k+r style arg list"
  (interactive)
  (save-excursion
    (n-s "(" t)
    (skip-chars-forward " \t\n")
    (nc-skip-token)
    (or (looking-at "[ \t\n]*,")
        (looking-at "[ \t\n]*)")
        )
    )
  )

(defun nc-s( pat)
  "search forward for PAT, ignoring C cmts"
  (nc-v (list (list pat)) 'n-sv 'n-s))

(defun nc-r( pat)
  "search backward for PAT, ignoring C cmts"
  (nc-v (list (list pat)) 'n-rv 'n-r))

(defun nc-sv( pats)
  "search forward for PATS, ignoring C cmts"
  (nc-v pats 'n-sv 'n-s))

(defun nc-rv( pats)
  "search backward for PATS, ignoring C cmts"
  (nc-v pats 'n-rv 'n-r))

(defun nc-v( patLists svFunc sFunc)
  "search for PATS, ignoring C cmts and string contents"
  (let(
       (oldPt	(point))
       hit
       done
       )
    (while (not done)
      (setq hit (funcall svFunc 
                         (append
                          patLists
                          
                          ;; which direction search is going determines which order cmt delimiters to look for
                          (if (eq svFunc 'n-sv)
                              (list (list "/\\*" sFunc "\\*/"))
                            (list (list "\\*/" sFunc "/\\*"))
                            )
                          
                          ;;
                          ;; this clause was causing a lot of trouble in
                          ;; ntags.  It can't deal with '"'.
                          ;;
                          ;;(list (list "\""   sFunc "[^\\]\""))
                          )
                         )
            
            done	(or (not hit)
                            (not (eq hit t))     ; sFunc must return t for a hit and nil for a miss
                            )
            )
      
      )
    (if hit
        t
      (goto-char oldPt)
      nil
      )
    hit			; bubble up svFunc's return
    )
  )

(defun nc-add-trace()
  "add LOG_ROUTINE stmts to beginning of all procs, s/return/RETURN/, etc."
  (interactive)
  (nc-add-trace-reps)
  (nc-goto-1rst-proc-hdr)
  (while (nc-add-trace1))
  (nc-goto-1rst-proc-hdr)
  (while (nc-add-void-return1))
  )

(defun nc-add-void-return1()
  "look for routines which end without returning a value.  Assume
it's void and insert a RETURN.  Return nil when there are no
more routines to look at"
  (if (not (n-s "^}"))
      nil
    (forward-line -1)
    (if (looking-at "    RETURN")
        t
      (end-of-line)
      (insert "\n    RETURN;")
      )
    (n-s "^{")			; get past }
    )
  )

(defun nc-add-trace-reps()
  "perform global replacements necessary to add C tracing code"
  (goto-char (point-min))
  (replace-regexp "[ \t]+\n" "\n")
  (goto-char (point-min))
  (replace-regexp "return;\n" "RETURN;\n")
  (goto-char (point-min))
  (replace-regexp "return \\([^\n]+\\);\n" "RETURN_VALUE(\\1);\n")
  )

(defun nc-add-trace1()
  (interactive)
  (let(
       (name (nc-goto-proc-hdr))
       )
    (if name
        (progn
          (n-sv (list
                 (list "\n\n")
                 (list "{"  'nc-add-trace1-to-proc-start)
                 (list "^}" 'nc-add-trace1-to-proc-start)
                 )
                )
          
          (forward-line 0)
          (if (not (looking-at "    LOG_ROUTINE( "))
              (insert (format  "    LOG_ROUTINE( \"%s\" );\n" name))
            )
          )
      )
    name
    )
  )
  
(defun nc-add-trace1-to-proc-start()
  "after having overshot the beginning of the proc, go back"
  (n-r "^{")
  (forward-line 1)
  )
  
(defun nc-goto-1rst-proc-hdr()
  (goto-char (point-min))
  (if (file-writable-p (buffer-file-name))
      (replace-regexp "[ \t]*\n" "\n") )
  (goto-char (point-max))
  (if (not (n-rv (list
                  (list "\\btypedef\\b" 'nc-skip-stmt)
                  (list "\\bdefine\\b"  'nc-skip-define)
                  (list "\\bstruct[ \t]*[a-z_A-Z0-9]*[ \t\n]*{"	  'beginning-of-buffer)
                  )
                 )
           )
      (goto-char (point-min))
    )
  (nc-goto-proc-hdr)
  )

(defun nc-skip-stmt()
  "advance past current C stmt.  Warning: won't skip past an entire func defn + body"
  (forward-line 0)
  (if (looking-at "#[ \t]*define")
      (while (progn
               (end-of-line)
               (forward-char -1)
               (looking-at "\\\\")
               )
        (forward-line 1)
        )
    (n-sv (list
           (list ";")
           (list "{" 'nc-forward-sexp)
           (list "(" 'nc-forward-sexp)
           )
          )
    )
  (forward-line 1)
  )

(defun nc-forward-sexp()
  (forward-char -1)
  (forward-sexp 1)
  )
(defun nc-goto-proc-hdr()
  "move point to the next proc dcl, on the name of the proc; return proc name"
  (interactive)
  (if (n-s "^[^ \t]\\([^\n]*[ \t]\\)*\\([a-zA-Z0-9_]*\\)([^\n]*)[ \t]*\n")
      (progn
        (forward-line -1)
        (forward-line 0)
        (or (looking-at "^\\*?\\([^\n]*[ \t]\\)*\\([a-zA-Z0-9_]*\\)([^\n]*)[ \t]*\n")
            (error "nc-goto-proc-hdr: my regexp's are not consistent"))
        (n--pat 2)
        )
    (error "no more proc hdrs")
    )
  )
(defun nc-ansi-to-kr()
  "in the current file convert all proc headers to the msc style"
  (interactive)
  (nc-goto-1rst-proc-hdr)
  (while (nc-goto-proc-hdr)
    (if (nc-kr-argsp)
        (forward-line 1)
      (nc-ansi-to-kr1))
    )
  )

(defun nc-ansi-to-kr1()
  (narrow-to-region (progn
                      (n-s "(" t)
                      (skip-chars-backward " \t\n")
                      (point)
                      )
                    (progn
                      (n-s ")" t)
                      (skip-chars-forward " \t\n")
                      (point)
                      )
                    )
  (goto-char (point-min))
  (let(
       (args	(buffer-substring-no-properties (point-min) (point-max)))
       )
    (goto-char (point-min))
    (replace-regexp "[_a-zA-Z0-9]+[ 	]+\\**\\([_a-zA-Z0-9]+\\)\\(\\[\\]\\)?" "\\1")
    (goto-char (point-min))
    (replace-regexp "[\t \n]+" " ")
    (goto-char (point-min))
    (replace-regexp " ?( ?" "(")
    (goto-char (point-min))
    (replace-regexp " ?) ?" ")")
    
    (goto-char (point-max))
    (insert "\n")
    (n-loc-push)
    (insert args)
    )
  (narrow-to-region (point) (progn (n-loc-pop)
                                   (point))
                    )
  (goto-char (point-min))
  (replace-regexp "[ \t\n]+" " ")
  (goto-char (point-min))
  (replace-regexp "," ";\n")
  (goto-char (point-min))
  (replace-regexp "^ " "")
  
  (goto-char (point-max))
  (n-r ")" t)
  (delete-char 1)
  
  (delete-horizontal-space)
  
  (insert ";\n")
  (widen)
  )

(defun nc-get-args-info()
  (interactive)
  (end-of-line)
  (let(
       nameV	; vector of names corresponding to the arg list
       typeV	; vector of types corresponding to the arg list
       ptrV	; vector of t/nil values telling whether the 
                                        ; corresponding arg is a ptr
       (begArgs	(nc-find-args-start))
       (endArgs	(progn
		  (n-r ")" t)
                  (point)
                  )
                )
       )
    (narrow-to-region begArgs endArgs)
    (goto-char (point-min))
    
    (while (not (eobp))
      (let(
           (type	(n-grab-token))
           (ptr	(progn
                  (nc-next-token)
                  (if (looking-at "\*")
                      (progn
                        (forward-char 1)
                        t
                        )
                    )
                  )
                )
           (name      (n-grab-token))
           )
        (nc-next-token)
        (setq nameV (append nameV (list name)))
        (setq typeV (append typeV (list type)))
        (setq ptrV  (append ptrV  (list ptr )))
                                        ;(n-print (concat "type is " type "\n"))
                                        ;(n-print (concat "name is " name "\n"))
                                        ;(n-print (concat "ptr is "
                                        ;                 (n-booltoa ptr)
                                        ;                 "\n"
                                        ;         )
                                        ;)
        )
      )
    
    (widen)
    (list nameV typeV ptrV)
    )
  )
(defun nc-prototype()
  "generate a prototype for C proc, whose first line is under point.
This prototype is written to the end of the appropriate header file"
  (interactive)
  (let(
       dclHdr
       nameV	; vector of names corresponding to the arg list
       typeV	; vector of types corresponding to the arg list
       ptrV	; vector of t/nil values telling whether the 
                                        ; corresponding arg is a ptr
       (extern	(progn
                  (forward-line 0)
                  (not (looking-at "[^\n(]*static"))
                  )
                )
       (begDcl	(point))
       (endDcl	(progn
                  (if (n-s "(")
                      (point)
                    (error "cannot find '(' where args begin")
                    )
                  )
                )
       (begArgs	(nc-find-args-start))
       (endArgs	(progn
                  (if (looking-at ")")		; special case: no args
                      (point)
		    (n-s "{" t)
		    (n-r ")" t)
                    )
                  (point)
                  )
                )
       (argInfo (nc-get-args-info))
       )
    (setq dclHdr (buffer-substring-no-properties begDcl endDcl))
    (narrow-to-region begArgs endArgs)
    (setq nameV (car argInfo)
	  typeV (cadr argInfo)
	  ptrV (caddr argInfo)
	  )
    
    (widen)
    (delete-region endDcl endArgs)
    (if extern
        (nc-update-prototype (nc-header-name (buffer-file-name)) 
			     dclHdr
			     typeV
			     ptrV
			     )
      )
    (nc-k-r-hdr typeV nameV ptrV)
    )
  )

(defun nc-find-args-start()
  "find the beginning of the argument list for a routine whose
header is under point (with type and name immediately preceding
the cursor)."
  (save-excursion
    (n-r "(" t)
    (forward-char 1)
    (point)
    ;;                                        ;
    ;;                                        ;	There are 2 important cases:
    ;;                                        ;		1. MS-C's style
    ;;                                        ;		2. K+R style
    ;;                                        ;			in this case, delete the initial list
    ;;                                        ;			of names, which will not be needed anymore.
    ;;                                        ;
    ;;    
    ;;    (if (looking-at ")")
    ;;	(point)
    ;;      (progn
    ;;	(skip-chars-forward " \t\n")
    ;;	(let (
    ;;	      (argsIfMSC	(point))	; if it's MS-C, the args start here
    ;;	      argsIfKR			; if it's K+R, the args start here
    ;;	      (krArg1		(n-grab-token))	; if it's K+R, this is the first arg
    ;;	      )
    ;;	  (if (n-s ")")
    ;;	      (progn
    ;;                                        ;
    ;;                                        ; Find the 2nd, full dcl for the first arg.  It'll only be there
    ;;                                        ; if it is K+R.
    ;;                                        ;
    ;;		(nc-next-token)
    ;;		(setq argsIfKR (point))
    ;;		(nc-next-token)
    ;;		(if (equal (n-grab-token) krArg1)  
    ;;		    argsIfKR
    ;;		  argsIfMSC
    ;;		  )
    ;;		)
    ;;	    argsIfMSC
    ;;	    )
    ;;	  )
    ;;	)
    ;;)
    )
  )

(defun nc-k-r-hdr (typeV nameV ptrV)
  "given a list TYPEV of that routine's args' types,
a list NAMEV of that routine's args' names,
and a t/nil list PTRV telling whether any of these args
are pointers, this routine dumps out a K+R proc header at point, not including
the routine name and type"
  (let(
       (name2V	nameV)
       (nameCol	(+ 16 (n-max-strlen typeV)))
       )
    (while name2V
      (insert 
       (format " %s" (car name2V))
       )
      (setq name2V (cdr name2V))
      (if name2V
          (insert ","))
      )
    (if nameV
        (insert " )"))
    
    (while typeV
      (insert
       (format "\n            %s" (car typeV))
       )
      (if (car ptrV)
          (progn
            (indent-to-column (1- nameCol))
            (insert "*")
            )
        (indent-to-column nameCol)
        )
      (insert
       (format "%s;" (car nameV))
       )
      (setq nameV (cdr nameV))
      (setq typeV (cdr typeV))
      (setq ptrV  (cdr  ptrV))
      )
    )
  )

(defun nc-update-prototype (hFn dclHdr typeV ptrV)
  "given the name HFN of a C header file, a string DCLHDR containing the type and
name of a C routine, a list TYPEV of
that routine's args' types, and a t/nil list PTRV telling whether any of these args
are pointers, this routine dumps updates the K+R prototype (suitable for gcc)
in the aforementioned header file"
  (save-excursion
    (find-file hFn)
    (goto-char (point-min))
    (if (n-s dclHdr)
        (nsimple-kill-line)
      )
    
                                        ;
                                        ; go to the end of the buffer.  Don't waste space.
                                        ;
    (goto-char (point-max))
    (just-one-space)
    (forward-line 0)
    (if (not (nsimple-blank-line-p))
        (progn
          (end-of-line)
          (insert "\n")
          )
      )
    
    (insert
     (format "%s" dclHdr )
     )
    (while typeV
      (insert
       (format " %s" (car typeV))
       )
      (if (car ptrV)
          (insert " *"))
      (setq typeV (cdr typeV))
      (setq ptrV (cdr ptrV))
      (if typeV
          (insert ","))
      )
    (insert " );\n")
    )
  )


(defun nc-skip-token()
  "skip a C token forward"
  (skip-chars-forward "A-Za-z_0-9")
  )

(defun nc-skip-chaff()
  "skip past white space, commas, semicolons, parentheses"
  (skip-chars-forward " 	\n,;()")
  )

(defun nc-next-token()
  "skip past a C token and the white space immediately following"
  (nc-skip-token)
  (nc-skip-chaff)
  )

(defun nc-define-no()
  (save-excursion
    (forward-line -1)
    (if (not (looking-at "#define"))
        1
      (let(
           (x1	(progn (end-of-line)
                       (forward-word -1)
                       (n-grab-number)
                       )
                )
           (x2	(if (not (progn
                           (forward-line -1)
                           (looking-at "#define"))
                         )
                    nil
                  (end-of-line)
                  (forward-word -1)
                  (n-grab-number)
                  )
                )
           )
        (if (and x2 (eq 2 (/ x1 x2)))	; bit map (i.e., each define is twice the last)?
            (* x1 2)
          (1+  x1)			; ...or incremental progression?
          )
        )
      )
    )
  )

(defun nc-looking-at-include-p()
  (save-excursion
    (forward-line 0)
    (looking-at "#[ \t]*include")
    )
  )
(defun nc-get-includes-list()
  "returns a list of directory names composing the INCLUDE path"
  (let(
       (includeString   (nc-get-includes))
       (canonicalList	(list default-directory))
       includeList
       )
    (if (not includeString)
        nil
      (setq includeString (nstr-replace-regexp includeString "-I" ""))
      (setq includeString (nstr-replace-regexp includeString ";" " "))
      (setq includeList      (nstr-split includeString))
      (while includeList
        (let(
             (raw	(car includeList))
             (canonical	(n-host-to-canonical (car includeList)))
             )
                                        ;(n-trace "raw=%s, canonical=%s" raw canonical)
          (setq canonicalList 	(append canonicalList
                                        (list
                                         (concat canonical "/")
                                         )
                                        )
                includeList		(cdr includeList)
                )
          )
        )
      canonicalList
      )
    )
  )



(defun nc-get-includes()
  "from a C file, return the value of $(INCLUDE)."
  (let(
       (valueList   (cond
		     ;;((nsyb-make-searching)
		     ;;(nsyb-get-incs-make-search)
		     ;;)
		     ((string-match "highgate/" (buffer-file-name))
		      "-I. -I.. -I~/highgate/server/inc -I~/highgate/share/inc -I/usr/local/rogue"
		      )
		     (t
                      (require 'n-make)
		      ;;(n-make-outside-eval "INCLUDE" "INCLUDE_FLAGS")
		      (n-make-outside-eval "INCLUDE_FLAGS")
		      )
		     )
		    )
       )

    (if valueList
	(concat valueList " -I/usr/include")
      "-I. -I/usr/include"
      )
    )
  )


(defun nc-show-includes-print-name(fn end)
  (if nc-show-includes-expand
      (n-print ":::%s:::%s" fn end)
    (n-print "%s%s" fn end)
    )
  )

(defun nc-show-includes-2( fn col)
  (if (not nc-show-includes-expand)
      (n-print (make-string col 32)))		; space
  (nc-show-includes-print-name fn "\n")
  (goto-char (point-min))
  (while (not (eobp))
    (if (and (funcall n-looking-at-include-p)
             (not (nc-include-already-seen (funcall n-get-include-name)))
             )
        (save-window-excursion
          (nc-note-that-this-include-has-been-seen (funcall n-get-include-name))
          (if (n-file-find-from-path (funcall n-get-include-name) nc-show-includes-list)
              (save-window-excursion
                (nc-show-includes-2 (buffer-file-name) (+ 4 col) )
                (if nc-show-includes-expand
                    (nc-show-includes-print-name fn "continued\n"))
                (nbuf-kill-current)
                )
            (nc-show-includes-print-name (funcall n-get-include-name) "	couldn't find it\n")
            (setq nc-show-includes-e-cnt (1+  nc-show-includes-e-cnt))
            )
          )
      (if nc-show-includes-expand
          (n-print "%s\n" (n-get-line)))
      )
    (forward-line 1)
    )
  )

(defun nc-show-includes( &optional arg)
  "in the current C file, find all (including nested) includes.
write the names to *n-output*, or if optional ARG is non-nil, expand out the includes"
  (interactive "P")
  (nbuf-kill "*n-output*")
  (let(
       (nc-show-includes-list (funcall n-get-includes-list))
       includes-already-seen
       (nc-show-includes-expand arg)
       (nc-show-includes-e-cnt 0)
       )
    (nc-show-includes-2 (buffer-file-name) 0)
    (switch-to-buffer-other-window (get-buffer "*n-output*"))
    (cond
     ((< 0  nc-show-includes-e-cnt)
      (message (format "couldnt find %d"  nc-show-includes-e-cnt)))
     (nc-show-includes-expand
      (message "nc-show-includes done"))
     )
    )
  )
(defun nc-get-includes-text()
  (n-text-to-tokens (nstr-replace-regexp (nc-get-includes) "\\\\\n" " ")))

(defun nc-include( &optional arg)
  (interactive "P")
  (if (save-excursion
        (forward-line 0)
        (looking-at "^[a-zA-z0-9/_]+$")
        )
      (progn
        (forward-line 0)
        (delete-horizontal-space)
        (insert "#include ")
        (if (y-or-n-p "use quotes")
            (progn
              (insert "\"")
              (end-of-line)
              (insert ".h\"")
              )
          (progn
            (insert "<")
            (end-of-line)
            (insert ".h>\n")
            )
          )
        )
    (let(
         (include	(file-name-nondirectory (buffer-file-name)))
         )
      (n-other-window)
      (goto-char (point-max))
      (n-r "#include" t)
      (forward-line 1)
      (insert "#include \"" include "\"\n")
      )
    )
  )

(defun nc-define()
  (interactive)
  (forward-line 0)
  (insert "#define ")
  (just-one-space)
  (if (looking-at "[a-zA-Z0-9_]+[ \t]*$")
      (progn
        (upcase-region (point) (progn
                                 (end-of-line)
                                 (point)
                                 )
                       )
        (just-one-space)
        (forward-char -1)
        (delete-char 1)
        (insert (format "\t%d" (nc-define-no)))
        )
    )
  (forward-line 1)
  )

(defun nc-assert-parm()
  "add an assert stmt for the given parm; assumes LOG_ROUTINE is there"
  (interactive)
  (let(
       (parm	(n-grab-token))
       )
    (save-excursion
      (if (not (n-s "LOG_ROUTINE"))
          (error "no LOG_ROUTINE in this proc"))
      (forward-line 1)
      (insert "    ASSERT( " parm " );\n")
      )
    (forward-line 1)
    (end-of-line)
    (forward-word -1)
    )
  )

(defun nc-line-up-cols-cnt-whites()
  (save-restriction
    (narrow-to-region (point) (progn
                                (forward-line 0)
                                (point)
                                )
                      )
    (end-of-line)
    (let(
         cols
         )
      (while (progn
               (if (n-r "[ \t]")
                   (progn
                     (forward-char 1)
                     (setq cols (cons (current-column) cols))
                     (skip-chars-backward " \t")
                     t
                     )
                 (if (/= (current-column) 0)
                     (setq cols (cons 0 cols)))
                 nil
                 )
               )
        )
      (widen)
      cols
      )
    )
  )

(defun nc-line-up-cols()
  "line up columns: after you put (point) on a token, this proc seeks out
similar following lines and makes the corresponding token line up"
  (interactive)
  (let(
       (cols	(nc-line-up-cols-cnt-whites))
       )
    (goto-char (point-min))
    (while (catch 'nc-line-up-cols-tag
             (let(
                  (lcols	cols)
                  )
               (forward-line 1)
               (save-restriction
                 (n-narrow-to-line)
                 (goto-char (point-min))
                 
                 (while lcols
                   (just-one-space)
                   (if (= 1 (current-column))
                       (delete-char -1))
                   (indent-to-column (car lcols))
                   (if (and (setq lcols (cdr lcols))
                            (or (eobp)
                                (not (n-s "[ \t]+"))
                                )
                            )
                       (throw 'nc-line-up-cols-tag nil))
                   )
                 (widen)
                 )
               )
             (not (eobp))
             )
      )
    )
  )

(defun nc-line-up-args()
  "line up args; call from where nc-goto-next-proc moves pt"
  (interactive)
  (n-s "(")
  (forward-char -1)
  (forward-sexp 1)
  (forward-line 1)
  (narrow-to-region (point) (progn
                              (n-s "^{")
                              (forward-char -1)
                              (point)
                              )
                    )
  (goto-char (point-min))
  (just-one-space)
  (delete-char -1)
  (if (and (not (eobp))
           (n-s ";")
           )
      (progn
        (n-r "[ \t]" t)
        (just-one-space)
        (delete-char -1)
        (if (< (current-column) 8)
            (insert "\t"))
        (insert "\t")
        (nc-line-up-cols)
        )
    )
  (widen)
  )

(defun nc-no-lower-p( token )
  "t if no lowercase chars"
  (nstr-buf token '(lambda()
                      (goto-char (point-min))
                      (not (n-s "[a-z]"))
                      )
            )
  )

(defun nc-rm-unused()
  (interactive)
  (let(
       (tt	(n-grab-token))
       (cnt	0)
       )
    (setq tt (concat "\\b" tt "\\b"))
    (save-excursion
      (goto-char (point-min))
      (while (n-s tt)
        (setq cnt (1+ cnt))
        )
      )
    (if (eq cnt 1)
        (delete-region (progn
                         (forward-line -1)
                         (point)
                         )
                       (progn
                         (n-s "^}" t)
                         (point)
                         )
                       )
      )
    (forward-line 1)
    (nc-goto-proc-hdr)
    )
  )
(setq nc-ifdef-what "dead")
(defun nc-ifdef-to-bracket-header()
  (let(
       (token (nstr-replace-regexp
               (nstr-upcase
                (file-name-nondirectory (buffer-file-name)))
               "\\."
               "_"
               )
              )
       )
    (goto-char (point-min))
    (insert "#ifndef " token "\n#define " token "\n\n")
    (goto-char (point-max))
    (insert "#endif\n")
    )
  )
(defun nc-ifdef( &optional arg)
  (interactive "P")
  (let(
       (command (if (not arg)
                    ?-
                  (message "h-header_bracket, v-variable")
                  (read-char)
                  )
                )
       done
       )
    (cond
     ((eq command ?h)
      (nc-ifdef-to-bracket-header)
      (setq done t)
      )
     ((eq command ?v)
      (setq nc-ifdef-what (read-string "def variable:"))
      )
     )
    (if (not done)
        (progn
          (forward-line 0)
          (insert "#ifdef " nc-ifdef-what "\n")
          (forward-line 1)
          (insert "#endif\n")
          )
      )
    )
  )

(defun nc-clone-define-cmd()
  "UNUSED: call in buf1, a .h with point on define; put repetitive code into buf2, which is reached by means of n-other-window"
  ;;Example:
  ;;
  ;;	#define XATEST_OP_FLAG		(xatest_THREAD_OP)14
  ;;pt>	#define XATEST_OP_LOOP		(xatest_THREAD_OP)15
  ;;
  ;;[pfx=XATEST_OP_, var1=FLAG, var2=LOOP]
  ;;
  ;; or if point is not in a series of defines, var2 is the current token and var1 is the previous.
  ;;
  ;; ...XATEST_OP_FLAG, XATEST_OP_LOOP...
  ;;                        pt^
  ;;
  ;;[pfx=XATEST_OP_, var1=FLAG, var2=LOOP]
  ;;
  ;;In buf2, for each understood use of XATEST_OP_FLAG, create analogous code
  ;;using XATEST_OP_LOOP:
  ;;
  ;;        else if (!strcmp(op, 'flag'))
  ;;        {
  ;;                action->op = XATEST_OP_FLAG;
  ;;                action->flagValue = parse__flag(rest);
  ;;        }
  ;;
  ;;to
  ;;
  ;;        else if (!strcmp(op, 'flag'))
  ;;        {
  ;;                action->op = XATEST_OP_FLAG;
  ;;                action->flagValue = parse__flag(rest);
  ;;        }
  ;;        else if (!strcmp(op, 'loop'))
  ;;        {
  ;;                action->op = XATEST_OP_LOOP;
  ;;                action->flagValue = parse__flag(rest);
  ;;        }
  ;;
  ;;

  (save-window-excursion
    (let(
         pfx
         var2
         var1
         )
      (if (save-excursion
            (forward-line 0)
            (looking-at "#define")
            )
          (setq var2	(progn
                          (forward-line 0)
                          (n-s "#define[ \t]*" t)
                          (n-grab-token)
                          )
                var1	(progn
                          (forward-line -1)
                          (n-s "#define[ \t]*" t)
                          (n-grab-token)
                          )
                )
        (setq var2 (n-grab-token)
              var1 (progn
                     (n-r "[^a-zA-Z0-9_]" t)
                     (forward-word -1)
                     (n-grab-token)
                     )
              )
        )
      (setq pfx	(substring var1 0 (nstr-dif var1 var2))
            var1	(substring var1 (length pfx))
            var2	(substring var2 (length pfx))
            )
      (n-other-window)
      (nc-clone-define pfx var1 var2)
      )
    )
  )
(defun nc-clone-define(pfx var1 var2)
  (goto-char (point-min))
  (while (n-s (concat "^[ \t]*case " pfx var1 ":$"))
    (narrow-to-region (progn
                        (forward-line 0)
                        (point)
                        )
                      (progn
                        (forward-line 1)
                        (n-sv (list
                               (list "^[ \t]*case ")
                               (list "^[ \t]*default:$")
                               )
                              "nc-clone-define: end-of-case"
                                        ;                               10
                              )
                        (forward-line 0)
                        (point)
                        )
                      )
    (nc-clone-define-dupe pfx var1 var2)
    )
  
  (goto-char (point-min))
  (while (n-s (concat "if (!str[a-z]*cmp([^)]*"
                      (nstr-downcase var1)
                      "[^{}]*{"
                      "[^{}]*"
                      var1
                      )
              )
    (narrow-to-region (progn
                        (n-r "{" t)
                        (forward-line -1)
                        (point)
                        )
                      (progn
                        (n-s "}" t)
                        (forward-line 1)
                        (point)
                        )
                      )
    (nc-clone-define-dupe pfx var1 var2)
    )
  )
(defun nc-clone-define-dupe(pfx var1 var2)
  (let(
       (lvar1	(nstr-downcase var1))
       (lvar2	(nstr-downcase var2))
       (data	(buffer-substring-no-properties (point-min) (point-max)))
       )
    (goto-char (point-max))
    (narrow-to-region (point) (point))
    (insert data)
    
    (goto-char (point-min))
    (replace-regexp 
     (concat pfx var1)    
     (concat pfx var2)
     )
    
    (goto-char (point-min))
    (replace-regexp lvar1 lvar2)
    
    (let(
         (cmd	(progn
                  (message "remember point?")
                  (read-char)
                  )
                )
         )
      (cond
       ((= cmd ?y)
        (n-loc-push)
        )
       )
      )
    )
  (widen)
  )
(defun nc-check-pointers()
  (interactive)
  (forward-line 1)
  (n-loc-push)
  (forward-line -1)
  (while (progn
           (n-2-lines)
           (back-to-indentation)
           (insert "TU_CHECK_PTR(")
           (end-of-line)
           (insert ")                   ;")
           (forward-line -1)
           (n-narrow-to-line)
           (delete-region
            (progn
              (end-of-line)
              (point)
              )
            (progn
              (n-r "->")
              (point)
              )
            )
           (widen)
           (forward-line 1)
           (if (looking-at ".*->")
               (progn
                 (forward-line -1)
                 t
                 )
             (forward-line -1)
             (nsimple-delete-line 1)
                         nil
                         )
              )
          )
  (n-loc-pop)
  )
(defun nc-leap-back-bracket()
  (forward-line -1)
  (indent-according-to-mode)
        )
(defun nc-declare-local-data()
  (interactive)
  (let(
       (prefix	(nfn-prefix))
       )
    (insert "
typedef struct {
	;;
} " prefix "__DATA;
" prefix "__DATA	" prefix "__Data;
")
    
    (n-r "@@" t)
    (delete-char 2)
    )
  )

(defun nc-declare-class-at-header-top()
  (interactive)
  (n-loc-push)
  
  (let(
       (token (n-grab-token))
       )
    (goto-char (point-min))
    (if (n-s "^class.*;" t)
        (forward-line 0)
      (goto-char (point-max))
      (n-r "^#include" t)
      (forward-line 1)
      (insert "\n\n")
      )
    (insert "class " token ";\n")
    )
  )

(defun nc-class-add-runtime-type()
  (interactive)
  (n-loc-push)
  (or (save-excursion
        (forward-line 0)
        (looking-at "class \\([a-zA-Z0-9_]+\\)")
        )
      (error "nc-class-add-runtime-type: cannot find class name")
      )
  (let(
       (class (n--pat 1))
       base
       )
    (forward-line 0)
    (if (not (looking-at ".*:"))
        (progn
          (end-of-line)
          (insert ": public HGObject")
          )
      )
    (forward-line 0)
    (or (looking-at ".*:[ \t]*public[ \t]*\\([a-zA-Z0-9_]+\\)")
        (error "nc-class-add-runtime-type: base class")
        )
    (setq base (n--pat 1))
    (n-s "{" t)
    (forward-line 1)
    (insert "    HG_DECL(" class ");\n")
    (insert "HG_DEFN(" class ", " base ");\n")
    (forward-line -1)
    (nsimple-kill-line)
    )
  )
(defun nc-declare-auto-pointer()
  (interactive)
  (nsimple-back-to-indentation)
  (let(
       token
       aptoken
       type
       )
    (cond
     ((looking-at "\\(.*[\t* ]\\)?\\([^ \t]+\\) = new \\([^][;()]+\\)\\(.\\)")
      (setq token (n--pat 2)
            type (n--pat 3)
            nextChar (n--pat 4)
            )
      )
     (t (error "nc-declare-auto-pointer: "))
     )
    
    (cond
     ((= (elt nextChar 0) 91)	; left-bracket
      (setq autoToken "auto_ptr_array<"))
     (t
      (setq autoToken "auto_ptr<"))
     )
    (end-of-line)
    (setq apToken (if (string-match "^p" token)
                      (concat "a" token)
                    (concat "ap" token) 
                    )
          )
    (if (string-match ">$" type)
        (setq type (concat type " ")))
    
    (nsimple-newline-and-indent)
    (insert autoToken type ">\t" apToken "(" token ");\n")
    (insert apToken ".release();\n")
    )
  (forward-line -1)
  (nsimple-kill-line 1)
  (nsimple-back-to-indentation)
  )

(defun nc-generate-assert()
  (delete-region (point)
                 (progn
                   (n-s "HG_ASSERT(" t)
                   (point)
                   )
                 )
  (end-of-line)
  (delete-region (point)
                 (progn
                   (n-r ")" t)
                   (point)
                   )
                 )

  (let(
       (condition (buffer-substring-no-properties (progn
                                      (forward-line 0)
                                      (point)
                                      )
                                    (progn
                                      (end-of-line)
                                      (point)
                                      )
                                    )
                  )
       )
    (delete-region (progn
                     (forward-line 0)
                     (point)
                     )
                   (progn
                     (end-of-line)
                     (point)
                     )
                   )
    (cond
     ((string-match "0" condition)
      (setq condition nil)
      )
     ((string-match "^!\\(.*\\)" condition)
      (setq condition (n--pat condition 1))
      )
     (t
      (setq condition (concat "!" condition))
      )
     )
    (if condition
        (insert "if (" condition ") {\n"))
    (insert "throw ApiError(hgHighgateAssert_error, \"@@\");\n")
    (if condition
        (insert "}\n"))
    )

  (let(
       (start (point-min))
       (end (point-max))
       )
    (widen)
    (indent-region start end nil)
    (goto-char start)
    (n-complete-leap)
    )
  )

(defun nc-declare-static-instance()
  (interactive)
  (let(
       (line	(n-get-line))
       (className (save-excursion
                    (n-r "^class[ \t]*\\([^ \t]+\\)" t)
                    (n--pat 1)
                    )
                  )
       )
    (other-window 1)
    (forward-line 0)
    (insert line "\n")
    (forward-line -1)
    (n-narrow-to-line)
    (forward-line 0)
    (delete-region (point) (progn
                             (n-s "static[ \t]*" t)
                             (point)
                             )
                   )
    (end-of-line)
    (n-r "[ \t]+" t)
    (forward-word 1)
    (forward-word -1)
    (insert className "::")
    )
  (end-of-line)
  (n-r ";" t)
  (insert " = ")
  (widen)
  )

(defun nc-gen-set-and-get-methods()
  "generate get and set methods for the identifier whose declaration is under point."
  (interactive)
  (n-2-lines)
  (save-restriction
    (end-of-line)
    (delete-char 1)
    (narrow-to-region (point) (progn
				(forward-line 0)
				(point)
				)
		      )

    (forward-line 0)
    (replace-regexp "[ \t]*=.*" "")
    (replace-regexp ";" "")
    (let(
	 (token (n-grab-token))
	 (type (progn
		 (n-r "[ \t]+" t)
		 (forward-word -1)
		 (n-grab-token)
		 )
	       )
	 )
      (if (not (string-match "^m_\\(.*\\)" token))
	  (error "nc-gen-set-and-get-methods: variable must begin with 'm_'"))
      (setq token (n--pat 1 token))
      (delete-region (point-min) (point-max))
      (if (eq major-mode 'njava-mode)
          (insert "public "))
      (insert type " get" token)
      (n-r " " t)
      (n-s "get" t)
      (nsimple-upcase-char)
      (end-of-line)
      (insert "() {\nreturn m_" token ";\n}\n")

      (forward-line 1)
      (if (eq major-mode 'njava-mode)
          (insert "public "))
      (insert "void set" token)
      (n-r " " t)
      (n-s "set" t)
      (nsimple-upcase-char)
      (end-of-line)
      (insert "(" type " " token ") {\nm_" token " = " token ";\n}\n")
      (kill-region (point-min) (point-max))
      )
    )
  (save-excursion
    (n-r "}" t)
    (forward-line 1)
    (nsimple-yank-command)
    )
  )

(defun nc-complete-constructor(dummy1)
  (let(
       (data (buffer-substring-no-properties (progn
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
    (forward-line 0)
    (n-loc-push)

    (end-of-line)
    (insert " {\n")
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data)
      (goto-char (point-min))
      (replace-regexp "\\([A-Za-z_0-9]+\\)[ \t\n]+\\([A-Za-z_0-9]+\\)[ \t\n]*,?"
                      "\\2 = \\2;\n"
                      )
      (goto-char (point-min))
      (while (n-s "= ")
        (nsimple-back-to-indentation)
        (insert "m_")
        (forward-line 1)
        )
      (goto-char (point-max))
      )
    (forward-line 1)
    (insert "}\n")
    (n-loc-pop)
    (save-restriction
      (narrow-to-region (point) (point))
      (insert data "\n")
      (goto-char (point-min))
      (replace-regexp "\\([A-Za-z_0-9]+\\)[ \t\n]+\\([A-Za-z_0-9]+\\)[ \t\n]*,?"
                      "@@private \\1\t!\\2;\n"
                      )
      (goto-char (point-min))
      (while (n-s "!")
        (forward-char -1)
        (delete-char 1)
        (insert "m_")
        )
      (goto-char (point-min))
      (n-complete-leap)
      )
    )
  (call-interactively 'n-indent-region)
  )
(defun nc-generate-enumerator()
  (interactive)
  (or (y-or-n-p "generate an enumeration class?") (error "nc-generate-enumerator: "))
  (let(
       (oldClass (save-excursion
                   (n-r "^{" t)
                   (n-r "\\bclass" t)
                   (forward-word 2)
                   (n-grab-token)
                   )
                 )
       newClass
       (vectorField (progn
                      (n-s "^}" t)
                      (if (n-r "private Vector[ \t]+\\([A-Za-z0-9]+\\)")
                          (n--pat 1)
                        "mVector"
                        )
                      )
                    )
       )
    (setq newClass (concat oldClass "Enumeration"))

    (n-r "^{" t)
    (if (not (n-s "private" t))
        (progn
          (forward-char -1)
          (forward-sexp 1)
          )
      )
    (forward-line 0)
    (insert "    public Enumeration elements()
    {
        return new " newClass "(" vectorField ");
    }\n")

    (find-file (concat newClass ".java"))
    (insert "import " oldClass ".*;
import java.util.*;

class " newClass " implements Enumeration {
    public " newClass "(Vector vector)
    {
        " vectorField " = vector;
    }
    public boolean hasMoreElements()
    {
        return (" vectorField ".size() > mIndex);
    }
    public Object nextElement() throws NoSuchElementException
    {
        if (" vectorField ".size() <= mIndex) throw new NoSuchElementException();
        return " vectorField ".elementAt(mIndex++);
    }
    private int mIndex = 0;
    private Vector " vectorField ";
}
")
    )
  )

(defun nc-generate-enumerated-for-loop(&rest unused)
  (forward-line 0)
  (n-s "(" t)
  (save-restriction
    (widen)
    (delete-char 2)
    (insert "Enumeration e = @@.elements(); e.hasMoreElements();)")
    (forward-line 2)
    (indent-according-to-mode)
    (insert "@@ = e.nextElement();")
    )
  (goto-char (point-min))
  (n-complete-leap)
  )

(defun nc-narrow-to-routine()
  (save-excursion
    (nc-beginning-of-defun)
    (narrow-to-region (point)
                      (progn
                        (forward-sexp 1)
                        (point)
                        )
                      )
    )
  )

(defun nc-at-beginning-of-defun-p()
  (let(
       (pnt (point))
       )
    (save-excursion
      (condition-case nil
	  (progn
	    (nc-beginning-of-defun)
	    (eq pnt (point))
	    )
	(error	; no methods defined...
	 nil	; ...so we aren't at start of one
	 )
	)
      )
    )
  )

(defun nc-end-of-defun()
  (nc-beginning-of-defun)
  (forward-sexp 1)
  )

(defun nc-beginning-of-defun(&optional includingDcl)
  (interactive)
  (cond
   ((eq major-mode 'njava-mode)
    (njava-beginning-of-defun)
    (if includingDcl
	(progn
	  (n-r "\\(public\\|private\\|protected\\|static\\)" t)
	  (nsimple-back-to-indentation)
	  )
      )
    )
   ((eq major-mode 'nperl-mode)
    (if includingDcl
	(progn
	  (end-of-line)		; in case we are starting on the "sub " line
	  (n-r "^.?sub " t)  ; the .? is for the possibility of marking
	  )
      (beginning-of-defun)
      )
    )
   (t
    (beginning-of-defun)
    )
   )
  )

(defun nc-find-current-code-class-context()
  (save-excursion
    (if (not (n-r "^{"))
        ""
      (let(
           (hit (nc-v (list
                       (list "class[ \t]")
                       (list "(")
                       )
                      'n-rv
                      'n-r
                      )
                )
           )
        (cond
         ((string= hit "class[ \t]")
          (or (looking-at "class[ \t\n]+\\([0-9a-zA-Z_]+\\)")
              (error "nc-find-current-code-class-context: class")
              )
          (n--pat 1)
          )
         ((string= hit "(")
          (forward-line 0)
          (if (looking-at "^\\(.*[ \t\n]\\)\\([0-9a-zA-Z_]+\\)::[0-9a-zA-Z_]+[ \t\n]*(")
              (n--pat 2)
            ""; we just were not in class code
            )
          )
         )
        )
      )
    )
  )
(defun nc-find-current-token-class-context()
  (let(
       context
       )
    (setq context
          (cond
           ((save-excursion
              (skip-chars-backward "a-zA-Z0-9_")
              (forward-char (- ntags-find-class-context-operator-length))
              (if (looking-at ntags-find-class-context-operator-regexp)
                  (progn
                    (forward-char -1)
		    (require 'nclass-browser)
                    (if (nclass-browser-query-tag)
                        (setq context (n-grab-token))
                      )
                    )
                )
              )
            )
           ((save-excursion
              (skip-chars-backward "a-zA-Z0-9_")
              (forward-char -1)
              (if (looking-at "\\.")
                  (let(
                       (variable (progn
                                   (forward-char -1)
                                   (n-grab-token)
                                   )
                                 )
                       variablePattern
                       done
                       )
                    (setq variablePattern (concat "[^0-9a-zA-Z_]\\([0-9a-zA-Z_]+\\)[ \t]+"
                                                  variable
                                                  "[ \t]*\\(=\\|[,;]\\)"
                                                  )
                          )
                    (goto-char (point-min))
                    (while (and (not context)
                                (n-s variablePattern)
                                )
                      (setq context (n--pat 1))
                      (if (or
                           (string= "return" context)
                           )
                          (setq context nil)
                        )
                      )              
                    )
                )
              context
              )
            context
            )
           (t
            (nc-find-current-code-class-context)
            )
           )
          )
    
    (if (not context)
        (setq context ""))
    
    (if (and
         (eq major-mode 'njava-mode)
         (string= context "super")
         )
        (setq context 
              (nclass-browser-get-parent
               (nc-find-current-code-class-context)
               )
              )
      )
    context
    )
  )
(defun nc-method-pruning-function()
  (goto-char (point-min))
  (let(
       public start done
              )
    (while (not done)
      (setq start (point))
      (if (not (n-s "public:"))
          (setq done t)
        (delete-region start (point))
        (if (n-s "private:")
            (progn
              (forward-line 0)
              (setq start (point))
              )
          (setq done t
                public t)
          )
        )
      )
    (if (not public)
        (delete-region start (point-max))
      )
    )
  (goto-char (point-min))
  (replace-regexp "//.*" "")
  (goto-char (point-min))
  (replace-regexp "\n" "")
  (goto-char (point-min))
  (while (n-s "{")
    (forward-char -1)
    (delete-region (1+ (point))
                   (progn
                     (forward-sexp 1)
                     (point)
                     )
                   )
    )
  (goto-char (point-min))
  (while (n-s "/\\*")
    (forward-char -2)
    (delete-region (point)
                   (progn
                     (n-s "\\*/")
                     (point)
                     )
                   )
    )
  (goto-char (point-min))
  (replace-regexp ";" ";\n")
  (replace-regexp "{" ";\n")
  )

(defvar n-get-include-name nil)
(make-variable-buffer-local 'n-get-include-name)
(set-default 'n-get-include-name 'nc-get-include-name)

(defvar n-looking-at-include-p nil)
(make-variable-buffer-local 'n-looking-at-include-p)
(set-default 'n-looking-at-include-p 'nc-looking-at-include-p)

(defvar n-get-includes-list nil)
(make-variable-buffer-local 'n-get-includes-list)
(set-default 'n-get-includes-list 'nc-get-includes-list)

(defun nc-imitate( &optional arg)
  (interactive "P")
  (if arg
      (let(
	   (token (n-grab-token))
	   (from (buffer-file-name))
	   (to (n-database-get "imitate-destination-file"))
	   (defaultTo default-directory)
	   )
	(save-window-excursion
	  (other-window 1)
	  (if (and
	       (buffer-file-name)
	       (not (string= from (buffer-file-name)))
	       (string-match default-directory (buffer-file-name))
	       )
	      (setq defaultTo (buffer-file-name))
	    ) 
	  )
	(setq token (read-string "token to imitate: " token))
	
	
	
	
	
	(setq to defaultTo)
 	;;(if (not to) (setq to (nfly-read-fn "imitate-destination-file: " defaultTo)))
	
	
	
	
	
	(n-database-set "imitate-file-to" to)
	(n-database-set "imitate-file-from" from)
	(n-database-set "imitate-token" token)
	
	(find-file from)
	(goto-char (point-max))
	(while (n-r (concat "\\b" token "\\b"))
	  (n-loc-push)
	  )
	)
    )    
  (let(
       (to	(n-database-get "imitate-file-to"))
       (from	(n-database-get "imitate-file-from"))
       (token	(n-database-get "imitate-token"))
       )
    (find-file to)
    (delete-other-windows)
    (nsimple-split-window-vertically)
    (find-file from)
    (let(
	 (method (n-defun-name))
	 )
      (other-window 1)
      (goto-char (point-min))
      (if (not method)
	  (progn
	    (n-s "^{")
	    (forward-line 1)
	    (if (looking-at ".*DEBUG.*=")
		(forward-line 1)
	      (forward-line -1)
	      )
	    )
	(n-s (concat "^\t?[^\t ].*" method "[ \t]*(") t)
	(n-s "{" t)
	(forward-line 1)
	(cond
	 ((looking-at ".*if (DEBUG)[ \t\n]*{")
	  (n-s "{" t)
	  (forward-char -1)
	  (forward-sexp 1)
	  )
	 ((looking-at ".*if (DEBUG)")
	  (n-s ";" t)
	  (forward-line 1)
	  )
	 )
	(other-window 1)
	)
      )
    )
  )
(defun nc-2-lines-programming-block-p()
  (save-excursion
    (and
     (progn
       (nsimple-back-to-indentation)
       (looking-at "\\(else \\)?if (.*)$")
       )
     (progn
       (forward-line 1)
       (nsimple-back-to-indentation)
       (looking-at "{")
       )
     )
    )
  )

(defun nc-2-lines-programming-block()
  (let(
       addedElse
       )
    (nsimple-back-to-indentation)
    (if (looking-at "if")
	(progn
	  (insert "else ")
	  (setq addedElse t)
	  )
      )
    (n-loc-push)
    (n-2-lines (save-restriction
		 (narrow-to-region (point) (point-max))
		 (forward-line 1)
		 (forward-sexp 1)
		 (prog1
		     (n-what-line)
		   (goto-char (point-min))
		   )
		 )
	       )
    (n-loc-pop)
    (nsimple-back-to-indentation)
    (if addedElse
	(delete-region (point) (progn
				 (n-s "else " t)
				 (point)
				 )
		       )
      )
    )
  (kill-region
   (progn
     (end-of-line)
     (n-r "\"" t)
     (point)
     )
   (progn
     (forward-line 0)
     (n-s "\"" t)
     (point)
     )
   )
  )
(defun nc-2-lines()
  (interactive)
  (require 'n-2-lines)
  (if (not (nc-2-lines-programming-block-p))
      (call-interactively 'n-2-lines)
    (nc-2-lines-programming-block)
    )
  )
(defun nc-mode-kin-p()
  (or
   (eq major-mode 'c++-mode)
   (eq major-mode 'c-mode)
   (eq major-mode 'njava-mode)
   )
  )
(defun nc-delete-comments()
  (goto-char (point-min))


  ;;I used to delete "//.*", but this can lead the trouble when you have URLs
  ;;embedded in the code:
  ;;
  ;;	whatever("HTTP://host/")
  ;;
  ;;Becomes
  ;;
  ;;	whatever("HTTP:
  ;;
  ;;And now we don't have balanced parentheses.  This causes problems down the
  ;;line for, for example, the class browser code cleanup.  We can avoid this
  ;;issue most of the time by simply checking for a colon immediately
  ;;preceding the "//".

  (replace-regexp "\\([^:\"]\\)//.*" "\\1")

  (goto-char (point-min))
  (while (n-s "/\\*")
    (forward-char -2)
    (delete-region (point)
		   (progn
		     (if (not (n-s "\\*/"))
			 (end-of-line)
		       )
		     (point)
		     )
		   )
    )
  
  (goto-char (point-min))
  (replace-regexp "/\\*.*" "")
  )

(defun nc-add-curlies()
  (n-open-line)
  (insert "{")
  (indent-according-to-mode)
  (forward-line 2)
  (n-open-line)
  (insert "}")
  (indent-according-to-mode)
  )

(defun nc-add-curlies-cmd()
  (interactive)
  (n-loc-push)
  (goto-char (point-min))
  (while (n-s "^[\t ]+\\(if *(.*)\\|else\\) *\n[ \t]+[^ \t{]")
    ;;(if (nsimple-y-or-n-p "add brackets? ")
    (nc-add-curlies)
    ;;   )
    )
  (n-loc-pop)
  )

(defun nc-stringify( &optional undo)
  "prepare the current and succeeding lines for being printed.  
With non-nil UNDO, undo this processing."
  (interactive "P")
  (let(
       prefix
       cmd
       )
    (cond
     ((save-excursion
	(forward-line -1)
	(nsimple-back-to-indentation)
	(looking-at "\\(print \\$[0-9a-zA-Z_]+ \\)")
	)
      (setq prefix (concat (n--pat 1) "\"")
	    suffix "\\n\";"
	    )
      )
     ((eq major-mode 'nsh-mode)
      (setq prefix "echo \""
	    suffix "\""
	    )
      )
     (t
      (if undo
	  (setq prefix "\\+ \""
		suffix "\\\\n\""
		)
	(setq prefix "+ \""
	      suffix "\\n\""
	      )
        )
      )
     )
    (while (progn
	     (save-restriction
	       (n-narrow-to-line)
	       
	       (if undo
		   (progn
		     (forward-line 0)
		     (replace-regexp "\\\\\"" "\"")
		     
		     (forward-line 0)
		     (replace-regexp (concat "[ \t]*" prefix) "")
		     (replace-regexp (concat suffix "$") "")
		     
		     (replace-regexp "\\\\\\\\" "__backslash__")
		     (replace-regexp "\\\\" "")
		     (replace-regexp "__backslash__" "\\\\")
		     )
		 (forward-line 0)
		 (replace-regexp "\\\\" "\\\\\\\\")
		 
		 (forward-line 0)
		 (replace-regexp "\"" "\\\\\"")
		 )
	       
	       (nsimple-back-to-indentation)
	       (if (not undo)
		   (insert prefix)
		 )
	       
	       (end-of-line)
	       (if (not undo)
		   (insert suffix)
		 )
	       (widen)
	       (indent-according-to-mode)
	       )
	     (prog1
		 (progn
		   (message "Continue? (y/n)")
		   (setq cmd (read-char))
		   (or 
		    (eq cmd ? )
		    (eq cmd ?y)
		    )
		   )
	       (forward-line 1)
	       )
	     )
      )
    )
  )

(defun nc-make-depend()
  "n3.el: dump dependencies at point of C files in the current directory"
  (interactive)
  (n-xdired "./" ".*\.c" 'nc-make-depend-1)
  )

(defun nc-make-depend-1( fN )
  "n3.el: dump dependencies at point of C_FILE"
  (interactive)
  (find-file fN)
  (goto-char (point-min))
  (while (n-s "^#include[ \\t]*\\\"")
    (n-print (concat (buffer-file-name)
                     ": "
                     (buffer-substring-no-properties (point)
                                       (progn
                                         (n-s "\.h")
					 (point)
					 )
				       )
                     ".h\n"
		     )
	     )
    )
  )
(defun nc-add-tracing(&rest unused)
  (widen)
  (let(
       (fName (n-defun-name t))
       )
    (n-s "^[ \t]*L$" t)
    (delete-char -1)
    (insert "cout << \"" fName "@@\" << endl;@@\n")
    )
  (forward-line -1)
  (n-complete-leap)
  )
(defun nc-narrow-to-var(var type)
  "narrow to region where the variable VAR is in scope"
  (narrow-to-region (progn
		      (n-r (concat type "[ \t]+" var "\\b") t)
		      (point)
		      )
		    (progn
		      (n-r "{" t)
		      (forward-sexp 1)
		      (point)
		      )
		    )
  (goto-char (point-min))
  )
(defun nc-narrow-to-statement()
  (save-excursion
    (narrow-to-region (progn
			(n-s ";" t)
			(point)
			)
		      (progn
			(forward-char -2)
			(if (looking-at ")")
			    (progn
			      (forward-char 1)
			      (forward-sexp -1)
			      )
			  )
			(nsimple-back-to-indentation)
			(point)
			)
		      )
    )
  )
(defun nc-join-lines()
  (interactive)
  (nsimple-join-lines)
  (if (save-excursion
	(forward-char -2)
	(looking-at "} .")	; line starts w/ '}', but has stuff after that
	)
      ;; indication that we had
      ;;
      ;;    else
      ;;    {
      ;; pt>}
      ;;    $self->HashPut("autoNotedTokens", $pattern, $note);
      ;;
      ;; before the join, and then
      ;;
      ;;    else
      ;;    {
      ;;    } pt>$self->HashPut("autoNotedTokens", $pattern, $note);
      ;;
      ;; afterward.  What's really wanted here is to encase the statement
      ;; in the brackets like so:
      ;;
      ;;    else
      ;;    {
      ;;      pt>$self->HashPut("autoNotedTokens", $pattern, $note);
      ;;    }
      ;;
      (progn
	(forward-char -2)
	(or (looking-at "}")
	    (error "nc-join-lines: ")
	    )
	(delete-char 1)
	(indent-according-to-mode)
	(end-of-line)
	(insert "\n}")
	(indent-according-to-mode)
	(forward-line -1)
	(nsimple-back-to-indentation)
	)
    )
  )
(defun nc-delete-code()
  (goto-char (point-min))
  (replace-regexp "\\\\\." "")

  (goto-char (point-min))
  (replace-regexp "'.'" "")

  (goto-char (point-min))
  (replace-regexp "\"[^\n\"]*\"" "")

  (goto-char (point-min))
  (replace-regexp "\"[^\n\"]*\"" "")

  (nc-delete-comments)

  (goto-char (point-min))

  ;; look for a curly bracket following a subroutine name and arguments (thus the left paren in the regexp or "static"
  (while (n-s "\\(([^}{]*\\|static[ \t]*\\){")
    (forward-char -1)
					; trouble w/ nested classes:
					;
					;class w{
                                        ;private class DataFetcher extends Callback
					;{
                                        ;private	Hashtable	m_lazyRequestsById		= new Hashtable();
					;}
					;}
    (delete-region (point)
                   (progn
		     (condition-case nil
			 (forward-sexp 1)
		       (error
			(nelisp-bp "nc-delete-code" "unbalanced '{'" 658)
			(if (n-s "^[ \t\n]*\\(private\\|public\\|protected\\)" 'eof)
			    (forward-line -1)
			  )
			)
		       )
		     (point)
		     )
		   )
                                        ;(nelisp-bp "nc-delete-code" "njava.el" 607);;;;;;;;;;;;;;;;;
    )
  )

(defun nc-include-already-seen(include-name)
  (not (null (assoc include-name includes-already-seen)))
  )
(defun nc-note-that-this-include-has-been-seen(include-name)
  (setq includes-already-seen (cons (cons include-name t)
                                    includes-already-seen
                                    )
        )
  )
(defun nc-new-object()
  (n-complete-replace "\\(^[\t ]*\\)\\(\\(private\\|protected\\|public\\)[ \t]+\\)?\\(static[ \t]+\\)?\\([^ \t]+\\)[ \t]+\\([^ \t]+\\) n$"
                      "\\1\\2\\4\\5 \\6 = new \\5(@@);@@"
                      )
  (save-excursion
    (forward-word -1)
    (if (looking-at "List(")
        (insert "Array")
      )
    )
  )
(defun nc-make-ifdef-tags-correct()
  (let(
       insert-tags
       (tag	(nstr-upcase
                 (nstr-replace-regexp
                  (file-name-nondirectory
                   (buffer-file-name)
                   )
                  "\\."
                  "_"
                  )
                 )
                )
       )
    (if (not (n-s "^#ifndef "))
        (setq insert-tags t))
    (if (y-or-n-p "replace ")
        (progn
          (setq insert-tags t)
          (nsimple-delete-line 2)
          (n-loc-push)
          (goto-char (point-max))
          (n-r "#endif" t)
          (nsimple-delete-line 1)
          (n-loc-pop)
          )
      )
    (if insert-tags
        (progn
          (insert "\n#ifndef " tag "\n#define " tag "\n")
          (goto-char (point-max))
          (insert "#endif\n")
          )
      )
    )
  )

