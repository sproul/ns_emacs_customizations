(provide 'n-next-error)
(require 'compile)
(setq compilation-error-regexp-alist
      (append
       (list
        (list
         ;; $dp/channel/trader.rb:1:in `require_relative': $dp/channel/heat_map.rb:2: syntax error, unexpected '=', expecting keyword_end (SyntaxError)
         "c:/.*: \\(c:/[^:]+\\.rb\\):\\([0-9]+\\):";; ruby error in sub file
         1 2)
        (list
         "File \"\\([^\"]+\\.py\\)\", line \\([0-9]+\\)";; python
         1 2)
        (list
         "\\[[a-zA-Z0-9_]+\\] \\(\\(.:\\)?[^: \t\n]+\\):\\([0-9]+\\):"
         ;; ant: java
         1 3)
        (list
         "\\[[a-zA-Z0-9_]+\\] \"\\(\\(.:\\)?[^:\n]+\\)\", line \\([0-9]+\\)\\(\\.\\([0-9]+\\)\\)?:"
	 ;; ant: Solaris C++, AIX C++ (needs column at end)
         1 3 5)
        (list
         "\\[[a-zA-Z0-9_]+\\] \\([^:\n]+\\)(\\([0-9]+\\)) :"
	 ;; ant: MS C++
         1 2)
        (list
         "^file:\\([/[0-9a-zA-Z_]+\\.xml\\):\\([0-9]+\\):" ;; ant build.xml errors
         1 2)
	(list
	 "^\\\"\\([^\\\"(:\n ]+\\)\\\", line \\([0-9]+\\): "
         1 2)
        (list
         "^\\(~/[^:]+\\):\\([0-9]+\\):" ;; grep
         1 2)
        (list
         "^\\(/[^:]+\\): line \\([0-9]+\\):" ;; bash
         1 2)
        (list
         " in file \\([^ ]+\\) at line \\([0-9]+\\)"	;; perl
         1 2)
        (list
         "^\t\\([^<> ]+\\) line \\([0-9]+\\)"	;; perl split line emsg
         1 2)
        (list
         " at \\([^<> ]+\\) line\n?[ \t]*\\([0-9]+\\)"	;; perl

         1 2)
        (list
         "^_*\\([a-z_]+\\.[0-9]+\\): [A-Z][a-z]+: "	;; teacher
         1)
        (list
         "^error: \\([^\t\n ]+\\): \\([^ ]+\\)\(.*\): "	;; my perl
         1 2)
        (list
         "^\t\\([^<> ]+\\) line \\([0-9]+\\) ("	;; perl
         1 2)
   (list
         " at \\([/:a-zA-Z0-9_\\.]+\\) line \\([0-9]+\\)"	;; perl
         1 2)
        (list
         "^\\([a-zA-Z0-9_\\.]+\\):\\([0-9]+\\)"	;; gcc
         1 2)
        (list
         "^\\(\\([a-z]:\\)?[^(:\n ]+\\)(\\([0-9]+\\)) : "
         1 3)
        (list
         "^\\(.*\\.java\\)(\\([0-9]+\\),\\([0-9]+\\)) : "
         1 2)
        (list
         "^\\([^\n]+\\.java\\):\\([0-9]+\\): "	;; java
         1 2)
        (list
         "^\\([^\n]+\\.rb\\):\\([0-9]+\\)\\(:.*\\)?$"	;; ruby
         1 2)
        (list
         "	at [a-z_A-Z0-9\\.<>]+(\\([^ ]+\\)\\.java:\\([0-9]+\\)"	;; java run-x crash
    1 2)
        )
       compilation-error-regexp-alist
       )
      )
(setq n-next-error-purify2-line nil)

(defun n-next-error-purify2()
  (goto-line n-next-error-purify2-line)
  )

(defun n-next-error-purify()
  (set-buffer "pure.err")
  (setq n-next-error-purify-mode t)
  (let(
       fn line
          )
    (cond
     ((n-s " called from:")
      (setq fn (concat (buffer-substring-no-properties (progn
                                           (forward-line 1)
                                           (n-s "(" t)
                                           (point)
                                           )
                                         (progn
                                           (n-s ";" t)
                                           (forward-char -2) ; back off .o;
                                           (point)
                                           )
                                         )
                       "c"
                       )
            line (progn (n-s "line " t)
                        (n-grab-number)
                        )
            )
      (if (n-file-find-from-path fn (n-env-domain-file-dirs))
          (goto-line line)
        (back-to-indentation)
        (ntags-find-where)
        (message "n-next-error-purify: cannot find %s in n-env-domain-file-list, using tags" fn)
        (setq n-next-error-purify2-line line)
        (nasync-timer 1 'n-next-error-purify2)
        )
      )
     (t	(message "No more hits in %s" (buffer-name))
        (setq n-next-error-purify-mode nil)
        )
     )
    )
  )

(setq n-next-error-called-already nil);; keep record of calls since last compile was sent

(setq n-next-error-purify-mode nil)

(setq n-cc-warnings t)

(defun n-next-error-command(&optional arg use-current-buffer-for-midnight-file)
  (interactive "P")
  (cond
   ((and (not (eq major-mode 'nmidnight-mode))
         nshell-error-diagnose-mode
         )
    (n-other-window)
    (nshell)
    (nshell-error-diagnose)
    )
   (t
    (setq nshell-error-diagnose-mode nil)
    (cond
     (use-current-buffer-for-midnight-file
      )
     ((equal major-mode 'nmidnight-mode)
      (nmidnight-push-output-file)
      )
     ((n-database-get "last-nmidnight-file")
      (n-file-find (n-database-get "last-nmidnight-file"))
      )
     )
    (let(
         (cmd (if (not arg)
                  ""
                (message "p-urify-%s, r-eference-mode"
                         (nmenu-mode-toggle-prompt n-next-error-purify-mode)
                         )
                (read-char)
                )
              )
         )
      ;; preprocessing:
      (cond
       ((eq cmd ?r)
        (n-next-error-remove-non-references)
        )
       )

      ;; now do it:
      (cond
       ((or n-next-error-purify-mode
            (string= (buffer-name) "pure.err")
            )
        (n-next-error-purify)
        )
       ((string= (buffer-name) "PL_SQL.midnight")
        (nplsql-next-error)
        )
       ((and
         (buffer-file-name)
         (string= "EX_LOAD.midnight" (file-name-nondirectory (buffer-file-name)))
         )
        (n-next-error-ex_load)
        )
       ((string= midnight-grep-output-buffer (buffer-name))
        (if (and
             (not n-next-error-called-already)
             (string= n-env "spring")
             )
            (progn
              (require 'n-prune-buf)
              (n-prune-buf "\\.html:")
              )
          )
        (n-next-grep-hit)
        )
       (t
        (n-next-error)
        )
       )
      )
    )
   )
  )
(defun n-next-grep-hit()
  (if n-next-error-called-already
      (end-of-line)
    (setq n-next-error-called-already t)
    (goto-char (point-min))
    )
  (if (not (n-s "^[^ \n]+:[0-9]"))
      (message "no more hits")
    (forward-line 0)
    (n-grab-file)
    )
  )

(defun n-next-error-massage-output--compress-ruby-assertions-onto-line-where-condition-failed()
  (require 'n-prune-buf)
  (n-prune-buf ":in `assert_eq'$")
  (goto-char (point-min))
  (while (n-s "\\.rb:[0-9]+:in `assert.*':")
    (let(
         assertion-msg
         (assertion-msg-begin (progn
                                (point)
                                )
                              )
         (assertion-msg-end (progn
                              ;; since msg could span lines, look for the next ruby stack frame, and then come back one line
                              (n-s "^\tfrom " t)
                              (forward-line -1)
                              (end-of-line)
                              (point)
                              )
                            )
         )
      (setq assertion-msg (buffer-substring-no-properties assertion-msg-begin assertion-msg-end))
      (delete-region assertion-msg-begin assertion-msg-end)
      (nsimple-delete-line)
      (end-of-line)
      (insert ": assertion: " assertion-msg)
      )
    )
  )
(defun n-next-error-massage-output()
  (save-excursion
    ;;(n-next-error-massage-output--compress-ruby-assertions-onto-line-where-condition-failed)

    (n-prune-buf "warning: setting Encoding.default_external")
    (n-prune-buf "warning: setting Encoding.default_internal")

    (goto-char (point-min))
    (replace-regexp ".*warning: assigned but unused variable - _" "SUPPRESSED unused variable report: _")

    (goto-char (point-min))
    (replace-regexp "^:1: """)

    (require 'n-prune-buf)
    (n-prune-buf ":in `assert': assertion failed (RuntimeError)")

    (goto-char (point-min))
    (if (looking-at "/bin/grep$")
        (nsimple-delete-line))
    (goto-char (point-min))
    (replace-regexp "^[0-9][0-9]?:[0-9][0-9]:[0-9][0-9] " "hh-mm-ss ")	;; Get rid of wayward timestamps, which lead to false positives for file:line matching

    (goto-char (point-min))
    (replace-regexp ".*:in `require_relative': " "")

    (goto-char (point-min))
    (replace-regexp "/net/slcipaq.us.oracle.com/scratch/nsproul/dp/mongo_data_manager/" "")

    (goto-char (point-min))
    (forward-line 1)
    (if (n-s ":")
        (progn
          (delete-region (progn
                           (forward-line 0)

                           (point)
                           )
                         (progn
                           (goto-char (point-min))
                           (forward-line 1)
                           (point)
                           )
              )
          )
      )
    
    (goto-char (point-min))
    (replace-regexp "^\tfrom " "")     ;; ruby stack traces

    (goto-char (point-max))
    (forward-char -2)
    (if (looking-at "\\$")
        (nsimple-delete-line 1))	;; rm prompt
    
    ;; xpunit Status message should not be interpreted as an error worth following up on.  I insert an extra space before the line number in order to get the regular expression analyzer to skip this message:
    (goto-char (point-min))
    (replace-regexp "\\(:[0-9]+:  xpunit has the following state:\\)" " \\1")

    (goto-char (point-min))
    (replace-regexp "\\b[0-9][0-9]:[0-9][0-9]:[0-9][0-9] [0-9a-zA-Z_]+ [0-9]+\\$ " "")

    (goto-char (point-min))
    (replace-regexp "-bh:5 " "-bh___ns_colon___5 ")
    (goto-char (point-min))
    (replace-regexp (concat "/\\(stable\\|main\\)/" (nsimple-env-expand "build/$OS/")) "/\\1/java/")

    (goto-char (point-min))
    (replace-regexp "\\\\" "/")

    (goto-char (point-min))
    (replace-regexp "/build/\\(ppc\\|x86\\)/test/java/" "/test/java/")

    (goto-char (point-min))
    (replace-regexp "/build/\\(ppc\\|x86\\)/java/" "/java/")

    (goto-char (point-min))
    (replace-regexp "Total time: " "Total time:_")
    )

  (n-prune-buf "Warning: OpenKernel::OKCookieDatabase::OKDomainCookiePrefixMap::OnDestructElements hides the virtual function")
  (n-prune-buf "Warning: OpenKernel::OKCookieDatabase::OKDomainCookies::OKUserCookiePrefixMap::OnDestructElements hides the virtual function OpenKernel::OKPrefixMapT")

  (n-next-error-meta-update-symbols-files)
  ;;;;;;;;;;;;;;;(n-next-error-harvest-update-cgi-calls)

  (goto-char (point-min))
  (replace-regexp "\\bC:\\\\" "c:\\\\")
  
  (goto-char (point-min))
  (if (and n-win 	;; eliminate initialization for local_build.sh
           (let(
                (command	(n-get-line))
                )
             (n-s command)
             )
           (progn
             (skip-chars-forward " \t\n")
             (not (eobp))
             )
           )
      (progn
	(delete-region (point) (progn
				 (goto-char (point-min))
				 (forward-line 1)
				 (point)
				 )
		       )
	)
    )

  (goto-char (point-min))
  (while (n-s "^	line [0-9]+")		;; perl stuff
    (forward-line -1)
    (nsimple-join-lines)
    (forward-line 1)
    )

  (goto-char (point-min))
  (while (n-s "^	[0-9]+ \(#")		;; perl stuff
    (forward-line -1)
    (nsimple-join-lines)
    )

  (goto-char (point-min))
  (while (n-s "^[A-Z]:")
    (forward-line 0)
    (downcase-word 1)
    (forward-line 1)
    )

  (require 'n-prune-buf)
  (if (not n-cc-warnings)
      (n-prune-buf ": warning: "))

  (goto-char (point-min))
  (replace-regexp "/cygdrive/\\(.\\)/" "\\1:/")

  ;;(n-prune-buf "Things you should know:")
  ;;(n-prune-buf " -- Check for working C compiler: /opt/SUNWspro/bin/cc -- works")
  ;;(n-prune-buf " -- Check for working CXX compiler: /opt/SUNWspro/bin/CC -- works")
  ;;(n-prune-buf " -- Configuring done")
  ;;(n-prune-buf " -- Generating done")
  ;;(n-prune-buf " /sw/bin/make  cmake.depends")
  ;;(n-prune-buf ": `cmake.depends' is up to date.")
  ;;(n-prune-buf ": Nothing to be done for")
  ;;(n-prune-buf ": Entering directory `")
  ;;(n-prune-buf ": Nothing to be done for")
  ;;(n-prune-buf ": Leaving directory `")
  ;;
  ;;(goto-char (point-min))
  ;;(replace-regexp " -L/.*" "")
  ;;
  (goto-char (point-min))
  (replace-regexp ".* [0-9]+\\$ " "")
  (goto-char (point-min))
  (replace-regexp (n-host-to-canonical "$dp") "$dp")
  (goto-char (point-min))
  )

(setq n-next-error-file-last	"")
(setq n-next-error-line-last	-1)

(defun n-next-error()
  (if (not n-next-error-called-already)
      (progn
        (setq n-next-error-called-already	t
              n-next-error-file-last	""
              n-next-error-line-last	-1
              )
	(n-next-error-massage-output)
        )
    )
  (let(
       (patterns compilation-error-regexp-alist)
       hit
       pattern
       filePatternNumber
       linePatternNumber
       colPatternNumber
       file
       line
       )
    (while (and patterns
                (not hit)
                (listp (car patterns))
                )
      (setq
       pattern			(caar patterns)
       filePatternNumber	(cadar patterns)
       linePatternNumber	(caddar patterns)
       patterns			(cdr patterns)
       )
      (n-trace (concat "m-e: " pattern))
      (while (and (not hit)
                  (n-s pattern)
                  )
        (setq
         line (if linePatternNumber (string-to-int (n--pat linePatternNumber)))
         file (n--pat filePatternNumber)
         )

        (if (and (string= file n-next-error-file-last)
		 (or (not n-next-error-line-last)
		     (= line n-next-error-line-last)
		     )
                 )
	    (progn
	      nil
	      )
          (setq hit t)
          (setq file (nstr-replace-regexp file "> " "")         ;; ridiculous I know -- this is happening due to errors being contained by diff output
                n-next-error-file-last	file
                n-next-error-line-last	line
                )
          (if (not (file-exists-p file))
              (setq file (n-host-to-canonical file)))
          (if (not (file-exists-p file))
              (n-next-error-on-nonexistent-file file)
            )
          )
      )
      (if hit
	  (progn
            (nsimple-scroll-to-top)
            (setq file (nstr-replace-regexp file "\\\\" "\\\\\\\\"))
            (n-s n-next-error-file-last t)
	    (if (not (n-next-error-was-in-generated-file file n-next-error-line-last))
		(progn
		  (n-grab-file)
		  )
	      )
	    (n-next-error-propose-fix)
	    )
	)
      )

    (if (not hit)
	(progn
	  (goto-char (point-min))
          (if (n-s "^propose ")
              (save-restriction
                (narrow-to-region (progn
                                    (goto-char (point-min))
                                    (forward-line 1)
                                    (point)
                                    )
                                  (progn
                                    (goto-char (point-max))
                                    (point)
                                    )
                                  )
                (n-prune-buf-v "^propose ")
                (goto-char (point-min))
                (replace-regexp "^propose " "")
                (if (y-or-n-p "execute proposals? ")
                    (n-host-shell-cmd-visible (buffer-substring-no-properties (point-min) (point-max)))
                  )
                )
            )
	  (message "no hits")
	  )
    )
    )
  )

;;(defun n-next-error-grab-column()
;;  (save-excursion
;;    (cond
;;     ((save-excursion
;;        (forward-line 2)
;;        (save-restriction
;;          (n-narrow-to-line)
;;          (forward-line 0)
;;          (n-s "[ \t]+\\^$")
;;          )
;;        )
;;      (n-s "[ \t]+\\^$")
;;      (1- (current-column))
;;      )
;;     (t 20)
;;     )
;;    )
;;  )

(defun n-next-error-insert-import(package importStatement)
  (other-window 1)
  (save-excursion
    (goto-char (point-min))
    (if (n-s "^ +package")
        (progn
          (forward-line 0)
          (delete-horizontal-space)	; my indentation constantly puts "package" a couple of spaces to the right.  Stop!
          )
      )
    )

  (cond
   ((progn
      (goto-char (point-min))
      (not (n-s "^import "))
      )
    (if (n-s "^package")
        (forward-line 1)
      )
    )
   ((string-match "^pso" package)
    (goto-char (point-max))
    (n-r "^import ")
    (forward-line 1)
    )
   ((string-match "^largesoft" package)
    (goto-char (point-max))
    (if (n-r "^import largesoft")
        (forward-line 1)
      (goto-char (point-min))
      (if (n-s "^import pso")
          (forward-line 1)
        (goto-char (point-max))
        (n-r "^import " t)
        (forward-line 1)
        )
      )
    )
   (t
    (goto-char (point-min))
    (if (n-s "^package")
        (forward-line 1))
    )
   )
  (insert importStatement "             ;\n")
  )
(defun n-next-error-propose-import(unknownType)
  (require 'nclass-browser)
  (let(
       (fnAndOffset (nclass-browser-query-tag unknownType))
       package
       srcFn
       )
    (if fnAndOffset
	(progn
	  (setq srcFn (car fnAndOffset)
		package	(nfn-fn-to-java-package srcFn)
		importStatement (concat "import " package ".*")
                )
          (if (and
               (not (string-match "^\\(java.lang\\)$" package))
               (y-or-n-p importStatement)
               )
              (n-next-error-insert-import package importStatement))
          )
      )
    )
  )
(defun n-next-error-figure-out-missing-java-type()
  "the compiler output looks like the following:

n_trader.java:17: cannot resolve symbol
symbol  : class DataInputStream

we need to move to the next line and grab the name:"

  (forward-line 1)
  (end-of-line)
  (forward-word -1)	;; this is because there are some trailing blanks in the compiler output
  (n-grab-token)
  )

(defun n-next-error-propose-fix()
  (let(
       exception command
		 )
    (nterminal-highlight t)
    (save-window-excursion
      (other-window 1)
      (cond
       ((and (looking-at ".*: warning: suboptimal t_start for test; should use \\(.*\\)") (y-or-n-p "update all suboptimal t_starts?"))
        (while (n-s      ".*: warning: suboptimal t_start for test; should use \\(.*\\)")
          (let(
               (optimal-date (nre-pat 1))
               )
            (save-excursion
              (forward-line 0)
              (save-window-excursion
                (n-grab-file)
                (n-s "," t)
                (delete-region (point)
                               (progn
                                 (n-s "," t)
                                 (forward-char -1)
                                 (point)
                                 )
                               )
                (insert " \"" optimal-date "\"")
                )
              )
            )
          )
        (n-prune-buf "warning: suboptimal t_start for test; should use")
        )
       ((and (looking-at ".*: warning: successful channel test running under debug") (y-or-n-p "stop debug mode?"))
        (n-grab-file)
        (nruby-channel-test-debug-rm)
        )
       ((and (looking-at ".*analyze_channel exiting early since we are in debug mode...") (y-or-n-p "stop debug mode?"))
        (n-grab-file)
        (n-s "first test marker" t)
        (forward-line 1)
        (nruby-channel-test-debug-rm)
        (nmidnight-compile)
        )
       ((and
         (or
          (save-excursion (forward-line 0) (looking-at ".*analyze_channel.* expected \\(.*\\) but saw \\(.*\\) at "))
          )
         (setq cmd (progn
                     (message "3-cmt-out-to-take-care-of-later, a-ccept test behavior, d-debug")
                     (read-char)
                     )
               )
         )
        (n-next-error--channel-analyze-channel-test-manage cmd)
        )
       ((looking-at ".*: undefined method `\\(.*\\)=' for #<\\(.*\\):0x.*> (NoMethodError)")
        (nruby-propose-new-field (nre-pat 1) (nre-pat 2))
        )
       ((save-excursion
	  (forward-line -1)
	  (or (looking-at "\\(\\$ \\)?Can't locate object method \"new\" via package\n?[ \t]*\"\\([^\"]+\\)\"")
	      (looking-at "\\(\\$ \\)?Undefined subroutine &\\([^:]+\\)::.* called at")
	      )
	  )
	(let(
	     (missingModule (n--pat 2))
	     )
	  (if (y-or-n-p (format "use %s?" missingModule))
	      (progn
		(other-window 1)
		(goto-char (point-max))
		(if (n-r "^use [a-zA-Z:0-9]+;")
		    (forward-line 1)
		  (goto-char (point-min))
		  (if (n-s "^package ")
		      (forward-line 1))
		  )
		(insert "use " missingModule ";\n")
		)
	    )
	  )
	)
       ((looking-at ".*: teacher.ini: \\(.*\\)")
	(if (y-or-n-p "insert into teacher.ini? ")
	    (let(
		 (data	(n--pat 1))
		 )
	      (n-file-find "$HOME/work/adyn.com/httpdocs/teacher/teacher.ini")
	      (goto-char (point-max))
	      (insert data ";\n")
              )
	  )
	)
       ((and (looking-at ".*error J0067: Cannot convert 'BOb\\[\\]' to 'Vector'")
	     (y-or-n-p "switch from Vector to BOb[]?")
     )
	(n-next-error-propose-switch-from-Vector-to-BOb-array)
	)
       ((and (looking-at ".*warning J5014: 'void \\(update\\|insert\\|delete\\)Bob(BOb)' has been deprecated by the author of 'largesoft.db.BobStorage'")
	     (y-or-n-p "use Bkg to update bob? ")
	     )
	(n-next-error-propose-switch-from-sqlEngine-to-Bkg-update-bob (n--pat 1))
	)
       ((and (n-next-error-m_sqlEngine-use)
 	     (n-next-error-propose-switch-from-sqlEngine-to-Bkg-obj-retrieval)
	     )
	nil
	)
       ((and (looking-at ".*Undefined name 'log'")
	     (y-or-n-p "switch to Bkg to get Bkg.log? ")
	     )
	(other-window 1)
 	(n-next-error-extend-from-Bkg)
)
       ((looking-at ".*Undefined name '\\([^ \\.]+\\)'")
	(n-next-error-propose-import (n--pat 1))
	)
       ((looking-at ".*: cannot resolve symbol")
	(n-next-error-propose-import (n-next-error-figure-out-missing-java-type))
	)
       ((looking-at ".*Variable '\\([^ \\.]+\\)' is already defined in this method.")
	(let(
	     (variable (n--pat 1))
	     decoratedVariable
	     variable2
	     )
	  (other-window 1)
	  (save-restriction
	    (nc-narrow-to-routine)
	    (narrow-to-region (point) (progn
					(goto-char (point-max))
					(point)
                                        )
                              )
            (goto-char (point-min))
            (setq decoratedVariable (concat "\\b" variable "\\b")
                  variable2 (read-string (format "Replace duplicate variable %s with " variable)
                                         (concat variable "2")
                                         )
                  )
            (query-replace-regexp decoratedVariable variable2)
            )
          )
        )
       ((and (looking-at ".* : warning J5014: 'String toString(String)' has been deprecated by the author of 'largesoft.bob.ALCalendar'")
	     (y-or-n-p "add getTimeZone call? ")
	     )
	(other-window 1)
	(forward-line 0)

	(n-s "[^0-9a-zA-Z_]\\([0-9a-zA-Z_]+\\)\\.toString( *\"" t)
	(let(
	     (dateVariable (n--pat 1))
	     )
	  (forward-line 0)
	  (query-replace-regexp (concat dateVariable "\\.toString(")
				(concat dateVariable
					".toString("
					dateVariable
					".getTimeZone(), "
					)
				)
	  )
	)
       ((or
	 (looking-at ".*Exception .*\\.\\([^ \\.]+\\) must be caught, or it must be declared in the throws clause of this method.")
	 (looking-at ".*: Exception '\\([^']+\\)' not caught or declared by ")
	 (looking-at ".*: unreported exception .*\\.\\([^ \\.]+\\); must be caught or declared to be thrown")
	 )
	(setq exception (n--pat 1))
	(other-window 1)
	(message "c-atch or d-eclare exception %s?" exception)
	(setq command (read-char))
	(cond
	 ((eq command ?d)
	  (nc-beginning-of-defun)
	  (n-r ")" t)
	  (forward-char 1)
	  (if (looking-at "[ \t\n]*throws")
	      (progn
		(forward-word 2)
		(insert ", " exception)
		)
	    (insert " throws " exception)
	    )
	  )
         ((eq command ?c)
	  (save-restriction
	    (nc-narrow-to-statement)
	    (goto-char (point-min))
	    (nsimple-back-to-indentation)
	    (insert "try {\n")

	    (goto-char (point-max))
	    (insert "\n}\ncatch(" exception " e) {\n")
	    (if (string-match "/\\(bkgproc\\|fingateway\\)/" (buffer-file-name))
		(insert "log(\"Error encountered @@: \" + e, DBStatic.LOG_ERROR)")
	      (insert "@@")
	      )
	    (insert ";\n}\n")
	    (n-r "@@" t)
	    (delete-char 2)
	    )
	  (n-indent-region)
          )
         )
        )
       ((or
         (looking-at ".*Class \\([^ ]+\\) not found ")
         )
        (if (n-s "not found in \\(type declaration\\|throws\\)")
            (progn
              (forward-line -1)
              (n-next-error-command)
              )
          (let(
               (missingClass (n--pat 1))
               )
            (other-window 1)
            (message "import: a-wt, e-%s, i-java.io, u-java.util?" missingClass)
            (setq command (read-char))
            (cond
             ((eq command ?a)
              (goto-char (point-min))
              (insert "import java.awt.*;\n")
              )
             ((eq command ?e)
              (goto-char (point-min))
              (insert "import " missingClass ".*;\n")
              )
             ((eq command ?i)
              (goto-char (point-min))
              (insert "import java.io.*;\n")
              )
             ((eq command ?u)
              (goto-char (point-min))
              (insert "import java.util.*;\n")
              )
             )
            )
          )
        )
       ((or
	 ;; the reason I have encased _incompatible_ in parens into two cases below is to make it so that
	 ;; it is always the _third_ pattern which matches the needed type.
         ;; the '[^\n]*'s are sprinkled through the patterns in order to overcome the prefixes ant adds
         ;; to the compiler output.
	 (looking-at ".*\\(Incompatible\\) type for .*. Explicit cast needed to convert [^ ]+ to \\(.*\\.\\)?\\([^ \\.]+\\).$")
	 (looking-at ".*Cannot \\(implicitly \\)?convert '[^ ]+' to '\\(.*\\.\\)?\\([^ \\.]+\\)'")
	 (looking-at ".*: \\(incompatible\\) types\n[^\n]*found   : [^\n]+\n[^\n]*required: \\(.*\\.\\)?\\([^\n \\.]+\\)")
	 )
	(setq destinationType (n--pat 3))
	(other-window 1)
	(let(
             (overlay-arrow-string "=======>")
             (overlay-arrow-position (make-marker))
             )
          (save-excursion
            (forward-line 0)
            (set-marker overlay-arrow-position (point) (current-buffer))
            )
          (cond
           ((not (y-or-n-p (format "cast to %s?" destinationType)))
            nil
            )
           ((save-restriction
              (n-narrow-to-line)
              (nsimple-back-to-indentation)
              (cond
	       ((looking-at ".*[0-9a-zA-Z_]+[ \t]*=[^=]")
		(n-s "=[ \t]*" t)
		)
	       ((looking-at "return\\b")
		(forward-word 1)
		(just-one-space)
		)
               ((n-s "[\\.0-9a-zA-Z_]")
		(forward-char -1)
		)
	       ((n-r "[^\\.0-9a-zA-Z_]")
		(forward-char 1)
		)
	       (t
		(error "n-next-error-propose-fix: 89")
		)
	       )
	      (insert "(" destinationType ")")
	      )
            )
           )
          )
        )
       )
      )
    (nterminal-highlight nil)
    )
  )
(defun n-next-error-ex_load()
  (goto-char (point-min))
  (cond
   ((or
     (n-s "Failed to load table: al\\([0-9a-zA-Z_]+\\)")
     (n-s "Attempt to insert the value NULL into column '[0-9a-zA-Z_]+', table '.*\\.al\\([0-9a-zA-Z_]+\\)'; column does not allow nulls.  INSERT fails.")
     )
    (let(
	 (table (n--pat 1))
	 fn
	 )
      (setq fn (n-host-to-canonical (concat "$dev/pso/$extdatasetdir/$extdataset/" table ".txt")))
      (if (not (file-exists-p fn))
	  (setq fn (n-host-to-canonical (concat "$ext/pso/$extdataset/V0/data/$extdataset/" table ".txt")))
	)
      (n-file-find fn)
      )
    )
   )
  )

(defun n-next-error-was-in-generated-file(file line)
  (if (string= file "teacher.javax")
      (progn 
	(n-file-find "$HOME/work/adyn.com/httpdocs/teacher/teacher.pl")
	(goto-char (point-min))
	(n-s "\\$__j" t)
	(forward-line line)
	(save-excursion
	  (if (n-r "^EOSj$") ; if this succeeds, then the error lies outside the here-value
	      (progn
		(message "Warning: you are in GENERATED code")
		nil
		)
	    t
	    )
	  )
	)
    )
  )
(defun n-next-error-m_sqlEngine-use()
  (save-window-excursion
    (other-window 1)
    (nsimple-back-to-indentation)
    (looking-at ".* = m_sqlEngine\\.\\(selectByElement\\)")
    )
  )
(defun n-next-error-extend-from-Bkg()
  (save-excursion
    (goto-char (point-min))
    (if (n-s "extends ServerBackgroundProcess")
	(progn
	  (forward-word -1)
	  (delete-region (point) (progn (end-of-line)
					(point)
					)
			 )
	  (insert "Bkg")
	  )
      )
    )
  )
(defun n-next-error-propose-switch-from-sqlEngine-to-Bkg-obj-retrieval()
  (if (y-or-n-p "switch to Bkg? ")
      (let(
	   (targetArray (progn
			  (other-window 1)
			  (nsimple-back-to-indentation)
			  (n-s "=" t)
			  (forward-word -1)
			  (n-grab-token)
			  )
			)
	   targetObj
	   targetObjFromMe
	   (targetObjPreamble "") ;; sometimes a dcl, sometimes \s*
	   )
 	(n-next-error-extend-from-Bkg)
	
	;; figure out where the value is going
	(save-excursion
	  (if (n-s (concat "^\\(.*[ \t]\\)\\([0-9a-zA-Z_]+\\) *= *(.*)" targetArray "\\[ *0 *\\]"))
	      ;;                        this is for casting       ^^^^
	      (progn
		(setq targetObjPreamble (n--pat 1)
		      targetObj (n--pat 2)
		      )
		)
	    )
	  targetObj
	  )
	
	;; confirm my guess with the user
	(setq targetObjFromMe (read-string "target var: " targetObj))
	(if (not (string= targetObjFromMe targetObj))
	    (setq targetObj targetObjFromMe
		  targetObjPreamble ""
		  )
	  ;; guess was correct; get rid of the assignment from targetArray[0]
	  (save-excursion
	    (n-s (concat "= *(.*)" targetArray "\\[ *0 *\\]") t)
	    ;; casting:      ^^^^
	    (nsimple-delete-line)
	    )
	  )
	
	;; replace m_sqlEngine use w/ Bkg
	(nsimple-back-to-indentation)
	(insert targetObjPreamble targetObj " = ")
	(delete-region (point) (progn (n-s "m_sqlEngine\\." t)
				      (point)
				      )
		       )
	(indent-according-to-mode)
	
	;; adjust null test on array var, if any exist
	(save-excursion
	  (replace-regexp (concat targetArray "\\( *[!=]= *null\\)")
			  (concat targetObj   "\\1")
			  )
	  )
	
	;; now move point to the next instance of the array var, if any exist
	(if (n-s targetArray)
	    (n-r targetArray t))	;; get point to the beginning of it, to ease deletion
	)
    )
  )
(defun n-next-error-propose-switch-from-sqlEngine-to-Bkg-update-bob(whichMethod)
  (save-window-excursion
    (other-window 1)
    (goto-char (point-min))
    (replace-regexp (concat "m_sqlEngine." whichMethod "Bob *(")
		    (concat whichMethod "Bob(")
		    )
    )
  )
(defun n-next-error-propose-switch-from-Vector-to-BOb-array()
  (let(
       (var (progn
	      (other-window 1)
	      (forward-line 0)
	      (n-s "\\([0-9a-zA-Z_]+\\) *=" t)
	      (n--pat 1)
	      )
	    )
       )
    (nc-narrow-to-var var "Vector")
    (or (looking-at "Vector")
	(error "n-next-error-propose-switch-from-Vector-to-BOb-array: "))
    (delete-region (point) (progn
			     (n-s "Vector" t)
			     (point)
			     )
		   )
    (insert "BOb[]")
    (replace-regexp (concat var "\\.size()")
		    (concat var ".length")
		    )
    (query-replace-regexp (concat "\\((BOb) *\\)?" var "\\.elementAt(\\([^)]+\\))")
			  (concat var "[\\2]")
			  )
    (widen)
    )    
  )
(defun n-next-error-harvest-update-cgi-calls()
  (n-prune-buf "/home/sites/site200/web/teacher/html/update.cgi")
  (let(
       test_update_called
       )
    (save-excursion
      (goto-char (point-min))
      (while (n-s "update.cgi \\([^<]+\\)<<")
	(let(
	     data
	     (user	(n--pat 1))
	     (beg (point))
	     (end (progn
		    (end-of-line)
		    (point)
		    )
		  )
	     )
	  (if (not (string= user "null"))
	      (progn
		(setq data (buffer-substring-no-properties beg end)
		      test_update_called t
		      )
		
		(setq user 
		      (cond
		       ((string-match "ts\\." data) "ts")
		       ((string-match "de_" data) "de")
		       ((string-match "it_" data) "it")
		       (t user)
		       )
		      )
		(delete-region beg end)
		(n-host-shell-cmd-visible (concat "sh $HOME/work/adyn.com/httpdocs/teacher/test_update.sh "
						  user
						  " '"
						  data
						  "'"
						  )
					  )
		)
	    )
	  )
	)
      )
    (if test_update_called
	(progn
	  (n-host-shell-cmd-visible "ch")
	  (delete-region (progn
			   (goto-char (point-min))
			   (forward-line 1)
			   (point)
			   )
			 (point-max)
			 )
	  (save-buffer)
	  )
      )
    )
  )
(defun n-next-error-meta-update-symbols-files()
  (while
      (let(
	   timePeriod
	   symF
	   badsymF
	   )
	(if (save-excursion
	      (goto-char (point-min))
	      (if (n-s "^\\([A-Z0-9]+\\) BAD for \\([^ ]+\\) at ")
		  (progn
		    (setq timePeriod (n--pat 2))
		    (y-or-n-p (format "Update %s symbols files? " timePeriod))
		    )
		)
	      )
	    (progn
	      (setq symF	(concat "~/work/ts/data/" timePeriod ".symbols")
		    badsymF	(concat "~/work/ts/data/" timePeriod ".bad.symbols")
		    )
	      (goto-char (point-min))
	      (while (n-s (concat "^\\([A-Z0-9]+\\) BAD for " timePeriod " at "))
		(setq badSym (n--pat 1))
		(n-loc-push)
                
		(n-file-find symF)
		(goto-char (point-min))
		(if (n-s (concat "^" badSym "$"))
		    (nsimple-delete-line 1))
                
		(n-file-find badsymF)
		(goto-char (point-min))
		(insert badSym "\n")
                
		(n-loc-pop)
		)
	      (goto-char (point-min))
	      (replace-regexp (concat " BAD for " timePeriod " at ")
			      (concat " bad for " timePeriod " at "))
              
	      t	;; so while loop will look once more for additional time periods to be corrected
	      )
	  )
	)
    )
  )
(defun n-next-error-remove-non-references()
  (save-excursion
    (goto-char (point-min))
    (replace-regexp  (concat ":[^\"\n]*\"[^\"\n]*" n-g)
		     "string_reference"
		     )
    (goto-char (point-min))
    (replace-regexp  (concat ":sub " n-g "$")
		     "perl_defn"
		     )
    (goto-char (point-min))
    (replace-regexp  (concat ":\\(function\\|var\\) " n-g) "js_defn")
    (goto-char (point-min))
    (replace-regexp  (concat ":\\(defun\\|defvar\\|setq\\) " n-g "$")
		     "lisp_defn"
		     )
    (goto-char (point-min))
    (replace-regexp  (concat "[" (n-grab-token-chars) "]" n-g)
		     "superset1"
		     )
    (goto-char (point-min))
    (replace-regexp  (concat n-g "[" (n-grab-token-chars) "]")
		     "superset2"
		     )
    (n-prune-buf-v n-g)
    )
  )

(defun n-next-error-on-nonexistent-file(fn)
  (if (progn
        (forward-line 0)
        (looking-at "[ \t]**at org.apache.tools.ant.")
        )
      (n-next-error-find-ant-problem)
    (error "n-next-error-on-nonexistent-file: could not find %s" fn)
    )
  )

(defun n-next-error-find-ant-problem()
  (n-s "^Caused by:" t)
  (while (looking-at ".*: The following error occurred while executing this line:")
    (forward-line 1)
    (forward-line 0)
    )
  (or (looking-at "^\\([^ \t\n].*?\\):\\([0-9]+\\)")
      (progn
        (forward-line 0)
        (if (not (looking-at "Caused by: \\([^ \t\n].*?\\):\\([0-9]+\\)"))
            (error "n-next-error-find-ant-problem: "))
        )
      )
  (nsimple-scroll-to-top)
  (setq n-next-error-file-last	(n--pat 1)
        n-next-error-line-last	(n--pat 2)
        )
  )
(defun n-next-error--channel-analyze-channel-test-manage(cmd)
  (let(
       (old-val (nre-pat 1))
       (new-val (nre-pat 2))
       (low     (save-excursion
                  (forward-line -1)
                  (looking-at ".*support"))
                )
       )
    (setq old-val (nstr-replace-regexp old-val "\\+-.*" ""))
    (forward-line 0)
    (n-grab-file)
    (cond
     ((eq cmd ?3)
      (nruby-channel-test-mark-to-be-done-later)
      )
     ((eq cmd ?a)
      (delete-region (progn
                       (n-s old-val t)
                       (point)
                       )
                     (progn
                       (n-r old-val t)
                       (point)
                       )
                     )
      (insert new-val)
      (message "replaced %s w/ %s" old-val new-val)

      ;; wipe out any debug setting, if one exists
      (nruby-channel-test-debug-rm)
      )
     ((eq cmd ?d)
      (forward-line 0)
      (n-s ")" t)
      (insert (if low "l" "h"))
      (nruby-channel-test-debug-setup)
      )
     )
    )
  (nmidnight-compile)
  (n-other-window)
  (goto-char (point-min))       ;; otherwise we are frequently at EOF w/ nothing visible!
  )
