(provide 'nant)
(defvar nant-mode-map nil)
(defun nant-mode-meat()
  (interactive)
  (nhtml-mode)
  (setq n-completes
        (append
         nsimple-shared-completes
         (list
          (list	"^[\t ]*c$"	'n-complete-replace	"c$" "<echo message=\"@@\" level=\"verbose\"/>\n@@")
          )
         )
        )
  ;;(setq tab-width 4)

  (setq case-fold-search nil)

  (if (and (equal (point-min) (point-max))
           (not (string-match "^*" (buffer-name)))
           )
      (insert "nant-mode-meat beginning\n")
    )
  (setq major-mode 'nant-mode
        mode-name "nant mode"
        )
  (setq ntags-find-current-token-class-context 'nant-find-current-token-class-context)
  (require 'nsh)
  (if (not nant-mode-map)
      (setq nant-mode-map (copy-keymap (current-local-map))))
  (define-key nant-mode-map "\C-x\C-e" 'nsh-evaluate-last-expression)
  (define-key nant-mode-map "\C-x " 'nant-toggle-bp)
  (define-key nant-mode-map "\M-c" 'nant-run-target-or-just-call-midnight-compile)
  ;;(define-key nant-mode-map "\M-w" 'nant-tags-find)
  (define-key nant-mode-map "\\" 'n-complete-self-insert-command)
  (use-local-map nant-mode-map)

  (nstr-eval-and-return-obj
   (nstr-call-process nil nil "perl" "-w" (n-host-to-canonical "$NELSON_BIN/perl/ant_extract_properties.pl") (buffer-file-name))
   )
  )

(defun nant-tags-find--goto-called-ant-file()
  (forward-line 0)
  (let(
       (dir (if (n-s "[ \t]dir[ \t]*=[ \t]*\"\\([^\"]+\\)\"")
                (n--pat 1)
              "."
              )
            )
       fn
       )
    (forward-line 0)
    (if (n-s "[ \t\n]+antfile[ \t]*=[ \t]*\"\\([^\"]*\\)\"")
        (setq fn (concat dir "/" (n--pat 1)))
      (setq fn (concat dir "/" "build.xml"))
      )
    
    (n-file-find fn)
    )
  )

(defun nant-tags-find(&optional token)
  (interactive)
  (cond
   ((or
     (eq last-command 'ntags-find-where)
     (eq last-command 'nant-tags-find)
     )
    (call-interactively 'ntags-find-where)
    )
   (t
    (if (not token)
        (setq token (n-grab-token)))

    (n-loc-push)

    (if (save-excursion
          (forward-line 0)
          (looking-at (concat ".*<ant[ \t\n]+.*[ \t\n]+target[ \t]*=[ \t]*\"" token "\""))
          )
        (nant-tags-find--goto-called-ant-file)
      )

    (let(
         (src (nsimple-get-src-of-var token))
         )
      (if (and src
               (not (string= (buffer-file-name) src))
               )
          (n-file-find src)
        )
      )

    ;; look in the current file
    (goto-char (point-min))
    (cond
     ((n-s (concat "<property[ \t]+name[ \t]*=[ \t]*\"" token "\""))
      t
      )
     ((n-s (concat "<target[ \t\n]+name[ \t]*=[ \t]*\"" token "\""))
      t
      )
     ((n-s (concat "<macrodef[ \t\n]+name[ \t]*=[ \t]*\"" token "\""))
      t
      )
     ((n-s (concat "<presetdef[ \t\n]+name[ \t]*=[ \t]*\"" token "\""))
      t
      )
     ((n-s (concat "<loadfile[ \t\n]+property[ \t]*=[ \t]*\"" token "\""))
      t
      )
     ((n-s (concat "<condition[ \t\n]+property[ \t]*=[ \t]*\"" token "\""))
      (n-r "\"" t)
      (n-r "\"" t)
      (forward-char 1)
      t
      )
     (t
      (n-loc-pop)
      ;;(error "nant-tags-find: no findy")

      (call-interactively 'ntags-find-where)
      )
     )
    (forward-char -1)
    )
   )
  )

(defun nant-run-target-or-just-call-midnight-compile()
  (interactive)
  (save-excursion
    (let(
         (token (n-grab-token))
         (antFile (file-name-nondirectory (buffer-file-name)))
         )
      (save-some-buffers t)
      (if (progn
            (nsimple-back-to-indentation)
            (looking-at (concat "<target[ \t]+name=\"" token "\""))
            )
          (n-host-shell-cmd-visible (format "cd %s; ant %s%s"
                                            default-directory
                                            token
                                            (if (string= "build.xml" antFile)
                                                ""
                                              (concat " -f " antFile)
                                              )
                                            )
                                    )
        (require 'nmidnight)
        (call-interactively 'nmidnight-compile)
        )
      )
    )
  )

(defun nant-find-current-token-class-context()
  (save-excursion
    (skip-chars-backward "a-zA-Z0-9_")
    (if (and (not (bobp))
             (progn
               (forward-char -1)
               (looking-at ":")
               )
             (not (bobp))
             )
        (progn
          (forward-char -1)
          (n-grab-token)
          )
      )
    )
  )
(defun nant-toggle-bp( &optional arg)
  (interactive "P")

  (cond
   (arg
    (if (y-or-n-p "rm all bp's in current file? ")
	(save-excursion
	  (goto-char (point-min))
	  (while (n-s "<!--BP-->")
	    (nsimple-delete-line)
	    )
	  )
      )
    )
   (t
    (forward-line 0)
    (insert "<echoproperties destfile=\"${env.TMP}/ant-bp.dat\"/><exec executable=\"sh\"><arg line=\"${env.dp}/bin/pause ${env.TMP}/ant-bp.dat "
            (n-host-to-canonical (buffer-file-name))
            ":"
            (int-to-string (n-what-line))
            "\"/></exec><!--BP-->\n")
    )
   )
  )
