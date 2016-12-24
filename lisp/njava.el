(provide 'njava)

(setq nhtml-browser (getenv "BROWSER_EXE"))
(setq nhtml-browser-ie (getenv "BROWSER_IE_EXE"))

(defvar minor-mode nil)
(make-variable-buffer-local 'minor-mode)
(setq nhtml-javascript-start-regexp "<script language=\"JavaScript\"\\|<script type=\"text/javascript\"")

(if nil
    (cond
     ((eq minor-mode 'French)
      )
     ((eq minor-mode 'Spanish)
      )
     ((eq minor-mode 'German)
      )
     ((eq minor-mode 'Italian)
      )
     (t (error "xxxxxxxxxxxxxx"))
     )
  )

(defun nhtml-suppress-image-in-firefox()
  (n-file-find "$UNIX_dp/data/proxy.pac")
  (n-s "return " t)
  (forward-line -1)
  (n-open-line)
  (insert "          || shExpMatch(url, \"")
  (nsimple-yank)
  (insert "\")")
  (save-buffer)
  )

(defun nhtml-mode-meat()
  (njavascript-mode)
  (make-local-variable 'indent-line-function)
  (setq major-mode 'nhtml-mode
        n-indent-tab 4
        n-indent-in "<[^!\?/][^>]*[^/]>$"
        n-indent-in-except "\\(<%\\|<meta \\|<link \\|<img \\|<br>\\|<p>\\)"
        n-indent-out "</[^!][^>]*>$"
        indent-line-function    'n-indent
        )
  (let(
       (map		(copy-tree (current-local-map)))
       )
    (define-key map "," nil)
    (define-key map "\M-\"" 'nhtml-2-lines)
    (define-key map "\M-." 'nsimple-end-of-buffer)
    ;;(define-key map "\M-\C-g" 'nhtml-possibly-push-browse)
    (define-key map "\C-m"  'nhtml-newline)
    (define-key map "\C-cQ"  'nhtml-nuke-word-bs)
    (define-key map "\C-x " 'njavascript-toggle-bp)
    (define-key map "\C-xj" 'njavascript-mode)
    ;;(define-key map "\M-\C-f" 'nhtml-make-link)
    (use-local-map map)
    )
  (setq mode-name "HTML"
	major-mode 'nhtml-mode
	minor-mode (cond
		    ((string-match "French" (buffer-file-name)) (setq minor-mode 'French))
		    ((string-match "German" (buffer-file-name)) (setq minor-mode 'German))
		    ((string-match "Spanish" (buffer-file-name)) (setq minor-mode 'Spanish))
		    ((string-match "Italian" (buffer-file-name)) (setq minor-mode 'Italian))
		    (t nil)
		    )
	case-fold-search nil
	)
  (setq n-completes
	(append
         nsimple-shared-completes
	 (list
	  (list	"^anchor [^ \t]+$"	'nhtml-anchor)
	  (list	"^i$"	'nhtml-img)
	  (list	"^link$"	'nhtml-link)
	  (list	"^chunk [^ \t]+$"	'nhtml-chunk)
	  ;;(list	"^[ \t]*if$"		'n-complete-replace "if" "<!--if $fileName eq \".html\"-->\n<!--endif-->")
	  (list	"^include$"	'nhtml-include)
	  (list	"^I$"	'nhtml-init)
	  (list	"^[a-zA-Z0-9_]+ >>$"	'n-complete-replace	"^\\([a-zA-Z0-9_]+\\) >>$" "<\\1 >\n@@\n</\\1>\n")
	  (list	"^[a-zA-Z0-9_]+ <<$"	'n-complete-replace	"^\\([a-zA-Z0-9_]+\\) <<$" "<\\1>@@</\\1>\n")
	  (list "^list$"	'n-complete-replace	"list" "<ul>\n<li>@@</li>\n<li>@@</li>\n<li>@@</li>\n<li>@@</li>\n<li>@@</li>\n<li>@@</li>\n</ul>\n")
	  (list "^[ \t]*script$"	'n-complete-replace	"script" "<script type=\"text/javascript\">\n@@\n</script>\n")
	  (list "^table$"	'n-complete-replace	"table" "<table @@bgcolor=@@ border=@@ cellpadding=@@ cellspacing=@@ width=@@ >\n<tr>\n<td>@@</td>\n</tr>\n</table>\n")

	  (list "\\bp$"	'n-complete-replace	"\\(.\\)$" "<\\1>\n@@")
	  )
	 (cond
	  ((eq minor-mode 'French)
	   (list
	    (list "^v$"	'n-complete-replace	"v" "Verb('@@', '@@r', @@undef, @@undef, '@@', '-@@s', '-@@s', '-@@', '-@@ons', '-@@ez', '-@@nt')")
            )
	   )
	  ((eq minor-mode 'Spanish)
	   (list
	    (list "^v$"	'n-complete-replace	"v" "Verb('@@', '@@r', @@undef, '@@', '-@@o', '-@@s', '-@@', '-@@mos', '-@@is', '-@@n')")
	    )
	   )
	  ((eq minor-mode 'Italian)
	   (list
	    (list "^v$"	'n-complete-replace	"v" "Verb('@@', '@@re', @@undef, '@@', '-@@o', '-@@i', '-@@', '-@@iamo', '-@@te', '-@@no')")
	    )
	   )
	  ((eq minor-mode 'German)
	   (list
	    (list "^v$"	'n-complete-replace	"v" "Verb('@@', '@@en', @@undef, '@@', '-@@', '-@@t', '-@@t', '-@@en', '-@@t')")
	    )
	   )
	  (t nil)
	  )
	 (list
	  (list "^o$"	'n-complete-replace	"o" "Override('@@', '@@")
	  (list "^ot"	'n-complete-replace	"ot" "OverrideList('@@', '@@")
	  (list "^Noun('[^']+', '.', '" 'nhtml-teacher-umlauted-plural)
	  (list "^OverrideList('[/`:#~\\^0-9a-zA-Z_]+', '[a-z ]+', '[/`:~#a-z]*$"	'nhtml-teacher-do-OverrideList)
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'a$"	'n-complete-replace	"a$" "past participle', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'd$"	'n-complete-replace	"d$" "preterite', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', '3$"	'n-complete-replace	"3$" "preterite 133', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'f$"	'n-complete-replace	"f$" "future', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'i$"	'n-complete-replace	"i$" "imperative', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'I$"	'n-complete-replace	"I$" "imperfect', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'p$"	'n-complete-replace	"p$" "preterite', '@@')")
	  (list "^Override('[/`:\\^0-9a-zA-Z_]+', 'P$"	'n-complete-replace	"P$" "preterite_irregular', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'r$"	'n-complete-replace	"r$" "present participle', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 's$"	'n-complete-replace	"s$" "subjunctive', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'S$"	'n-complete-replace	"S$" "strong', '@@')")
	  (list "^Override\\(List\\)?('[/`:\\^0-9a-zA-Z_]+', 'u$"	'n-complete-replace	"u$" "past subjunctive', '@@')")
	  (list "^#?EqVerb([^,]*,[^,]*,[ \t]*'$" 'nhtml-teacher-guess-paradigm-verb)
	  (list "^q$"	'n-complete-replace	"q" "EqVerb('@@', '@@', '@@')@@")
	  (list "^Q$"	'n-complete-replace	"Q" "EqVerb('@@', '@@', '@@', 1)\nxOverride@@\n")
	  (list "^xOverride$"	'nhtml-nmw-fill-override)
	  (list "\\b[b-z]$"	'n-complete-replace	"\\(.\\)$" "<\\1>@@</\\1>")
	  (list ".*\\b\\(li\\|h1\\|h2\\|h3\\)$"	'nhtml-matching-tags)
	  (list ".*\\b[uo]l$"	'nhtml-do-uol)
	  (list ".*\\b[uo]l,$"	'nhtml-do-uol-commaMode)
	  (list ".*VerbTable('$"	'nhtml-nmw-insert-tense)
	  )
	 )
	)
  )

(defun nhtml-matching-tags(&optional unused)
  ;; This routine is intended to deal with the situation where data has been pasted into an emacs buffer, and now the user wants to add matching HTML tag boundaries to this line.  The completion infrastructure dictates that at the time of this routine's execution, the buffer will be narrowed to the initial matching tag (e.g., if the incoming data is going to be a list item, then the user will have inserted "li" at the beginning of the line, and the buffer will be narrowed to that same "li")

  (nsimple-back-to-indentation)
  (let(
       (tag (n-grab-token))
       )
    (insert "<")
    
    (n-s tag t)
    (insert ">")

    (widen)
    
    (end-of-line)
    (insert "</" tag ">")

    (forward-line 1)
    (nsimple-back-to-indentation)
    )
  )

(defun nhtml-nmw-fill-override()
  (forward-line 0)
  (or (looking-at "xOverride")
      (error "nhtml-nmw-fill-override: "))
  (delete-char 1)
  (save-restriction
    (widen)
    (forward-line -1)
    (or (looking-at "#?EqVerb('\\([^']+\\)")
	(error "nhtml-nmw-fill-override: 2"))
    (let(
	 (verb (n--pat 1))
	 )
      (forward-line 1)
      (end-of-line)
      (insert "('" verb "', '")
      )
    )
  )


(defun nhtml-nmw-insert-tense()
  (require 'nmw-data)
  (let(
       (tense (nmw-data-add-tense-markers-read-tense "present"))
       )
    (end-of-line)
    (insert tense)
    (n-complete-leap)
    )
  )
(defun nhtml-newline()
  (interactive)
  (cond
   ;;   ((save-excursion
   ;;      (forward-line 0)
   ;;      (looking-at "^[a-z][a-z]+$")
   ;;      )
   ;;    (forward-line 0)
   ;;    (insert "<")
   ;;    (end-of-line)
   ;;    (insert ">\n")
   ;;    )
   (t
    (insert "\n")
    )
   )
  )

(defun nhtml-2-lines( &optional arg)
  (interactive "p")
  (require 'n-2-lines)
  (cond
   ((save-excursion
      (forward-line 0)
      (looking-at "^<li>.*</li>$")
      )
    (end-of-line)
    (insert "\n<li>@@</li>")
    (forward-line 0)
    (n-complete-leap)
    )
   ((save-excursion
      (forward-line 0)
      (looking-at "Override(")
      )
    (n-2-lines)
    (forward-line 0)

    (n-s "'" t) (n-s "'" t) (n-s "'" t)

    (delete-region (point) (progn
			     (end-of-line)
			     (point)
			     )
		   )
    )
   (t
    (call-interactively 'n-2-lines)
    )
   )
  )

(defun nhtml-undo-decoration()
  (save-excursion
    (goto-char (point-min))
    (n-s nhtml-javascript-start-regexp t)
    (n-r "<script" t)
    (delete-region (point)
                   (progn
                     (n-s "^</script>" t)
                     (point)
                     )
                   )
    (let(
	 (s (format "%c$" 13)) ;; avoid ^M in this module, which will spread like a virus
	 )
      (replace-regexp s "")
      )

    (goto-char (point-min))
    (replace-regexp "<font color=red><b><sup>[0-9]+</sup></b></font>" "")

    (goto-char (point-min))
    (replace-regexp "<FONT color=red><B><SUP>[0-9]+</SUP></B></FONT>" "")

    (require 'n-prune-buf)
    (n-prune-buf "wk_data\\[[0-9]+\\]=")
    (n-prune-buf "wk_itemCount=")
    (n-prune-buf "wk_documentID=")
    (n-prune-buf "wk_minimumIndex=")
    (n-prune-buf "wk_.*action\\[[0-9]+\\]=")

    (replace-string "wk_frame_onLoad();" "")

    (goto-char (point-min))
    (replace-regexp (concat nhtml-javascript-start-regexp
                            "[\t \n]*</script>"
                            )
                    ""
                    )

    )
  )
(defun nhtml-prepare-for-decorate()
  (interactive)




  ;; hack for ext batch files
  (if (and (string= (nfn-suffix) "bat")
           (save-excursion
             (goto-char (point-min))
             (n-s "jre\" ")
             )
           )
      (progn
        (goto-char (point-min))
        (if (save-excursion
              (n-s "-nojit")
              )
            (replace-regexp "-nojit" "")
          (n-s "jre\" ")
          (insert "-nojit")
          )
        )



    (let(
         (data (buffer-substring-no-properties (point-min) (point-max)))
         )
      (find-file "/cygdrive/c//k.html.old")
      (delete-region (point-min)(point-max))
      (insert data)
      )

    (delete-other-windows)
    (nsimple-split-window-vertically)
    (find-file "$NELSON_BIN/perl/midnight")
    (other-window 1)
    (nhtml-undo-decoration)
    )
  )
(defun nhtml-default-anchor-name()
  (let(
       (file (n-host-to-canonical (buffer-file-name)))
       name
       )
    (cond
     ((string-match "public/\\(.*\\)\\.html?$" file)
      (setq name (n--pat 1 file))
      )
     ((string-match "work/\\(.*\\)\\.html?$" file)
      (setq name (n--pat 1 file))
      )
     ((string-match "[a-zA-Z]:/\\(.*\\)\\.html?$" file)
      (setq name (n--pat 1 file))
      )
     ((string-match "/\\(.*\\)\\.html?$" file)
      (setq name (n--pat 1 file))
      )
     (t
      (error "nhtml-default-anchor-name: ")
      )
     )
    (concat "file_"
            (nstr-replace-regexp name "/" "_")
            )
    )
  )
(defun nhtml-browse(&optional arg fn browser-directive)
  "browse FN using 'browser' script."

  ;;  "ARG, browse FN using 'browser' script.
  ;;If ARG non-nil, transform local file names so as to access them via local web servers"

  (interactive "P")
  (save-some-buffers t)
  (if (not browser-directive)
      (setq browser-directive ""))

  (if (not fn)
      (progn
	(save-buffer)
	(setq fn (n-host-to-canonical (buffer-file-name)))
	)
    )
  (let(
       (drop (getenv "dp"))
       )
    (setq fn (nstr-replace-regexp fn "/cygdrive/c/Users/nelsons/work/monr/web/"  "http://localhost:7081/"))
    (setq fn (nstr-replace-regexp fn "/cygdrive/c/scratch/mavrepo/\\(acmsmtv1045\\)\\(/com/oracle.*/\\)[^/]*$"  "http://\\1.us.oracle.com:16200/content/idcplg?IdcService=COLLECTION_DISPLAY&hasCollectionPath=true&dCollectionPath=/Contribution%20Folders/external/content/maven/content\\2"))
    (setq fn (nstr-replace-regexp fn "/cygdrive/c/scratch/mavrepo/\\(acmsmtv2074\\)\\(/com/oracle.*/\\)[^/]*$"  "http://\\1.us.oracle.com:16200/content/idcplg?IdcService=FLD_BROWSE&path=/Enterprise%20Libraries/content/maven/content\\2"))

    (setq fn (nstr-replace-regexp fn (concat drop "/adyn/cgi-bin/")  "http://localhost:2082/cgi-bin/"))
    (setq fn (nstr-replace-regexp fn (concat drop "/adyn/httpdocs/") "http://localhost:2082/"))
    (setq fn (nstr-replace-regexp fn "/home/\\([^/]*\\)/public_html/" "http://wonkaha.us.oracle.com/~\\1/"))
    (setq fn (nstr-replace-regexp fn
                                  (concat (getenv "HOME") "/public_html")
                                  "http://wonkaha.us.oracle.com/~nsproul"
                                  )
          )
    )
  (setq fn (concat browser-directive fn))
  (setq fn (nstr-replace-regexp fn "/cygdrive/\\(.\\)/" "file:///\\1:/"))

  (cond
   ((and nhtml-browser-ie (string-match "^ie:" fn))
    (setq fn (nstr-replace-regexp fn "^ie:" ""))
    (start-process "browser" "t" nhtml-browser-ie fn)
    )
   ;;
   ;; for better pfr, but not sure we need it...
   ;;
   ;;((and nhtml-browser
   ;; (not (string-match "^\\(ie\\|firefox\\):" fn))
   ;;      (not (string-match "|" fn))
   ;;      )
   ;; ;; a little odd -- this translation used to be in n-host-name-xlate-nt386, but was commented out.  Not sure why...
   ;;  ;;(setq fn      (nstr-replace-regexp fn "/cygdrive/\\(.\\)/" "\\1:/"))
   ;; (n-trace "browser %s" fn)
   ;;  (start-process "browser" "t" nhtml-browser fn)
 ;; )
   (t
    (start-process "browser"
                   "t"
                   "bash"
                   "-x"
                   "browser"
                   fn
                   )
    )
   )
  )

(defun nhtml-anchor()
  (forward-line 0)
  (or (looking-at "anchor \\([^ \t]+\\)")
      (error "nhtml-anchor:"))
  (let(
       (localAnchor (n--pat 1))
       globalAnchor
       )
    (setq globalAnchor (concat
                        (file-name-nondirectory (buffer-file-name))
                        "#"
                        localAnchor
                        )
          )
    (save-window-excursion
      (nmenu-goto-data-file "html-links")
      (goto-char (point-min))
      (and (n-s (concat "^" localAnchor "$"))
           (error "nhtml-anchor: %s is not unique" localAnchor))
      (insert localAnchor "\n")
      (bury-buffer)
      )
    (nsimple-delete-line 1)
    (insert "<!--anchor " localAnchor "-->\n")
    )
  )
(defun nhtml-link()
  (nsimple-delete-line 1)
  (let(
       (link	(nmenu "choose link" "html-links"))
       )
    (if (not link)
        (insert "<a href=@@>@@</a>")
      (insert "<!--link " link "@@-->@@")
      )
    )
  (forward-line 0)
  (n-complete-leap)
  )


(defun nhtml-chunk()
  (forward-line 0)
  (or (looking-at "chunk \\([^ \t]+\\)")
      (error "nhtml-chunk: "))
  (let(
       (chunkName (n--pat 1))
       )
    (save-window-excursion
      (nmenu-goto-data-file "html-includes")
      (goto-char (point-min))
      (if (n-s (concat "^" chunkName "$"))
          (progn
            (message "nhtml-chunk: %s is not unique" chunkName)
            )
        (insert chunkName "\n")
        )
      (bury-buffer)
      )
    (nsimple-delete-line 1)
    (insert "<!--chunk " chunkName "-->\n@@\n<!--chunkEnd " chunkName "-->\n@@")

    (goto-char (point-min))
    (n-complete-leap)
    )
  )
(defun nhtml-include()
  (nsimple-delete-line 1)
  (let(
       (include	(nmenu "choose include" "html-includes"))
       )
    (if (not include)
        (setq include "@@"))
    (insert "<!--include " include "-->@@")
    )
  (forward-line 0)
  (n-complete-leap)
  )
(defun nhtml-delete-tags(tag &optional pair)
  (goto-char (point-min))
  (while (n-s (concat "<" tag))
    (n-r "<" t)
    (delete-region (point) (progn
			     (n-s (if pair
				      (concat "/" tag ">")
				    ">"
				    )
				  t
				  )
			     (point)
			     )
		   )
    )
  )


(defun nhtml-nuke-word-bs()
  (interactive)
  (delete-region (point-min) (progn
			       (goto-char (point-min))
			       (n-s "^<body.*" t)
			       (point)
			       )
		 )
  (insert "<html>\n<body>")

  (nhtml-delete-tags "span" t)
  (nhtml-delete-tags "style" t)

  (goto-char (point-min))
  (replace-regexp "<p [^>]+>" "<p>")

  (while (n-s "<b$")
    (delete-char 1)
    (insert " ")
    )
  (goto-char (point-min))
  (replace-regexp "<b [^>]+>" "<b>")

  (goto-char (point-min))
  (replace-regexp "<b></b>" "")

  (goto-char (point-min))
  (replace-regexp "<p></p>" "")

  )


(defun njavascript-mode-meat()
  (make-local-variable 'indent-line-function)
  (setq n-indent-tab 4
        n-indent-in "{"
        n-indent-out "}"
        indent-line-function	'n-indent
        n-comment-boln "// "
	comment-start "// "
	n-comment-end ""
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"public [A-Za-z0-9_]+([^()]+)$"	'nc-complete-constructor nil	)
                 (list	"^[^ \t]*($"	'n-complete-dft	")\n{\n@@\n}\n")
                 (list	"^[ \t]*c$"	'n-complete-replace "c"	"alert('@@')")
                 (list	"^[ \t]*C$"	'n-complete-replace "C"	"console.log('@@')")
                 (list	"^[ \t]*ca$"	'n-complete-replace "ca"	"console.assert(@@, \"@@\")")
                 (list	"^[ \t]*ce$"	'n-complete-replace "ce"	"console.error('@@')")
                 (list	"^[ \t]*cE$"	'n-complete-replace "cE"	"console.exception('@@')")
                 (list	"^[ \t]*cl$"	'n-complete-replace "cl"	"console.log('@@')")
                 (list	"^[ \t]*ci$"	'n-complete-replace "ci"	"console.info('@@')")
                 (list	"^[ \t]*cd$"	'n-complete-replace "cd"	"console.debug('@@')")
                 (list	"^[ \t]*cD$"	'n-complete-replace "cD"	"console.dir(@@)")  ;; to dump out objects
                 (list	"^[ \t]*cX$"	'n-complete-replace "cX"	"console.dirxml(@@)")  ;; to dump out XML
                 (list	"^[ \t]*ct$"	'n-complete-replace "ct"	"console.trace()")
                 (list	"^[ \t]*cT$"	'n-complete-replace "cT"	"console.time('@@')")
                 (list	"^[ \t]*cTE$"	'n-complete-replace "cTE"	"console.timeEnd('@@')")
                 (list	"^[ \t]*cw$"	'n-complete-replace "cw"	"console.warn('@@')")
                 (list	"^[ \t]*\\(console\..*\\|alert\\)('$"	'njavascript-trace-func)
                 (list	"^[ \t]*e$"	'n-complete-dft	"lse\n{\n@@\n}\n")
                 (list	"^f$"	'n-complete-dft	"unction @@()\n{\n@@\n}\n")
                 (list	"^[ \t]*f$"	'n-complete-dft	"or (@@)\n{\n@@\n}")
                 (list	"^[\t ]*for ($" 'n-complete-dft	"var %V = 0; %V < @@; %V++" 'njavascript-replace-with-new-var "j" "k" "i")
                 (list	"^[ \t]*F$"'n-complete-replace	"F" "for (@@key in @@)\n{\n@@\n}\n")
                 (list	"^[ \t]*i$"	'n-complete-dft	"f (@@)\n{\n@@\n}\n")
                 (list	"^[ \t]*E$"	'n-complete-replace "E"	"else if (@@)\n{\n@@\n}\n")
                 (list	"^[ \t]*else if ($"	'njavascript-else-if)
                 (list	"^[ \t]*w$"	'njavascript-write-document)
                 (list	"^[ \t]*W$"	'n-complete-replace "W"	"while (@@)\n{\n@@\n}\n")
                 )
                )
        )
  (require 'nsh)
  (setq njavascript-kbd-map		(copy-tree (nsh-mode-setup-kbd-map)))
  ;;(define-key njavascript-kbd-map "\M-/" 'njavascript-comment)
  (define-key njavascript-kbd-map "\M-c" nil)
  (define-key njavascript-kbd-map "\M-\C-h" nil)
  (define-key njavascript-kbd-map "\C-x " 'njavascript-toggle-bp)
  (define-key njavascript-kbd-map "\M-." 'nsimple-end-of-buffer)
  (use-local-map njavascript-kbd-map)
  (setq mode-name "JavaScript"
        major-mode 'njavascript-mode
        )
  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (cond
       ((string-match "/guide.*html?" (buffer-file-name))
        (insert "<body bgcolor=#cccccc><font face=arial size=+3>
<ul>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
    <li>@@</li>
</ul>
<iframe style=\"width: 100%;height:90%\" type=\"text/html\" src=\"https://www.youtube.com/embed/@@?autoplay=1&rel=0\" frameborder=\"0\"></iframe>
</font>
")
        )
       )
    )
  )

(defun njavascript-args-get()
  (save-restriction
    (widen)
    (save-excursion
      (n-r "function.*(" t)
      (nstr-split
       (nstr-replace-regexp
        (buffer-substring-no-properties (progn
                                          (n-s "(" t)
                                          (point)
                                          )
                                        (progn
                                          (forward-char -1)
                                          (forward-sexp 1)
                                          (forward-char -1)
                                          (point)
                                          )
                                    )
        ","
        " "
        )
       )
      )
    )
  )


(defun njavascript-trace-func()
  (forward-line 0)
  (n-s "'" t)
  (insert (n-defun-name) "(")
  (let(
       (args (njavascript-args-get))
       (firstTime t)
       )
    (while args
      (if firstTime
          (setq firstTime nil)
        (insert ", ")
        )
      (setq arg (car args)
            args (cdr args)
            )
      (insert arg "=' + " arg " + '")
      )
    )
  (insert ")")
  )

(defun njavascript-comment( &optional dontRetrieveCommentFromKill)
  (interactive "P")

  (forward-line -1)
  (if (not (looking-at "$"))
      (progn
        (end-of-line)
        (insert "\n")
        )
    )
  (insert "//\n// ")
  (n-loc-push)
  (insert "\n")
  (n-loc-pop)
  (if (not dontRetrieveCommentFromKill)
      (progn
        (nsimple-delete-line)
        (save-restriction
          (narrow-to-region (point) (point))
          (yank)
          (if (save-excursion
                (forward-char -1)
                (not (looking-at "\n"))
)
	      (insert "\n")
	    )

          (goto-char (point-min))
          (nsimple-marginalize-region 75 (point-min) (point-max))

          ;; remove line beginning comment markers
          (goto-char (point-min))
          (replace-regexp "^[ \t]*//[ \t]*" "")
          
          ;; add line beginning comment markers
          (goto-char (point-min))
          (replace-regexp "^" "// ")

          (goto-char (point-max))
          (widen)
          )
        )
    )
  )

(defun njavascript-else-if()
  (let(
       switch-var possible-quote
                  )
    (save-restriction
      (widen)
      (n-r "^[ \t]*if (" t)
      (n-s "(" t)
      (if (looking-at "\\([0-9a-zA-Z_]+\\)==\\(\"?\\)")
          (setq switch-var (nre-pat 1)
                possible-quote (nre-pat 2)
                )
        )
      )
    (if switch-var
        (n-complete-replace "("	(concat "(" switch-var "==" possible-quote "@@" possible-quote))
      (insert " ")
      )
    )
  )


(defun njsp-mode-meat()
  (nhtml-mode-meat)
  (setq n-completes
        (append
         nsimple-shared-completes
         (list
          (list	"^[ \t]*cc$"	'n-complete-replace "cc"	"<c:choose>\n<c:when test='@@'>\n@@\n</c:when>\n<c:otherwise>\n@@\n</c:otherwise>\n</c:choose>\n")
          (list	"^[ \t]*cf$"	'n-complete-replace "cf"	"<c:forEach var=\"@@\" items=\"${@@}\">\n@@\n</c:forEach>\n")
          (list	"^[ \t]*cfj \\([a-zA-Z0-9-\\.]*\\) \\([a-zA-Z0-9_]*\\)$"	'njsp-load-js-from-bean-list)
          (list	"^[ \t]*ci$"	'n-complete-replace "ci"	"<c:if test='@@'>\n@@\n</c:if>\n")
          (list	".*\\bco$"	'n-complete-replace "co$"	"<c:out escapeXml=\"false\" value=\"${@@}\"/>@@")
          (list	"^[ \t]*ji$"	'n-complete-replace "ji"	"<jsp:include page=\"/WEB-INF/jsp@@/fields/@@.jsp\"/>\n@@")
          )
         n-completes
         )
        )
  (setq njsp-kbd-map (copy-tree  njavascript-kbd-map))
  (define-key njsp-kbd-map "\M-c" nil)
  (define-key njsp-kbd-map "\M-\C-h" nil)
  (define-key njsp-kbd-map "\C-x " 'njavascript-toggle-bp)
  (use-local-map njsp-kbd-map)
  (setq mode-name "JSP"
        major-mode 'njsp-mode
        )
  (if (= (point-min) (point-max))
      (insert "<%@ include file=\"/WEB-INF/jsp/includes.jsp\" %>\n\n")
    )
  )

(defun njava-mode-meat()
  (require 'nc)
  (c++-mode)
  (nc-mode)
  (nstr-copy-to-register ?0 (nfn-prefix))
  (setq ntags-find-class-context-operator-regexp "\\."
        ntags-find-class-context-operator-length 1
        c-default-style "java"
        ;;c-default-style "gnu"
        ;;c-default-style "whitesmith"
        ;;c-default-style "stroustrup"
        ;;c-default-style "bsd"
	nsimple-transpose-words-xlate (list
				       (cons "private" "protected")
				       (cons "protected" "public")
				       (cons "public" "protected")
				       )
        nclass-browser-method-pruning-function 'njava-method-pruning-function
        nmidnight-make-makefile 'njava-make-makefile
        mode-name "njava"
        major-mode 'njava-mode
        n-get-include-name 	'njava-get-include-name
        n-looking-at-include-p 	'njava-looking-at-include-p
        n-get-includes-list 	'njava-get-includes-list
	n-comment-boln " *"
	comment-start "/**"
	n-comment-end "*/"
        
	;;tab-width 2
        ;;n-indent-tab 2
        ;;n-indent-in "{"
        ;;n-indent-out "}"

	;;c-indent-line is default indent func:
        ;;indent-line-function	'n-indent

        indent-line-function	'njava-indent
	indent-region-function	nil
	)
  (setq n-completes
        (append
         nsimple-shared-completes
         (list
          (list	"^[\t ]*;$"	'njava-xform) ;
          (list	"^[\t ]*\\([0-9a-zA-Z_]+\\)\\.$"	'njava-gen-data-dcl)
          (list	"^[\t ]*suite$"	'n-complete-replace	"suite"	"public static Test suite() {\n\n		try {\n			String tests[] = {\n				\"@@\",\n			};\n\n\n			TestSuite suite = new TestSuite(\"@@\");\n			for (int i = 0; i < tests.length; i++) {\n				suite.addTest(new @@(tests[i]));\n			}\n			return suite;\n		} catch (Exception e) {\n\n			throw XPException.GetInstance(e);\n		}\n	}\n")
          (list	"^[\t ]*a$"	'njava-assert)
          (list	"^[\t ]*c$"	'njava-cout)
          (list	"^.* \\.$"	'njava-gen-name-based-on-type)
          (list	"^[\t ]*C$"	'njava-cout t)
          (list	"^[\t ]*ce$"	'n-complete-replace	"ce$"	"System.err.println(@@\");\n")
	  (list	".*\\.a$"	'n-complete-replace	"a$"	"addElement(@@);")
	  ;;(list	".*.\\bd$"	'n-complete-replace	"d$"	"DBStatic.@@")
	  (list	".*\\.e$"	'n-complete-replace	"e$"	"elementAt(@@);")
	  (list	"^[\t ]*fe$"	'njava-enumeration)
	  (list	"^[\t ]*fi$"	'njava-iteration)
	  (list	".*\\.g$"	'njava-gen-get)
	  (list	".*\\.gI$"	'n-complete-replace	"gI$"	"getElementAsInteger(\"@@\")@@")
	  (list	".*\\.gb$"	'n-complete-replace	"gb$"	"getElementAsBoolean(\"@@\", false)@@")
	  (list	".*\\.gc$"	'n-complete-replace	"gc$"	"getElementAsALMoney(\"@@\")@@")
	  (list	".*\\.gd$"	'n-complete-replace	"gd$"	"getElementAsDate(\"@@\")@@")
	  (list	".*\\.ge$"	'n-complete-replace	"ge$"	"getElement(\"@@\")@@")
	  (list	".*\\.gf$"	'n-complete-replace	"gf$"	"getElementAsFloat(\"@@\")@@")
	  (list	".*\\.gi$"	'n-complete-replace	"gi$"	"getElementAsInt(\"@@\")@@")
	  (list	".*\\.gr$"	'n-complete-replace	"gr$"	"getElementInBobRef(\"@@\", \"@@\")@@")
          (list	".*\\.gs$"	'n-complete-replace	"gs$"	"getElementAsString(\"@@\")@@")
          (list	"^[\t ]*h$"	'n-complete-replace	"h$"	"cryForHelp h = new cryForHelp(\"@@\");")
	  (list	"^[\t ]*iq$"	'njava-query-hibernate t)
          (list	"^[\t ]*L$"	'njava-add-tracing nil)
          (list	"^[\t ]*LL$"	'njava-add-tracing t)
          (list	"^[ \t]*m$"	'n-complete-replace	"m" "public static void main(String[] arguments)\n{\n@@;\n}\n")
          (list	"^[ \t]*test$"	'n-complete-replace	"test" "public void test@@() {\n@@;\n}\n")
          (list	"^[ \t]*sb$"	'njava-sb)
          (list	"^[ \t]*ts$"	'njava-make-ts)
          (list	"^p$"	'njava-package)
	  (list	"^[\t ]*q$"	'njava-query-hibernate nil)
	  (list	"^[\t ]+\\([0-9a-zA-Z_]+\\) qb$"	'n-complete-replace	"^[\t ]+\\([0-9a-zA-Z_]+\\) qb$"	"boolean \\1 = RequestUtils.get@@Required@@BooleanParameter(request, \"\\1\"@@, @@true@@false);")
	  (list	"^[\t ]+\\([0-9a-zA-Z_]+\\) qi$"	'n-complete-replace	"^[\t ]+\\([0-9a-zA-Z_]+\\) qi$"	"int \\1 = RequestUtils.get@@Required@@IntParameter(request, \"\\1\"@@, \"@@\");")
	  (list	"^[\t ]+\\([0-9a-zA-Z_]+\\) qs$"	'n-complete-replace	"^[\t ]+\\([0-9a-zA-Z_]+\\) qs$"	"String \\1 = RequestUtils.get@@Required@@StringParameter(request, \"\\1\"@@, \"@@\");")
          (list	".*\\.se$"	'n-complete-replace	"se$"	"setElement(\"@@\", @@);")
	  (list	".*\\.ts$"	'n-complete-replace	"ts$"	"toString()@@")
	  ;;(list	".*\\bst$"	'n-complete-replace	"st$"	"StaticBob.@@")
	  (list	"^[\t ]*t$"	'n-complete-replace	"t$"	"throw new RuntimeException(\"@@\");")
	  (list "^[\t ]*T$"	'n-complete-replace	"T" "StaticLoggers.OK_FUNCTIONTRACING_LOGGER.Info(\"@@\");\n@@")
	  )
	 n-completes
	 )
	)
  (let(
       (map		(copy-tree (current-local-map)))
       )
    (if (not map)
	(setq map (make-keymap))
      (define-key map "," nil)
      )
    ;;(define-key map "\M-\C-t" 'njava-goto-test)
    (define-key map "\C-c\C-i" 'njava-include)
    (define-key map "\C-cg" 'njava-gen-set-and-get-methods)
    (define-key map "\C-m" 'njava-newline)
    ;;(define-key map "\C-y" 'njava-yank)
    (define-key map "\C-\M-h" nil)
    (define-key map "\C-\M-v" 'njava-kill-next-routine)
    (define-key map "\C-\M-z" 'njava-goto-corresponding-db-table)
    ;;(define-key map "\M-/" 'njava-doc-comment)
    (use-local-map map)
    )
  (if (eq (point-max) 1)
      (progn                            ; new file
        (if (string-match "/pso/" (n-host-to-canonical (buffer-file-name)))
            (progn
              (insert "p")
              (n-complete-or-space)

              (insert "/*
	Copyright (C) 1995 - 2001 Extensity Software, Inc.

	All rights reserved.

	All use is subject to provisions of executed license agreement.
	Restricted Rights Legend (U.S. Government Customers):
	Use, duplication and disclosure by the government is subject to
	restrictions set forth in government regulations applicable to rights
	in technical data and computer software.
*/

")
              )
          )
        (insert "class ")
        (insert (njava-file-class-name))
        (insert "\n{\n    @@;\n}\n")
        (forward-word -1)

	(require 'n-make)
	(n-make-possibly-add-to)
	)
    )
  (if (and
       (string-match "hibernate_generated_code" (buffer-file-name))
       (y-or-n-p "clean up?")
       )
      (progn

        (require 'n-prune-buf)
        (n-prune-buf "persistent field")	;; rm obnoxious comments
        (n-prune-buf "^$")

        (goto-char (point-min))
        (replace-regexp "" "")

        (goto-char (point-min))
        )
    )
  )

(defun njava-cout(&optional suppressDebugIf)
  (let(
       (fName (n-defun-name t))
       (isEh (or
              (string-match "/com/eh/"  (n-host-to-canonical (buffer-file-name)))
              )
             )
       (isXpunit (or
                  (string-match "/xpunit/"  (n-host-to-canonical (buffer-file-name)))
                  )
                 )
       (isPt (and
              (string-match "/p4/"  (n-host-to-canonical (buffer-file-name)))
              (not (string-match "Tools/TestResultsFormatter/" (n-host-to-canonical (buffer-file-name))))
              )
             )
       debugVariable
       outer
       pattern
       )
    (cond
     (isEh
      (setq outer "EhLog.info")
      )
     (isXpunit
      (setq outer "_XPSystem.Out.WriteLine")
      )
     (isPt
      (setq outer "XPSystem.Out.WriteLine")
      )
     ((string= (nfn-suffix) "cs")
      (setq outer "Console.WriteLine")
      )
     (t
      (setq outer "System.out.println")
      (if (not suppressDebugIf)
          (setq debugVariable (save-excursion
                                (save-restriction
                                  (widen)
                                  (cond
                                   ;;((or (n-s "\\bm_debug\\b") (n-r "\\bm_debug\\b"))
                                   ;;"m_debug"
                                   ;;)
                                   ;;((or (n-s "\\bDEBUG\\b") (n-r "\\bDEBUG\\b"))
                                   ;;"DEBUG"
                                   ;;)
                                   (t
                                    nil
                                    )
                                   )
                                  )
                                )
                )
        )
      )
     )
    (n-s "^[ \t]*[Cc]$" t)
    (delete-char -1)
    (n-loc-push)
    (if debugVariable
        (insert "if (" debugVariable ")\n{\n"))
    (insert outer "(\"")
    (if fName
        (insert fName ": "))
    (insert "@@\"")
     (if (string= outer "log")
	(progn
	  (if suppressDebugIf
	      (insert ", DBStatic.LOG_ERROR")
	    (insert ", DBStatic.LOG_DEBUG")  ;;INFO
	    )
	  )
      )
    (insert ");")
    (if debugVariable
	(insert "\n}\n"))
    (save-restriction
      (let(
	   (end (point-max))
	   (begin (point-min))
	   )
	(goto-char (point-min))
	(widen)
	(forward-line -1)
	(narrow-to-region (point-min) end)
	(while (not (eobp))
	  (forward-line 1)
	  (indent-according-to-mode)
	  (end-of-line)
	  )
	)
      )
    )
  (n-loc-pop)
  (n-complete-leap)
  )
(defun njava-package()
  (let(
       (p (nfn-fn-to-java-package))
       )
    (end-of-line)
    (insert "ackage " p ";\n")
    )
  )
(defun njava-file-class-name(&optional file)
  (if (not file)
      (setq file (buffer-file-name)))
  (if (string-match "\\(.*\\).java" (file-name-nondirectory file))
      (n--pat 1 (file-name-nondirectory file)))
  )


(defun njava-beginning-of-defun()
                                        ;(n-r "^[][()A-Za-z_0-9 \t\n]+)[\t\n ]*\\(throws [A-Za-z0-9,\t\n ]*\\)?{" t)
                                        ;(n-s "{" t)
                                        ;(forward-char -1)
  (let(
       done
       (start (point))
       (last 1)
       )
    (if (not (n-r "^\\([^ \t].*\\)?\\bclass[ \t]"))
        (setq done t))
    (if (not done)
	(progn
	  (n-s "{" t) ; class
	  (n-s "{" t) ; first method
	  )
      )
    (while (not done)
      (forward-char -1)
      (if (<= (point) start)
	  (progn
	    (setq last (point))
	    (forward-sexp 1)
	    (if (not (n-s "{"))
		(setq done t)
	      )
	    )
	(setq done t)
	)
      )
    (goto-char last)
    )
  )
(defun njava-file-copied-hook(oldFileName newFileName)
  (goto-char (point-min))
  (if (and
       (not (string= (file-name-nondirectory oldFileName) ; i.e., not porting
		     (file-name-nondirectory newFileName) ; across codelines
		     )
	    )
       (n-s "^[ \t]*\\*[ \t]*@author[ \t]+")
       )
      (progn
	(delete-region (point) (progn
				 (end-of-line)
				 (point)
				 )
		       )
	(insert "Nelson Sproul (nelsons@plumtree.com) "
		(n-month-day t t)
		)
	)
    )
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
	(njava-package)
	)
    )
  (goto-char (point-min))
  (let(
       (oldClassName (njava-file-class-name oldFileName))
       (newClassName (njava-file-class-name newFileName))
       )
    (if (and
         oldClassName
         newClassName
         (string-match "\\(.*\\)Test$" oldClassName)
         (string-match "\\(.*\\)Test$" newClassName)
         )
        (progn
          (string-match "\\(.*\\)Test$" oldClassName)
          (setq oldClassName (n--pat 1 oldClassName))
          (string-match "\\(.*\\)Test$" newClassName)
          (setq newClassName (n--pat 1 newClassName))
          )
      )
    (if (and
         oldClassName
         newClassName
         )
        (progn
          (n-trace "oldClassName is %s, newClassName is %s"
                   oldClassName
                   newClassName)
          (goto-char (point-min))
          (replace-regexp (concat "\\b" oldClassName)
                          newClassName
                          )
          )
      )
    )
  )
(defun njava-goto-test()
  (interactive)
  (let(
       otherFile
       (className (njava-file-class-name))
       )
    (setq otherFile        (concat className "Test.java"))
    (if (and
         (not (file-exists-p otherFile))
         (string-match "\\(.*\\)Test$" className)
         )
        (setq otherFile (concat (n--pat 1 className) ".java"))
      )
    (if (file-exists-p otherFile)
        (n-file-find otherFile))
    )
  )
(defun njava-method-pruning---mark-deprecated-functions(deprecation-marker)
  (goto-char (point-min))
  (while (n-s deprecation-marker)
    (nsimple-delete-line)
    (save-restriction
      (n-narrow-to-line)
      (or (n-s "(")
	  (n-s ";" t)
	  )
      (n-r "[ \t]" t)
      (forward-char 1)
      (insert "!")
      )
    )
  )

(defun njava-method-pruning-function(showData showMethods)
  (goto-char (point-min))
  (replace-regexp "'('" "LPN")

  (goto-char (point-min))
  (replace-regexp "')'" "RPN")

  (let(
       (deprecation-marker "__deprecation-marker__()")
       )
    (goto-char (point-min))
    (replace-regexp "@deprecated"
		    (concat "*/ " deprecation-marker " /*")
		    )

    (nc-delete-code)

    (nclass-browser-get-parenthesized-expressions-on-individual-lines)

    (goto-char (point-min))
    (replace-regexp "[ \t]*\n[ \t\n]*(" "(")

    (goto-char (point-min))
    (replace-regexp "[ \t]*(" "(")

    (require 'n-prune-buf)
    (if showData
	(progn
	  (goto-char (point-min))
	  (replace-regexp "[ \t]*=.*" "")
	  )
      (progn
	(n-prune-buf-v "(")
	(n-prune-buf "=")
	)
      )
    (if (not showMethods)
	(n-prune-buf "^[^=\n]*(")
      (njava-method-pruning---mark-deprecated-functions deprecation-marker)
      (nclass-browser-method---mark-functions-by-attribute "abstract" "-")
      )
    (n-prune-buf "[{}]")
    (n-prune-buf "^[ \t]*throws ")
    )
  )
(defun njava-make-makefile()
  (if (file-exists-p "makefile")
      (error "njava-make-makefile: makefile already exists"))
  (let(
       (files (directory-files "."))
       (className (njava-file-class-name))
       )
    (find-file "makefile")
    (insert "all:	include $(java_modules)
	make $(java_modules)
	java " className "

include:
	cd ../include; make

java_modules = \\
")
    (while files
      (if (string-match "\\.class" (car files))
	  (insert "\t" (car files) "\t\\\n"))
      (setq files (cdr files))
      )
    (insert "

.SUFFIXES:
.SUFFIXES: .class .java .html .htm

.java.class :
	javac $<
")
    )
  )
(defun njava-include()
  (interactive)
  (forward-line 0)
  (insert "import ")
  (end-of-line)
  (insert ";\n")
  )
(defun njava-looking-at-include-p()
  (save-excursion
    (forward-line 0)
    (looking-at "^import[ \t]+\\(\\([0-9a-zA-Z_]+\\.?\\)+\\);$")
    )
  )
(defun njava-get-include-name()
  (let(
       (name (if (njava-looking-at-include-p)
                 (n--pat 1)
               "")
             )
       )
    (setq name (nstr-replace-regexp name "\\." "/"))
    (setq name (concat name ".java"))
    )
  )
(defun njava-get-includes-list()
  (let(
       (java-includes (getenv  "CLASSPATH"))
       )
    (or java-includes (error "njava-get-includes-list: "))
    (setq java-includes (nstr-replace-regexp java-includes ";" "/ "))
    (setq java-includes (nstr-replace-regexp java-includes "\\\\" "/"))
    (setq java-includes (concat java-includes "/"))
    (nstr-split java-includes)
    )
  )
(defun njava-enumeration-get-container-name()
  (let(
       (containerName (save-restriction
			(widen)
			(save-excursion
			  (if (n-r "\\(ArrayList\\|Collection\\|List\\|Set\\|Hashtable\\|Vector\\) \\([0-9a-zA-Z_]+\\)")
			      (n--pat 2)
			    ""
			    )
			  )
			)
		      )
       )
    (save-restriction
      (widen)
      (read-string "Loop over which container? " containerName)
      )
    )
  )

(defun njava-enumeration-get-elt-name(containerName)
  (cond
   ((or
     (string-match "^\\(vec\\|ht\\|col\\)\\(.*\\)" containerName)
     )
    (n--pat 2 containerName)
    )
   ((or
     (string-match "^all\\([A-Z].*\\)s$" containerName)
     )
    (nstr-downcase
     (n--pat 1 containerName)
     t
     )
    )
   ((or
     (string-match "^\\(.*\\)s$" containerName)
     (string-match "^\\(.*\\)List$" containerName)
     (string-match "^\\(.*\\)Vector$" containerName)
     (string-match "^\\(.*\\)Set$" containerName)
     )
    (n--pat 1 containerName)
    )
   (t "@@")
   )
  )
(defun njava-enumeration-get-container-name-stem(containerName)
  (setq stem containerName)
  (if (string-match "^.*\\.\\([^\\.]+\\)$" stem)
      (setq stem (n--pat 1 stem)))
  (setq stem (nstr-replace-regexp stem "^m_" "")
	stem (nstr-replace-regexp stem "^\\(col\\|ht\\|vec\\)\\(.\\)" "\\2")
	stem (nstr-replace-regexp stem "\\(IndexedBy.*\\|For.*\\)$" "")
        stem (nstr-make-singular stem)
        )
  )

(defun njava-enumeration()
  (let(
       (containerName (njava-enumeration-get-container-name))
       containerNameStem
       enumerationMethod
       enumerationName
       eltName
       isHash
       (objType	(if (nfn-is-extensity-p)
                    "BOb"
                  "Object"
                  )
                )
       )
    (n-s "^[ \t]*fe$" t)
    (delete-char -2)

    (setq containerNameStem (njava-enumeration-get-container-name-stem containerName)
          isHash		(or (string-match "^\\(m_\\)?ht" containerName)
                                    (string-match "Hash$" containerName)
                                    )
          eltName (njava-enumeration-get-elt-name containerNameStem)
          enumerationName	(concat "en"
					(nstr-capitalize containerNameStem)
					)
          enumerationMethod	(if isHash
				    "keys"
				  "elements"
				  )
          nextEltExpr		(concat enumerationName ".nextElement();")
          )

    (nstr-copy-to-register ?2   nextEltExpr)
    (message "Reg 2 contains: " nextEltExpr)

    (insert "for (Enumeration " enumerationName " = " containerName
            ".@@" enumerationMethod "(); " enumerationName ".hasMoreElements();)\n{\n")
    (if isHash
        (insert "Object " eltName "Key = @@" nextEltExpr "\n"
                "@@" objType " " eltName " = " containerName ".get(" eltName "Key)")
      (insert "@@" objType
              " @@" eltName " = @@;" nextEltExpr)
      )
    (insert ";\n}\n")
    (save-restriction
      (let(
	   (end (point-max))
	   (begin (point-min))
	   )
	(goto-char (point-min))
	(widen)
	(forward-line -1)
	(narrow-to-region (point-min) end)
	(while (not (eobp))
	  (forward-line 1)
	  (indent-according-to-mode)
	  (end-of-line)
	  )
	)
      )
    )
  (goto-char (point-min))
  (n-complete-leap)
  )

(defun njava-get-objType(containerName eltName)
  (cond
   ((string-match "\\(.*\\)s\\(IndexedBy.*\\|For.*\\)?$" containerName)
    (nmenu "choose type" nil nil nil (list
                                      (cons ?1 (nstr-capitalize (n--pat 1 containerName)))
                                      (cons ?o "Object")
                                      )
           )
    )
   (t
    (read-string "elt type: ")
    )
   )
  )

(defun njava-iteration(&optional containerName eltName objType)
  (let(
       containerNameStem
       enumerationMethod
       enumerationName
       isHash
       )
    (if (not containerName)
        (progn
          (setq containerName (njava-enumeration-get-container-name))
          (n-s "^[ \t]*fi$" t)
          (delete-char -2)
          )
      )
    (if (not objType)
        (setq objType (njava-get-objType containerName eltName)))

    (setq containerNameStem (njava-enumeration-get-container-name-stem containerName)
          isHash		(or (string-match "^\\(m_\\)?ht" containerName)
                                    (string-match "Hash$" containerName)
                                    )
          ;;eltName (njava-enumeration-get-elt-name containerNameStem)
          eltName containerNameStem
          enumerationName	(concat "it"
                                        (nstr-capitalize containerName)
                                        )
          enumerationMethod	(if (not isHash)
                                    "iterator"
                                  "new@@Key@@Value@@Iterator"
                                  )
          nextEltExpr		(concat enumerationName ".next();")
          cast		                (if (not (string= "Object" objType))
                                            (concat "(" objType ")")
                                          ""
                                          )
          )
    (nstr-copy-to-register ?2   nextEltExpr)
    (message "Reg 2 contains: " nextEltExpr)

    (insert "for (Iterator " enumerationName " = " containerName
            "." enumerationMethod "(); " enumerationName ".hasNext();)\n{\n")
    (if isHash
        (insert "Object " eltName "Key = @@" nextEltExpr "\n" "@@" objType " " eltName " = "
                case
                containerName ".get(" eltName "Key)"
                )
      (insert objType
              " @@" eltName " = " cast nextEltExpr "\n@@;")
      )
    (insert "\n}\n")
    (save-restriction
      (let(
           (end (point-max))
           (begin (point-min))
           )
        (goto-char (point-min))
        (widen)
        (forward-line -1)
        (narrow-to-region (point-min) end)
        (while (not (eobp))
          (forward-line 1)
          (indent-according-to-mode)
          (end-of-line)
          )
        )
      )
    )
  (goto-char (point-min))
  (n-complete-leap)
  )
(defun njava-doc-comment-format()
  (goto-char (point-min))
  (nsimple-marginalize-region 75 (point-min) (point-max))

  (goto-char (point-min))
  (replace-regexp ",\\([0-9a-zA-Z_]+\\)" "<i>\\1</i>")

  ;; remove line beginning comment markers
  (goto-char (point-min))
  (replace-regexp "^[ \t]*\\*?[ \t]*" "")

  ;; add line beginning comment markers
  (goto-char (point-min))
  (replace-regexp "^" "   * ")
  )
(defun njava-doc-comment( &optional dontRetrieveCommentFromKill)
  (interactive "P")

  (if (bobp)
      (progn
        (insert "\n")
        (forward-line -1)
        )
    (forward-line -1)
    (end-of-line)
    (insert "\n")
    )
  (insert "  /**\n   * ")
  (n-loc-push)
  (n-loc-pop)
  (if (not dontRetrieveCommentFromKill)
      (progn
	(nsimple-delete-line)
	(save-restriction
	  (narrow-to-region (point) (point))
	  (yank)
	  (if (save-excursion
		(forward-char -1)
		(not (looking-at "\n"))
		)
	      (insert "\n")
	    )

	  (goto-char (point-min))
	  (let(
	       (begin (point))
	       )
	    (while (n-s "<pre>")
	      (save-restriction
		(narrow-to-region begin (point))
		(njava-doc-comment-format)
		(goto-char (point-max))
		(widen)
		)
	      (n-s "</pre>" t)
	      (forward-line 1)
	      (setq begin (point))
	      )
	    (narrow-to-region begin (point-max))
	    (njava-doc-comment-format)

            (goto-char (point-max))
            (insert "\n*/\n")
	    )
	  )
	)
    )
  (n-indent-region)
  )
(defun njava-newline()
  (interactive)
  (let(
       (in-javadoc (save-excursion
		     (nsimple-back-to-indentation)
		     (looking-at "\\* ")
		     )
		   )
       )
    (nsimple-newline-and-indent)
    (if in-javadoc
	(insert "* ")
      )
    )
  )

(setq njava-kill-next-routine-marker "!!!!")

(defun njava-kill-next-routine()
  (interactive)
  (n-s "{" t)
  (n-r "(" t)
  (forward-line -1)
  (nsimple-back-to-indentation)
  (if (looking-at "\\*/[ \t]*$")
      (n-r "/\\*" t)
    (forward-line 1)
    )
  (kill-region (point) (progn
			 (insert njava-kill-next-routine-marker)
			 (n-s "{" t)
			 (forward-char -1)
			 (forward-sexp 1)
			 (point)
			 )
	       )
  )

;;(defun njava-yank()
;;  (interactive)
;;  (njava-yank-cmd 'nsimple-yank)
;;  )
;;
;;(defun njava-indented-yank()
;;  (interactive)
;;  (njava-yank-cmd 'n-yank)
;;  )
;;
;;(defun njava-yank-cmd(func)
;;  (if (and
;;       (string-match (concat "^[ \t]*" njava-kill-next-routine-marker)
;;		     (nstr-get-kill)
;;		     )
;;       (not (nsimple-blank-line-p))
;;       )
;;      (or (n-r "^[ \t]*$")
;;	  (progn
;;	    (n-r "^class" t)
;;	    (forward-line 1)
;;	    )
;;	  )
;;    )
;;  (call-interactively func)
;;  (njava-remove-routine-marker)
;;  )

(defun njava-remove-routine-marker()
  (exchange-point-and-mark)
  (if (looking-at njava-kill-next-routine-marker)
      (delete-char (length njava-kill-next-routine-marker))
    )
  (exchange-point-and-mark)
  )

(defun njava-is-eh-test()
  (and (string-match "/test/com/eh/" (buffer-file-name))
       (string-match "^test" (n-defun-name))
       )
  )
(defun njava-add-tracing(traceRoutine &rest unused)
  "add trace statements for the current method"
  (interactive)
  (widen)

  (or (looking-at "^[ \t]*LL?$")
      (error "njava-add-tracing: 1")
      )
  (nsimple-delete-line 1)
  (n-open-line)

  (let(
       nameV	; vector of names corresponding to the arg list
       typeV	; vector of types corresponding to the arg list
       (incomingTraceRoutine (cond
                              ((string= n-env "teacher") "u.inTrace")
                              ((njava-is-eh-test) "EhLog.testBegin")
                              ((string= n-env "eh") "EhLog.info")
                              (t "System.out.println")
                              )
                             )
       (outgoingTraceRoutine (cond
                              ((string= n-env "teacher") "u.outTrace")
                              ((njava-is-eh-test) "EhLog.testEnd")
                              ((string= n-env "eh") "EhLog.info")
                              (t "System.out.println")
                              )
                             )
       (argInfo (save-excursion
                  (njava-beginning-of-defun)
                  (nc-get-args-info)
                  )
                )
       )
    (setq nameV (car argInfo)
	  typeV (cadr argInfo)
	  )
    (end-of-line)
    (insert incomingTraceRoutine "(\""
            (nc-class-name)
            "."
            (n-defun-name)
            "("
            )
    (while nameV
      (insert "\" + ")
      (cond
       ((string= "String" (car typeV))
        (insert "\"\\\"\" + ")
        (insert (car nameV))
        (insert " + \"\\\"\"")
        )
       (t
	(insert (car nameV))
	)
       )
      (setq nameV (cdr nameV)
	    typeV (cdr typeV)
	    )
      (insert " + \"")
      (if nameV
	  (insert ", "))
      )
    (insert ")\");")
    (indent-according-to-mode)
    (if traceRoutine
        (njava-add-tracing-of-return outgoingTraceRoutine))
    )
  )
(defun njava-add-tracing-of-return(outgoingTraceRoutine)
  (let(
       (returnType (njava-get-return-type))
       returnValueName
       )
    (njava-end-of-defun)
    (if (save-excursion
          (forward-word -1)
          (nsimple-back-to-indentation)
          (looking-at "return \\([0-9a-zA-Z_]+\\);")
          )
        (progn
          (forward-word -1)	;; so n-open-line below will put us above the return
          (setq returnValueName (n--pat 1))  ;<<<<<<<<<<<<<<<
          )
      )

    (n-open-line)
    (insert "\n\t\t\t"
            outgoingTraceRoutine
            "(\""
            (nc-class-name)
            "."
            (n-defun-name)
            " returned")
    (if (not returnValueName)
        (insert "\"")
      (insert " \" + " returnValueName)
      (if (not (string= returnType "String"))
          (insert ".toString()"))
      )
    (insert ");")
    )
  )
;;(defun njava-simple-type-p(type)
;;  (or
;;   (string= type "boolean")
;;   (string= type "byte")
;;   (string= type "char")
;;   (string= type "int")
;;   )
;;  )

(defun njava-end-of-defun()
  (njava-beginning-of-defun)
  (forward-sexp 1)
  )
(defun njava-get-return-type()
  (save-excursion
    (njava-beginning-of-defun)
    (n-r "(" t)
    (nsimple-back-to-indentation)
    (while (or
	    (looking-at "abstract")
	    (looking-at "native")
	    (looking-at "private")
	    (looking-at "protected")
	    (looking-at "public")
	    (looking-at "static")
	    (looking-at "synchronized")
	    )
      (forward-word 2)
      (forward-word -1)
      )
    (n-grab-token)
    )
  )

(defun njava-looking-at-top-dcl()
  (looking-at ".*\\b\\(class\\|interface\\)\\b")
  )

(defun njava-looking-at-method-dcl()  ;; assumes (nsimple-back-to-indentation) already
  (and
   (not (njava-looking-at-top-dcl))
   (or
    (looking-at "abstract")
    (looking-at "native")
    (looking-at "private")
    (looking-at "protected")
    (looking-at "public")
    (looking-at "static")
    (looking-at "synchronized ")
    )
   )
  )

(defun njava-indent()
  (save-excursion
    (cond
     ((save-excursion
        (forward-line 0)
        (looking-at ".*\\bclass ")
        )
      (delete-horizontal-space)
      )
     ((save-excursion
        (forward-line 0)
        (looking-at "[ \t]*\\(public\\|protected\\|private\\)\\b")
        )
      (forward-line 0)
      (delete-region (point) (progn
                               (skip-chars-forward " \t")
                               (point)
                               )
                     )
      (insert "\t")
      )
     (t
      (condition-case nil
          (c-indent-line)
        (error nil)	;; fails under XEmacs, I don't know why?
        )
      )
     )
    )
  (if (looking-at "[ \t]*$")
      (end-of-line))
  )

(defun nhtml-teacher-umlauted-plural()
  (let(
       (single	(progn
		  (goto-char (point-min))
		  (if (not (looking-at "Noun('\\([^']+\\)', '"))
		      (error "nhtml-teacher-umlauted-plural: "))
		  (n--pat 1)
		  )
		)
       plural
       )
    (setq plural single
	  plural (nstr-replace-regexp plural "\\(.*\\)\\([aou]\\)\\([^aou]+\\)" "\\1:\\2\\3")
	  )
    (end-of-line)
    (forward-char -1)
    (or (looking-at "-")
	(error "nhtml-teacher-umlauted-plural: expectd the hyphen")
	)
    (delete-char 1)
    (insert plural "e")
    (n-complete-leap)
    )
  )
(defun nhtml-teacher-guess-paradigm-verb(&rest unused)
  (forward-line 0)
  (let(
       (inf (n--pat 1))
       bdy
       paradigmVerb
       )
    (setq paradigmVerb
	  (cond
	   ((eq minor-mode 'French)
	    (or (looking-at "#?EqVerb('\\(se \\|s\\\\?'\\)?\\([^' 2]+\\)2?\\([ ']\\)")
		(error "nhtml-teacher-guess-paradigm-verb: ")
		)
	    (setq inf (n--pat 2))
	    (setq bdy (n--pat 3))
	    (cond
	     ((string-match "uire$" inf) "conduire")
	     ((string-match "cer$" inf) "commencer")
	     ((string-match "venir$" inf) "venir")
	     ((string-match "voir$" inf) "voir")
	     ((string-match "mettre$" inf) "mettre")
	     ((string-match "/e.er$" inf) "r/ep/eter")
	     ((string-match "yer$" inf) "payer")
	     ((string-match "tenir$" inf) "tenir")
	     ((string-match "venir$" inf) "venir")
	     ((string-match "ffrir$" inf) "offrir")
	     ((string-match "ndre$" inf) "prendre")
	     ((string-match "eler$" inf) "appeler")
	     ((string-match "ger$" inf) "manger")
	     ((string-match "er$" inf) "parler")
	     ((string-match "ir$" inf) "finir")
	     )
	    )
	   ((eq minor-mode 'Spanish)
	    (or (looking-at "#?EqVerb('\\([^ ']+r\\)\\(se\\)?2?\\([ ']\\)")
		(error "nhtml-teacher-guess-paradigm-verb: ")
		)
	    (setq inf (n--pat 1))
	    (setq bdy (n--pat 3))
	    (cond
	     ((string-match "cordar$" inf) "acordar")
	     ((string-match "seguir$" inf) "seguir")
	     ((string-match "sentir$" inf) "sentir")
	     ((string-match "volver$" inf) "volver")
	     ((string-match "contar$" inf) "contar")
	     ((string-match "tener$" inf) "tener")
	     ((string-match "venir$" inf) "venir")
	     ((string-match "jugar$" inf) "jugar")
	     ((string-match "re/ir$" inf) "re/ir")
	     ((string-match "cer$" inf) "conocer")
	     ((string-match "cir$" inf) "conducir")
	     ((string-match "ar$" inf) "hablar")
	     ((string-match "er$" inf) "comer")
	     ((string-match "gir$" inf) "dirigir")
	     ((string-match "ir$" inf) "vivir")
	     )
	    )
	   ((eq minor-mode 'German)
	    (cond
	     ((looking-at "#?EqVerb('\\(sich \\)?\\([^ '2]+n\\)2?\\([ ']\\)")
	      (setq inf (n--pat 2))
	      (setq bdy (n--pat 3))
	      )
	     (t
	      (error "nhtml-teacher-guess-paradigm-verb: cannot recognize")
	      )
	     )
	    (cond
	     ((string-match "[^rlaeiou][dmnt]en$" inf) "finden")
	     ((string-match "ssen$" inf) "passen")
	     ((string-match "[szx]en$" inf) "setzen")
	     ((string-match "fehlen$" inf) "befehlen")
	     ((string-match "rechen$" inf) "brechen")
	     ((string-match "ingen$" inf) "singen")
	     ((string-match "en$" inf) "kaufen")
	     ((string-match "ln$" inf) "l:acheln")
	     ((string-match "rn$" inf) ":andern")
	     (t (error "nhtml-teacher-guess-paradigm-verb: %s" inf))
	     )
	    )
	   ((eq minor-mode 'Italian)
	    (cond
	     ((looking-at "#?EqVerb('\\([^ ']+r\\)si2?\\([ ']\\)")
	      (setq inf (concat (n--pat 1) "e"))
	      (setq bdy (n--pat 2))
	      )
	     ((looking-at "#?EqVerb('\\([^' ]+[^2]\\)2?\\([ ']\\)")
	      (setq inf (n--pat 1))
	      (setq bdy (n--pat 2))
	      )
	     (t
	      (error "nhtml-teacher-guess-paradigm-verb: cannot recognize")
	      )
	     )
	    (cond
	     ((string-match "[cg]iare$" inf) "cominciare")
	     ((string-match "[cg]are$" inf) "cercare")
	     ((string-match "ggere$" inf) "leggere")
	     ((string-match "correre$" inf) "correre")
	     ((string-match "porre$" inf) "porre")
	     ((string-match "mettere$" inf) "mettere")
	     ((string-match "endere$" inf) "comprendere")
	     ((string-match "parire$" inf) "comparire")
	     ((string-match "idere$" inf) "ridere")
	     ((string-match "tenere$" inf) "tenere")
	     ((string-match "venire$" inf) "venire")
	     ((string-match "rire$" inf) "aprire")
	     ((string-match "durre$" inf) "produrre")
	     ((string-match "sedere$" inf) "sedere")
	     ((string-match "fare$" inf) "fare")
	     ((string-match "are$" inf) "parlare")
	     ((string-match "ere$" inf) "credere")
	     ((string-match "ire$" inf) "dormire")
	     (t (error "nhtml-teacher-guess-paradigm-verb: %s" inf))
	     )
	    )
	   (t (error "nhtml-teacher-guess-paradigm-verb: "))
	   )
	  )
    (if (not paradigmVerb)
	(if (string= bdy " ")
	    (setq paradigmVerb inf)			;; e.g., 'faire un pas' -> 'faire'
	  (error "nhtml-teacher-guess-paradigm-verb: %s" inf)
	  )
      )
    (end-of-line)
    (insert paradigmVerb)
    )
  )
(defun nhtml-do-uol---is-a-comma-delimited-list-on-a-single-line()
  (save-restriction
    (widen)
    (and (looking-at ".*,")
	 (save-excursion
	   (forward-line 1)
	   (end-of-line)
	   (eobp)
	   )
	 )
    )
  )

(defun nhtml-do-uol---split-line-by-commas()
  (n-loc-push)
  (widen)
  (n-narrow-to-line)
  (forward-line 0)
  (replace-regexp ",[ \t]*" "\n")

  (end-of-line)
  (insert "\n")

  ;; restore the situation ante
  (n-loc-pop)
  (narrow-to-region (progn
		      (forward-line 0)
		      (point)
		      )
		    (progn
		      (n-s "ul" t)
		      (point)
		      )
		    )
  (forward-line 0)
  )

(defun nhtml-do-uol(&optional commaMode)
  (goto-char (point-min))
  (if (nhtml-do-uol---is-a-comma-delimited-list-on-a-single-line)
      (setq commaMode t))
  (if commaMode
      (nhtml-do-uol---split-line-by-commas))

  (let(
       indent
       listTag
       (doubleSpaceMode	(save-restriction
			  (widen)
			  (save-excursion
			    (forward-line 1)
			    (looking-at "^$")
			    )
			  )
			)
       )
    (or (looking-at "\\([ \t]*\\)\\([ou]l\\)")
	(error "nhtml-do-uol: "))
    (setq
     indent (n--pat 1)
     listTag (n--pat 2)
     )


    (nsimple-back-to-indentation)
    (insert "<")
    (forward-char 2)
    (insert ">\n")
    (save-restriction
      (widen)
      (while (not (or
		   (looking-at "[ \t]*$")
		   (looking-at "^[qa]$")
		   (looking-at "^</li>$")
		   )
		  )
	(delete-horizontal-space)
	(insert indent "<li>")
	(end-of-line)
	(forward-line 1)
	(if doubleSpaceMode
	    (forward-line 1))
	(while (and (looking-at "[ \t]")
		    (not (eobp))
		    )
	  (forward-line 1)
	  )
	(insert "</li>\n")
	)
      (insert indent "</" listTag ">\n")
      )
    )
  )

(defun nhtml-teacher-do-OverrideList(&rest unused)
  (cond
   ((looking-at ".*imperative")
    (cond
     ((string= (buffer-name) "Spanish.dat.htm")
      (n-complete-replace "\\('[a-z:`~/#:]*\\)$" "undef, \\1@@', \\1@@', \\1@@', \\1@@mos', \\1@@is', \\1@@d', \\1@@n")
      )
     ((string= (buffer-name) "German.dat.htm")
      ;;$HOME/work/adyn.com/httpdocs/teacher/German_grammar.pmmy $conjugation = $self->GetOverrideList($verb_b, "imperative");
      ;; wir, du, ihr
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "\\1@@', \\1@@', \\1@@'")
      )
     ((string= (buffer-name) "Italian.dat.htm")
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "undef, \\1@@', \\1@@', \\1@@iamo', \\1@@te', \\1@@no")
      )
     ((error "nhtml-teacher-do-OverrideList: 1")
      )
     )
    )
   ((looking-at ".*preterite")
    (cond
     ((string= (buffer-name) "Italian.dat.htm")
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "\\1@@i', \\1@@sti', \\1@@e', \\1@@mmo', \\1@@ste', \\1@@ero")
      )
     ((error "nhtml-teacher-do-OverrideList: 1.1")
      )
     )
    )
   (t
    (cond
     ((string= (buffer-name) "Spanish.dat.htm")
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "\\1@@', \\1@@', undef, \\1@@', \\1@@mos', \\1@@is', undef, \\1@@n")
      )
     ((string= (buffer-name) "German.dat.htm")
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "\\1@@', \\1@@', \\1@@t', \\1@@en', \\1@@t")
      )
     ((string= (buffer-name) "Italian.dat.htm")
      (n-complete-replace "\\('[a-z`~/#:]*\\)$" "\\1@@', \\1@@', \\1@@', \\1@@iamo', \\1@@te', \\1@@no")
      )
     ((error "nhtml-teacher-do-OverrideList: ")
      )
     )
    )
   )
  )
(defun njava-fuckin-hell-just-match-indent-above()
  (let(
       (indent-above (save-excursion
		       (forward-line -1)
		       (nsimple-back-to-indentation)
		       (current-column)
		       )
		     )
       )
    (delete-horizontal-space)
    (indent-to-column indent-above)
    )
  )
(defun njavascript-toggle-bp( &optional arg)
  (interactive "P")

  (let(
       (bp-pre (concat "\n" "alert('" (nfn-prefix) " "))
       (bp-post (concat "')\n"))
       (bp-id-regexp "alert('.* \\([\\.0-9]+\\)')")
       (bp-regexp "alert\\('\\w+ [\\.\\d]+'\\)")
       )
    (if (and arg
             (y-or-n-p "rm all break points in the file? ")
             )
        (n-prune-buf bp-regexp)

      (forward-line 0)
      (let(
           (thisAlertNumber (nsimple-bp-get-id bp-id-regexp))
           )
        (if (njavascript-serverSide)
            (insert "Response.write(\""))

        (insert bp-pre (int-to-string thisAlertNumber) bp-post)

        (if (njavascript-serverSide)
            (insert "\")"))
        (insert "\n")
        (forward-line 1)
        )
      )
    )
  )
(defun nhtml-do-uol-commaMode()
  (or (looking-at ".*,$")
      (error "nhtml-do-uol-commaMode: "))
  (end-of-line)
  (delete-char -1)
  (forward-line 0)
  (nhtml-do-uol t)
  )
;;(defun nhtml-make-link(&optional href)
;;"create link to optional HREF (if null, we just take current kill).
;;Link text is the current region.
;;
;;If
;;1. the current line follows a line which is a bulleted link, AND
;;2. the current line is taken up by the link we are creating now,
;;THEN bullet the current line also.
;;So if the preceding line is
;;<li><a href='http://www.globus.org/security/simple-ca.html'>security</a></li>
;;AND the current line after nhtml-make-link adds <a href...></a> looks like
;;<a href='http://www.globus.org/research/papers.html'>papers</a>
;;THEN assume that bulleting is wanted on the current line, resulting in
;;<li><a href='http://www.globus.org/research/papers.html'>papers</a></li>
;;"
;;(interactive)
;;(if (not href)
;;(setq href (nstr-get-kill)))
;;
;;(save-restriction
;;(call-interactively 'narrow-to-region)
;;(goto-char (point-min))
;;(insert "<a href='" href "'>")
;;
;;(goto-char (point-max))
;;(insert "</a>")
;;)
;;(if (and
;;(save-excursion
;;(nsimple-back-to-indentation)
;;(looking-at "<a href.*</a>$")
;;)
;;(save-excursion
;;(forward-line -1)
;;(nsimple-back-to-indentation)
;;(looking-at "<li><a href.*</a></li>$")
;;)
;;)
;;(progn
;;(nsimple-back-to-indentation)
;;(insert "<li>")
;;(end-of-line)
;;(insert "</li>")
;;)
;;)
;;)

(defun nhtml-init()
  (if (and (looking-at "I$")
           (= 2 (point-max))
           )
      (progn
        (delete-char 1)
        (insert "<html>
<head>
<title>@@</title>
</head>
<body bgcolor=#cccccc>
<font face='arial'>
<h3>@@</h3>

</font>
</body>
</html>
")
        (goto-char (point-min))
        (n-complete-leap)
        )
    )

  )

(defun nhtml-possibly-push-browse( &optional push_and_browse_remotely)
  "if PUSH-AND-BROWSE-REMOTELY then push this file to the appropriate web site and then browse the result __on_that_web_site__.
Otherwise just locally browse this file."
  (interactive "P")




  (setq push_and_browse_remotely t)





  (if (not push_and_browse_remotely)
      (nhtml-browse)
    (require 'nxfer)
    (nxfer-put)
    (n-host-shell-cmd (format "browse_remotely.sh %s"
			      (buffer-file-name)
			      )
		      )
    )
  )
(defun njavascript-write-document()
  (end-of-line)
  (delete-char -1)
  (let(
       serverSide
       )
    (save-restriction
      (widen)
      (insert (if (njavascript-serverSide) "Response" "document")
              ".write(\"\\n\")"
              )
      (forward-char -4)
      )
    )
  )
(defun njavascript-duplicate-client-and-server-code()
  (let(
       (data (buffer-substring-no-properties (point-min) (point-max)))
       (fn (buffer-file-name))
       cfn
       sfn
       )
    (setq cfn (nstr-replace-regexp fn "__shared_cs.js" "__shared_c.js")
          sfn (nstr-replace-regexp fn "__shared_cs.js" "__shared_s.js")
          )
    (find-file sfn)
    (delete-region (point-min) (point-max))
    (insert "<%\n" data "\n%>\n")
    (save-buffer)
    (kill-buffer (current-buffer))

    (find-file cfn)
    (delete-region (point-min) (point-max))
    (insert data)
    (save-buffer)
    (kill-buffer (current-buffer))
    )
  )
(defun nhtml-enhance-timestamps-restore-original-state()
  (goto-char (point-min))
  (replace-regexp (concat marker1 "\\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\)[^<>]*" marker2)
                  (concat marker1 "\\1" marker2)
                  )
  )

(defun nhtml-enhance-timestamps-make-into-floats()
  (goto-char (point-min))
  (replace-regexp (concat marker1 "\\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\)" marker2)
                  (concat marker1 "\\1.0" marker2)
                  )
  )

(defun nhtml-enhance-timestamps-goto-next-data-insertion-pt()
  (n-s marker2 t)
  (n-r marker2 t)
  )

(defun nhtml-enhance-timestamps-region()
  (interactive)

  (let(
       t0
       tn
       n
       tm
       m
       tPercent
       )

    (goto-char (point-min))
    (delete-region (point-min) (progn
                                 (n-s marker1 t)
                                 (forward-line 0)
                                 (point)
                                 )
                   )

    (if (save-excursion
          (goto-char (point-min))
          (n-s marker1)
          )
        (save-excursion
          (nhtml-enhance-timestamps-restore-original-state)
          (nhtml-enhance-timestamps-make-into-floats)

          (setq t0 (progn
                     (goto-char (point-min))
                     (n-s marker1 t)
                     (n-grab-number)
                     )
                tn (progn
                     (goto-char (point-max))
                     (n-r marker2 t)
                     (forward-char -1)
                     (n-grab-number)
                     )
                n (- tn t0)
                )
          (goto-char (point-min))
          (if (> n 0)
              (while (n-s marker1)
                (setq tm (n-grab-number)
                      m  (- tm t0)
                      tPercent (/ (* 100.0 m) n)
                      )
                (nhtml-enhance-timestamps-goto-next-data-insertion-pt)
                (insert (format " %.1f" tPercent) "% ")

                ;; these are timings in milliseconds; convert to seconds, and show where we are in our progress to the end
                (insert (format "(%.1f/%.1f) " (/ m 1000) (/ n 1000)))
                )
            )
          )
      )

    (goto-char (point-min))
    (or (n-s "SummarizeStockCategory")
        (n-s marker1)
        )
    )
  )

(defun nhtml-enhance-timestamps()
  (interactive)

  ;;(delete-region (point-min) (point-max))
  ;;(yank)

  (let(
       (marker1 ">t>i>m>e>s>t>a>m>p>")
       (marker2 "<t<i<m<e<s<t<a<m<p<")
       )
    (goto-char (point-min))
    (if (not (n-s (concat marker2 "test begin")))
        (nhtml-enhance-timestamps-region)
      (save-restriction
        (widen)
        (forward-line 0)
        (while (n-s (concat marker2 "test begin"))

          (narrow-to-region (progn
                              (forward-line 0)
                              (point)
                              )
                            (progn
                              (n-s (concat marker2 "test end") t)
                              (end-of-line)
                              (point)
                              )
                            )
          (nhtml-enhance-timestamps-region)

          (goto-char (point-max))
          )
        )
      )
    (goto-char (point-min))
    (insert (buffer-substring-no-properties (point-min) (point-max)))
    (save-restriction
      (narrow-to-region (point-min) (point))
      (n-prune-buf-v marker1)
      )
    )
  )

(defun njavascript-serverSide()
  (save-restriction
    (widen)
    (save-excursion
      (string= "<%"
               (n-rv (list (list "<%" nil) (list "%>" nil)))
               )
      )
    )
  )

(defun njava-xform()
  (goto-char (point-max))
  (delete-char -1)	; get rid of ;
  (widen)
  (cond
   ((looking-at "suite.addTestSuite(\\([0-9a-zA-Z_]+\\)\\.class);")
    (n-narrow-to-line)
    (goto-char (point-min))
    (replace-regexp "suite.addTestSuite(\\([0-9a-zA-Z_]+\\)\\.class);" "suite.addTest(\\1.suite());")
    )
   ((looking-at "com\\.[0-9a-zA-Z_\\.]+$")
    (save-excursion
      (save-restriction
        (narrow-to-region (point) (progn
                                    (n-s "};" t)
                                    (forward-line 0)
                                    (point)
                                    )
                          )
        (let(
             (fullyQualifiedClassName (buffer-substring-no-properties (progn
                                                          (goto-char (point-min))
                                                          (nsimple-back-to-indentation)
                                                          (point)
                                                          )
                                                        (progn
                                                          (end-of-line)
                                                          (n-r "\\." t)
                                                          (point)
                                                          )
                                                        )
                                      )
             (className (buffer-substring-no-properties
                         (progn
                           (end-of-line)
                           (n-r "\\." t)
                           (point)
                           )
                         (progn
                           (n-r "\\." t)
                           (forward-char 1)
                           (point)
                           )
                         )
                        )
             )

          (goto-char (point-min))
          (replace-regexp ".*\\." "\"")

          (goto-char (point-min))
          (replace-regexp "$" "\",")

          (widen)
          (narrow-to-region (point) (point-min))
          (n-r "{" t)
          (forward-line 1)
          (while (not (eobp))
            (indent-according-to-mode)
            (forward-line 1)
            )
          (widen)

          (if (n-s "new TestSuite(\"@@")
              (progn
                (delete-char -2)
                (insert	fullyQualifiedClassName)
                (n-s "suite.addTest(new @@" t)
                (delete-char -2)
                (insert className)

                (n-host-shell-cmd-visible (format "cd %s; grep -n %s *.java" (file-name-directory (buffer-file-name)) className))
                )
            )
          )
        )
      )
    )
   )
  )
(defun njava-gen-sql-junit()
  (interactive)
  ;;
  ;; test setup
  ;;(n-file-find "$dp/bin/can/sql")
  ;;(goto-char (point-min))
  ;;(n-s "create table swc_test_db.dbo.test_rex" t)
  ;;
  (save-excursion
    (let(
         (colList	  (save-restriction
                            (narrow-to-region (progn
                                                (n-s "(" t)
                                                (skip-chars-forward " \t\n")
                                                (point)
                                                )
                                              (progn
                                                (n-s ");" t)
                                                (forward-char -2)
                                                (point)
                                                )
                                              )
                            (goto-char (point-min))
                            (message "will now generate persistence tests based on this ddl")
                            (read-char)
                            (nsimple-grab-columns 0)
                            )
                          )
         (valList	(save-restriction
                          (n-loc-pop)
                          (n-loc-push)	;; to make this repeatable during dev
                          (n-narrow-to-line)
                          (nsimple-back-to-indentation)
                          (if (looking-at "insert")
                              (n-s "values[ \t]*(" t))
                          (nsimple-grab-comma-list)
                          )
                        )
         testPairs
         val
         col
         valNoQuotes
         (javaOutput	"")
         )
      (setq testPairs (nlist-zip colList valList))
      (while testPairs
        (setq col (caar testPairs)
              val (cdar testPairs)
              valNoQuotes (nstr-replace-regexp val "\"" "")
              testPairs (cdr testPairs)
              javaOutput (concat javaOutput
                                 "assertEquals(\""
                                 col
                                 " == "
                                 (nstr-replace-regexp valNoQuotes "'" "\"")
                                 "\", x.get"
                                 (nstr-capitalize col)
                                 "(), "
                                 val
                                 ");\n"
                                 )
              )
        ;;(nelisp-bp (format "njava-gen-sql-junit: %s/%s" val col) "njava.el" 2256)
        )
      (message "test code in kill")
      (nstr-kill javaOutput)
      )
    )
  )

(defun njava-goto-corresponding-db-table()
  (interactive)
  (nelisp-bp "njava-goto-corresponding-db-table" "njava.el" 2580);;;;;;;;;;;;;;;;;

  (require 'nsql)
  (n-file-find (nsql-get-baseline-query-output-fn (nstr-make-plural (nfn-prefix))))
  )

(defun njava-get-gamersite-name()
  (cond
   ((string-match "GamerSiteTest" (buffer-file-name))
    "gamerSite"
    )
   ((string-match "HibernateGamerSite" (buffer-file-name))
    "this"
    )
   (t
    nil
    )
   )
  )

(defun njava-get-hibernateTemplate-name()
  (let(
       (gamersite (njava-get-gamersite-name))
       )
    (cond
     (gamerSite
      (concat gamerSite ".getHibernateTemplate()")
      )
     (t
      "getHibernateTemplate()"
      )
     )
    )
  )

(defun njava-query-hibernate(iterationRequested)
  (let(
       (objName (nmenu-choose-shortcut-java-object))
       singleVarName
       collectionVarName
       )
    (nsimple-delete-line)
    (n-open-line)
    (setq singleVarName (nstr-uncapitalize objName)
          collectionVarName (nstr-make-plural  singleVarName)
          hibernateTemplate	(njava-get-hibernateTemplate-name)
          )
    (insert "List " collectionVarName " = " hibernateTemplate ".find(\"from " objName "@@ where @@\"@@, @@);\n")
    (if iterationRequested
        (njava-iteration collectionVarName singleVarName objName))
    )
  (goto-char (point-min))
  (n-complete-leap)
  )

(defun njava-assert()
  (nsimple-back-to-indentation)
  (delete-char 1)
  (let(
       (cmd (progn
              (message "=, 1-not-null, n=size ck")
              (read-char)
              )
            )
       )
    (cond
     ((= cmd ?=)
      (insert "assertEquals(\"@@\", @@, @@);\n")
      )
     ((= cmd ?1)
      (insert "assertNotNull(\"@@\", @@);\n")
      )
     ((= cmd ?n)
      (let(
           (containerName (njava-enumeration-get-container-name))
           )
        (insert "assertEquals(\"" containerName ".size()\", @@, " containerName ".size());\n")
        (forward-line -1)
        (n-complete-leap)
        )
      )
     )
    )
  )

(defun njava-get-fields-for-current-class()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (n-s "^\\(public \\)?class " t)
    (forward-line 1)
    (let(
         (classCode (buffer-substring-no-properties (point) (progn
                                                (n-s "^}" t )
                                                (point)
                                                )
                                      )
                    )
         )
      (save-restriction
        (narrow-to-region (point) (point))
        (insert classCode)
        (n-prune-buf-v "^[ \t]*\\(public\\|protected\\|private\\) [^(\n]*$")
        (n-prune-buf "\\bstatic\\b")

        (goto-char (point-min))
        (replace-regexp "=.*" "")

        (goto-char (point-min))
        (replace-regexp "//.*" "")

        (goto-char (point-min))
        (replace-regexp ";" "")

        (goto-char (point-min))
        (replace-regexp "[ \t]*$" "")

        (goto-char (point-min))
        (replace-regexp "[^\n]*[ \t]" "")

        (goto-char (point-min))
        (replace-regexp "[ \t\n]+" " ")

        (prog1
            (nstr-split (buffer-substring-no-properties (point-min) (point-max)))
          (delete-region (point-min) (point-max))
          )
        )
      )
    )
  )
(defun njava-gen-obj-dumper()
  (interactive)
  
  (let(
       (fields (njava-get-fields-for-current-class))
       )
    (while fields
      (n-s "^}" t)
      (n-open-line)
      (insert "public String toString() {\n" "return \"" (nc-class-name) ": \"")
      (while fields
        (insert " + \n\"\\n\\t" (car fields) "=\" + " (car fields))
        (setq fields (cdr fields))
        )
      (insert ";\n}\n")
      (n-indent-region)
      )
    )
  )

(defun njava-gen-name-based-on-type()
  (end-of-line)
  (delete-char -1)
  (forward-word -1)
  (let(
       (type (n-grab-token))
       var
       )
    (setq var (nstr-uncapitalize type))
    (end-of-line)
    (insert var " ")

    (nsimple-register-set type ?0)
    (nsimple-register-set var ?9)
    )
  )

(defun njava-make-ts()
  (end-of-line)
  (delete-char -2)
  (widen)

  (cond
   ((save-excursion
      (forward-line -1)
      (looking-at "[ \t]*public static final int")
      )
    (njava-gen-constant-to-string-func)
    )
   (t
    (njava-gen-obj-dumper)
    )
   )
  )

(defun njava-gen-constant-to-string-func()
  (save-restriction
    (let(
         (consts (save-restriction
                   (narrow-to-region (point)
                                     (progn
                                       (n-r "= 0;" t)
                                       (forward-line 0)
                                       (point)
                                       )
                                     )
                   (if (y-or-n-p "gen constant-to-string-func? ")
                       (buffer-substring-no-properties (point-min) (point-max))
                     nil
                     )
                   )
                 )
         constStem
         val
         )
      (if consts
          (progn
            (goto-char (point-max))
            (n-r "^}" t)
            (n-open-line)
            (narrow-to-region (point) (point))
            (insert consts)

            (goto-char (point-min))
            (replace-regexp "^[ \t]*" "")

            (goto-char (point-min))
            (replace-regexp "public static final int " "")

            (goto-char (point-min))
            (replace-regexp " =.*" "")

            (goto-char (point-min))
            (or (looking-at "\\(.*\\)__")
                (error "njava-gen-constant-to-string-func: expected '__' to be able to determine the const stem")
                )
            (setq constStem (nstr-downcase (n--pat 1)))
            (n-open-line)
            (insert "public static String from" (nstr-capitalize constStem) "ToString(int " constStem ") {\nswitch (" constStem ") {")
            (forward-line 1)
            (narrow-to-region (point) (point-max))

            (goto-char (point-min))
            (while (not (eobp))
              (or (looking-at ".*__\\(.*\\)")
                  (error "njava-gen-constant-to-string-func: expected '__' to be able to determine the val")
                  )
              (setq val (n--pat 1))
              (forward-line 0)
              (insert "case ")
              (end-of-line)
              (insert ": return \"@@" (nstr-downcase val) "\";")
              (forward-line 1)
              )
            (goto-char (point-max))
            (insert "default: assert false;\n}\n return \"unknown " constStem " value \" + " constStem ";\n}\n")
            (widen)
            (n-loc-push)
            (n-indent-region)
            )
        )
      )
    )
  )

(defun njava-gen-set-and-get-methods( &optional lineCnt)
  "generate get and set methods for the identifier whose declaration is under point"
  (interactive)
  (nsimple-back-to-indentation)
  (if (not (or
            (looking-at "public")
            (looking-at "protected")
            (looking-at "private")
            )
           )
      (progn
        (insert "private ")
        (nsimple-back-to-indentation)
        )
    )

  (let(
       (type (progn
               (n-s "[ \t]" t)	; skip past public|protected|private
               (n-s "[^ \t]" t)	; get to the type token
               (n-grab-token)
               )
             )
       (name (progn
               (n-s "[ \t]" t)	; skip past type
               (n-s "[^ \t]" t)	; get to the name token
               (n-grab-token)
               )
             )
       )
    (save-excursion
      (forward-line 1)
      (n-loc-push)
      )
    (if (n-s "{")		; try to go to the first code
        (n-r "(" t)			; retreat to the function declaration
      (goto-char (point-max))
      (n-r "^}" t)
      )
    (n-open-line)
    (insert "public void set" (nstr-capitalize name) "(" type " value) {\n this."  name " = value;\n}\n")
    (insert "public " type " get" (nstr-capitalize name) "() {\n return this."  name ";\n}\n")
    (n-indent-region)
    (message "pushed location one line after data declaration")
    )
  )
(defun njava-gen-get()
  (nsimple-back-to-indentation)
  (let(
       (propName (progn
                   (or (looking-at ".*[ \t]\\([0-9a-zA-Z_]+\\) =")
                       (error "njava-gen-get: ")
                       )
                   (n--pat 1)
                   )
                 )
       )
    (end-of-line)
    (insert "et" (nstr-capitalize propName) "();")
    )
  )
(defun njava-gen-data-dcl()
  (let(
       (type	(progn
                  (forward-line 0)
                  (or (looking-at ".*[ \t]\\([0-9a-zA-Z_]+\\)\\.$")
                      (error "njava-gen-data-dcl: ")
                      )
                  (n--pat 1)
                  )
                )
       )
    (end-of-line)
    (delete-char -1)
    (insert " " (nstr-uncapitalize type))
    )
  )
(defun njava-sb()
  (n-complete-replace	"sb" "StringBuffer sb = new StringBuffer(\"@@\");\n        sb.append(@@)\n;\n")
  (save-restriction
    (save-excursion
      (widen)
      (forward-line -1)
      (if (looking-at "^[ \t]*{[ \t]*$")
          (forward-line -1))
      (if (looking-at "^[ \t]*\\(public\\|private\\|protected\\)\\( static\\)? String ")
          (progn
            (n-s "{" t)
            (forward-char -1)
            (forward-sexp 1)
            (forward-line -1)
            (if (not (looking-at "^[ \t]*return "))
                (progn
                  (end-of-line)
                  (insert "\n        return sb.toString();")
                  )
              )
            )
        )
      )
    )
  )
(defun njava-doc-prep()
  (interactive)

  )
(defun njsp-load-js-from-bean-list()
  (nsimple-back-to-indentation)
  (or (looking-at "cfj \\([a-zA-Z0-9-\\.]*\\) \\([a-zA-Z0-9_]*\\)")
      (error "njsp-load-js-from-bean-list: oops 2")
      )
  (let(
       (beanList	(n--pat 1))
       (jsList		(n--pat 2))
       item
       )
    (delete-region (point) (progn
                             (end-of-line)
                             (point)
                             )
                   )
    (setq item (nstr-make-singular jsList))
    (insert "var " jsList " = null\n")
    (indent-according-to-mode)
    (insert "<c:if test=\"${" beanList "!=null}\">\n")
    (indent-according-to-mode)
    (insert jsList " = new Array()\n")
    (indent-according-to-mode)
    (insert "<c:forEach var=\"" item "\" varStatus=\"j\" items=\"${" beanList "}\">\n")
    (indent-according-to-mode)
    (insert "<c:out escapeXml=\"false\" value=\"" jsList "[${j.index}] = '${" item "@@.name}'\"/>\n")
    (indent-according-to-mode)
    (insert "</c:forEach>\n")
    (indent-according-to-mode)
    (insert "</c:if>\n")
    )
  (n-complete-leap)
  )
(defun njavascript-replace-with-new-var(&rest list-of-alternative-names)
  (setq list-of-alternative-names (car list-of-alternative-names))       ;; rest wraps a list, but we're expecting just one
  (let(
       replacement-var-name
       )
    (save-restriction
      (widen)
      (narrow-to-region (progn
                          (if (n-s "^}")
                              (point)
                            (point-max)
                            )
                          )
                        (progn
                          (if (n-r "^function ")
                              (point)
                            (point-min)
                            )
                          )
                        )
      (while (and list-of-alternative-names (not replacement-var-name))
        (setq replacement-var-name (car list-of-alternative-names)
              list-of-alternative-names (cdr list-of-alternative-names)
              )
        (if (njavascript-var-defined-p replacement-var-name)
            (setq replacement-var-name nil))

        )
      (if (not replacement-var-name)
          (setq replacement-var-name (read-string (format "var name "))))
      )
    replacement-var-name
    )
  )
(defun njavascript-var-defined-p(var-name)
  (save-excursion
    (goto-char (point-min))
    (n-s (concat "var " var-name "\\b"))
    )
  )
(defun nhtml-img()
  (delete-char 1)
  (insert "<br><img src='@@'/><br>")
  (forward-line 0)
  (n-complete-leap)
  (call-interactively 'nfly-find-file-shell)
  )
