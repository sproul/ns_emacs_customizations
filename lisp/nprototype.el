(provide 'nprototype)
(defconst nprototype-START "PROTO OUTPUT BEGIN")
(defconst nprototype-END   "PROTO OUTPUT END")
(setq nprototype-header-file "/remote/conn3/csi/users/dce/nelson/dp/emacs/script/tupriv.h")

(defun nprototype( &optional arg)
  (interactive "P")
  (if arg
      (nprototype-prompt-for-header-file))

  (if (not (equal (nfn-suffix) "c"))
      (error "only valid for *.c files"))
  (nprototype-init)
  (if n-win
      (call-process "cl" nil t nil "/Zg" (buffer-file-name))
    (apply 'call-process "rsh" nil t nil
           "moose"
           "nrsh"
           default-directory
           "cproto"
           ;;"-Fint main(\n\ta,\n\tb\n\t)"
           "-d"
           "-m"
           "PROTOTYPE"
           "-e"
           "-s"
           "-v"
           "-f4"
           "-D_CPROTO_=1"
           (append (nstr-split (nc-get-includes))
                   (list (buffer-name)
                         )
                   )
           )
    )
  (if n-win
      (nprototype-massage-nt386)
    (nprototype-massage-unix)
    )
  (nprototype-publicize-externs)
  )

(defun nprototype-init-header-file()
  (save-buffer)
  (let(
       (prefix	(progn	; for names in the file, e.g., "tu_run" for turun.c
                  (goto-char (point-min))
                  (if (n-s "[ \t\n]\\([a-z0-9_]+\\)__")
                      (n--pat 1)
                    )
                  )
                )
       (hFn	(nfn-suffix-supplant
                 (file-name-nondirectory (buffer-file-name))
                 "h"
                 )
                )
       )
    (if (not (file-exists-p hFn))
        (setq hFn (concat (file-name-directory (buffer-file-name))
                          "../include/"
                          hFn
                          )
              )
      )
    (if (not (file-exists-p hFn))
        (setq hFn nprototype-header-file))
    
    (if (not (file-exists-p hFn))
        nil
      (find-file hFn)
      (nprototype-init t
                       (string= hFn nprototype-header-file)
                       prefix
                       )
      (nbuf-post-for-kill 'save-buffer)
      (current-buffer)
      )
    )
  )

(defun nprototype-publicize-externs()
  (goto-char (point-min))
  (let(
       (cBuf	(current-buffer))
       (hBuf	(nprototype-init-header-file))
       )
    (if hBuf
        (progn
          (set-buffer cBuf)
          (goto-char (point-min))
          (while (n-sv (list
                        (list "extern ")
                        (list "CS_PUBLIC ")
                        )
                       )
            (nprototype-publicize-externs-move-defn hBuf cBuf)
            )
          (set-buffer hBuf)
          (widen)
          )
      )
    (set-buffer cBuf)
    (widen)
    )
  )

(defun nprototype-publicize-externs-move-defn( hBuf cBuf)
  (let(
       (begin	(progn
                  (forward-line 0)
                  (point)
                  )
                )
       (end	(progn
                  (n-s ";")
                  (forward-char 1)
                  (point)
                  )
                )
       defn
       )
    (setq defn (buffer-substring-no-properties begin end)
          )
    
    (delete-region begin end)
    (set-buffer hBuf)
    (nprototype-remove defn)
    (insert defn)
    (set-buffer cBuf)
    )
  )
(defun nprototype-remove(defn)
  (let(
       (name	(progn
                  (if (string-match "[\* \t]\\([^\* \t]*\\) PROTOTYPE" defn)
                      (n--pat 1 defn))
                  )
                )
       )
    (if name
        (progn
          (goto-char (point-min))
          (if (n-s (concat "[\* \t\n]" name " PROTOTYPE"))
              (delete-region (save-excursion
                               (forward-line 0)
                               (point)
                               )
                             (progn
                               (forward-sexp 1)
                               (forward-line 1)
                               (point)
                               )
                             )
            )
          )
      )
    )
  )

(defun nprototype-init(&optional headerFile shared prefix)
  ;; find the section of the file containing the prototypes.  Narrow to
  ;; that section.
  (widen)
  (goto-char (point-min))
  (cond
   ((n-s nprototype-START)
    (forward-line 1))
   (headerFile
    (if (n-s "^[a-zA-Z_\\* ]*PROTOTYPE((")
        (forward-line 0)
      (goto-char (point-max))
      )
    )
   (t
    (goto-char (point-max))
    (if (not (n-r "^#include"))
        (error "nprototype: don't know where to insert output"))
    (forward-line 1)
    (insert (format "\n/* %s */\n/* %s */\n" nprototype-START nprototype-END))
    (forward-line -1)
    )
   )
  
  ;; now delete the existing prototypes, if appropriate, and then
  ;; narrow the region to the area where the new prototypes will go.
  (if shared
      (progn
        (narrow-to-region (point) (point-max))
        ;; if we know what the prototype names look like,then get rid of them
        (if prefix
            (progn
              (goto-char (point-min))
              (replace-regexp (concat "^[^\n]* \\*?" prefix "_[_a-z0-9]* PROTOTYPE[^;]*;\n")
                              ""
                              )
              )
          )
        )
    (delete-region (point) (progn
                             (if (n-s nprototype-END)
                                 (forward-line 0)
                               (goto-char (point-max))
                               )
                             (point)
                             )
                   )
    (narrow-to-region (point) (point))
    )
  (save-buffer)
  )

(defun nprototype-massage-nt386()
  (goto-char (point-min))
  (delete-region (point)
                 (progn
                   (n-s (concat "^" (n-host-to-canonical (buffer-file-name))) t)
                   (point)
                   )
                 )
  )
(defun nprototype-massage-unix()
  (goto-char (point-min))
  (delete-region (point)(progn
                          (n-s "/\\*" t)
                          (forward-line 0)
                          (point)
                          )
                 )
  (require 'n-prune-buf)
  (n-prune-buf "syntax error")
  (n-prune-buf "^\\+ ")	@@ script output
  (goto-char (point-min))
  (replace-regexp "struct _iobuf" "FILE")
  
  ;; remove data definitions.  We are only interested in function prototypes:
  (goto-char (point-min))
  (replace-regexp "^[^)\n]*;\n" "")
  
  (goto-char (point-min))
  (replace-regexp ", " ",\n\t")
  
  ;; we don't need a prototype for main
  (goto-char (point-min))
  (replace-regexp "^[^;]* main PROTOTYPE[^;]*;" "")
  
  (goto-char (point-min))
  (replace-regexp "PROTOTYPE((" "PROTOTYPE((\n\t")
  
  (goto-char (point-min))
  (replace-regexp "void" "CS_VOID")
  
  (goto-char (point-min))
  (while (n-s "^[ \t]*extern ")
    (if (save-excursion
          (forward-line 0)
          (looking-at "^[ \t]+")
          )
        (progn
          (forward-line 0)
          (delete-region (point) (progn
                                   (n-s "e" t)
                                   (forward-char -1)
                                   (point)
                                   )
                         )
          )
      )
    (if (string-match "CS_INTERNAL" (n-get-line))
        (progn
          (forward-line 0)
          (delete-char 7)
          )
      )
    (forward-line 1)
    )
  )
(defun nprototype-prompt-for-header-file()
  (setq nprototype-header-file (read-string "use: " nprototype-header-file))
  (if (string= nprototype-header-file "")
      (setq nprototype-header-file nil)
    )
)

