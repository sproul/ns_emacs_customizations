(provide 'narithmetic)
(defvar narithmetic-register 0)
(defvar narithmetic-register-is-a-dollar-value-and-we-should-show-trailing-zeroes-for-cents nil)

;; execute an arithmetic operation on the accumulator.
;;
;; categories of commands:
;;
;; 1. Adjust its contents:
;; 	'-'	decrement
;; 	'+'	increment
;; 	'2'	multiply by 2
;; 	'='	set its value to match the prefix arg
;; 	'g'	grab the number under point
;; 	'G'	grab the number under point, add it to the accumulator
;;	'o'	apply (prompt1) Operator w/ (prompt2) arg
;; 2. Insert its value into the buffer according to the specified format:
;; 	'd'	decimal
;; 	'x'	hex
;;
;; 3. Call error if at 0:
;; 	'0'
(defun narithmetic-op(&optional op)
  (interactive)
  (if (not op)
      (setq op (read-string "arithmetic operator: ")))

  (let(
       (arg (n-grab-number))
       p
       )
    (save-restriction
      (narrow-to-region (point) (point))
      (insert (format "(%s %0.5f %s)" op narithmetic-register arg))
      (setq p (point))
      (eval-last-sexp t)
      (delete-region (point-min) p)
      (narithmetic-g)
      (delete-region (point-min) (point-max))
      )
    )
  )
(defun narithmetic-%() (interactive) (narithmetic-op "%"))
(defun narithmetic-*() (interactive) (narithmetic-op "*"))
(defun narithmetic-/() (interactive) (narithmetic-op "/"))
(defun narithmetic-+() (interactive) (narithmetic-op "+"))
(defun narithmetic--() (interactive) (narithmetic-op "-"))
(defun narithmetic+1() (interactive) (setq narithmetic-register (1+ narithmetic-register)))
(defun narithmetic-1() (interactive) (setq narithmetic-register (1- narithmetic-register)))
(defun narithmetic--() (interactive) (narithmetic-op "-"))
;;(defun narithmetic-@@() (interactive) (narithmetic-op "@@"))

(defun narithmetic-eat-space()
  "no-op to swallow bogus spaces produced by voice dictation software"
  (interactive)
  (let(
       (command (read-char))
       )
    (call-interactively (nkeys-binding (concat "\C-xa" (char-to-string command))))
									)
								      )
								    (defun narithmetic-power()
					     (interactive)
  (let(
       (power (n-grab-number))
       (base narithmetic-register)
       )
    (while (> power 1)
      (setq narithmetic-register (* narithmetic-register base)
	    power (1- power)
	    )
      )
    )
  (narithmetic-show)
  )
(defun narithmetic-get-number(n)
  (cond
   ((numberp n) t)
   (n
    (setq n (string-to-number
	     (read-string "Enter number: "))
	  )
    )
   (t
    (setq n (n-grab-number))
    )
   )
  n
  )

(defun narithmetic-increment()
  "add to the arithmetic accumulator"
  (interactive)
  (setq narithmetic-register (1+ narithmetic-register))
  (narithmetic-show)
  )
(defun narithmetic-multiply-by-number( &optional n)
  (interactive "P")
  (setq n (narithmetic-get-number n))
  (setq narithmetic-register (* narithmetic-register n))
  (narithmetic-show)
  )
(defun narithmetic-divide-by-number( &optional n)
  (interactive "P")
  (setq n (narithmetic-get-number n))
  (setq narithmetic-register (/ narithmetic-register (* 1.0 n)))	;; 1.0 makes it floating point
  (narithmetic-show)
  )
(defun narithmetic-minus-number( &optional n)
  (interactive "P")
  (setq n (narithmetic-get-number n))
  (setq narithmetic-register (- narithmetic-register n))
  (narithmetic-show)
  )
(defun narithmetic-add-number(&optional n)
  (interactive "P")
  (setq n (narithmetic-get-number n))
  (setq narithmetic-register (+ narithmetic-register n))
  (narithmetic-show)
  )

(defun narithmetic-2()
  "multiply  the arithmetic accumulator by 2"
  (interactive)
  (setq narithmetic-register (* 2 narithmetic-register))
  (narithmetic-show)
  )
(defun narithmetic-0()
  "prepend zeros to the number under point"
  (interactive)
  (let(
       (token	(n-grab-token))
       )
    (insert (substring "000000000000000" (- (length token) 15)))
    )
  (narithmetic-show)
  )
(defun narithmetic-decrement()
  "subtract one from the arithmetic accumulator"
  (interactive)
  (setq narithmetic-register (1- narithmetic-register))
  (if (= -1 narithmetic-register)
      (error "n-arithmetic: "))
  (narithmetic-show)
  )
(defun narithmetic-=()
  " set the value of the arithmetic accumulator"
  (interactive)
  (setq narithmetic-register arg)
  (narithmetic-show)
  )
(defun narithmetic-toString()
  (let(
       (s	(format "%f" narithmetic-register))
       )
    (setq s (nstr-replace-regexp s "\\([0-9]*\\.[0-9]*[^0]\\)0*$" "\\1")
	  s (nstr-replace-regexp s "\\.0*$" "")
	  )
    s
    )
  )

(defun narithmetic-d()
  "insert the value of the arithmetic accumulator"
  (interactive)
  (insert (narithmetic-toString))
  (narithmetic-show)
  )
(defun narithmetic-g( &optional ignoreCommas)
  "grab the number under point and load it into the arithmetic accumulator"
  (interactive "P")
  (setq narithmetic-register (n-grab-number ignoreCommas))
  (narithmetic-show)
  )
(defun narithmetic-G()
  "grab the number under point and add it to the arithmetic accumulator"
  (interactive)
  (setq narithmetic-register (+ narithmetic-register (n-grab-number)))
  (narithmetic-show)
  )
(defun narithmetic-sum()
  "sum the column under point"
  (interactive)
  (let(
       (col (current-column))
       )
    (setq narithmetic-register 0)
    (while (not (eobp))
      (move-to-column col)
      (setq narithmetic-register (+ narithmetic-register (n-grab-number)))
      ;;(narithmetic-show) (read-char)
      (forward-line 1)
      (end-of-line)
      )
    )
  (narithmetic-show)
  )
(defun narithmetic-sum-last-column()
  "sum the last column on all the lines"
  (interactive)
  (setq narithmetic-register 0)
  (while (not (eobp))
    (end-of-line)
    (setq narithmetic-register (+ narithmetic-register (n-grab-number)))
    ;;(narithmetic-show) (read-char)
    (forward-line 1)
    (end-of-line)
    )
  (narithmetic-show)
  )
(defun narithmetic-x()
  "insert the value of the arithmetic accumulator in hex"
  (interactive)
  (insert (format "0x%x" narithmetic-register))
  (narithmetic-show)
  )
(defun narithmetic-pretty(&optional n)
  (if (not n)
      (setq n narithmetic-register))
  (let(
       (s	(nstr-replace-regexp (format "%f" n)
				     "\\.?0+$"
				     ""
				     )
		)
       )
    (if narithmetic-register-is-a-dollar-value-and-we-should-show-trailing-zeroes-for-cents
	(cond
	 ((not (string-match "\\." s))
	  (setq s (concat s ".00"))
	  )
	 ((string-match "\\.[0-9]$" s)
	  (setq s (concat s "0"))
	  )
	 )
      )
    s
    )
  )

(defun narithmetic-show()
  "display the arithmetic accumulator"
  (interactive)
  (message (narithmetic-pretty))
  narithmetic-register
  )

(defun narithmetic-help()
  (interactive)
  (n-file-find "$dp/emacs/lisp/nkeys.el")
  (goto-char (point-min))
  (n-s "narithmetic" t)
  )
(defun narithmetic-set-arg()
  (interactive)
  (setq prefix-arg narithmetic-register)
  )
