(defun
nm-macro-note_another_way_to_say()
(interactive)
;; put the alternative into mc-1
(execute-kbd-macro 
   "\C-e\342\C-cmNAnother phrase to express <i>\365</i> is <i>\C-x1</i>.\C-rEnglish\C-e\C-b\C-b\C-r>\C-f\C-f\C-f\347\357\C-y")
)
