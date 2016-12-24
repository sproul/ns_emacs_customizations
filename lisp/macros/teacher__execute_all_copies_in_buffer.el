(defun
nm-macro-teacher__execute_all_copies_in_buffer()
(interactive)
(execute-kbd-macro 
 [?\M-, ?\M-. ?\M-g ?\M-s ?\M-= ?\C-y ?\C-\M-b ?v ?c ?p ?  return ?\M-, ?\M-7 ?. ?* ?c ?p ?  return ?c ?p ?  return ?\M-. return])
)
