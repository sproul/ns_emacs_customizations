(provide 'n-grab)
(setq n-grab-common-dirs (list
                          "$dp/python/site_cp/scripts/"
                          "$dp/python/site_cp/scripts/test/"
                          (cons "$dp/bin/win/powercli."        ".ps1")
                          "$dp/adyn/httpdocs/teacher/html/"
                          "$dp/adyn/teacher/bin/"
                          "$dp/adyn/cgi-bin/"
                          "$dp/adyn/teacher/"
                          "$RAILS_ROOT/script/rails/"
                          "$dp/rideaux/bin/"
                          "$dp/rideaux/"
                          "$dp/bin/ruby/"
                          "$dp/bin/perl/"
                          "$dp/bin/$OS/"
                          "$dp/bin/${OS}64/"
                          "$dp/bin/"
                          "$dp/home/"
                          "$dp/data/"
                          "$dp/python/site_cp/test/whitebox.inputs/"
                          "$HOME/"
                          "$TMP/"
                          "$HOME/work/monitor/"
                          "$dp/adyn/cgi-bin/data/"
                          "$dp/teacher/"
                          "$dp/teacher/grammar/"
                          "$dp/data/vc/"
                          "$dp/sensu/dist/client/plugins/"
                          "$dp/sensu/dist/server/server_bin/"
                          "$dp/config_webapp/"
                          "$mrc/bin/"
                          "$mrc/staging.process/$i/mavenfactory/"
                          "$mrc/staging.process/$i/mavenfactory/artifactory/"
                          "$mrc/staging.process/$i/mavenfactory/pushlocal/"
                          "$mrc/ucminjection/$i/maveninjection/"
                          "$mrc/ucmprovider/$i/mavenfactory/filesystem/"
                          "$mrc/ucmprovider/src/test/java/oracle/fmw/platform/mavenfactory/test/"
                          "/cygdrive/c/adt/adt-bundle-windows-x86_64-20140702/sdk/tools/"
                          (cons "$dp/ts/test_input/" ".log")
                          (cons "/cygdrive/c/ts_logs/" ".log")
                          )
      )
(setq n-grab-file-go-by-lines t)
(make-variable-buffer-local 'n-grab-file-go-by-lines)
(setq n-open-file-in-new-window t
      n-grab-file-offset-func nil
      )

(defun n-grab-drive-maybe()
  "if point is on a drive letter, return the drive letter and advance point past the colon"
  (let(
       isDrive
       )
    (save-excursion
      (setq isDrive (if (looking-at ":")
                        (cond
                         ((= (current-column) 0)
                          nil
                          )
                         ((= (current-column) 1)
                          (forward-line 0)
                          (if (looking-at "\\([a-zA-Z]\\):")
                              (n--pat 1))
                          )
                         ((> (current-column) 1)
                          (forward-char -2)
                          (if (looking-at "[^a-zA-Z]\\([a-zA-Z]\\):")
                              (n--pat 1))
                          )
                         )
                      (if (looking-at "\\([a-zA-Z]\\):")
                          (cond
                           ((< (current-column) 0)
                            (forward-char -1)
                            (if (looking-at "[^a-zA-Z]\\([a-zA-Z]\\):")
                                (n--pat 1))
                            )
                           (t
                            (n--pat 1)
                            )
                           )
                        )
                      )
            )
      )
    (if isDrive
        (n-s ":" t))
    isDrive
    )
  )
(defun n-grab-file-find-test-results(fn)
  (setq fn (nstr-replace-regexp fn "\\\\" "/")
        fn (nstr-replace-regexp fn "/temp$" "/*/results.html")
        )
  (n-host-shell-cmd-visible (concat "browser " fn " &"))
  )

(defun n-grab-file-get-token( &optional userWillEditFileName)
  (let(
       (token (nfn-grab))
       )
    (if userWillEditFileName
        (setq token (read-file-name "" token)))
    token
    )
  )

(defun n-grab-looking-at-flashcard-address(fn)
  (and
   (not (string= fn ""))
   (save-excursion
     (if (n-r "[^0-9a-zA-Z_\\.]")
	 (progn
	   (forward-char 1)
	   (if (n-s "[^_]" t)
	       (forward-char -1))
	   )
       (forward-line 0)
       )
     (looking-at "\\([a-z][a-z_0-9]+\\)\\.\\([0-9]+\\)\\(: \\([A-Z][a-z]+\\)\\)?")
     )
   (let(
	(tmp  (concat "$HOME/work/adyn.com/httpdocs/teacher/data/" (n--pat 1)))
	(idNumber (n--pat 2))
	(lang (n--pat 4))	; eg, from verb_swim.24: Spanish: no verb identified: >>/El nada.<<
	)
     (if (n-file-exists-p tmp)
	 (progn
	   (setq n-grab-file-offset-regexp (concat "'id' => '?" idNumber "'?,?$")
		 n-grab-file-offset-func-arg lang
		 n-grab-file-offset-func '(lambda()
					    (n-r (concat "'" n-grab-file-offset-func-arg "' => '") t)
					    )
		 )
	   tmp
	   )
       )
     )
   )
  )

(defun n-grab-file-try(fnToTry)
  (if (and (not found)
           (not (string= fnToTry ""))
           (n-file-exists-p fnToTry)
           )
      (setq found t
            fn fnToTry
            )
    )
  )

(defun nsimple-on-white-space()
  (and (or (looking-at"[ \t\n]")
           (eobp)
           )
       (save-excursion
         (or (bobp)
             (progn
               (forward-char -1)
               (looking-at"[ \t\n]")
               )
             )
         )
       )
  )

(defun n-grab-file--possibly-move-to-likely-file()
  (if (nsimple-on-white-space)
      (or (n-r "\\.js:[0-9]+:function")
          (n-r "\\.html?:[0-9]+:function")
          (n-r "\\.pl:[0-9]+:sub")
          (n-r "\\.pm:[0-9]+:sub")
          (n-s "/")
          )
    )
  )

(defun n-grab-file--on-a-diff(arg)
  (or (and arg (= arg 2))
      (looking-at "diff ")
      )
  )

(defun n-grab-file--diff-2()
  (cond ((save-excursion
           (forward-line 0)
           (if (looking-at ".*diff -b ")
               (replace-regexp "diff -b" "diff")
             (n-s "diff" t)
             )
           (skip-chars-forward " \t")
           (or (looking-at "['\"]\\(.*\\)['\"] ['\"]\\(.*\\)['\"]")
               (looking-at "['\"]\\(.*\\)['\"] \\(.*\\)")
               (looking-at "\\(.*\\) ['\"]\\(.*\\)['\"]")
               (looking-at "\\(.*\\) \\(.*\\)")
               )
           )
         (let(
              (f1        (nre-pat 1))
              (f2        (nre-pat 2))
              )
           ;;(message "%s/%s" f1 f2)
           (setq ediff-diff-options "-w")
           (ediff f1 f2)
           )
         )
        )
  )
(defun n-grab-teacher-exercise()
  (let(
       went-off-to-browse
       found-in-teacher-data
       cmd
       token
       lang
       areaName
       id
       fn
       )
    (save-excursion
      (setq token   (n-grab-token "_a-zA-Z\\.0-9" nil t))
      (if (string-match "^\\(verb\\|vocab\\)\\(_[_a-z]+\\)[\\._]\\([0-9]+\\)$" token)
          (progn
            (setq areaName   (concat (nre-pat 1 token) (nre-pat 2 token))
                  id      (nre-pat 3 token)
                  cmd     (read-char "b-browse exercise, c-source under cgi-bin, t-source under teacher")
                  )

            (skip-chars-forward " ")
            (if (looking-at "\\(French\\|German\\|Italian\\|Spanish\\)")
                (setq lang (nre-pat 1)))
            (cond
             ((eq cmd ?b)
              (n-host-shell-cmd-visible (concat "$dp/adyn/teacher/bin/teacher.ex.url " areaName "_" id))
              (setq went-off-to-browse t)
              )
             ((or (eq cmd ?c)
                  (eq cmd ?t)
                  )
              (cond
               ((eq cmd ?c)
                (setq fn (concat "$dp/adyn/cgi-bin/data/" areaName))
                )
               ((eq cmd ?t)
                (setq fn (concat "$dp/adyn/teacher/data/" areaName))
                )
               )
              (n-file-find fn)
              (goto-char (point-min))
              (n-s (concat "'id' => " id ",") t)
              (n-r "^{" t)
              (if lang
                  (n-s (concat lang "' => '") t)
                )
              (setq found-in-teacher-data t)
              (n-loc-push)
              )
             )
            )
        )
      )
    (if found-in-teacher-data
        (n-loc-pop)
      )
    (or found-in-teacher-data went-off-to-browse)
    )
  )
(defun n-grab-check-common-dirs()

  (let(
       (common-dirs n-grab-common-dirs)
       to-be-added-to-fn
       dir
       suffix
       )
    (while (and (not found)
                common-dirs
                )
      (setq to-be-added-to-fn   (car common-dirs)
            common-dirs         (cdr common-dirs)
            )
      (if (consp to-be-added-to-fn)
          (setq dir     (car to-be-added-to-fn)
                suffix  (cdr to-be-added-to-fn)
                )
        (setq dir       to-be-added-to-fn
              suffix    ""
              )
        )
      (setq possible-fn (concat dir fn suffix))
      ;(nelisp-bp "n-grab-check-common-dirs" possible-fn 275);;;;;;;;;;;;;;;;;
      (n-trace "n-grab-check-common-dirs testing %s" possible-fn)
      (if (n-file-exists-p possible-fn)
          (setq found   t
                fn      possible-fn
                )
        )
      )
    )
  )
(defun n-grab-diff-spot--point-on-diff-location-p()
  (save-excursion
    (let(
         diff-line-offset1
         diff-line-offset2
         )
      (forward-line 0)
      (and (looking-at "\\([0-9]+\\)\\(,[0-9]+\\)?[acd]\\([0-9]+\\)\\(,[0-9]+\\)?$")
           (setq diff-line-offset1 (nre-pat 1)
                 diff-line-offset2 (nre-pat 3)
                 )
           (save-excursion
             (if (n-r "diff \\(-[^ ]+ \\)?\\(.*[^ \t]\\)[ \t]+\\(.*\\)$")
                 (list (nre-pat 2)
                       (nre-pat 3)
                       diff-line-offset1
                       diff-line-offset2
                       )
               )
             )
           )
      )
    )
  )
(defun n-grab-diff-spot--find-chunk1()
  (forward-line 1)
  (or (looking-at "<") (looking-at ">") (error "n-grab-diff-spot--find-chunk1: thought I would be looking at diff data"))
  (buffer-substring-no-properties (point) (progn
                                            (n-s "^[^<>]" t)
                                            (forward-line 0)
                                            (point)
                                            )
                                  )
  )
(defun n-grab-diff-spot--find-chunk2()
  (if (looking-at "---$")
      (buffer-substring-no-properties (progn
                                        (forward-line 1)
                                        (point)
                                        )
                                      (progn
                                        (n-s "^[^>]" t)
                                        (forward-line 0)
                                        (point)
                                        )
                                      )
    )
  )

(defun n-grab-diff-spot()
  (let(
       (diff-fn-args-con        (n-grab-diff-spot--point-on-diff-location-p))
       )
    (if diff-fn-args-con
        (save-excursion
          (let(
               (point-on-loc1 (looking-at ".*[acd]"))
               (diff-fn-loc1      (elt diff-fn-args-con 0))
               (diff-fn-loc2      (elt diff-fn-args-con 1))
               (diff-line-offset1 (elt diff-fn-args-con 2))
               (diff-line-offset2 (elt diff-fn-args-con 3))
               )
            (if (or (and      point-on-loc1  (n-file-exists-p diff-fn-loc1))
                    (and (not point-on-loc1) (n-file-exists-p diff-fn-loc2))
                    )
                (progn
                  (nsimple-register-set (n-grab-diff-spot--find-chunk1) ?8)
                  (nsimple-register-set (n-grab-diff-spot--find-chunk2) ?9)
                  (if point-on-loc1
                      (n-file-find diff-fn-loc1 t diff-line-offset1 t)
                    (n-file-find diff-fn-loc2   t diff-line-offset2 t)
                    )
                  )
              )
            )
          )
      )
    )
  )
(defun n-grab-and-fix()
  (let(
       directive
       )
    (if (save-excursion
          (and (n-r "[^/a-zA-Z0-9_\\.]")
               (progn
                 (if (looking-back "fix")
                     (forward-char -3))
                 (looking-at "fix:[^:]*:\\(.*\\)")
                 )
               (setq directive   (nre-pat 1))
               (progn
                 (n-s "fix" t)
                 (insert "ed")
                 t
                 )
               )
          )
        (progn
          (n-grab-file)
          (require 'nfix)
          (nfix-apply directive)
          t
          )
      )
    )
  )
(defun n-grab-file(&optional arg)
  "edit thefile whose name is at point

If following the filename there is a colon and then a number, it
is assumed that this number isthe desired offset into the file.

If point is on a URL, then browser is called to go to that URL.

If following the filename is a regexp delimited by ^S characters,
then that regexp will be searched for in the file from
the beginning to achieve the desired offset into the file.

Ifpoint is on a C #include directive, the includepath is searched
for the file.

If the current buffer is a Makefile,the name under point is
examined for references to Makefile vars, which are expanded

If the file cannot be found, look in the tags database for it, unlessarg.

If arg==2, load 2 files and diff
If arg==3, just load the grabbed name into the minibuffer.
If arg==4, call 'launch' to start the appropriate Windows program to view the file.
"
  (interactive "P")
  (n-trace "n-grab: 0.10")
  (n-loc-push)
  (n-trace "n-grab: 0.30")
  (n-grab-file--possibly-move-to-likely-file)
  (n-trace "n-grab: 0.50")
  (cond ((n-grab-file--on-a-diff arg) (n-grab-file--diff-2))
        ((n-grab-and-fix) t)
        ((not (or (n-grab-URL-and-browse-it)
                  (n-grab-diff-spot)
                  (and (boundp 'n-looking-at-include-p)
                       (funcall n-looking-at-include-p)
                       (n-file-find-from-path (funcall n-get-include-name)
                                              (funcall n-get-includes-list)
                                              nil))
                  )
              )
         (let(
              n-grab-file-offset-regexp
              (n-grab-file-offset	"0")
              (n-grab-file-column-offset	nil)
              (startLaunch		(and (integerp arg) (= arg 4)))
              fn
              found
              )
           (n-trace "n-grab: %s: 1.00" fn)

           (cond
            ((n-makefile-p)			; grabbing a Makefile exp?
             (require 'n-make)
             (setq fn (n-make-eval (n-grab-file-get-token)))
             (n-trace "n-grab: %s: 1.5" fn)
             )
            ((save-excursion
               (forward-line 0)
               ;; [ERROR] /C:/Users/nelsons/src/main/java/oracle/fmw/platform/mavenfactory/filesystem/UCMPrimitives.java:[150,49]
               (nre-safe-looking-at ".* \\(/\\(.\\):\\)?\\(/[-\\./a-zA-Z0-9_]+\\.java\\):\\[\\([0-9]+\\),\\([0-9]+\\)\\]")
               )
             (setq drive-letter (n--pat 2)
                   fn-no-drive (n--pat 3)
                   n-grab-file-offset	(n--pat 4)
                   n-grab-column-offset (n--pat 5)
                   )
             (if  drive-letter
                 (setq drive-letter (concat "/cygdrive/" (nstr-downcase drive-letter)))
               (setq drive-letter "")
               )
             (setq fn (concat drive-letter fn-no-drive))
             (n-trace "n-grab: %s: 1.55" fn)
             )
            ((save-excursion
               (forward-line 0)
               (nre-safe-looking-at ".*at \\([a-zA-Z0-9<>_/\\.]+\\)/[^/ ]+ (\\([a-zA-Z0-9]+\\.java\\):\\([0-9]+\\))")
               )
             (setq fn (concat (n--pat 1) "/" (n--pat 2))
                   fn (nstr-replace-regexp fn "\\." "/")
                   fn (nstr-replace-regexp fn "/java$" ".java")
                   n-grab-file-offset	(n--pat 3)
                   )
             (n-trace "n-grab: %s: 1.75" fn)
             )
            ((save-excursion
               (forward-line 0)
               (nre-safe-looking-at ".*at \\([a-zA-Z0-9<>_/\\.]+\\)\\.[^\\.]+\\.[^/ ]+(\\([a-zA-Z0-9]+\\.java\\):\\([0-9]+\\))")
               nil
               ;; I don't want to hit the java when (point) is at boln of a line like this:
               ;; results/xpunit/runner/TestMultipleSuiteNamesComposition.xml:18:        <Failure ErrorMessage="this will fail expected:&lt;0&gt; but was:&lt;1&gt;" StackTrace="junit.framework.ComparisonFailure: this will fail expected:&lt;0&gt; but was:&lt;1&gt;&#xD;&#xA;   at junit.framework.Assert.assertEquals(Assert.java:103)"></Failure>

               )
             (setq fn (concat (n--pat 1) "/" (n--pat 2))
                   fn (nstr-replace-regexp fn "\\." "/")
                   fn (nstr-replace-regexp fn "/java$" ".java")
                   n-grab-file-offset	(n--pat 3)
                   )
             (n-trace "n-grab: %s: 2" fn)
             )
            ((save-excursion
               (forward-line 0)
               ;;2	The constructor MyPageStressTest() is undefined	MyPageStressTest.java	PortalTestsCommon/java/src/com/plumtree/server/test/community/stress	line 24	September 28, 2005 11:18:57 AM
               (nre-safe-looking-at ".*\t\\([a-zA-Z0-9]+\\.java\\)	\\([A-Za-z_0-9]+\\)/\\([A-Za-z_/0-9]+\\)	line \\([0-9]+\\)	")
               )
             (setq fn (concat (nfn-eclipse (n--pat 2)) (n--pat 3) "/" (n--pat 1))
                   n-grab-file-offset	(string-to-int (n--pat 4))
                   )
             (n-trace "n-grab: %s: 3" fn)
             )
            ((save-excursion
               (forward-line 0)
               (nre-safe-looking-at "	at [a-zA-Z0-9<>_/\\.]+(\\([A-Za-z0-9_]+\\.java\\):\\([0-9]+\\))")
               )
             (setq fn (n--pat 1)
                   n-grab-file-offset	(n--pat 2)
                   )
             (n-trace "n-grab: %s: 3.5" fn)
             )
            ((nre-safe-looking-at "[/\.:0-9a-zA-Z_]+\\([^]+\\)")
             (setq n-grab-file-offset-regexp	(n--pat 1)
                   fn (nfn-grab)
                   )
             (n-trace "n-grab: %s: 4" fn)
             )
            (t
             (setq fn (n-grab-file-get-token (and (integerp arg) (= arg 3))))

             (n-trace"n-grab: %s: 5" fn)
             (if (and (get-buffer fn)
                      (buffer-file-name (get-buffer fn))
                      )
                 (setq fn (buffer-file-name (get-buffer fn))))
             (n-trace "n-grab: %s: 6" fn)
             )
            )
           (n-trace "n-grab: %s: 6" fn)

           (if (and (not n-grab-file-offset)
                    (nre-safe-looking-at ".*:line \\([0-9]+\\)")
                    )
               (setq n-grab-file-offset (n--pat 1))
             )

           (n-trace "n-grab: %s: 6.3" fn)

           (if (and (not found) (string-match "^/" fn ))
               (let(
                    fn2
                    (sfn
                     (progn
                       (require 'nsyb)
                       (require 'nscm-p4)
                       (nscm-p4-maybe-grab fn))
                     )
                    )
                 (if sfn
                     (setq found (n-file-exists-p sfn)))
                 (if found
                     (setq fn sfn))
                 )
             )

           (n-trace "n-grab: %s: 6.5" fn)
           (setq fn (nstr-replace-regexp fn "\\\\" "/")
                 found (and
                        fn
                        (not (string= "" fn))
                        (file-exists-p fn)
                        )
                 )

           (n-trace "n-grab: %s: 7" fn)

           (setq fn (nsimple-env-expand fn))

           (if (and (not found) (n-file-exists-p fn))                              (setq found t))

           (if (string-match "^/" fn)
               (progn
                 (if (and (not found) (n-file-exists-p (concat "$dp/adyn/httpdocs" fn))) (setq found t fn (concat "$dp/adyn/httpdocs" fn)))
                 (if (and (not found) (n-file-exists-p (concat "$dp/adyn" fn))) (setq found t fn (concat "$dp/adyn" fn)))
                 (if (and (not found) (n-file-exists-p (concat "/cygdrive/c" fn))) (setq found t fn (concat "/cygdrive/c" fn)))
                 )
             (n-grab-check-common-dirs)
             (if (and (not found) (not (string-match "/" fn)) (string= "rb" (nfn-suffix fn))) (setq found t fn (concat "$dp/bin/ruby/" fn)))
             )
           (n-trace "n-grab: %s: 8, found=%s" fn (if found "t" "NO"))

           (if (and (not found) (setq fn2 (n-file-exists-replace-p fn
                                                                   (concat ".*/Dro"
                                                                           "pbox")
                                                                   "$dp"
                                                                   )
                                      )
                    )
               (setq found t fn fn2)
             )
           (if (not n-win)
               (setq fn (nstr-replace-regexp fn "^[zZ]:" "$HOME")))
           (if (and (not found)
                    (string-match "^b/python/site_cp/\\(.*\\)" fn)
                    (n-file-exists-p (concat "$dp/python/site_cp/" (nre-pat 1 fn)))
                    )
               (setq found t
                     fn  (concat "$dp/python/site_cp/" (nre-pat 1 fn))
                     )
             )
           (if (and (not found)
                    (not arg)
                    (not (string= fn ""))
                    (not (string-match "^/" fn))

                    ;; in the case where I use a relative path for a file which doesn't exist, but the relative
                    ;; path is valid and based on the cwd, then I don't want to bother searching main.flist:
                    (or (not (file-name-directory fn))       ;; not relative path
                        (not (file-exists-p (file-name-directory fn)))   ;; or `dirname fn` isn't valid
                        )
                    )
               (save-window-excursion
                 (n-file-find "~/tmp/tags/main.flist")
                 (goto-char (point-min))
                 (if (or
         (n-s (concat (nsimple-env-expand "$extprj") ".*/" fn "$"))
                      (n-s (concat "/" fn "$"))
                      )
                     (progn
                       (setq fn (n-get-line)
                             found t)
                       )
                   )
                 (bury-buffer)
                 )
             )
           (n-trace "n-grab: %s: 9" fn)
           (setq fn (n-host-to-canonical fn))

           (n-trace "n-grab: %s: 10" fn)

           (n-grab-file-try fn)
           (n-grab-file-try (concat fn ".bat"))
           (n-grab-file-try (concat fn ".ksh"))
           (n-grab-file-try (concat fn ".java"))
           (n-grab-file-try (concat "$P4ROOT/" fn))
           (n-grab-file-try (nstr-replace-regexp fn"m?\\([^\\.]*\\).*" "\\1.java"))
           (n-grab-file-try (nstr-replace-regexp fn "//socrates/unixhome/" "/home/"))
           (n-trace "n-grab 30: %s" fn)

           (if (and (not found)
                    (n-grab-teacher-exercise)
                    )
               (setq fn (buffer-file-name)
                     found t
                     )
             )
           (n-trace "n-grab 75: %s" fn)
           (require 'nmw-data)
           (if (not found)
               (nmw-data-launch-browser-if-is-verb-with-vt fn))

					;(if (not found)
					;(let(
                                        ;(possibleVt (nmw-data-is-verb-with-vt fn))
					;)
					;(if possibleVt
					;(setq fn possibleVt
					;found t
					;)
					;)
					;)
					;)

           (if (and
                (not found)
                (or
                 (save-excursion
                   (forward-line 0)
                   (nre-safe-looking-at ".* at \\([:a-zA-Z0-9<>_/\\.]+\\) line \\([0-9]+\\)")
                   )
                 (save-excursion
                   (forward-line 0)
                   (nre-safe-looking-at ".* at \\([:a-zA-Z0-9<>_/\\.]+\\) line \\([0-9]+\\)")
                   )
                 )
                )
               (setq fn			(n--pat 1)
                     n-grab-file-offset	(n--pat 2)
                     found			t
                     )
             )
           (n-trace "n-grab 87: %s" fn)
           (if (and
                (not found)
                )
               (progn
                 ;;  (setq fn (nfly-maybe-mount (n-host-from-canonical fn))))
                 (if (and fn (not found))
                     (let(
                          (translatedFn (n-host-name-xlate (if (file-name-absolute-p fn)
                                                               fn
                                                             (concat default-directory fn)
                                                             )
                                                           (if n-win
                                                               "nt386"
                                                             (system-name)
                                                             )
                                                           )
                                        )
                          )
                       (if (file-exists-p translatedFn)
                           (setq fn translatedFn
                                 found t)
                         )
                       )
                   )
                 )
             )
           (n-trace "n-grab 93: %s" fn)
           (if (and (not found)
                    (require 'nclass-browser)
                    (nclass-browser-edit)
                    )
               (setq found t
                     fn nil
                     )
             )
           (n-trace "n-grab 96: %s" fn)
           (if (and (not found)
                    fn
                    (n-file-exists-p (file-name-directory fn))
                    )
               (setq found t)
             )
           (n-trace "n-grab 97.5: %s" fn)
           (if (and (not found)
                    (n-file-exists-p (concat "$HOME/work/adyn.com/httpdocs/teacher/data/" fn))
                    )
               (setq found t
                     fn ""
                     )
             )
           (n-trace "n-grab 98.25: %s" fn)
           (if (and (not found)
                    (n-grab-find-fn-which-might-contain-blanks)
                    )
               (setq found t
                     fn 		 (n-grab-find-fn-which-might-contain-blanks)
                     )
             )
           (n-trace "n-grab 98.625: %s" fn)
           (if (and (not found)
                    (n-file-exists-p (concat "$dp/bin/" fn))
                    )
               (setq found t
                     fn 		 (concat "$dp/bin/" fn)
                     )
             )
           (n-trace "n-grab 98.812: %s" fn)
           (cond
            ((and fn (string-match "^[a-zA-Z]:$" fn))
             (setq found nil)
             (error "I refuse to grab based on a drive letter alone -- this is probably a mistake.")
             )
            ((and found
                  fn
                  (not (string= fn ""))
                  )
             (n-trace "n-grab 98.906: %s" fn)
             (if startLaunch
                 (start-process "launch"
                                (get-buffer-create "*Messages*")
                                "launch.exe"
                                fn
                                )
               (n-trace "n-grab 98.906B: %s" fn)
               (n-file-find fn
                            nil
                            n-grab-file-offset
                            n-grab-file-go-by-lines
                            (if n-grab-file-column-offset n-grab-file-column-offset)
                            )
               (n-trace "n-grab 98.908: %s" fn)
               (if n-grab-file-offset-regexp
                   (progn
                     (goto-char (point-min))
                     (n-s n-grab-file-offset-regexp)
                     (n-trace "n-grab 98.918: %s" fn)
                     (setq n-grab-file-offset-regexp nil)
                     )
                 )
               (if n-grab-file-offset-func
                   (progn
                     (n-trace "n-grab 99.928: %s" fn)
                     (condition-case nil
                         (funcall n-grab-file-offset-func)
                       (error nil)
                       )
                     (n-trace "n-grab 99.938: %s" fn)
                     (setq n-grab-file-offset-func nil)
                     )
                 )
               )
             )
            )
           (if (not found)
               (error "n-grab-file could not find %s" fn))
           found
        )
         )
        )
  )
(defun n-grab-set-file-offset()
  (setq n-grab-file-offset nil)
  ;;
  ;; look for an offset BEFORE the file name
  (save-excursion
    (if (n-r (format "[%s]" (n-grab-token-badChars)))
	(cond
	 ((save-excursion
	    (forward-word -3)
	    (nre-safe-looking-at "line \\([0-9]+\\) in \"")
	    )
	  (setq n-grab-file-go-by-lines t
		n-grab-file-offset (n--pat 1)
		)
	  )
	 ((nre-safe-looking-at ".* line: \\([0-9]+\\)$")
	  (setq n-grab-file-go-by-lines t
		n-grab-file-offset (n--pat 1)
		)
	  )
	 ((nre-safe-looking-at ".* line\nExtra parameter returned: \\([0-9]+\\)$")
	  (setq n-grab-file-go-by-lines t
		n-grab-file-offset (n--pat 1)
		)
	  )
	 ((save-excursion
	    (forward-word -4)
	    (nre-safe-looking-at "line \\([0-9]+\\) in file \"")
	    )
	  (setq n-grab-file-go-by-lines t
                n-grab-file-offset (n--pat 1)
                )
          )
         )
      )
    )
  ;; look for an offset AFTER the file name
  (if (not n-grab-file-offset)
      (save-excursion
        (if (nre-safe-looking-at "[a-zA-Z]:")
            ;; advance past the drive specification
            (forward-char 2))

        (if (n-s (format "[%s]" (n-grab-token-badChars)))
            (progn
              (forward-char -1)
              (cond
	       ((save-excursion
		  (and
		   (condition-case nil
		       (progn
			 (forward-char -5)
			 t
			 )
		     (error nil)
		     )
		   (progn
		     (nre-safe-looking-at "\\.java(\\([0-9]+\\),\\([0-9]+\\)) : ")
		     )
		   )
		  )
		(setq n-grab-file-go-by-lines t
		      n-grab-file-offset (n--pat 1)
		      n-grab-file-column-offset  (1- (string-to-int (n--pat 2)))
		      )
		)
               ((progn
                  (nre-safe-looking-at " : \\([0-9]+\\)  -- ")
                  )
                (setq n-grab-file-go-by-lines t
                      n-grab-file-offset (n--pat 1)
                      )
                )
	       ((nre-safe-looking-at ".* line \\([0-9]+\\),")
                (setq n-grab-file-go-by-lines t)
                (setq n-grab-file-offset (n--pat 1))
                )
               ((nre-safe-looking-at "\"?[:(]\\([0-9]+\\)")
                (forward-word 1)
                (setq n-grab-file-offset (n--pat 1))
                )
               ((nre-safe-looking-at ".* line:? \\(= \\)?\\([0-9]+\\)")
                (setq n-grab-file-go-by-lines t)
                (setq n-grab-file-offset (n--pat 2))
                )
               ((nre-safe-looking-at "\", \"\\([0-9]*\\)\"")
                (setq n-grab-file-go-by-lines t)
                (setq n-grab-file-offset (n--pat 1))
                )
               )
              )
          )
        )
    )
  n-grab-file-offset
  )

(defun x7()
  (interactive)
  (message( n-grab-drive-maybe))
  )
(defun n-grab-token-pair()
  (let(
       old/new
       (pair (n-grab-token "a-zA-Z0-9_/"))
       )
    (nstr-split pair "/")
    )
  )

(defun n-grab-programming-arg(&optional delete-it)
  ;; important simplicfication: I assume I am at the beginning or the end of the arg.  If it is a literal string, I am INSIDE the
  ;; quote (since emacs gravitates away from quotes, e.g., using forward-word).
  ;;
  ;; So the following code is responsible for figuring this out and moving point in order to capture the surrounding quotes or parens, if they exist.
  (save-excursion
    (let(
         beg
         end
         )
      (save-excursion
        (cond
         ((nre-safe-looking-at "\"")
          (setq end (1+ (point))
                beg (progn
                      (n-r "\"" t)
                      (point)
                      )
                )
          )
         ((nre-safe-looking-at "'")
          (setq end (1+ (point))
                beg (progn
                      (n-r "'" t)
                      (point)
                      )
                )
          )
         ((nre-safe-looking-at "[ ,)]")
          (setq end (point)
                beg (progn
                      (n-r "[( \t]" t)
                      (1+ (point))
                      )
                )
          )
         (t
          (if (save-excursion
                (forward-char -1)
                (nre-safe-looking-at "['\"]")
                )
              (setq beg (1- (point)))
            (setq beg (point))
            )
          (setq end (progn
                      (n-s "['\",)]" t)
                      (forward-char -1)
                      (if (nre-safe-looking-at "['\"]")
                          (forward-char 1))     ;; since quotes should be included as part of the yielded expression
                      (point)
                      )
                )
          )
         )
        )
      (prog1
          (buffer-substring-no-properties beg end)
        (if delete-it
            (delete-region beg end)
      )
        )
      )
    )
  )
(defun n-grab-programming-arg--test()
  (interactive)
  (message "\"%s\"" (n-grab-programming-arg))
  )
;;(nkeys-global-set-key (kbd "<f3>") nil 'n-grab-programming-arg--test)
;; abc(arg1, arg2)
;; abc(arg1, "literal arg2")
;; abc("literal arg1", "literal arg2")
;; abc("literal arg1", functional_arg("literal arg2"))
;;      currently I can't grab expressions like the following if point is at the arg end.  This wouldn't be hard though --
;; just see if we are sitting on a ')'...
;; abc(functional_arg1("literal arg1"), functional_arg2("literal arg2"))

(defun n-grab-token (&optional tokenChars delete-token advance-past-token)
  (let(
       end-of-token
       (okChars (if tokenChars
                    tokenChars
                  (n-grab-token-chars)
                  )
                )
       token
       )
    ;; {} not properly handled by regexp search utilities.  So skip some other way...
    ;; If they aren't in okChars, narrow to avoid them.
    (save-restriction
      (if (not (string-match "[{}<>]" okChars))
          (progn
            (save-excursion
              (n-narrow-to-line)	;; avoid buffer-wide searches for {}
              )
            (save-excursion
              (narrow-to-region (progn
                                  (if (n-r "[{}<>]")
                                      (forward-char 1)
                                    (forward-line 0)
                                    )
                                  (point)
                                  )
                                (progn
                                  (if (n-s "[{}<>]")
                                      (forward-char -1)
                                    (end-of-line)
                                    )
                                  (point)
                                  )
                                )
              )
            )
        )
      (narrow-to-region (progn
                          (skip-chars-forward okChars)
                          (setq end-of-token (point))
                          end-of-token
                          )
                        (progn
                          (skip-chars-backward okChars)
                          (point)
                          )
    )
      (setq token (buffer-substring-no-properties (point-min) (point-max)))
      (if delete-token
          (delete-region (point-min) (point-max)))
      (if (string-match "^\\(.*[^\\.]\\)\\.+$" token)
          (setq token (n--pat 1 token))
        )
      )
    (if advance-past-token
        (goto-char end-of-token))
    token
    )
  )

(defun n-grab-token-chars()
  "return a string of characters which make up a
legit token in the current context"
  (cond
   ((n-modes-lispy-p)	       "-+a-zA-Z0-9_\\$\\./\\*")
   ((n-makefile-p)		"a-zA-Z0-9_\\$()/")
   ((or (eq major-mode 'c-mode)
        (eq major-mode 'c++-mode)
        (eq major-mode 'njava-mode)
        (eq major-mode 'njavascript-mode)
        )
    "a-zA-Z0-9~_"
    )
   ((eq major-mode 'nant-mode) "-a-zA-Z\\.0-9_")
   ((eq major-mode 'nteacher-mode) "-a-zA-Z/`:\\^")
   ((eq major-mode 'gud-mode) "->a-zA-Z~0-9_")
   ((eq major-mode 'nsql-mode) "-a-zA-Z0-9_")
   ((eq major-mode 'nperl-mode) "a-zA-Z0-9_\\$%@")
   ((eq major-mode 'nmw-data-mode)	"a-zA-Z~0-9_,\\^:`/")
   ((eq major-mode 'shell-mode)	"-a-zA-Z~0-9\\\\_\\$\\.")
   (t	"-a-zA-Z~0-9_\\$")
   )
  )


(defun n-grab-token-badChars()
  "return a string of characters which don't make up a
legit token in the current context"
  (cond
   ((n-modes-lispy-p)		"|': 	\n()><\"\*`")
   ((eq major-mode 'shell-mode)	"|': 	\n()><\"\*`=,;\[")
   ((eq major-mode 'nant-mode)	"|': 	\n()><\"\*`=,;\[")
   ((n-makefile-p)		"|:><\"* \t\n`=")
   ((eq major-mode 'c-mode)
    "|' 	\n():><\"=\\*,;/?!#$%^&`")
   (t
    "|='\t \n()):><\"\*,;!#%^&`)[")
   )
  )
(defun n-grab-token2( &optional tokenBadChars )
  "n1.el: grab token under point"
  (let(
       (badChars	(if tokenBadChars
                            tokenBadChars
                          (n-grab-token-badChars)
                          )
                        )
       )
    (save-excursion
      (setq fn (buffer-substring-no-properties (progn
                                   (if (not (re-search-forward (concat "[" badChars "]") (point-max) t))
                                       (goto-char (point-max))
                                     (forward-char -1)
                                     )
                                   (point)
                                   )
                                 (progn
                                   (if (not (re-search-backward (concat "[" badChars "]") (point-min) t))
                                       (goto-char (point-min))
                                     (forward-char 1)
                                     )
                                   (point)
                                   )
                                 )
            )
      )
    )
  )
(defun n-grab-number(&optional ignoreCommas)
  "n5.el: return the integer value of the number under point"
  (let(
       (start	(point))
       stringNumber
       (end	(progn
		  (if (nre-safe-looking-at "-")
		      (forward-char 1))
		  (skip-chars-forward (if ignoreCommas ",\.0-9" "\.0-9"))
		  (if (save-excursion
			(forward-char -1)
			(nre-safe-looking-at "\\.")
			)
		      (forward-char -1)
		    )
		  (point)
		  )
		)
       (begin	(progn
		  (skip-chars-backward (if ignoreCommas ",\.0-9" "\.0-9"))
		  (if (and
		       (> (point) (point-min))
		       (save-excursion
			 (forward-char -1)
			 (nre-safe-looking-at "-")
			 )
		       )
		      (forward-char -1)
		    )
		  (point)
		  )
		)
       )
    (goto-char start)
    (setq stringNumber (buffer-substring-no-properties begin end))
    (if ignoreCommas
 	(setq stringNumber (nstr-replace-regexp stringNumber "," "")))
    (string-to-number stringNumber)
    )
  )
(defun n-grab-file-at-next-slash( &optional arg)
  "edit the file whose name is somewhere in the current buffer after point.  This function finds the name by looking for either a '/' or '\' character"
  (interactive "P")
  (if (string= "RMAIL-summary" (buffer-name))
      (set-buffer "RMAIL"))
  (let(
       (regexp "[^-0-9a-zA-Z_0-9_/\\.#%&=]")
       )
    (if (not arg)
	(progn
	  (n-s regexp 'eof)
	  (n-s "[\\\\/]" 'eof)
	  )
      )
    (if (or arg (eobp))
	(progn
	  (n-r regexp 'bof)
	  (n-r "[\\\\/]" t)
	  )
      )
    )
  (n-grab-file)
  )
(defun n-grab-token-in-file(fn &optional patt chars)
  (save-window-excursion
    (n-file-find fn)
    (if patt
	(progn
	  (goto-char (point-min))
	  (n-s patt t)
	  )
      )
    (toggle-read-only 1)
    (prog1
	(n-grab-token-recursive chars)
      (nbuf-kill-current)
      )
    )
  )
(defun n-grab-file-toggle-behavior()
  (message "toggle file characteristic: j-jump offset by bytes/lines, o-use other window")
  (let(
       (cmd (read-char))
       )
    (cond
     ((= cmd ?j)
      (message "n-grab-file will jump to offsets by %s"
               (if (setq n-grab-file-go-by-lines (not n-grab-file-go-by-lines))
                   "lines"
                 "bytes")
               )
      (set-default 'n-grab-file-go-by-lines n-grab-file-go-by-lines)
      )
     ((= cmd ?o)
      (message "n-grab-file will %sopen new windows"
               (if (setq n-open-file-in-new-window (not n-open-file-in-new-window))
                   ""
                 "not ")
               )
      )
     )
    )
  )
(defun n-grab-URL-and-browse-it()
  (save-excursion
    (save-restriction
      (narrow-to-region (progn
			  (if (n-s "[ \t\n()',;\"<>]")
			      (forward-char -1)
			    (goto-char (point-max))
			    )
			  (point)
			  )
			(progn
			  (if (n-r "[ \t\n(),';\"<>]")
			      (forward-char 1)
			    (goto-char (point-min))
			    )
			  (point)
			  )
			)
      (if (nre-safe-looking-at "href=")
          (progn
            (n-s "=" t)
            (narrow-to-region (point) (point-max))
            )
        )
      (if (nre-safe-looking-at "\\(firefox:\\|chrome:\\|ie:\\)?\\(http\\|https\\|ftp\\)://")
	  (progn
	    (require 'njava)
            (nhtml-browse nil (buffer-substring-no-properties (point-min) (point-max)))
	    t
	    )
	)
      )
    )
  )
(defun n-grab-find-fn-which-might-contain-blanks()
  (save-restriction
    (save-excursion
      (narrow-to-region (point) (save-excursion
				  (end-of-line)
				  (point)
				  )
			)
      (cond
       ((n-s ":[ 0-9]")
	(forward-char -2)
	)
       ((n-s "['\"\t,]")
	(forward-char -1)
	)
       (t
	(end-of-line)
	)
       )
      (widen)
      (narrow-to-region (point) (progn
				  (forward-line 0)
				  (point)
				  )
			)
      (end-of-line)
      (cond
       ((n-r " /")
	(forward-char 1)
	)
       ((n-r " [a-zA-Z]:/")
	(forward-char 1)
	)
       ((n-r "['\"]")
	(forward-char 1)
	)
       (t
	(forward-line 0)
	)
       )
      (let(
	   (fn (buffer-substring-no-properties (point) (point-max)))
	   )
	(if (n-file-exists-p fn)
	    fn)
	)
      )
    )
  )
(defun n-grab-and-decode()
  (interactive)
  (let(
       (tt (n-grab-token))
       s
       )
    (cond
     ((string-match "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$" tt)
      (setq s (nstr-call-process nil nil "perl" "$NELSON_HOME/perl/ip_id.pl" tt))
      )
     (t
      (setq s (nstr-call-process nil nil "perl" (nsimple-env-expand "$dp/bin/perl/decode_time.pl") tt))
      )
     )
    (message s)
    (nstr-kill s)
    )
  )
(defun n-grab-file-stealthily-get-lines()
  "return the contents of the file whose name is under point, but don't disturb the buffers + windows"
  (save-window-excursion
    (n-grab-file)
    (prog1
        (buffer-substring-no-properties (point-min) (point-max))
      (bury-buffer)
      )
    )
  )
