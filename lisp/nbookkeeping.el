(provide 'nbookkeeping)

(if (not (boundp 'nbookkeeping-mode-map))
    (setq nbookkeeping-mode-map (make-sparse-keymap)))
(define-key nbookkeeping-mode-map "\M-'" 'nbookkeeping-clone)
(defvar nbookkeeping-month 0)
(defvar nbookkeeping-day 0)
(setq nbookkeeping-pushed nil)

(defun nbookkeeping-mode-meat()
  (setq major-mode 'nbookkeeping-mode
        mode-name "nbookkeeping mode"
        )
  (nbookkeeping-goto-current)
  (use-local-map nbookkeeping-mode-map)

  (setq nbookkeeping-month	(car (n-month-day 0))
        nbookkeeping-day	(cdr (n-month-day 0))
        )
  )

(defun nbookkeeping-goto-current()
  (if nbookkeeping-pushed
      (progn
        (setq nbookkeeping-pushed nil)
        (n-loc-pop)
        )
    (n-s "^>")
    (forward-line 0)
    )
  )

(defun nbookkeeping-increment-date()
  (forward-line 0)
  (forward-word 1)
  (forward-char 1)
  (let(
       (day	(1+ (string-to-int (n-grab-token))))
       )
    (kill-word 1)
    (insert (format "%d" day))
    )
  )

(defun nbookkeeping-looking-at-monthly-expense()
  (or
   (looking-at "[0-9]+-[0-9]+/phone/cash/cingular [794-5044]/")
   (looking-at "[0-9]+-[0-9]+/software/visa/tradestation 6/")
   (looking-at "[0-9]+-[0-9]+/Internet access/visa/comcast/")
   (looking-at "[0-9]+-[0-9]+/miscellaneous/check/charge/first bank + trust checking/")
   (looking-at "[0-9]+-[0-9]+/miscellaneous/visa/wsj/")
   )
  )
(defun nbookkeeping-increment-month()
  (insert (int-to-string (1+ (save-restriction
                               (n-narrow-to-line)
                               (forward-line 0)
                               (prog1
                                   (n-grab-number)
                                 (delete-region (point)
                                                (progn
                                                  (n-s "-" t)
                                                  (forward-char -1)
                                                  (point)
                                                  )
                                                )
                                 )
                               )
                             )
                         )
          )
  )
(defun nbookkeeping-get-month-day(line)
  (save-match-data
    (or (string-match "^\\([0-9]+\\)-\\([0-9]+\\)" line)
        (error "nbookkeeping-get-month-day: no date in %s" line)
        )
    (cons (string-to-int (n--pat 1 line))
          (string-to-int (n--pat 2 line))
          )
    )
  )

(defun nbookkeeping-later(line1 line2)
  (let(
       (monthDay1 (nbookkeeping-get-month-day line1))
       (monthDay2 (nbookkeeping-get-month-day line2))
       month1
       day1
       month2
       day2
       )
    (setq
     month1 (car monthDay1)
     day1 (cdr monthDay1)
     month2 (car monthDay2)
     day2 (cdr monthDay2)
     )
    (or
     (> month1 month2)
     (and
      (= month1 month2)
      (> day1 day2)
      )
     )
    )
  )

(defun nbookkeeping-insert-line-in-order(line)
  (save-restriction
    (narrow-to-region (point-min) (progn
                                    (goto-char (point-min))
                                    (n-s "^>" t)
                                    (forward-line 0)
                                    (point)
                                    )
                      )
    (goto-char (point-min))
    (while (and (save-excursion
                  (end-of-line)
                  (not (eobp))
                  )
                (nbookkeeping-later line (n-get-line))
                )
      (forward-line 1)
      )
    (insert line)
    )
  )

(defun nbookkeeping-clone( &optional arg)
  (interactive "p")
  (if (and
       (integerp arg)
       (> arg 1)
       )
      (progn
        (setq nbookkeeping-pushed nil)
        (while (> arg 0)

                                        ;
          ;; if nbookkeeping-pushed isn't nil, then the pushed spot
          ;; becomes the location of the next line-cloning.  This is
          ;; not desirable, so:
          (setq nbookkeeping-pushed nil)

          (save-excursion (nbookkeeping-clone nil))
          (forward-line 1)
          (setq arg (1- arg))
          )
        (nbookkeeping-goto-current)
        )
    ;;(delete-other-windows)
    ;;(nsimple-split-window-vertically)
    ;;(n-other-window)

    (require 'n-2-lines)
    (n-2-lines)

    (forward-line 0)
    (cond
     ((looking-at ".*/miles/")
      (nbookkeeping-increment-date)
      )
     (t
      (save-excursion
        (let(
             (monthly (nbookkeeping-looking-at-monthly-expense))
             line
             )
          (if monthly
              (nbookkeeping-increment-month)
            (nbookkeeping-delete-date)
            (insert (format "%02d-@@%02d" nbookkeeping-month nbookkeeping-day))
            )

          (setq line	(n-get-line t))

          (if monthly
              (nbookkeeping-insert-line-in-order line)
            (nbookkeeping-goto-current)
            (insert line)
            )
          (insert "\n")
          )
        )
      (cond
       ((looking-at ".*/check/")
        (nbookkeeping-check)
        )
       )
      (forward-line 0)
      (n-complete-leap)
      )
     )
    )
  )
(defun nbookkeeping-delete-date()
  (forward-line 0)
  (delete-region (point) (progn
                           (n-s "/" t)
                           (forward-char -1)
                           (point)
                           )
                 )
  )

(defun nbookkeeping-check()
  (n-s "/check/" t)
  (if (and (not (looking-at "charge/"))
           (looking-at "[0-9]+")
           )
      (progn
        (delete-region (point) (progn
                                 (n-s "[^0-9]" t)
                                 (forward-char -1)
                                 (point)
                                 )
                       )
        (insert (format "%d" (nbookkeeping-next-check)))
        )
    )
  (end-of-line)
  (n-r ":" t)
  (forward-char 1)
  (nbookkeeping-push)
  )
(defun nbookkeeping-next-check()
  (save-excursion
    (goto-char (point-max))
    ;; this search will put us on the line of the most recent search
    (n-r "/check/\\([0-9]+\\)/" t)
    (1+ (string-to-int (n--pat 1)))
    )
  )
(defun nbookkeeping-push()
(n-loc-push)
  (setq nbookkeeping-pushed t)
  )
