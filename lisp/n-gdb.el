(provide 'n-gdb)
(setq n-gdb-new-binary nil)	; prevent automatic rerun except after recompile

(defvar n-gdb-target-program (n-database-get "n-gdb-target-program"))

(defun n-gdb-target-program-dir-set()
  (setq n-gdb-target-program-dir nil)
  (if (not n-gdb-target-program)
      (setq n-gdb-target-program ""))
  (cond
   ((string-match "/wls[^/]+$" n-gdb-target-program)
    (setq n-gdb-target-program-dir "$HGPRIVATE/configs/server/")
    )
   ((string-match "/" n-gdb-target-program)
    (setq n-gdb-target-program-dir (file-name-directory n-gdb-target-program))
    )
   (t
    )
   )
  )

(n-gdb-target-program-dir-set)  

(defvar n-gdb-init-func	nil "ELISP to run to init this env (instead of invoking gdb)")
(defun n-gdb-buffer-name()
  (if (string= (nfn-suffix n-gdb-target-program) "java")
      (concat "*debug"
              (file-name-sans-extension n-gdb-target-program)
              "*"
              )
    (concat
     "*gud-"
     (if (or
          (not n-gdb-target-program)
          (string= "" n-gdb-target-program)
          )
         (progn
           (setq n-gdb-target-program (nfly-read-fn "target program: "))
           (n-database-set "n-gdb-target-program" n-gdb-target-program)
           )
       )
     (file-name-nondirectory n-gdb-target-program)
     "*"
     )
    )
  )

(setq n-gdb-n-bp nil)

(defun n-gdb-response-seen-p()
  "is the latest snatch of text from gdb the end of a full response to
a command?  (If it is, then we should find the (gdb) prompt at the end of it)"
  (n-gdb-goto)
  (goto-char n-gdb-stdout-start)
  (if (n-s "(gdb) ")
      (- (point) 6)		; return the location right before the prompt
    nil)
  )

(defun n-gdb-goto()
  (let(
       (gbuf	 (n-gdb-buffer-name))
       )
    (if (get-buffer gbuf)
        (progn
          (switch-to-buffer gbuf)
          t
          )
      nil
      )
    )
  )

(defun n-gdb-break( &optional arg)
  "break at current line; if non-nil ARG, break in func under pt"
  (interactive "P")
  (if arg
      (n-gdb-send-string (concat "b " (n-grab-token) "\n"))
    (n-gdb-send-string (format "sa %s:%d\n"
                               (file-name-nondirectory (buffer-file-name))
                               (n-what-line)
                               )
                       )
    )
  )

(defun n-gdb-send-string(ss)
  (n-gdb-goto)
  (goto-char (point-max))
  (nsimple-send-string ss)
  )

(defun n-gdb-hot-mode-tell()
  (message "gdb hotkeys %s" (if n-gdb-hot-mode-on "on" "off")))

(defun n-gdb (&optional arg)
  "start a debugger under emacs"
  (interactive "P")
  (save-some-buffers t)
  (if arg
      (let(
           (cmd	(progn
                  (message "?-enter program, a-pi, i-nit, p-rocess attach, r-uby")
                  (read-char)
                  )
                )
           )
        (cond
         ((= cmd ??)
          (setq n-gdb-target-program (nfly-read-fn))
          (n-database-set "n-gdb-target-program" n-gdb-target-program)
          )
         ((= cmd ?a)
          (setq n-gdb-target-program "$HGPRIVATE/clib/test/apitest")
          (n-database-set "n-gdb-target-program" n-gdb-target-program)
          )
         ((= cmd ?i)
          (or n-gdb-init-func
              (error "n-gdb: ")
              )
          (funcall n-gdb-init-func)
          )
         ((= cmd ?p)
          (setq n-gdb-target-program (concat "- " (read-string "pid:")))
          (n-database-set "n-gdb-target-program" n-gdb-target-program)
          )         
         (t (error "n-gdb: invalid argument"))
         )
        )
    )
  (if (n-gdb-goto)
      (n-gdb-possibly-rerun)
    (n-gdb-start)
    (setq n-gdb-new-binary nil)
    )
  )


(defun n-gdb-start()
  (let(
       (platform	(n-host-devo-env))
       (code-debugger	(n-host-debugger-invocation))
       )
    (if (string-match "wlserver$" n-gdb-target-program)
        (n-host-shell-cmd-visible "k9 wlserver"))
    
    (cond
     ((and
       (string-match "\\(.*\\)_purify$" n-gdb-target-program)
       (not (file-exists-p n-gdb-target-program))
       )
      (setq n-gdb-target-program (n--pat 1 n-gdb-target-program))
      (n-database-set "n-gdb-target-program" n-gdb-target-program)
      )
     ((file-exists-p (concat n-gdb-target-program "_purify"))
      (if (y-or-n-p "purified version exists.  Use ")
          (progn
            (setq n-gdb-target-program (concat  n-gdb-target-program "_purify"))
            (n-database-set "n-gdb-target-program" n-gdb-target-program)
            
            )
        (n-file-delete (concat  n-gdb-target-program "_purify"))
        )
      )
     ((string-match "\\(.*\\)_purify$" n-gdb-target-program)
      (let(
           (nonpurify	(n--pat 1 n-gdb-target-program))
           )
        (if (y-or-n-p "purified version exists.  Use ")
            nil
          (n-file-delete n-gdb-target-program)
          (setq n-gdb-target-program nonpurify)
          (n-database-set "n-gdb-target-program" n-gdb-target-program)
          )
        )
      )
     )
    
    (cond
     ((string-match "\\.java$" n-gdb-target-program)
      (n-file-find n-gdb-target-program)
      (delete-other-windows)
      (nsimple-split-window-vertically)
      (jdb "jdb k")
      ;;(n-gdb-jde-load)
      )
     ((string-match "dbx" code-debugger)
      (dbx (concat code-debugger " " "-C" " " n-gdb-target-program))
      )
     (t
      (gdb (concat code-debugger " " n-gdb-target-program))
      )
     )
    )
  (n-gdb-target-program-dir-set)
  (if n-gdb-target-program-dir 
      (cd n-gdb-target-program-dir))
  )

(defun n-gdb-possibly-rerun()
  (if (and n-gdb-new-binary
           (not (string-match "wlserver" n-gdb-target-program))
           )
      (progn
        (erase-buffer)
        (setq n-gdb-new-binary nil)
        (n-gdb-run)
        )
    )
  )


(setq n-gdb-hot-mode-on t)

(defun n-gdb-hot-mode(&optional setting)
  "toggle gdb hotkeys"
  (interactive)
  (if (not setting) (setq setting (not n-gdb-hot-mode-on)))
  
  (setq n-gdb-hot-mode-on setting)
  
  (define-key (current-local-map) "\M-r" nil)
  (if n-gdb-hot-mode-on 
      (progn
        (define-key (current-local-map) "<" 'n-gdb-up)
        (define-key (current-local-map) ">" 'n-gdb-down)
        (define-key (current-local-map) "0" 'n-gdb-repeat-input)
        (define-key (current-local-map) "1" 'n-gdb-repeat-input)
        (define-key (current-local-map) "2" 'n-gdb-repeat-input)
        (define-key (current-local-map) "3" 'n-gdb-repeat-input)
        (define-key (current-local-map) "4" 'n-gdb-repeat-input)
        (define-key (current-local-map) "5" 'n-gdb-repeat-input)
        (define-key (current-local-map) "6" 'n-gdb-repeat-input)
        (define-key (current-local-map) "7" 'n-gdb-repeat-input)
        (define-key (current-local-map) "8" 'n-gdb-repeat-input)
        (define-key (current-local-map) "9" 'n-gdb-repeat-input)
        (define-key (current-local-map) "c" 'n-gdb-cont)
        ;;(define-key (current-local-map) "f" 'gud-finish)
        (define-key (current-local-map) "l" 'gud-refresh)
        (define-key (current-local-map) "n" 'n-gdb-next)
        (define-key (current-local-map) "p" 'n-gdb-print)
        (define-key (current-local-map) "r" 'n-gdb-run)
        (define-key (current-local-map) "s" 'gud-step)
        (define-key (current-local-map) "t" 'n-gdb-hot-mode)
        (define-key (current-local-map) "w" 'n-gdb-where)
        (define-key (current-local-map) "W" 'n-gdb-where-all)
        (define-key (current-local-map) "y" 'n-gdb-y)
        )
    (define-key (current-local-map) "<" 'self-insert-command)
    (define-key (current-local-map) ">" 'self-insert-command)
    (define-key (current-local-map) "0" 'self-insert-command)
    (define-key (current-local-map) "1" 'self-insert-command)
    (define-key (current-local-map) "2" 'self-insert-command)
    (define-key (current-local-map) "3" 'self-insert-command)
    (define-key (current-local-map) "4" 'self-insert-command)
    (define-key (current-local-map) "5" 'self-insert-command)
    (define-key (current-local-map) "6" 'self-insert-command)
    (define-key (current-local-map) "7" 'self-insert-command)
    (define-key (current-local-map) "8" 'self-insert-command)
    (define-key (current-local-map) "9" 'self-insert-command)
    (define-key (current-local-map) "c" 'self-insert-command)
    (define-key (current-local-map) "f" 'self-insert-command)
    (define-key (current-local-map) "l" 'self-insert-command)
    (define-key (current-local-map) "n" 'self-insert-command)
    (define-key (current-local-map) "p" 'self-insert-command)
    (define-key (current-local-map) "r" 'self-insert-command)
    (define-key (current-local-map) "s" 'self-insert-command)
    (define-key (current-local-map) "t" 'self-insert-command)
    (define-key (current-local-map) "w" 'self-insert-command)
    (define-key (current-local-map) "W" 'self-insert-command)
    (define-key (current-local-map) "y" 'self-insert-command)
    (define-key (current-local-map) "\M-t" 'n-gdb-hot-mode)
    )
  (n-gdb-hot-mode-tell)
  )

(defun n-gdb-next()
  "advance one statement"
  (interactive)
  (setq n-gdb-repeat-input-string "next")
  (gud-next 1)
  )

(defun n-gdb-cont()
  "allow debugged program to continue"
  (interactive)
  (setq n-gdb-repeat-input-string "cont")
  (gud-cont 1)
  )

(setq n-gdb-repeat-input-string "next")

(defun n-gdb-repeat-input()
  "repeat last debugger command"
  (interactive)
  (let(
       (repetitions	(- last-command-event ?0))
       )
    (if (eq repetitions 0)
        (setq repetitions 10))
    (while (> repetitions 0)
      (setq repetitions (1- repetitions))
      (nsimple-send-string n-gdb-repeat-input-string)
      )
    )
  )

(defun n-gdb-y()
  (interactive)
  (nsimple-send-string "y")
  )
(defun n-gdb-run()
  (interactive)
  (nsimple-send-string "run")
  )
(defun n-gdb-where()
  "show the stack"
  (interactive)
  (n-gdb-filter-expect 'where-output)
  (nsimple-send-string "where -h")      ; show all frames to avoid confusing my filter
  )
(defun n-gdb-where-all()
  "display stacks of all threads"
  (interactive)
  (erase-buffer)
  (nsimple-send-string "threads")
  (nasync-wait-for "t@[0-9]+ l@[0-9]+ <[0-9]+> " 'n-gdb-where-all2)
  )

(setq n-gdb-where-all-boring-threads "in _restorefsr()")

(defun n-gdb-where-all2()
  (require 'n-prune-buf)
  (n-prune-buf n-gdb-where-all-boring-threads)
  (goto-char (point-min))
  (let(
       threads
       )
    (while (n-s "^.....t@\\([0-9]+\\)")
      (setq threads (cons (n--pat 1) threads))
      )
    (erase-buffer)
    (while threads
      (nsimple-send-string "echo =========================================================================================")
      (nsimple-send-string "thread t@%s" (car threads))
      (nsimple-send-string "where")
      (setq threads (cdr threads))
      )
    )
  )

(defun n-gdb-print()
  "evaluate an expression"
  (interactive)
  (goto-char (point-max))
  (insert "p ")
  ;;I keep forgetting about the return to hot mode.  Better to simply disable it.
  ;;(define-key (current-local-map) "" 'n-gdb-go-back-to-hot-mode)
  (n-gdb-hot-mode)
  )
(defun n-gdb-go-back-to-hot-mode()
  "switch to hot-mode, where unmodified keystrokes control the debugger"
  (interactive)
  (define-key (current-local-map) "" 'comint-send-input)
  (call-interactively 'comint-send-input)
  (n-gdb-hot-mode t)
  )
(defun n-gdb-kill()
  "n1.el: find gdb buffers              ; kill 'em"
  (interactive)
  (if (get-buffer  (n-gdb-buffer-name))
      (kill-buffer (n-gdb-buffer-name))
    )
  )

(setq gdbinit-mode-map (make-sparse-keymap)) 
(define-key gdbinit-mode-map " " 'n-complete-abbrev)

(defun n-gdb-clean()
  (interactive)
  (erase-buffer)
  )

(defun n-gdb-goto-init()
  (interactive)
  (find-file-other-window
   (cond
    ((string-match "gdb" (n-host-debugger-invocation)) ".gdbinit")
    ((string-match "dbx" (n-host-debugger-invocation)) "~/.dbxrc")
    (t (error "n-gdb-goto-init: "))
    )
   )
  (nbuf-post-for-kill 'save-buffer)
  )

(defun n-gdbinit-mode-meat()
  (setq
   major-mode 'gdbinit-mode
   mode-name "gdbinit mode"
   n-completes (list
		(list	"^c$"	'n-complete-dft	"ommands\n@@\nend\n")
		(list	"^de$"	'n-complete-dft	"fine xx\n@@\nend\n")
		(list	"^p p$"	'n-complete-dft	"urify_watch_n(@@, 4, \"@@w\")\n")
		(list	"^b p$"	'n-complete-dft	"urify_stop_here\n@@")
		)
   )
  (use-local-map gdbinit-mode-map)
  )
(defun n-gdb-jump()
  (interactive)
  (let(
       (line	(n-what-line))
       )
    (n-gdb-tbreak)
    (n-gdb-send-string (format "jump %d\n" line))
    )
  )
(defun n-gdb-tbreak()
  (interactive)
  (n-gdb-send-string (format "tbreak %s:%d\n"
                             (buffer-file-name)
                             (n-what-line)))
  )
(defun n-gdb-skip()
  (interactive)
  (let(
       (line	(+ (n-read-number "lines: " 1)
                   (n-what-line)) 
                )
       )
    (n-gdb-break)
    (n-gdb-send-string (format "commands\njump %d\nend\n" line))
    )
  )
(defun n-gdb-cmds()
  (interactive)
  (message "gdb cmd: s-kip")
  (let(
       (cmd	(read-char))
       )
    (cond
     ((= cmd ?s)	(n-gdb-skip))
     (t			(message "?"))
     )
    )
  )
(defun n-gdb-assert()
  (interactive)
  (n-r "[Aa]ssertion failed.* file " t)
  (n-s "file" t)
  (forward-word 1)
  (n-grab-file)
  )
(defun n-gdb-init()
  (define-key (current-local-map) "\M-" 'n-gdb-goto-init)
  (define-key (current-local-map) "" 'nshell-ctrl-c)
  (define-key (current-local-map) "r" 'nshell-repeat)
  (define-key (current-local-map) "" 'n-gdb-clean)
  (define-key (current-local-map) "=" 'n-gdb-repeat)
  (define-key (current-local-map) "e" 'n-gdb-assert)
  (n-gdb-hot-mode t)
  )
(defun n-gdb-repeat()
  (interactive)
  (erase-buffer)
  (if (not n-gdb-hot-mode-on)
      (n-gdb-hot-mode))
  
  (n-gdb-run)
  )

(add-hook 'gud-mode-hook 'n-gdb-init)


(setq n-gdb-filter-raw-string "")
(setq n-gdb-filter-expecting nil)
(defun n-gdb-filter-raw(proc string)
  (let ((data (match-data)))
    (unwind-protect
        (progn
          (if (not (string-match "\\(t@[0-9]+ l@[0-9]+ <[0-9]+> \\)" string))
              (setq n-gdb-filter-raw-string (concat n-gdb-filter-raw-string string))
            (let(
                 (string-1 (substring string 0 (match-beginning 1)))
                 (prompt   (n--pat 1 string))
                 (string-3 (substring string (match-end 1)))
                 )
              (setq n-gdb-filter-raw-string (concat n-gdb-filter-raw-string string-1))
                                        ;(n-trace "filter:n-gdb-filter-raw-string:'%s'" n-gdb-filter-raw-string)
                                        ;(n-trace "filter:prompt:'%s'" prompt)
                                        ;(n-trace "filter:string-3:'%s'" string-3)
              
              (n-gdb-filter n-gdb-filter-raw-string)
              
              (setq n-gdb-filter-raw-string string-3)
              )
            )
          (gud-filter proc string)
          )
      (store-match-data data)
      )
    )
  )

(defun n-gdb-filter-expect(event)
  (setq n-gdb-filter-expecting event)
  (set-process-filter (get-buffer-process (current-buffer)) 'n-gdb-filter-raw)
  )

(defun n-gdb-filter(s)
  ;(n-trace " filter:'%s'" s)
  (let(
       (expecting n-gdb-filter-expecting)
       )
    (setq n-gdb-filter-expecting nil)
    (cond
     ((eq expecting 'where-output)
      (n-gdb-where-callback s)
      )
     ((or
       (string-match "continuing l@[0-9]+" s)
       (string-match "Running: " s)
       )
      (setq n-gdb-stack nil)
      )
     )
    )
  )

(defun n-gdb-down()
  (interactive)
  (n-gdb-stack-traverse -1)
  (gud-down 1)
  )
(defun n-gdb-up()
  (interactive)
  (n-gdb-stack-traverse 1)
  (gud-up 1)
  )

(setq n-gdb-stack nil)
(setq n-gdb-stack-current 0)

(defun n-gdb-stack-traverse(change)
  (if (not n-gdb-stack)
      (progn
        (n-gdb-where)
        (while (not n-gdb-stack)
          (sit-for 0.5))
        )
    )
  (let(
       (frame (+ n-gdb-stack-current change))
       )
    (n-trace "stack-traverse:frame %d, change =%d" n-gdb-stack-current change)
    (if (and
         (<= frame (length n-gdb-stack))
         (<= 1 frame)
         (elt n-gdb-stack frame)
         )
        (progn
          (setq n-gdb-stack-current frame)
          (gud-filter (get-buffer-process (current-buffer))
                      (format "stopped in z at line %s in file \"%s\""
                              (cdr (elt n-gdb-stack frame))
                              (car (elt n-gdb-stack frame))
                              "\n"
                              )
                      )
          )
      )
    )
  )

(defun n-gdb-where-callback(s)
  (setq n-gdb-stack (make-vector 100 nil)) ; if there are > 100 frames, this code breaks
  (while (string-match "\\[\\([0-9]+\\)\\] .*, line \\([0-9]+\\) in \"\\([^\"]+\\)\"" s)
    (let(
         (frame		(string-to-int (n--pat 1 s)))
         (line		(n--pat 2 s))
         (file		(n--pat 3 s))
         (match-end	(match-end 1))
         )
      (if (string-match "=>\\[[0-9]+\\]" s)
          (progn
            (setq n-gdb-stack-current frame)
            (n-trace "n-gdb-stack-current=%d" n-gdb-stack-current)            ;(sleep-for 1)
            )
        )
      (setq s		(substring s match-end))
      (aset n-gdb-stack frame (cons file line))
      (n-trace "stack[%d]: %s:%s" frame file line)            ;(sleep-for 1)
      )
    )
  )

(setq n-gdb-jde-loaded nil) 

(defun n-gdb-jde-load()
  (if (not n-gdb-jde-loaded)
      (progn
        (condition-case nil
            (require 'jde)
          (error nil)
          )
        (require 'jde)
        (setq jde-use-font-lock nil)
        (setq n-gdb-jde-loaded t)
        (setq auto-mode-alist (append
                               (list (cons "\\.java$" 'njava-mode))
                               auto-mode-alist
                               )
              )  
        )  
    )  
  (n-file-find n-gdb-target-program)
  (setq jde-db-source-directories (list "e:/"))
  (jde-db)
  
  ;; repair the damage of jde
  (global-font-lock-mode nil)
  )

(defun n-x7()
  (interactive)
  (n-gdb-where-callback "[1] _ex_dbg_will_throw(0x0, 0x582b9c, 0xef66b2c0, 0xef20bc80, 0xef670c9c, 0x0), at 0xef654344
  [2] _ex_throw(0xef670cc0, 0x898d58, 0xef666b60, 0x3fde08, 0x0, 0xef670c80), at 0xef653d40
=>[3] HgxAssert(pszFile = 0x82cd5c \"qeincell.cpp\", nLine = 286, pszCondition = 0x82cd6c \"levels.entries() == dimCtrlList.entries()\"), line 470 in \"/home/nelson/highgate/share/highgate/debug.cpp\"
  [4] IntermediateCellAndElem::UpdateDimControlsForLevels(this = 0x8bb7e8, levels =  CLASS , dimCtrlList =  CLASS ), line 286 in \"/home/nelson/highgate/server/qe/qeincell.cpp\"
  [5] IntermediateCellAndElem::IntermediateCellAndElem(this = 0x8bb7e8, rule = 0x8baa40), line 85 in \"/home/nelson/highgate/server/qe/qeincell.cpp\"
  [6] SqlFragments::MakeIntermediateQuery(this = 0x8bb938), line 273 in \"/home/nelson/highgate/server/qe/sqlfrags.cpp\"
  [7] QueryEngine::SingleNodeOptimizer(this = 0x8b9ae8), line 160 in \"/home/nelson/highgate/server/qe/qe.cpp\"
  [8] QueryEngine::ApplyQueryEngine(this = 0x8b9ae8), line 90 in \"/home/nelson/highgate/server/qe/qe.cpp\"
  [9] ExecutionTree::BuildAndExecuteQueue(this = 0x8ba8a8, pExecutionQueue = 0x8ba0c8, pSchema = 0x8a78d8), line 553 in \"/home/nelson/highgate/server/calc/xtree.cpp\"
  [10] HqlQueryContext::run(this = 0x8b7ab0), line 834 in \"/home/nelson/highgate/server/calc/calceng.cpp\"
  [11] static Threadable::runCallback(t = 0x8b7ab0), line 93 in \"/home/nelson/highgate/server/inc/thrdbl.h\"")
  )
