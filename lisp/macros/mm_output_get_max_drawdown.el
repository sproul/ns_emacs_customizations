(defun
nm-macro-mm_output_get_max_drawdown()
(interactive)
(execute-kbd-macro 
   [?\M-, ?\M-. ?\M-g ?\M-x ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?\M-, ?k return ?\M-, ?\C-y ?\M-. ?\C-w ?\C-\M-b ?v ?: ?- ?[ ?0 ?- ?9 ?] ?[ ?0 ?- ?9 ?] return ?\M-, ?\M-7 ?. ?* ?- return ?- return ?\M-, ?\M-7 ?\\ ?( ?. ?* return return ?\C-\M-b ?d ?\M-, ?\M-1 ?\M-.])
)
