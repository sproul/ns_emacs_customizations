(provide 'n-font)
(setq n-fonts-index 0)

(if n-win
    (setq n-fonts [ "big" "small" ])
  (setq n-fonts [
                                        ; run xlsfonts for a list of avail fonts
                 "-schumacher-clean-bold-r-normal--8-80-75-75-c-80-iso8859-1"
                 "-schumacher-clean-bold-r-normal--10-100-75-75-c-60-iso8859-1"
                                        ;               "-schumacher-clean-bold-r-normal--10-100-75-75-c-80-iso8859-1"
                                        ;               "-schumacher-clean-bold-r-normal--12-120-75-75-c-60-iso8859-1"
                                        ;               "-schumacher-clean-bold-r-normal--12-120-75-75-c-80-iso8859-1"
                                        ;               "-misc-fixed-bold-r-normal--13-100-100-100-c-70-iso8859-1"
                                        ;               "6x13"
                                        ;               "7x13"
                                        ;               "7x13bold"
                                        ;               "8x13"
                                        ;               "8x13bold"
                                        ;               "-misc-fixed-medium-r-normal--13-100-100-100-c-70-iso8859-1"
                                        ;               "-misc-fixed-medium-r-normal--13-100-100-100-c-80-iso8859-1"
                                        ;               "-misc-fixed-medium-r-normal--13-120-75-75-c-70-iso8859-1"
                                        ;               "-adobe-courier-bold-r-normal--14-100-100-100-m-90-iso8859-1"
                                        ;               "7x14"
                                        ;               "-dec-terminal-bold-r-normal--14-140-75-75-c-80-iso8859-1"
                                        ;               "-misc-fixed-bold-r-normal--15-120-100-100-c-90-iso8859-1"
                                        ;               "-schumacher-clean-bold-r-normal--13-130-75-75-c-80-iso8859-1"
                                        ;               "lucidasanstypewriter-14"
                                        ;               "lucidasanstypewriter-bold-14"
                                        ;               "-schumacher-clean-bold-r-normal--14-140-75-75-c-80-iso8859-1"
                                        ;               "9x15"
                                        ;               "9x15bold"
                                        ;               "-schumacher-clean-bold-r-normal--15-150-75-75-c-90-iso8859-1"
                                        ;               "-schumacher-clean-bold-r-normal--16-160-75-75-c-80-iso8859-1"
                                        ;               "8x16"
                                        ;               "chaos-bold"
                                        ;               "chaos-norm"
                 "10x20"
                 "12x24"
                 ]
        )
  )

(defun n-font-cycle()
  "cycle through some selected fonts"
  (interactive)
  (if (string= (buffer-name) "*merge*")
      (emerge-fast-mode)	; see comment in nmerge.el (search for "doesn't work")
    (setq n-fonts-index (1+ n-fonts-index))
    (if (= n-fonts-index (length n-fonts))
        (setq n-fonts-index 0))

    (require 'nshell)
    (if n-win
        (call-process (nshell-get-explicit-shell-file-name) nil (get-buffer-create "*Messages*") nil "-x" "font_cycle" (elt n-fonts n-fonts-index))
      (set-face-font 'default (elt n-fonts n-fonts-index))
      (redraw-display)
      )
    (message "Font set to %s (%d/%d)"
             (elt n-fonts n-fonts-index)
             n-fonts-index
             (1- (length n-fonts))
             )
    )
  )
                                        ;
;; (set-face-font 'default "9x15bold")
;; (set-face-font 'default "9x15")
;; (set-face-font 'default "8x16")
;; (set-face-font 'default "7x14")
;; (set-face-font 'default "6x13")
;; (n-font-cycle)
