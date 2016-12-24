(provide 'n-prune-buf)

(defun n-prune-duplicates()
  "sort the current buffer and remove duplicate lines"
  (interactive)
  (sort-lines nil (point-min) (point-max))
  (goto-char (point-min))
  (let(
       l1 l2
          )
    )
  (while (not (eobp))
    (setq l1 (n-get-line)
          l2 (progn
               (forward-line 1)
               (if (not (eobp))
                   (n-get-line)
                 "")
               )
          )
    (if (string= l1 l2)
        (progn
          (nsimple-delete-line)
          (forward-line -1)
          )
      )
    )
  )

(defun n-prune-buf-duplicate-dirs()
  "In a buffer containing complete file paths, truncate the base names and eliminate duplicates"
  (goto-char (point-min))
  (replace-regexp "/[^/]*$" "")
  (n-prune-duplicates)
  )

(defun n-prune-current-buf-lines-from-other-window()
  (goto-char (point-min))
  (while (not (eobp))
    (setq line (n-get-line))
    (other-window 1)
    (n-prune-buf line)
    (other-window -1)
    (forward-line 1)
    )
  )


(defun n-prune-buf-similar-consecutive-v()
  (let(
       (px	(point-min))
       )
    (goto-char (point-min))
    (while (nre-similar-consecutive)
      (delete-region (progn
		       (forward-line -2)
		       (point)
		       )
		     px
		     )
      (forward-line 2)
      (setq px (point))
      )
    )
  (delete-region (point) (point-max))
  )


(defun n-prune-cmd()
  "selectively prune certain lines from the current buffer"
  (interactive)
  (let(
       (cmd	(progn
                  (message "prune: ^-all-to-left-of-pt, 0-rm token, 2-pairs, a-rbitrary, b-uf-lines-from-other-window, c-sv, C-omponent, d-upes, D-ir dupes, g-rep-l, l-ine, n-umbers, p-roxy, s-imilar consec, t-okenLines, T-oken v, w-weblog junk, v-")
                  (read-char)
                  )
                )
       )

    (cond
     ((= ?^ cmd)
      (n-prune-buf (buffer-substring-no-properties (point) (progn
                                               (forward-line 0)
                                               (point)
                                               )
                                     )
                   )
      )
     ((= ?2 cmd)
      (sort-lines nil (point-min) (point-max))
      (goto-char (point-min))
      (replace-regexp "^\\(.*\\)\n\\1-2\n" "")
      )
     ((= ?a cmd) (call-interactively 'n-prune-buf))
     ((= ?b cmd) (n-prune-current-buf-lines-from-other-window))
     ((= ?c cmd) (n-prune-buf-csv-cols))
     ((= ?C cmd) (n-prune-buf (buffer-substring-no-properties
                               (progn
                                 (n-r "/" t)
                                 (point)
                                 )
                               (progn
                                 (forward-char 1)
                                 (n-s "/" t)
                                 (point)
                                 )
                               )
                              )
      )
     ((= ?d cmd) (call-interactively 'n-prune-duplicates))
     ((= ?D cmd) (n-prune-buf-duplicate-dirs))
     ((= ?g cmd) (n-prune-buf-to-file-names-from-grep-output))
     ((= ?l cmd) (n-prune-buf (concat "^" (n-get-line) "$")))
     ((= ?n cmd) (n-prune-buf-numbers))
     ((= ?p cmd) (nhtml-undo-decoration))
     ((= ?s cmd) (n-prune-buf-similar-consecutive-v))
     ((= ?t cmd) (n-prune-buf   (n-grab-token)))
     ((= ?T cmd) (n-prune-buf-v (n-grab-token)))
     ((= ?0 cmd) (let(
                      (tokenToBeSubtracted (n-grab-token))
                      )
                   (save-excursion
                     (goto-char (point-min))
                     (replace-regexp tokenToBeSubtracted "")
                     )
                   )
      )
     ((= ?v cmd) (call-interactively 'n-prune-buf-v))
     ((= ?w cmd) (n-prune-weblog))
     (t (error "n-prune-cmd: %c (%d) not a recognized command" cmd cmd))
     )
    )
  )
(defun n-prune-buf( pattern &optional linesUp linesDown )
  "n6.el: in the current buffer: for every instance of PATTERN, delete a set
of lines including PATTERN's line and LINES_UP additional lines above
and LINES_DOWN additional lines below"
  (interactive "sEnter pattern to be purged: ")
  (setq pattern (nre-perl-to-emacs pattern))
  (if (not linesUp)
      (setq linesUp 0))
  (if (not linesDown)
      (setq linesDown 0))

  (require 'nre)
  (setq pattern (nstr-trim (nre-perl-to-emacs
                            pattern
                            )
                           )
        )
  (save-excursion
    (goto-char (point-min))
    (while (and
	    (n-s pattern)
	    (not (eobp))
	    )
      (delete-region (progn
                       (forward-line (- linesUp))
                       (forward-line 0)
                       (point)
                       )
                     (progn
                       (forward-line (+ 1 linesUp linesDown))
                       (if (not (eobp))
                           (forward-line 0))
                       (point)
                       )
                     )
      )
    )
  )
(defun n-prune-buf-v( pattern &optional linesUp linesDown )
  "n6.el: delete everything in the current buffer except lines containing
PATTERN, and optionally the region delimited  LINES_UP lines above those lines, and LINES_DOWN
below those lines"
  (interactive "sEnter pattern to be left: ")
  (setq pattern (nre-perl-to-emacs pattern))
  (if (not linesUp)
      (setq linesUp 0))
  (if (not linesDown)
      (setq linesDown 0))
  ;;(setq pattern (nstr-trim pattern))
  (save-excursion
    (goto-char (point-min))
    (let(
         (cur	(point))
         lookAhead
         )
      (while (n-s pattern)
        (setq lookAhead (point))
        (if (< cur (progn
                     (forward-line (- linesUp))	; forward-line goes to line's beginning
                     (point)
                     )
               )
            (progn
              (delete-region cur (point))
              (forward-line linesUp)
              )
          (goto-char lookAhead)
          )
        (forward-line (+ 1 linesDown))
        (setq cur (point))
        )
      (delete-region (point) (point-max))

      )
    )
  )
(defun n-prune-weblog()
  (n-prune-buf "/robots.txt")
  (n-prune-buf "/system32/cmd.exe")
  (n-prune-buf "Invalid method in request")
  (n-prune-buf "client sent HTTP/1.1 request without hostname")
  (n-prune-buf "/default.ida")
  (n-prune-buf "/favicon.ico")
  (n-prune-buf-v "File does not exist")

  (goto-char (point-min))
  (replace-regexp ".*File does not exist: " "")
  (n-prune-duplicates)

  (goto-char (point-min))
  (replace-regexp "/home/httpd/vhosts/adyn.com" "http://www.adyn.com")

  (goto-char (point-min))
  (replace-regexp "adyn.com/httpdocs/" "adyn.com/")

  (goto-char (point-min))
  )
(defun n-prune-buf-numbers()
  (let(
       (powerOf10	(progn
                          (message "prune du output w/ sizes less than this power of 10: ")
                          (- (read-char) ?0)
                          )
                        )
       (pruneRegexp	"^")
       )
    (while (> powerOf10 0)
      (setq powerOf10 (1- powerOf10)
            pruneRegexp (concat pruneRegexp "[0-9]")
            )
      )
    (n-prune-buf-v pruneRegexp)
    )
  )

(defun nsimple-zero-based-char-to-int(c)
  "e.g., a => 0, b => 1, etc."
  (if (string-match "^[a-z]$" c)
      (setq c (- (char-to-int (string-to-char c)) (char-to-int ?a)))
    )
  c
  )


(defun n-prune-buf-csv-cols()
  (let(
       (colsToRetainS     (read-string "which col(s) to retain?" ))
       colsToRetain
       nextColToRetain
       j
       (regexp1 "^")
       (regexp2 "")
       (retainJ 1)
       )
    (setq colsToRetain (nstr-split colsToRetainS))
    (n-prune-buf-csv-cols-clean-csv)
    (goto-char (point-min))
    (setq j 0)
    (while colsToRetain
      (setq nextColToRetain (nsimple-zero-based-char-to-int (car colsToRetain))
            colsToRetain (cdr colsToRetain)
            regexp2 (concat regexp2 "\\" retainJ)
            retainJ (1+ retainJ)
            )
      (while (< j nextColToRetain)
        (setq regexp1 (concat regexp1 "[^,]+,")
              j (1+ j)
              )
        )
      (setq regexp1 (concat regexp1 "\\([^,]+\\)"))
      (if colsToRetain
          (setq regexp1 (concat regexp1 ",")))
      )
    (message "%s => %s" regexp1 regexp2)
    ;;(replace-regexp regexp1 regexp2)
    )
  )

(defun n-prune-buf-csv-cols-clean-csv()
  (goto-char (point-min))
  (while (n-s "\"")
    (narrow-to-region (point) (progn
                                (while (progn
                                         (n-s "\"")
                                         (if (not (looking-at "\""))
                                             nil
                                           (forward-char 1)
                                           t
                                           )
                                         )
                                  )
                                (point)
                                )
                      )
    (goto-char (point-min))
    (replace-regexp "\n" "\\\\n")

    (goto-char (point-min))
    (replace-regexp "," " ")

    (goto-char (point-max))
    (widen)
    (forward-char 1)
    )
  )
(defun n-prune-buf-to-file-names-from-grep-output()
  (goto-char (point-min))
  (replace-regexp ":.*" "")
  (n-prune-duplicates)
  )
