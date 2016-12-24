(defun
  nm-macro-teacher-format-review-answer()
  (interactive)
  (while (not (eobp))
    (execute-kbd-macro [?\C-s ?^ ?# ?\C-n ?\C-a ?\C-s ?\C-s ?\C-b ?\C-\M-w ?\M-, ?\C-u ?\C-j return return ?\C-\M-w])
    )
  )
