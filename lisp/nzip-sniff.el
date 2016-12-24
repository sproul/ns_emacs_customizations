(provide 'nzip-sniff)

(defun nzip-sniff-buf(outFile)
  (goto-char (point-min))
  (while (n-s "\\.\\(gar\\|jar\\|war\\|zip\\)")
    (save-window-excursion
      (archive-extract)
      (nzip-sniff-buf outFile)
      )
    )
  (if buffer-read-only
      (toggle-read-only))

  (goto-char (point-max))
  (delete-region (point-max) (progn
                               (forward-line -2)
                               (point)
                               )
                 )

  (goto-char (point-min))
  (delete-region (point) (progn
                           (forward-line 2)
                           (point)
                           )
                 )

  (require 'n-prune-buf)
  (n-prune-buf "^  d")	; remove dirs
  (replace-regexp "^..............................................."
                  (concat (buffer-file-name) "	")
                  )
  (toggle-read-only)

  (append-to-file  (point-min) (point-max) outFile)

  (not-modified)
  ;;(kill-buffer nil)
  )

(defun nzip-sniff-fn(fn outFile)
  (if (file-exists-p fn)
      ;;(condition-case nil
      (progn
        (find-file fn)
        (nzip-sniff-buf outFile)
        )
    )
  )
(nzip-sniff-fn "c:/downloads/grid/globus/server/gars/gram-rips.gar" "/k.z")

(defun nzip-sniff-all()
  (let(
       (nzip-sniff-out-file (n-host-to-canonical "$dp/data/find/zip.list"))
       )
    (if (file-exists-p nzip-sniff-out-file)
        (delete-file nzip-sniff-out-file))
    (switch-to-buffer (get-buffer-create "nzip-sniff.tmp"))
    (require 'nshell)
    (call-process-region (point-min) (point-max) (nshell-get-explicit-shell-file-name) t t nil "list_all_zip_files_in_system.sh")
    (goto-char (point-min))
    (while (not (eobp))
      (nzip-sniff-fn (n-get-line) nzip-sniff-out-file)
      (forward-line 1)
      )
 					;  (kill-buffer nil)
    )
  )
(defun nzip-sniff-ls()
  (let(
       (rr	"")
       )
    (if (> (point-max) (point-min))
	(progn
	  (toggle-read-only)

	  (goto-char (point-max))
	  (delete-region (point-max) (progn
				       (forward-line -2)
				       (point)
				       )
			 )

	  (goto-char (point-min))
	  (delete-region (point) (progn
				   (forward-line 2)
				   (point)
				   )
			 )
	  (setq rr (buffer-substring-no-properties   (point-min) (point-max)))

	  (not-modified)
	  (kill-buffer nil)
	  )
      )
    (find-file "c:/__nz__")
    (delete-region (point-min) (point-max))
    (insert rr)
    (save-buffer)

    (find-file "c:/__nz__.done")
    (insert "done")
    (save-buffer)

    (save-buffers-kill-emacs t)
    )
  )
