(provide 'n-genmake)
(defun n-genmake( &optional prog)
  "generate a bare-bones makefile in the current dir"
  (if (file-readable-p "Makefile")
      (error "Makefile already exists"))

  (if (not prog)
      (setq prog (read-string "prog name: ")))

  (find-file "Makefile")

  (n-genmake-objs)

  (goto-char (point-min))
  (n-genmake-top prog)

  (goto-char (point-max))
  (n-genmake-bottom prog)
  )

(defun n-genmake-make-search( prefix suffix)
  (insert (mapconcat '(lambda( dir )
                        (if (string-match "/generic/" dir)
                            ""
                          (concat prefix dir "/" suffix "\t\\\n")
                          )
                        )
                     (nsyb-get-make-path)
                     "\t"
                     )
          )
  )

(defun n-genmake-top( prog)
  (insert "CC		= gcc
LD		= /bin/cc

prog:		../../sun4/devbin/"
          )
  (insert prog)
  (insert "

OBJS_DIR	=	"
          )
  (insert default-directory)
  (insert "

OBJS		=	\
" )
  )

(defun n-genmake-objs()
  "gen a listing of object files; assumes that nothing else is in file"
  (call-process "nls" nil t nil "-1" "*.c")

  (goto-char (point-min))
  (replace-regexp "^" "\t$(OBJS_DIR)")
  
  (goto-char (point-min))
  (replace-regexp "\\.c$" ".o	\\\\")

  (goto-char (point-max))
  (forward-line 0)
  (kill-line)
  
  ;; kill last backslash
  (forward-line -1)
  (end-of-line)
  (forward-word -1)
  (forward-word 1)
  (kill-line)
  
  (insert "\n\n")
  )

(defun n-genmake-bottom( prog)
  (insert "../../sun4/devbin/")
  
  (insert prog)
  
  (insert ": $(OBJS)
	-@echo \"/bin/cc ")
  (insert prog)
  (insert "\"
	-@/bin/cc	$(OBJS) \\\n\t"
          )
  (call-process "syblibs" nil t nil "dev")
  (insert
   (nstr-replace-regexp (n-make-outside-eval "LIBS")
                         "\\$(GLIBPATH)"
                         ""
                         )
   )
   
  (insert "	-o ../../sun4/devbin/netx.exe
	emacs_client Z

.c.o:
	-@echo \"$(CC) -g $*\"
	-@$(CC) -c -g \
"
          )
  (n-genmake-make-search "-I" "include")
  (insert "	$*.c
 
"
          )
  )

(defun n-genmake-nm-tmp-3 ()
(execute-kbd-macro "^#p#p " nil)
)
(defun n-genmake-toggle-purify()
  (save-excursion
    (if (set-buffer ".gdbinit")
        (progn
          (goto-char (point-min))
          (if (n-s "purify_stop_here")
              (progn
                (forward-line 0)
                (if (looking-at "#")
                    (delete-char 1)
e                  (insert "#")
                  )
                )
            )
          )
      )
    )
  )

(defun n-genmake-toggle ()
  "from within a makefile/script: toggle line-pairs starting with #p"
  (interactive)
  (n-rm-objs)
  (execute-kbd-macro "\M-," nil)
  (let(
       (nm-exe 'n-genmake-nm-tmp-3 )
       )
    (nm-repeat-until-error)
    )
  (if (string= "Makefile" (buffer-name))
      (n-genmake-toggle-purify))
  (message "Toggled.")
  )

