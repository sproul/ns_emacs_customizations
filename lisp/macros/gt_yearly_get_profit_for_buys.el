(defun
  nm-macro-gt_yearly_get_profit_for_buys()
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
    (execute-kbd-macro [?\C-s ?  ?\C-x ?a ?g ?\C-e ?\C-x ?a ?g ?\C-r ?  ?\C-b ?\C-x ?a ?m ?\C-e ?\M-i ?\C-x ?a ?d ?/ backspace ?\C-n ?\C-a])
    )
  )
