(provide 'nfn)
;;( nfn-prod "/home/nelson/highgate/server/model/database.cpp")
(defun nfn-prod(&optional fn)
  (if (not fn)
      (setq fn (n-host-to-canonical (n-file-name))))
  (cond
   ((string-match "highgate/[^/]+/\\([^/]+\\)/[^/]*$" fn)
    (n--pat 1 fn)
    )
   ((string-match "calm/conn/ocs/[^/]+/\\([^/]*\\)/\\([^/]*\\)/"
                  fn)
    (n--pat 1 fn)
    )
   ((string-match "/\\(ocs/[^/]+\\|build\\|users/[^/]+\\|project\\)/[^/]+/\\([^/]+\\)/" fn)
    (n--pat 2 fn)
    )
   ((string-match "/main2?/\\([^/]+\\)/" fn)
    (n--pat 1 fn)
    )
   (t
    nil
    )
   )
  )
(defun nfn-mixed(fn)
  (nstr-replace-regexp fn "^/cygdrive/\\([a-zA-Z]\\)/" "\\1:/")
  )
(defun nfn-cygwin(fn)
  (nstr-replace-regexp fn "^\\([a-zA-Z]\\):" "/cygdrive/\\1")
  )
(defun nfn-subproj(&optional fn)
  (if (not fn)
      (setq fn (n-file-name)))
  (setq fn (n-host-to-canonical fn))
  (let(
       )
    (cond
     ((string-match "pso/\\([^/]+\\)/" fn)
      (n--pat 1 fn)
      )
     ((string-match "/largesoft/admin/robot/\\([^/]+\\)/" fn)
      (n--pat 1 fn)
      )
     (t
      "generic"
      )
     )
    )
  )
;;(nfn-proj "/home/nelsons/shared/p4/PS/collab/main/src/com/plumtree/core/util/test/GadgetCacheTest.java")
;;(nfn-proj "c:/j2sdk1.4.0_01/src/org/corba/io/Serializable.java")
;;(nfn-proj "c:/users/nsproul/work/doc/facts/jwsdp.facts")
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/src/java/lang"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/src/java/text"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/src/java/util"))
;;(insert (nfn-proj "c:/j2sdkee1.3.1-src/j2ee/j2ee13/src/share/com/sun/ejb/ejbql/"))
;;(insert (nfn-proj "c:/j2sdkee1.3.1-src/j2ee/j2ee13/src/share/com/sun/enterprise/"))
;;(insert (nfn-proj "c:/perl/lib"))
;;(insert (nfn-proj "c:/perl/site/lib"))
;;(insert (nfn-proj "c:/j2sdkee1.3.1-src/j2ee/j2ee13/src/share/com/sun/enterprise/deployment/xml"))
;;(insert (nfn-proj "c:/downloads/java/jaxrpc1.0-scsl/jaxrpc-ri/src/com/sun/xml/rpc/encoding"))
;;(insert (nfn-proj "c:/downloads/java/jstl1.0fcs-scsl/standard/src/org/apache/taglibs/standard/lang/jstl/parser"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/src/com/sun/java/swing/plaf/motif"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/src/javax/swing/plaf/basic"))
;;(insert (nfn-proj "c:/downloads/java/jaxm1.1-scsl/jaxm-ri/samples/translator/WEB-INF/src/translator"))
;;(insert (nfn-proj "c:/jwsdp-1_0_01/docs/tutorial/examples/jaxm/samples/translator"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/demo/applets/Animator"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/demo/jfc/Java2D/src/java2d/demos/Transforms"))
;;(insert (nfn-proj "c:/j2sdk1.4.0_01/demo/plugin/jfc/Java2D/src/java2d/demos/Arcs_Curves"))

(defun nfn-proj(&optional fn mainOk)
  (if (not fn)
      (setq fn (n-host-to-canonical (n-file-name))))
  (let(
       )
    (cond
     ((or (string-match (concat (nsimple-getenv "JAVA") "/src/java/") fn)
	  (string-match "/work/doc/" fn)
	  )
      "generic"
      )
     ((string-match "/\\(demos?\\|swing\\)/" fn)
      (n--pat 1 fn)
      )
     ((string-match "/users/nsproul/work/\\([^/]+\\)/" fn)
      (n--pat 1 fn)
      )
     ((or (string-match (concat (nsimple-getenv "JAVA") "/src/org/\\([^/]+\\)") fn)
	  (string-match (concat (nsimple-getenv "JAVA") "/src/\\([^/]+\\)") fn)
	  )
      (n--pat 1 fn)
      )
     ((string-match "/org/\\([^/]+\\)/" fn)
      (n--pat 1 fn)
      )
     ((string-match "/\\([^/]+\\)/\\(pso\\|largesoft\\|src\\|samples?\\|examples?\\)/" fn)
      (n--pat 1 fn)
      )
     ((string-match "highgate/\\([^/]+\\)/[^/]*/[^/]*$" fn)
      (n--pat 1 fn)
      )
     ((string-match "/view/conn\\([^/_]+\\)_[^/_]+_vu/" fn)
      (n--pat 1 fn)
      )
     ((string-match "^\\(.:\\)?/users/nelson/" fn)
      nil	; home directory on NT
      )
     ((string-match "/\\(ocs/[^/]+\\|build\\|users\\|project\\)/\\([^/]+\\)/" fn)
      (n--pat 2 fn)
      )
     ((string-match "/largesoft/mobile/" fn)
      "mobile"
      )
     ((string-match "mysql$" fn)
      "mysql"
      )
     ((string-match "/mysql/" fn)
      "mysql"
      )
     (mainOk
      (if (string-match "/csi/\\(main2?\\)/" fn)
          (n--pat 1 fn)
        nil
        )
      )
     (t nil)
     )
    )
  )

(defun nfn-plat(&optional fn)
  (let(
       (data (match-data))
       )
    (unwind-protect
        (progn
          (if (not fn)
              (setq fn (n-host-to-canonical (n-file-name))))
          (setq fn (n-host-to-canonical fn))
          (cond
	   ((string-match "mysql$" fn)
	    "mysql"
	    )
	   ((string-match "/mysql/" fn)
	    "mysql"
	    )
           ((string-match "/\\([^/]*\\)/midnight\\." fn)
            (n--pat 1 fn)
            )
           ((string-match "[a-z]:/ocs/[^/]+/[^/]*/[^/]*/\\([^/]*\\)/" fn)
            (n--pat 1 fn)
            )
           ((string-match "calm/conn/ocs/\\([^/]*\\)/\\([^/]*\\)/" fn)
            (n--pat 2 fn)
            )
           ((string-match "\\(/ocs/[^/]+/\\|/build/\\|/users/[^/]+/\\|/project/\\)[^/]+/[^/]+/\\([^/]+\\)/"
                          fn)
            (n--pat 2 fn)
            )
           ((string-match "/main2?/[^/]*/\\([^/]+\\)/" fn)
            (n--pat 1 fn)
            )
	   ((string-match "/pso/\\([^/]*\\)/" fn)
	    (n--pat 1 fn)
	    )
	   ((or (string-match (n-host-to-canonical "$JAVA/") fn)
		(string-match (n-host-to-canonical "$PERL/") fn)
		)
	    "generic"
	    )
           (t nil)
           )
          )
      (store-match-data data)
      )
    )
  )
;;(nfn-plat "c:/mysql/Docs/manual.txt")
;;(nfn-plat "c:/users/nsproul/work/ts/meta/logs/meta.mysql")
;;(nfn-user "/ccview/connebf_nelson_vu/calm/conn/ocs/ctlib/generic/src/whatever.c")
;;(nfn-user "d:/ocs/nelson/lego/ctlib/generic/src/whatever.c")
(defun nfn-user(fn)
  (cond
   ((string-match "/home/\\([^_/]+\\)/" fn)
    (n--pat 1 fn)
    )
   ((string-match "/\\(cc\\)?view/conn[^/_]*_\\([^_/]+\\)_vu/calm/conn/ocs/" fn)
    (n--pat 2 fn)
    )
   ((string-match "\\(.:\\)?/ocs/\\([^/_]+\\)/" fn)
    (n--pat 2 fn)
    )
   ((string-match "/users/\\([^/_]+\\)/" fn)
    (n--pat 1 fn)
    )
   (t nil)
   )
  )
(defun nfn-parse(fn)
  "given FILENAME, returned (cons host dir)"
  ;;(nfn-parse "/remote/conn7/")
  (if (string-match "^/remote\\(/.*\\)$" fn)
      (setq fn (n--pat 1 fn))
    )
  (cond
   ((string-match "^//\\([^/]+\\)\\(/.*\\)$" fn)
    (cons (n--pat 1 fn) (n--pat 2 fn))
    )
   ((string-match "^/pokey\\(/?.*\\)$" fn)
    (cons "pokey" (n--pat 1 fn))
    )
   ((string-match "^\\(/conn[0-9]+.*\\)$" fn)
    (cons "pokey" (n--pat 1 fn))
    )
   ((string-match "^[a-zA-Z]:" fn)
    (cons nil fn)
    )
   (t
    (cons nil fn)
    )
   )
  )
(defun nfn-drive(&optional fn)
  (if (not fn)
      (setq fn (buffer-file-name)))
  
  (if (and fn (string-match "/^\\(.*\\):/" fn))
      (n--pat 1 fn)
    nil
    )
  )
(defun nfn-cofile(dir fn)
  "look in DIR for a file like FN.
For example, (nfn-cofile '/remote/conn3/csi/users/nelson/tutils/' '//siberia-1/view/connebf_nelson_vu/calm/conn/ocs/tutils/generic/src/x.c')
should return '/remote/conn3/csi/users/nelson/tutils/generic/src/x.c', if it exists."
  (let(
       addend
       possible
       )
    (while fn
      (setq addend	(concat (file-name-nondirectory fn)
                                (if addend
                                    (concat "/" addend)
                                  ""
                                  )
                                )
            fn		(if (string-match "\\(.*\\)/[^/]*/?$" fn)
                            (n--pat 1 fn)
                          nil
                          )
            possible	(concat dir addend)
            )
      ;;(n-trace "'%s,%s,%s'" addend fn possible)
      (if (file-exists-p possible)
          (setq fn nil)
        (setq possible nil)
        )
      )
    possible
    )
  )
;;(if n-win
;;    (progn
;;      (if (not (boundp 'nfn-file-directory-p-old))
;;          (progn
;;;;            (if (file-directory-p "c:")
;;  ;;              (error "nfn.el: file-directory-p bug fixed.  Remove patch from nfn.el"))
;;              (setq nfn-file-directory-p-old (symbol-function 'file-directory-p))
;;
;;
;;            )
;;        )
;;      (defun file-directory-p(dir)
;;        (if (string-match "^[a-zA-Z]:$" dir)
;;            (setq dir (concat dir "/"))
;;          )
;;        (funcall nfn-file-directory-p-old dir)
;;        )
;;      )
;;  )
(defun nfn-CALM_PROJECT_ROOT(&optional dir)
  (if (not dir)
      (setq dir (n-host-to-canonical default-directory)))
  (let(
       (CALM_PROJECT_ROOT (if
                              (or
                               (string-match "\\(.*/project/[^/]+\\)" dir)
                               (string-match "\\(.*/build/[^/]+\\)" dir)
                               (string-match "\\(.*_vu/calm/conn/ocs\\)" dir)
                               (string-match "\\(.*/users/[^/]*/[a-z_0-9]+\\)" dir)
                               (string-match "\\(.*/ocs/[^/]+\\)" dir)
                               (string-match "\\(/remote/conn3/tmp.cougar.*\\)/[^/]+/dce_" dir)
                               )
                              (n-host-from-canonical
                               (n--pat 1 dir)
                               )
                            )
                          )
       )
    ;;(if (and CALM_PROJECT_ROOT
    ;;       (string= "nt386" (nfn-plat dir))
    ;;     )
    ;;(nstr-upcase CALM_PROJECT_ROOT)
    CALM_PROJECT_ROOT
    ;;)
    )
  )

(defun nfn-suffix(&optional fn)
  "get the suffix of the file"
  (if (not fn)
      (setq fn (buffer-file-name))
    )
  (if (and fn (string-match "\\.\\([^\\.]+\\)$" fn))
      (substring fn (match-beginning 1) (match-end 1))
    ""
    )
  )

(defun nfn-prefix(&optional fn)
  "get the prefix of the file"
  (let (
        (bn (if fn
                (file-name-nondirectory fn)
              (buffer-name)
              )
            )
        )
    (if (string-match "\\(.*\\)\\..*" bn)
        (substring bn (match-beginning 1) (match-end 1))
      )
    )
  )

(defun nfn-suffix-supplant( fn newSuffix)
  "strip FN of its suffix, replace with NEW_SUFFIX"
  (nstr-replace-regexp fn "\\.[^\\.]+" (concat "." newSuffix))
  )
(defun nfn-looking-at()
  (looking-at "\\([a-zA-Z]:\\)?[/\\~]")
  )
(defun nfn-is-extensity-p(&optional fn)
  (if (not fn)
      (setq fn (buffer-file-name)))
  (string-match "/largesoft\\|pso/" fn)
  )
(defun nfn-s-next(&optional mustBeThere)
  "advance (point) to the next file name"
  (n-s "^\\([a-zA-Z]:\\)?\\([\\/~]\\|\\$[a-zA-Z]\\)" mustBeThere)
  )

(setq n-system-name-shortened (nstr-replace-regexp system-name "\\..*" ""))

(defun nfn-grab(&optional makeFullPath)
  (let(
       (badChars	"[]\[|' \t!;:()\n`=<>\"?*,&]")
       begin
       end
       drive
       token
       )
    (save-excursion
      (save-restriction
        (n-narrow-to-line)
        (n-grab-set-file-offset)
        (setq
         begin			(progn
				  (if (n-r badChars)
				      (if (not (setq drive (n-grab-drive-maybe)))
					  (forward-char 1))
				    (forward-line 0)
				    (setq drive (n-grab-drive-maybe))
                                    )
                                  (point)
                                  )
         end			(progn
				  (if (looking-at "\\([a-zA-Z]\\):")
				      (progn
					(forward-char 2)
					)
				    )
				  (if (n-s badChars)
                                      (forward-char -1)
                                    (end-of-line)
                                    )
                                  (point)
                                  )
         token			(buffer-substring-no-properties begin end)
         )
        )
      )
    (n-trace "nfn-grab: %s 1.11" token)
    (setq token (nstr-replace-regexp token "`hostname`" n-system-name-shortened))
    (setq token (nstr-replace-regexp token ".*`\\(.\\)" "\\1"))
    (setq token (nstr-replace-regexp token "`.*" ""))

    (cond
     (drive
      (setq token (format "/cygdrive/%s%s" drive token))
      (n-trace "nfn-grab: %s 35" token)
      (if (and (not (file-exists-p token))
               (file-exists-p drive)
               )
          (setq token drive)
        )
      (n-trace "nfn-grab: %s 50" token)
      )
     (t
      (setq token (nfn-cygwin-to-nt386 token))
      )
     )
    (n-trace "nfn-grab: %s 74.5" token)
    (cond
     ((string-match "^-[LI]/" token)
      (setq token (substring token 2))
      (n-trace "nfn-grab: %s 86.75" token)
  )
     ((string-match "\\(.*\\)#." token)	; e.g., //Common/openkernel/main/openlog-framework/test/java/com/plumtree/openlog/test/impl/OpenLogMessageImpl_Test.java#5
      (setq token (n--pat 1 token))
      (n-trace "nfn-grab: %s 92.875" token)
  )
     ((save-excursion
        (forward-line 0)
        (let(
             (xx (buffer-substring-no-properties
                  (progn
                    (forward-line 0)
                    (skip-chars-forward " \t")
                    (point)
                    )
                  (progn
                    (end-of-line)
                    (skip-chars-backward " \t")
                    (point)
                    )
                  )
                 )
             )
          (if (and (or (not n-win)
                       (not (string-match "^//" xx)) ;; too expensive to check file existence of //* on PC
                       )
                   (file-exists-p xx)
                   )
              (setq token xx)
            (n-trace "nfn-grab: %s 95.937" token)
            )
          )
        )
      )
     )

    ;; strip trailing period
    (if (string-match "\\(.*[^\\.]\\)\\.+$" token)
        (setq token (n--pat 1 token)))
    (n-trace "nfn-grab: %s 97.468" token)
    (if (and makeFullPath (not (nfn-full-path-p token)))
        (setq token (n-host-to-canonical default-directory) token))
    token
    )
  )

(defun nfn-grab-for-external-win32()
  (interactive)
  (prog1
      (nstr-kill (n-host-from-canonical (nfn-grab t)))
    (forward-line 1)
    )
  )


(defun nfn-get-all-in-buffer()
  (goto-char (point-min))
  (let(
    li
       )
    (while (nfn-s-next)
      (setq li (cons
		(nsimple-env-expand (nfn-grab))
		li
		)
	    )
      )
    (nlist-uniq li)
    )
  )
(defun nfn-truncate-dir( dir)
  (if (string-match (concat "\\(.*[/\\\\]\\)[^/\\\\]+[/\\\\]?$") dir)
      (progn
        (n--pat 1 dir)
        )
    nil
    )
  )
(defun n-env-use-var-names-str(fn &optional useTilde elide)
  (setq fn (n-host-to-canonical fn))
  (setq fn (if useTilde
               (nstr-replace-regexp fn (n-host-to-canonical "$HOME/") "~/")
             fn
             )
	)
  )
(defun nfn-clean(fn)
  ;;(n-host-to-canonical
  (nstr-replace-regexp (n-host-to-canonical fn)
		       "^\\(..+\\):[0-9]+" "\\1")	;; get rid of oracle ":1521", but not drive letters
  ;;   )
  )

(defun nfn-fn-to-java-package(&optional srcFn)
  (if (not srcFn)
      (setq srcFn (buffer-file-name)))

  (or srcFn
      (error "nfn-fn-to-java-package: expected non-null srcFn"))

  (setq srcFn (n-host-to-canonical (file-name-directory srcFn)))
  (if (not (string-match "/\\(\\(java\\|largesoft\\|pso\\|com\\|src\\).*\\)" srcFn))
      srcFn
    (let(
         (package (n--pat 1 srcFn))
         )
      (setq
       package (nstr-replace-regexp package ".*/java/" "")
       package (nstr-replace-regexp package ".*src/" "")
       package (nstr-replace-regexp package ".*\\bjava/org/" "org/")
       package (nstr-replace-regexp package ".*/javax/" "javax/")
       package (nstr-replace-regexp package ".*/convertible/test/" "")
       package (nstr-replace-regexp package ".*/convertible/src/" "")
       package (nstr-replace-regexp package "/$" "")
       package (nstr-replace-regexp package ".*\\bjava\\(-nojump\\)/com/" "com/")

       package (nstr-replace-regexp package "/" ".")
       package (nstr-replace-regexp package ".java$" "")
       package (nstr-replace-regexp package "^\\." "")
       )
      )
    )
  )
(defun nfn-win-to-cygwin(fn)
  (setq
   fn (nstr-replace-regexp fn "^\\(.\\):" "/cygdrive/\\1")
   fn (nstr-replace-regexp fn "^/cygwin/" "/")
   )
  )
(defun nfn-cygwin-to-nt386(fn)
  (cond
   ((string-match "^/cygdrive/./" fn)
    (setq fn (nstr-replace-regexp fn "^/cygdrive/\\(.\\)/" "\\1:/"))
    )
   ((and (string-match "^/[^/]" fn)	;; the [^/] is to exclude p4 and UTC expressions
         (not (file-exists-p fn))
         (file-exists-p (concat "c:/cygwin" fn))
         )
    (setq fn (concat "c:/cygwin" fn))
    )
   )
  fn
  )

(defun nfn-split(dirS)
  "split DIRS, a string containing some full path file names, into a list of those file names"
  (setq
   dirS (nstr-replace-regexp dirS " /" ";/")
   dirS (nstr-replace-regexp dirS " \\([a-z]:/\\)" ";\\1")
   )
  (nstr-split dirS ";")
  )

(defun nfn-expand-wildcards(dirs &optional omitNonexistent reverseOrderOfExpandedDirListFromEachDir)
  (let(
       (canonicalDirs (n-host-to-canonical-dirs dirs))
       expandedDirListFromEachDir
       wildcardExpandedDirs
       )

    (if omitNonexistent
        (n-trace "omitNonexistent not impl.  Would need to be after 'echo' is called because wildcard expressions won't pass the file-exists-p test."))

    (while canonicalDirs

      (setq expandedDirListFromEachDir (nlist-call-process nil
                                                           "ls"
                                                           "-d"
                                                           (car canonicalDirs)
                                                           )
            )

      (setq wildcardExpandedDirs (append wildcardExpandedDirs
                                         expandedDirListFromEachDir
                                         )
            canonicalDirs (cdr canonicalDirs)
            )
      )
    wildcardExpandedDirs
    )
  )

(defun nfn-expand-wildcards-which-exist(dirs &optional reverseOrderOfExpandedDirListFromEachDir)
  (nfn-expand-wildcards dirs t reverseOrderOfExpandedDirListFromEachDir)
  )

(defun nfn-full-path-p(fn)
  (or
   (string-match "^[a-zA-Z]:" fn)
   (string-match "^/" fn)
   (string-match "^~" fn)
   )
  )


(defun nfn-to-pc(fn &optional skipBackslashNonsense)
  (save-match-data
    (setq fn (n-host-to-canonical fn))
    (setq fn (nstr-replace-regexp fn "^/home/" "//socrates/unixhome/"))
    (setq fn (nstr-replace-regexp fn "^/ptbuild/" "//socrates/Build/"))
    (setq fn (nstr-replace-regexp fn "^/cygdrive/\\([a-zA-Z]\\)/" "\\1:/"))
    (if (not skipBackslashNonsense)
        (progn
          (setq fn (nstr-replace-regexp fn "/" "\\\\"))
          )
      )
    )
  fn
  )

(defun nfn-cite()
  (concat (buffer-file-name) ":" (int-to-string(n-what-line)))
  )

(defun nfn-eclipse(proj)
  (cond
   ((string= proj "PortalTestsCommon")
    "$P4ROOT/P2/portaltests/main/commontests/"
    )
   (t
    (error "nfn-eclipse: ")
    )
   )
  )

;;
;;(nfn-expand-wildcards-which-exist (list "$HOME/work/*"))

;;(nfn-cygwin-to-nt386 "/cygdrive/c/kk")
;;(nfn-cygwin-to-nt386 "/cygwin.ico")
;;(nfn-cygwin-to-nt386 "/cygwin.ico.nonexistent")
;;(nfn-fn-to-java-package "c:/java/src/java/util/Enumeration.java")
;;(nfn-fn-to-java-package "c:/jdk.1.1.6/src/java/util/Hashtable.java")
;;(nfn-fn-to-java-package "c:/p4/Tools/build/buildcommon/main/test/test-cov/resources/sub-java/src/java/com/bea/bid/whatever/HelloKitty.java")
;;(nfn-fn-to-java-package "c:/jdk.1.1.6/src/java/util/Hashtable.java")
;;(nfn-fn-to-java-package "c:/users/nsproul/work/teacher_servers/tomcat/webapps/teacher_server/src/teacher_server_package/teacher_server_main.java")
;;(nfn-fn-to-java-package "d:/downloads/java/jakarta-oro-2.0.7/src/java/org/apache/oro/text/regex/Perl5Matcher.java")
;;(nfn-fn-to-java-package "$JAVA/java/util/StringTokenizer.java")
;;(nfn-fn-to-java-package "c:/j2sdk1.4.1_02/jakarta-servletapi-src/src/share/javax/servlet/GenericServlet.java")
;;(nfn-to-pc "/home/brade/ellington/nthome/test/openkernel/results/CheckinTest/results.xml" t)
