(provide 'nps)
(if (not (boundp 'nps-mode-map))
    (setq nps-mode-map (make-sparse-keymap)))

(setq nps-hit-list nil)
(make-variable-buffer-local 'nps-hit-list)
(setq nps-host nil)
(make-variable-buffer-local 'nps-host)

(defun nps-sentinel(proc msg)
  (switch-to-buffer (process-buffer proc))
  )

(defun nps-start( &optional arg)
  (interactive "P")
  (let(
       (host	(if arg
                    (nmenu "host" "hosts")
                  "pokey"
                  )
                )
       )
    (set-buffer
     (find-file-noselect
      (concat n-local-tmp host ".ps"))
     )
    (erase-buffer)
    (start-process (concat host "-ps") (current-buffer) "rsh" "pokey" "rsh" host "ps"
                   "-uxww")
    (set-process-sentinel (get-buffer-process (current-buffer)) 'nps-sentinel)
    (setq nps-host host)
    )
  )
(defun nps-mode-meat()
  (setq major-mode 'nps-mode
        mode-name "nps mode"
        )
  (use-local-map nps-mode-map)
  (nps-init-hit-list)
  )
(defun nps-kill()
  (interactive)
  (forward-line 0)
  (if (not (looking-at "nelson +\\([0-9]+\\)"))
      (error "nps-kill: "))
  (setq nps-hit-list (cons (n--pat 1) nps-hit-list))
  (forward-line 1)
  )
(defun nps-go()
  (interactive)
  (let(
       (cmd (concat " kill -9 " (mapconcat 'concat nps-hit-list " ")))
       )
    (n-host-shell-local-cmd nps-host cmd)
    (n-host-shell-local-cmd nps-host cmd)
    (n-host-shell-local-cmd nps-host cmd)
    )
  (nps-init-hit-list)
  )
(defun nps-init-hit-list()
  (setq nps-hit-list nil)
  )
(defun nps-undo()
  (interactive)
  (forward-line -1)
  (setq nps-hit-list (cdr nps-hit-list))
  )


;;(defun nps-kill-processes-listed-in-buffer()
;;  (interactive)
;;  (goto-char (point-min))
;;  (if n-win
;;      (progn
;;        (replace-regexp "^[ \t]*[0-9]+[ \t]+\\([0-9]+\\).*" "\\1")
;;        (goto-char (point-min))
;;        (insert "kill -9 ")
;;        (nsimple-join-lines (list "all"))
;;        (n-host-shell-cmd (n-get-line))
;;        (n-host-shell-cmd "r")
;;        (n-host-shell-cmd "r")
;;        (n-host-shell-cmd "p")
;;        )
;;    (replace-regexp "^\\([0-9]+\\).*" "\\1")
;;    (goto-char (point-min))
;;    (insert "kill -9 ")
;;    (nsimple-join-lines (list "all"))
;;    (n-host-shell-cmd (n-get-line))
;;    (n-host-shell-cmd "!!")
;;    (n-host-shell-cmd "!!")
;;    (n-host-shell-cmd "p")
;;    )
;;  )