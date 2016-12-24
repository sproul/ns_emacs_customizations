(provide 'ngnus)
(defun ngnus()
  (interactive)
  (if (get-buffer "*Summary*")
      (switch-to-buffer (get-buffer "*Newsgroup*"))
    (gnus nil)
    )
  )
(defun ngnus-summary-save()
  (interactive)
  (save-window-excursion
    (set-buffer "*Article*")
    (append-to-file (point-min)
                    (point-max)
                    (concat gnus-article-save-directory gnus-newsgroup-name))
    )
  )
(setq gnus-show-threads t
      gnus-default-nntp-server "sybase"
      gnus-thread-hide-subject nil
      gnus-thread-ignore-subject t
      gnus-thread-indent-level 1
      gnus-default-article-saver	'ngnus-summary-save
      gnus-article-save-directory	n-local-mail
      )

