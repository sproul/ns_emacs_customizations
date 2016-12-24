(defun
nm-macro-execute_all_pcS_in_shell()
(interactive)
(execute-kbd-macro 
   [?\C-\M-b ?v ?p ?c ?  return ?\M-, ?\M-7 ?^ ?\\ ?$ ?  return return ?\M-, ?\M-. ?\C-w return return ?\C-y return])
)
