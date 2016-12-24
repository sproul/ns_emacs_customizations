(provide 'nmini)
(defun nmini-unmaximize(cleanBuffer)
  (nmini-check-buffer "nmini-unmaximize")
  (if cleanBuffer
      (erase-buffer))
  (let(
       (height (window-height))
       )
    (shrink-window (- height 1))
    )
  )
(defun nmini-maximize()
  (nmini-check-buffer "nmini-maximize")
  ;;
  ;; impossibly large value forces the window to take up the whole screen:
  (enlarge-window 500)
  )
(defun nmini-p()
  (eq (selected-window) (minibuffer-window))
  )
(defun nmini-check-buffer(command)
  (or (string-match "Minibuf-" (buffer-name))
      (n-trace "%s: usually valid only in a minibuffer (executing in %s)" 
               command
               (buffer-name))
      )
  )