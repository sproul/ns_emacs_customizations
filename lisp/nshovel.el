(provide 'nshovel)
(if (not (boundp 'nshovel-mode-map))
    (progn
      (setq nshovel-mode-map	(make-sparse-keymap))
      )
  )

(defun nshovel-mode-meat()
  (setq major-mode 'nshovel-mode
        mode-name "nshovel"        
        n-grab-file-go-by-lines nil
        nshovel-show-methods nil
        )
  (define-key nshovel-mode-map "\M-c" 'nshovel-send)
  (use-local-map nshovel-mode-map)
  )
(defun nshovel-send()
  ;;(begin end)
  ;;(interactive "r")
  (interactive)
  (let(
       (begin (point-min))
       (end (point-max))
       )
    (save-window-excursion
      (let(
           (data (buffer-substring-no-properties begin end))
           (temporaryFile (n-host-to-canonical (concat n-local-tmp "shovel.macro")))
           )
        (find-file temporaryFile)
        (delete-region (point-min) (point-max))
        (insert data)
        
        (goto-char (point-min))
        (replace-regexp "^" "\"")
        
        (goto-char (point-min))
        (replace-regexp "\n" "\"\nenter\n")
        
        (goto-char (point-min))
        (insert "mtab\n")
        (goto-char (point-max))
                                        ;      (insert "\nmtab\n")
        
        (save-buffer)
        
        (call-process "macro.exe"
                      nil
                      "*Messages*"
                      t
                      "-f"
                      temporaryFile
                      )
        (bury-buffer)
        )
      )
    )
  )


(if (not (boundp 'nshovel-list-mode-map))
    (progn
      (setq nshovel-list-mode-map	(make-sparse-keymap))
      )
  )

(defun nshovel-list-mode-meat()
  (setq major-mode 'nshovel-list-mode
        mode-name "nshovel-list"        
        n-grab-file-go-by-lines nil
        )
  (define-key nshovel-list-mode-map "\M-c" 'nshovel-list-go)
  (use-local-map nshovel-list-mode-map)
  )
(defun nshovel-list-go()
  (interactive)
  (let(
       choice
       )
    (save-some-buffers t)
    (while (setq choice (nmenu "select shovel source" (buffer-file-name)))
      (save-window-excursion
        (find-file choice)
        (nshovel-send)
        )
      )
    )
  )
