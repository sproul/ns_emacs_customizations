(provide 'n-local)

(setq n-local-user (nsimple-getenv "USER" "nelsons"))
(if (not (getenv "USER"))
    (setenv "USER" n-local-user))

(setq n-local-world-name (nstr-downcase (system-name)))
(if (or
     (eq window-system nil)
     (eq window-system 'x)
     (eq window-system 'mswindows)
     )
    (if (not (string-match "^o.$" n-local-world-name))
        (setq n-local-world-name "x")
      )
  )

(setq n-local-situation (nsimple-getenv "SITUATION" "default"))
(n-load "n-database")

(defun n-host-local-PC-drive(drive) t) ; dft to compile
                                        ;(setq ntags-enabled nil)
(setq n-host-local-PC-last-drive ?c
      n-host-local-PC-last-drive (string-to-char (n-database-get "local-PC-last-drive" nil nil "d"))
      )

(setq n-local-calm_default_view "conncougar_nelson_vu")
;;(n-host-file-set n-local-calm_root
;;                 (cond
;;                  ((n-host-supports-clearcase (system-name)) "/view/")
;;                  (n-win		"//siberia/view/")
;;                  (t 			"/ccview/")
;;                  )
;;                 )
(if (n-file-writable-p "$NELSON_HOME/tmp")
    (n-host-file-set n-local-tmp "$NELSON_HOME/tmp/")
  (n-host-file-set n-local-tmp "/tmp/")
  )
(n-file-possibly-create n-local-tmp t)
(n-host-file-set n-local-shell-out "~/tmp/ktd.out.x457")
(n-host-file-set n-local-man	 (concat "$NELSON_HOME/" "man/"))
(n-host-file-set n-local-mail	 "~/mail/")

(setq n-local-msvc-include (concat (nsimple-getenv "msvc_drive")
                                   "/"
                                   (nsimple-getenv "msvc_dir")
                                   "/include/"
                                   )
      )
(n-host-file-set n-local-any-user-tree "^\\([^\n \t]*/\\)users/\\([^/]+\\)/\\([^/]+\\)/\\(.*\\)")
