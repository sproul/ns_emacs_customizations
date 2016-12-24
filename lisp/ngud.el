(provide 'ngud)
(setq ngud-new-binary nil)	; prevent automatic rerun except after recompile

(defvar ngud-target-program (n-database-get "ngud-target-program"))

(defun ngud-target-program-dir-set()
  (setq ngud-target-program-dir nil)
  (if (not ngud-target-program)
      (setq ngud-target-program ""))
  (cond
   ((string-match "/" ngud-target-program)
    (setq ngud-target-program-dir (file-name-directory ngud-target-program))
    )
   (t
    )
   )
  )

(ngud-target-program-dir-set)  

(defun ngud-buffer-name()
  (if (string= (nfn-suffix ngud-target-program) "java")
      (concat "*debug"
              (file-name-sans-extension ngud-target-program)
              "*"
              )
    (concat
     "*gud-"
     (if (or
          (not ngud-target-program)
          (string= "" ngud-target-program)
          )
         (progn
           (setq ngud-target-program (nfly-read-fn "target program: "))
           (n-database-set "ngud-target-program" ngud-target-program)
           )
       )
     (file-name-nondirectory ngud-target-program)
     "*"
     )
    )
  )

(setq ngud-n-bp nil)

(defun ngud-response-seen-p()
  "is the latest snatch of text from gdb the end of a full response to
a command?  (If it is, then we should find the (gdb) prompt at the end of it)"
  (ngud-goto)
  (goto-char ngud-stdout-start)
  (if (n-s "(gdb) ")
      (- (point) 6)		; return the location right before the prompt
    nil)
  )

(defun ngud-goto()
  (let(
       (gbuf	 (ngud-buffer-name))
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

(defun ngud-break( &optional arg)
  "break at current line; if non-nil ARG, break in func under pt"
  (interactive "P")
  (if arg
      (ngud-send-string (concat "b " (n-grab-token) "\n"))
    (ngud-send-string (format "sa %s:%d\n"
                              (file-name-nondirectory (buffer-file-name))
                              (n-what-line)
                              )
                      )
    )
  )

(defun ngud-send-string(ss)
  (ngud-goto)
  (goto-char (point-max))
  (nsimple-send-string ss)
  )

(defun ngud-hot-mode-tell()
  (message "gdb hotkeys %s" (if ngud-hot-mode-on "on" "off")))

(n-load "rdebug.el")

(defun ngud (&optional arg)
  (interactive "P")
  (save-some-buffers t)
  ;;(setq ngud-target-program "$dp/bin/ruby/test.rb")
  ;;(setq ngud-target-program "$dp/rideaux/ori_data.rb")
  
  
  (setq ngud-target-program "$HOME/.rvm/gems/ruby-1.9.2-p180/bin/rails runner -e production script/rideaux/add_access_to_s3_assets.rb")
  (setq ngud-target-program "rails runner -e production script/rideaux/add_access_to_s3_assets.rb")
  ;; yields: invalid argument: -e production
  
  ;;(n-load "trepan.el")
  (dbgr-rdebug (concat "rdebug "
                       (n-host-to-canonical ngud-target-program)
                       )
               )
  )

(defun ngud-start()
  (let(
       (platform	(n-host-devo-env))
       (code-debugger	(n-host-debugger-invocation))
       )    
    (ngud-target-program-dir-set)
    (if ngud-target-program-dir 
        (cd ngud-target-program-dir))
    (dbgr-rdebug (concat "rdebug"
                         (n-host-to-canonical ngud-target-program)
                         )
                 )
    )
  )

(defun ngud-possibly-rerun()
  (if (and ngud-new-binary
           (not (string-match "wlserver" ngud-target-program))
           )
      (progn
        (erase-buffer)
        (setq ngud-new-binary nil)
        (ngud-run)
        )
    )
  )


(setq ngud-hot-mode-on t)
(setq ngud-hot-mode-overrides nil)
(defun ngud-define-hot-key(key function)
  (setq ngud-hot-mode-overrides (cons key ngud-hot-mode-overrides ))
  (define-key (current-local-map) key function)
  )

(defun ngud-hot-mode(&optional setting)
  "toggle gdb hotkeys"
  (interactive)
  (if (string= (buffer-name) "*merge*")
      (emerge-fast-mode)                ; see comment in nmerge.el (search for "doesn't work")
    (if (not setting) (setq setting (not ngud-hot-mode-on)))
    
    (setq ngud-hot-mode-on setting)
    
    (if (not ngud-hot-mode-on)
        (progn
          (while ngud-hot-mode-overrides
            (define-key (current-local-map) (car ngud-hot-mode-overrides) 'n-complete-self-insert-command)
            (setq ngud-hot-mode-overrides (cdr ngud-hot-mode-overrides))
            )
          (define-key (current-local-map) "\M-t" 'ngud-hot-mode)
          )
      (setq ngud-hot-mode-overrides nil)
      (ngud-define-hot-key "0" 'ngud-repeat-input)
      (ngud-define-hot-key "1" 'ngud-repeat-input)
      (ngud-define-hot-key "2" 'ngud-repeat-input)
      (ngud-define-hot-key "3" 'ngud-repeat-input)
      (ngud-define-hot-key "4" 'ngud-repeat-input)
      (ngud-define-hot-key "5" 'ngud-repeat-input)
      (ngud-define-hot-key "6" 'ngud-repeat-input)
      (ngud-define-hot-key "7" 'ngud-repeat-input)
      (ngud-define-hot-key "8" 'ngud-repeat-input)
      (ngud-define-hot-key "9" 'ngud-repeat-input)
      
      (ngud-define-hot-key "<" 'gud-down)
      (ngud-define-hot-key ">" 'gud-up)
        (ngud-define-hot-key "c" 'ngud-cont)
      (ngud-define-hot-key "l" 'gud-refresh)
      (ngud-define-hot-key "n" 'ngud-next)
      (ngud-define-hot-key "r" 'ngud-run)
      (ngud-define-hot-key "s" 'gud-step)
      (ngud-define-hot-key "t" 'ngud-hot-mode)
      (ngud-define-hot-key "w" 'gud-where)
      (ngud-define-hot-key "y" 'ngud-y)
      )
    (ngud-hot-mode-tell)
    )
  )

(defun ngud-next()
  (interactive)
  (setq ngud-repeat-command 'gud-next)
  (gud-next 1)
  )

(defun ngud-cont()
  (interactive)
  (setq ngud-repeat-command 'gud-cont)
  (gud-cont 1)
  )

(setq ngud-repeat-command 'gud-next)

(defun ngud-repeat-input()
  (interactive)
  (let(
       (repetitions	(- last-command-event ?0))
       )
    (if (eq repetitions 0)
        (setq repetitions 10))
    (while (> repetitions 0)
      (setq repetitions (1- repetitions))
      (funcall ngud-repeat-command 1)
      )
    )
  )

(defun ngud-y()
  (interactive)
  (nsimple-send-string "y")
  )
(defun ngud-run()
  (interactive)
  (nsimple-send-string "run")
  )
(defun ngud-print()
  (interactive)
  (goto-char (point-max))
  (insert "p ")
  (ngud-hot-mode)
  )
(defun ngud-go-back-to-hot-mode()
  (interactive)
  (define-key (current-local-map) "" 'comint-send-input)
  (call-interactively 'comint-send-input)
  (ngud-hot-mode t)
  )
(defun ngud-kill()
  "n1.el: find gdb buffers              ; kill 'em"
  (interactive)
  (if (get-buffer  (ngud-buffer-name))
      (kill-buffer (ngud-buffer-name))
    )
  )

(setq gdbinit-mode-map (make-sparse-keymap)) 
(define-key gdbinit-mode-map " " 'n-complete-abbrev)

(defun ngud-clean()
  (interactive)
  (erase-buffer)
  )

(defun ngud-goto-init()
  (interactive)
  (find-file-other-window
   (cond
    ((string-match "gdb" (n-host-debugger-invocation)) ".gdbinit")
    ((string-match "dbx" (n-host-debugger-invocation)) "~/.dbxrc")
    (t (error "ngud-goto-init: "))
    )
   )
  (nbuf-post-for-kill 'save-buffer)
  )


(defun ngud-jump()
  (interactive)
  (let(
       (line	(n-what-line))
       )
    (ngud-tbreak)
    (ngud-send-string (format "jump %d\n" line))
    )
  )
(defun ngud-tbreak()
  (interactive)
  (ngud-send-string (format "tbreak %s:%d\n"
                            (buffer-file-name)
                            (n-what-line)))
  )
(defun ngud-skip()
  (interactive)
  (let(
       (line	(+ (n-read-number "lines: " 1)
                   (n-what-line)) 
                )
       )
    (ngud-break)
    (ngud-send-string (format "commands\njump %d\nend\n" line))
    )
  )
(defun ngud-cmds()
  (interactive)
  (message "gdb cmd: s-kip")
  (let(
       (cmd	(read-char))
       )
    (cond
     ((= cmd ?s)	(ngud-skip))
     (t			(message "?"))
     )
    )
  )
(defun ngud-assert()
  (interactive)
  (n-r "[Aa]ssertion failed.* file " t)
  (n-s "file" t)
  (forward-word 1)
  (n-grab-file)
  )
(defun ngud-init()
  (define-key (current-local-map) "\M-" 'ngud-goto-init)
  (define-key (current-local-map) "" 'nshell-ctrl-c)
  (define-key (current-local-map) "r" 'nshell-repeat)
  (define-key (current-local-map) "" 'ngud-clean)
  (define-key (current-local-map) "=" 'ngud-repeat)
  (define-key (current-local-map) "e" 'ngud-assert)
  (ngud-hot-mode t)
  )
(defun ngud-repeat()
  (interactive)
  (erase-buffer)
  (if (not ngud-hot-mode-on)
      (ngud-hot-mode))
  
  (ngud-run)
  )

(add-hook 'gud-mode-hook 'ngud-init)


(setq ngud-filter-raw-string "")
(setq ngud-filter-expecting nil)
(defun ngud-filter-raw(proc string)
  (let ((data (match-data)))
    (unwind-protect
        (progn
          (if (not (string-match "\\(t@[0-9]+ l@[0-9]+ <[0-9]+> \\)" string))
              (setq ngud-filter-raw-string (concat ngud-filter-raw-string string))
            (let(
                 (string-1 (substring string 0 (match-beginning 1)))
                 (prompt   (n--pat 1 string))
                 (string-3 (substring string (match-end 1)))
                 )
              (setq ngud-filter-raw-string (concat ngud-filter-raw-string string-1))
                                        ;(n-trace "filter:ngud-filter-raw-string:'%s'" ngud-filter-raw-string)
                                        ;(n-trace "filter:prompt:'%s'" prompt)
                                        ;(n-trace "filter:string-3:'%s'" string-3)
              
              (ngud-filter ngud-filter-raw-string)
              
              (setq ngud-filter-raw-string string-3)
              )
            )
          (gud-filter proc string)
          )
      (store-match-data data)
      )
    )
  )

(defun ngud-filter-expect(event)
  (setq ngud-filter-expecting event)
  (set-process-filter (get-buffer-process (current-buffer)) 'ngud-filter-raw)
  )

(defun ngud-filter(s)
  ;(n-trace " filter:'%s'" s)
  (let(
       (expecting ngud-filter-expecting)
       )
    (setq ngud-filter-expecting nil)
    (cond
     ((or
       (string-match "continuing l@[0-9]+" s)
       (string-match "Running: " s)
       )
      (setq ngud-stack nil)
      )
     )
    )
  )

(defun ngud-down()
  (interactive)
  (ngud-stack-traverse -1)
  (gud-down 1)
  )
(defun ngud-up()
  (interactive)
  (ngud-stack-traverse 1)
  (gud-up 1)
  )

(setq ngud-stack nil)
(setq ngud-stack-current 0)

(defun ngud-stack-traverse(change)
  (if (not ngud-stack)
      (progn
        (ngud-where)
        (while (not ngud-stack)
          (sit-for 0.5))
        )
    )
  (let(
       (frame (+ ngud-stack-current change))
       )
    (n-trace "stack-traverse:frame %d, change =%d" ngud-stack-current change)
    (if (and
         (<= frame (length ngud-stack))
         (<= 1 frame)
         (elt ngud-stack frame)
         )
        (progn
          (setq ngud-stack-current frame)
          (gud-filter (get-buffer-process (current-buffer))
                      (format "stopped in z at line %s in file \"%s\""
                              (cdr (elt ngud-stack frame))
                              (car (elt ngud-stack frame))
                              "\n"
                              )
                      )
          )
      )
    )
  )

;;(setq ngud-jde-loaded nil) 
;;
;;(defun ngud-jde-load()
;;  (if (not ngud-jde-loaded)
;;      (progn
;;        (condition-case nil
;;            (require 'jde)
;;          (error nil)
;;          )
;;        (require 'jde)
;;        (setq jde-use-font-lock nil)
;;        (setq ngud-jde-loaded t)
;;        ;;(setq auto-mode-alist (append
;;        ;;(list (cons "\\.java$" 'njava-mode))
;;        ;;auto-mode-alist
;;        ;;)
;;        ;;)  
;;        )  
;;    )  
;;  (n-file-find ngud-target-program)
;;  (setq jde-db-source-directories (list "e:/"))
;;  (jde-db)
;;  
;;  ;; repair the damage of jde
;;  ;;(global-font-lock-mode nil)
;;  )
