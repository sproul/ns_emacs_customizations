(provide 'nahk)

(if (not (boundp 'nahk-mode-map))
    (setq nahk-mode-map (make-sparse-keymap)))
(define-key nahk-mode-map "\M-c" 'nahk-compile)

(defun nahk-mode-meat()

  (require 'nsh)
  ;;(nsh-mode)
  (setq major-mode 'nahk-mode
        mode-name "nahk mode"
        )
  (use-local-map nahk-mode-map)
  (if (string= "" (buffer-substring-no-properties (point-min) (point-max)))
      (insert "#@@::
#SingleInstance force
IfWinExist @@
{
	@@
}
")
    )

  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	"^:$"	'n-complete-replace	":"	"::doc@@::\n@@\nreturn\n")
                 (list	"^\\.$"	'n-complete-replace	"\\."	"::,,@@::\nSendInput @@\nreturn\n")
                 (list	"^#$"	'n-complete-replace	"#"	"#@@::\n#SingleInstance force\n@@\nreturn\n")
                 (list	"^[ \t]*k$"	'n-complete-replace	"k"	"SendInput @@{@@}@@")
                 (list	"^[ \t]*s$"	'n-complete-replace	"s"	"SendInput @@{Enter}\n@@")
                 (list	"^[ \t]*S$"	'n-complete-replace	"S"	"Sleep 1000@@")
                 (list	"^[ \t]*w$"	'n-complete-replace	"w"	"WinActivate @@")
                 )
                )
	)
  )
(defun nahk-smells-like-a-send-string()
  ;; am I moving around multiple lines which don't contain ahk directives just yet?
  (save-excursion
    (goto-char (point-min))
    (and
     (n-s "\n")
     (not (n-s "^::"))
     (not (n-s "^#[^ ]"))
     (not (n-s "^Send "))
     (not (n-s "{Enter}"))
     )
    )
  )
(defun nahk-sendify-line()
  (save-restriction
    (n-narrow-to-line)

    (goto-char (point-min))
    (replace-regexp "\\([!#\\+\\^\\{\\}]\\)" "{\\1}")  ;; have to protect ahk special chars w/ curlies
    )

  (forward-line 0)
  (insert "Send ")
  (end-of-line)
  (insert "{Enter}")
  )
(defun nahk-sendify-all()
  (save-excursion
    (goto-char (point-min))
    (while (progn
             (nahk-sendify-line)
             (forward-line 1)
             (not (eobp))
             )
      )
    )
  )

(defun nahk-compile()
  (interactive)
  (save-some-buffers t)
  (n-host-shell-cmd-visible (concat "nohup ahk " (n-host-to-canonical (buffer-file-name)) " > /dev/null &"))
  )
