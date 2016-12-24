(provide 'serial)
(setq serial-defining-macro nil)
(setq serial-executing-macro nil)
(setq serial-macros-directory (concat "$HOME/" "work/a3x/macros/"))
(setq serial-current-macro-file (concat serial-macros-directory "current"))

(defun serial-begin-or-end()
  (cond
   (serial-executing-macro
    ;; each macro ends with the serial-begin-or-end key sequence.
    (setq serial-executing-macro nil)
    )
   (serial-defining-macro
    (let(
         (new-macro-file (read-string "enter serial macro's name: "))
         )
      (setq serial-defining-macro nil)
      (if (string= new-macro-file "")
          (message "serial-begin-or-end: forgetting macro")
        (setq new-macro-file (concat serial-macros-directory new-macro-file))
        (rename-file serial-current-macro-file new-macro-file 0)
        (message "stored in %s" new-macro-file)
        )
      )
    )
   ((not serial-defining-macro)
    (message "serial.exe will define a macro")
    (setq serial-defining-macro t)
    )
   )
  )
(defun serial-execute()
  (let(
       (macroName	(nmenu "execute macro" "GUI-macros"))
       macroFile
       )
    (setq macroFile (concat serial-macros-directory macroName))
    (copy-file macroFile serial-current-macro-file t)
    )
  (setq serial-executing-macro t)
  )
