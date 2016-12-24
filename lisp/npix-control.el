(provide 'npix-control)
(if (not (boundp 'npix-control-mode-map))
    (progn
      (setq npix-control-mode-map	(make-sparse-keymap))
      (setq npix-control-hot		nil
            )
      )
  )

(defun npix-control-mode-meat()
  (setq major-mode 'npix-control-mode
        mode-name "npix-control mode"
        )
  (use-local-map npix-control-mode-map)
  (define-key npix-control-mode-map "\M-'" 'npix-control-2-lines)
  (define-key npix-control-mode-map "\M-k" 'npix-control-kill-line)
  )
(defun npix-control-kill-line()
  (interactive)
  (let(
       (jpg	(save-excursion
                  (forward-line 0)
                  (if (looking-at "\\(.*.jpg\\)")
                      (n--pat 1))
                  )
                )
       )
    (if (and jpg
             (y-or-n-p (format "delete %s? " jpg))
             )
        (n-file-delete (concat "1024x768/" jpg))
      )
    (call-interactively 'nsimple-kill-line)
    )
  )
(defun npix-control-2-lines()
  (interactive)
  (save-excursion
    (forward-line 0)
    (looking-at ".*	-	\\([^\n]+\\) \\([0-9]+\\)$")
    )
  ;;(error "n-2-lines: %s/%s" (n--pat 1) (1+ (string-to-int (n--pat 2))))
  (n-complete-leap)
  (insert (n--pat 1) " " (int-to-string (1+ (string-to-int (n--pat 2)))))
  )
