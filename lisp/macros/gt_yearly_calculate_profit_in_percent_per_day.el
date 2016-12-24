(defun
  nm-macro-gt_yearly_calculate_profit_in_percent_per_day()
  (interactive)
  (goto-char (point-min))
  (while (not (eobp))
    (execute-kbd-macro
     [?\C-s ?  ?\C-x ?a ?g ?\C-e ?/ ?\C-x ?a ?d ?\C-r ?/ ?\M-b ?\C-x ?a ?g ?\C-e ?\C-x ?a ?? ?\M-i ?1 ?0 ?\C-x ?a ?* ?1 ?0 return ?\C-_ backspace backspace ?\C-x ?a ?d ?\C-n ?\C-a])
    )
  )
