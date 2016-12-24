(defun
  nm-macro-get_prices_from_within_gt_yearly_output()
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
    (execute-kbd-macro "\C-a\C-f\C-f\M--\C-sOLHC\346\C-f\C-xag\352\C-e\351\C-xad\352\C-u30\C-cn\C-e\C-rOLHC\346\C-s/\C-s\C-s\C-xag\352\351\C-xad\C-n\C-a")
    )
  )
