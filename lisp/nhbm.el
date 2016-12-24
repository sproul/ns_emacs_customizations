(provide 'nhbm)
(defvar nhbm-mode-map nil)
(defun nhbm-mode-meat()
  (interactive)
  (nhtml-mode)

  (require 'nsh)
  (if (not nhbm-mode-map)
      (setq nhbm-mode-map (copy-keymap (current-local-map))))
  (define-key nhbm-mode-map "\M-c" 'nhbm-gen-code)
  (define-key nhbm-mode-map "\\" 'n-complete-self-insert-command)
  (use-local-map nhbm-mode-map)

  (setq n-completes
        (append nsimple-shared-completes
                (append
                 (list
                  (list	"^[\t ]*c$"	'n-complete-replace	"c$" "<class name=\"com.eh.@@\" table=\"@@\">\n<id name=\"id\" unsaved-value=\"-1\" type=\"int\">\n<generator class=\"identity\"/>\n</id>\n<property name=\"name\" type=\"string\" length=\"@@30\" not-null=\"true\"/>\n@@\n</class>\n")
                  (list	"^[\t ]*p$"	'n-complete-replace	"p$" "<property name=\"@@name\" type=\"@@string@@int\" length=\"@@30@@255\" not-null=\"@@true\"/>\n@@")

                  )
                 )
                )
        )
  (setq major-mode 'nhbm-mode
        mode-name "nhbm mode"
        )
  )

(defun nhbm-gen-code()
  (interactive)
  (n-host-shell-cmd-visible (format "cd %s; ant hibernate-generate-code"
                                    "$HOME/work/event_horizon/site/db"
                                    default-directory
                                    )
                            )
  )
