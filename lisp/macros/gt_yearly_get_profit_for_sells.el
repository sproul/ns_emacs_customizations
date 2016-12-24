(defun
  nm-macro-gt_yearly_get_profit_for_sells()
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
    (execute-kbd-macro "\C-s \C-xag\C-e\C-xam\351\C-xad\C-n\C-a")
    )
  )
