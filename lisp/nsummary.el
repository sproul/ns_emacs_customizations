(provide 'nsummary)
(if (not (boundp ' nsummary-mode-map))
    (setq nsummary-mode-map (make-sparse-keymap)))

(defun nsummary-mode-meat()
  (interactive)
  (setq major-mode 'nsummary-mode
        mode-name "nsummary mode"
        )
  (setq n-completes
        (append nsimple-shared-completes
                (list
                 (list	".*[ \t]c$"	'nsummary-comp	"compilation failure")
                 (list	".*[ \t]d$"	'nsummary-comp	"build disk full")
                 (list	".*[ \t]e$"	'nsummary-comp	"executable")
                 (list	".*[ \t]f$"	'nsummary-comp	"file system error")
                 (list	".*[ \t]h$"	'nsummary-comp	"host system environment error")
                 (list	".*[ \t]l$"	'nsummary-comp	"local disk distribution error")
                 (list	".*[ \t]m$"	'nsummary-comp	"makefile error")
                 (list	".*[ \t]s$"	'nsummary-comp	"swap space shortage")
                 (list	".*[ \t]v$"	'nsummary-comp	"verified")
                 )
                )
        )
  (use-local-map nsummary-mode-map)
  (define-key nsummary-mode-map " " 'n-complete-or-space)
  (define-key nsummary-mode-map "\C-c\C-c" 'nsummary-send)
  (define-key nsummary-mode-map "\M-\"" 'nsummary-propagate)
  (define-key nsummary-mode-map "\M-c" 'nsummary-label-all)
  )
(defun nsummary-comp(insertion)
  "add INSERTION..."
  (goto-char (point-max))
                                        ;      (save-restriction
                                        ;        (widen)
                                        ;        (let(
                                        ;             (p1	(point))
                                        ;             (p2	                  (progn
                                        ;                                            (end-of-line)
                                        ;                                            (point)
                                        ;                                            )
                                        ;                                      )
                                        ;             )
                                        ;          (delete-region p1 p2)
                                        ;          )
                                        ;        )
  (delete-char -1)
  (nsimple-copy-region-as-kill (point) (progn
                                         (insert insertion)
                                         (point)                                 
                                         )
                               )
  (setq n-complete-end (point-marker))
  )

(defun nsummary-send()
  (interactive)
  (n-mail-buf "daily status"
              "nelson, laosiri, hannus, venkat, nancyg, pierrec, merritt, holly, mallen, dans, mimi, rhoda, gsmith, jjw"
              )
  )
(defun nsummary-label-all()
  (interactive)
  (setq nsummary-reason (progn
                          (narrow-to-region (point) (point))
                          (yank)
                          (prog1
                              (buffer-substring-no-properties (point-min) (point-max))
                            (delete-region (point-min) (point-max))
                            (widen)
                            )
                          )
        )
  (let(
       (prod	(progn
                  (forward-line 0)
                  (n-grab-token)
                  )
                )
       )
    (save-excursion
      (goto-char (point-min))
      (replace-regexp (concat "^\\(" prod "[^:]+:\\).*")
                      (concat "\\1\t" nsummary-reason)
                      )
      )
    (forward-line 1)
    )
  )
(defun nsummary-propagate( &optional arg)
  (interactive "p")
  (if (integerp arg)
      (while (> arg 0) (nsummary-propagate) (setq arg (1- arg)))
    (delete-region (progn
                     (n-s ": " t)
                     (forward-char -2)
                     (point)
                     )
                   (progn
                     (end-of-line)
                     (point)
                     )
                   )
    (insert (save-excursion
              (n-r ": " t)
              (buffer-substring-no-properties (point)
                                (progn
                                  (end-of-line)
                                  (point)
                                  )
                                )
              )
            )
    (forward-line 1)
    )
)

