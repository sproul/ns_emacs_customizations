(provide 'nst)
(require 'narithmetic)

(setq nst-cumulative-change 0)

(defun nst-mode-meat()
  (interactive)

  )
(defun nst-goto-tmp()
  (n-file-find "$tmp/st.import.dat")
  )
(defun nst-bury-tmp()
  (bury-buffer (get-buffer "st.import.dat"))
  )

(defun nst-get-futurePriceMultiplier(security)
  (cond
   ((string-match "^ES" security) 125)		; S&P500
   ((string-match "^.\\(AH\\|AM\\)" security) 100000)	; aud
   ((string-match "^.EH" security) 100000)	; E
   ((string-match "^.JH" security) 12500000)	; yen
   (error "nst-get-futurePriceMultiplier: unknown future " security)
   )
  )

(defun nst-identify-broker-of-import-trade-data()
  (delete-horizontal-space)
  (let(
       (broker (cond
                ((looking-at ".*;;$")
                 (cons "ib" "trade-data")
                 )
                ((looking-at "USD")
                 (cons "ib" "holdings-data")
                 )
                ((looking-at ".* Executed: ")
                 (cons "amtd" "trade-data")
                 )
                ((looking-at " *Portfolio")
                 (cons "amtd" "holdings-data")
                 )
                ((save-excursion (n-s "Balances <https://www2.harrisdirect.com"))
                 (cons "harris" "holdings-data")
                 )
                ((looking-at "[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]")
                 (cons "harris" "trade-data")
                 )
                (t (error "nst-identify-broker-of-import-trade-data: ")
                   )
                )
               )
       )
    ;;(if (not (y-or-n-p (format "Looks like it's from %s? " broker)))
    ;;(error "nst-identify-broker-of-import-trade-data: "))
    
    (message "Got %s" broker)
    (sleep-for 1)
    broker
    )
  )
(defun nst-goto-open-position(security)
  (let(
       (re  (concat " \\b" security ":.*@@"))
       )
    (if (save-excursion
	  (goto-char (point-max))
	  (n-r re)
	  )
	(progn
	  (goto-char (point-max))
	  (n-r re)
	  (forward-line 0)
	  t
	  )
      nil
      )
    )
  )

(defun nst-log-opening-xaction(cashChange securityCnt security sellPrice sellDate buyDate buyPrice broker tradeOverhead)
  (insert securityCnt
          " "
          security
          ":"
          buyPrice
          "/"
          sellPrice)

  ;; sample line w/ columns:
  ;; 1 NDX Sep 875 Puts:53.2/43.5            07-25-02        07-29-02        4327.51         5308.82   amtd	 3038.11
  ;; ........................................40              56              72              88        98      106
  ;; 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567

  (just-one-space)
  (indent-to-column 40)
  (insert buyDate)
  (indent-to-column 56)
  (insert sellDate)
  (indent-to-column 72)
  (insert (if (string= sellPrice "@@")
              "@@"
            cashChange
            ))
  (indent-to-column 88)
  (insert (if (string= buyPrice"@@")
              "@@"
            cashChange
            )
          )
  (indent-to-column 98)
  (insert broker)
  ;;(insert ".slippage=")
  (n-loc-push)
  )

(defun nst-looking-at-short-sale()
  (looking-at "[0-9]+ [A-Z]+:@@")
  )

(defun nst-calculate-total-price(securityCnt sellPrice buyPrice tradeOverhead)
  (if (string= buyPrice "@@")
      (setq buyPrice nil))
  (if (string= sellPrice "@@")
      (setq sellPrice nil))

  (format "%.2f"
	  (string-to-number
	   (nstr-eval "(%s (* %s %s) %d)"
		      (if sellPrice
			  "-"		; subtract tradeOverhead from the proceeds
			"+"		; add tradeOverhead to the price
			)
		      securityCnt
		      (if sellPrice
			  sellPrice
			buyPrice
			)
		      tradeOverhead
		      )
	   )
	  )
  )
(defun nst-update-running-realized-profit-total()
  (forward-line -1)
  (end-of-line)
  (narithmetic-g)	; got old total
  (forward-line 1)
  (end-of-line)

  ;; delete the profit total that's there, if a previous run of this routine was executed
  (delete-region (point) (progn
			   (n-r "\\(amtd\\|harris\\|ib\\)" t)
			   (forward-word 1)
			   (point)
			   )
		 )
  (n-r "[0-9]" t)       ; get to the buyPrice
  (narithmetic--)

  (n-r "[ \t]" t)       ; get past the buyPrice
  (n-r "[0-9]" t)       ; get to the sellPrice
  (narithmetic-+)

  (end-of-line)
  (indent-to-column 105)
  (narithmetic-d)
  )

(defun nst-move-line-to-closed-xactions-above()
  (save-excursion
    (let(
	 (line (n-get-line))
	 )
      (nsimple-delete-line)
      (goto-char (point-min))
      (n-s "^$" t)	; first blank line separates modern era from olden tymes
      (forward-line 1)
      (n-s "^$" t)	; 2nd   blank line separates open from the closed positions
      (insert line "\n")

      (forward-line -1)
      (nst-update-running-realized-profit-total)
      )
    )
  )
(defun nst-log-closing-xaction-with-open-xaction(cashChange securityCnt security sellPrice sellDate buyDate buyPrice broker tradeOverhead)
  (if (nst-looking-at-short-sale)
      (progn
	(n-complete-leap)
	(insert buyPrice)

        (n-s " " t)
        (just-one-space)
        (indent-to-column 40)

        (n-complete-leap)
        (insert buyDate)

        (just-one-space)
        (indent-to-column 56)

        (n-complete-leap)
        (insert cashChange)
        (just-one-space)
        (indent-to-column 98)
        )
    (n-complete-leap)
    (insert sellPrice)

    (just-one-space)
    (indent-to-column 40)

    (n-complete-leap)
    (insert sellDate)

    (just-one-space)
    (indent-to-column 72)

    (n-complete-leap)
    (insert cashChange)
    (just-one-space)
    (indent-to-column 88)
    )

  (nst-move-line-to-closed-xactions-above)
  )
(defun nst-calculate-cash-change-total(security securityCnt sellPrice buyPrice tradeOverhead multiplier)
  (let(
       change
       (buying (string= "@@" sellPrice))
       (isOption (string-match "\\(Put\\|Call\\)" security))
       )
    (if buying
        (progn
          (setq change (nstr-eval "(* %s %s)" buyPrice securityCnt))
          (setq change (string-to-number change))
          
          
          
          
          
          
          






          (if isOption
              (setq change (* change 100)))
          (setq change (* change multiplier))


          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          (setq change (+ change tradeOverhead))
          )
      (setq change (nstr-eval "(* %s %s)" sellPrice securityCnt))
      (setq change (string-to-number change))
      (if isOption
	  (setq change (* change 100)))

      (setq change (- change tradeOverhead))
      )

    (setq nst-cumulative-change (+ nst-cumulative-change
				   (if buying
				       (- change)
				     change
				     )
				   )
	  )
    (narithmetic-pretty change)
    )
  )

(defun nst-make-line-for-a-new-position()
  (goto-char (point-max))
  (if (not (looking-at "$"))
      (error "nst-make-line-for-a-new-position: should be at the end of the open positions"))

  (insert "\n")
  (forward-char -1)
  )


(defun nst-log-xaction(securityCnt security sellPrice sellDate buyDate buyPrice broker tradeOverhead &optional multiplier)
  (if (not multiplier)
      (setq multiplier 1))
  (save-window-excursion
    (setq buyDate (nstr-replace-regexp buyDate
                                       (concat "\\([0-9][0-9]\\)/\\([0-9][0-9]\\)/" (n-year t) "\\b")
                                       (concat "\\1-\\2-" (n-year nil))
                                       )
          sellDate (nstr-replace-regexp sellDate
                                        (concat "\\([0-9][0-9]\\)/\\([0-9][0-9]\\)/" (n-year t) "\\b")
                                        (concat "\\1-\\2-" (n-year nil))
                                        )
          cashChange (nst-calculate-cash-change-total security securityCnt sellPrice buyPrice tradeOverhead multiplier)
          security (nstr-replace-regexp security  "Puts" "Put")
          security (nstr-replace-regexp security "Calls" "Call")
          )
    (n-file-find "$dp/data/b.st")


    (if (nst-goto-open-position security)
        (progn
          (nst-log-closing-xaction-with-open-xaction cashChange securityCnt security sellPrice sellDate buyDate buyPrice broker tradeOverhead)
          )

      (nst-make-line-for-a-new-position)
      (nst-log-opening-xaction cashChange securityCnt security sellPrice sellDate buyDate buyPrice broker tradeOverhead)
      )
    )
  )

(defun nst-process-amtd-import-trade-data()
  (n-prune-buf-v "Executed")
  (nst-combine-transactions "amtd")
  (goto-char (point-min))
  (let(
       hit
       overhead
       )
    (while (not (eobp))
      (setq hit nil
	    overhead 10.99
	    )
      (forward-line 0)
      (delete-horizontal-space)

      (cond
       ;; 04/21/2003 09:33:47 Executed: Sold 1000 BA at 26.77
       ((looking-at "^\\([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]\\) +.* Executed: Sold \\([0-9]+\\) \\(.*\\) at \\([\\.0-9]+\\)")
	(setq hit t
	      sellDate   (n--pat 1)
	      securityCnt (n--pat 2)
	      security   (n--pat 3)
	      sellPrice   (n--pat 4)
	      buyDate    "@@"
	      buyPrice   "@@"
	      )
	)
       ((looking-at "^\\([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]\\) +.* Executed: Bought \\([0-9]+\\) \\(.*\\) at \\([\\.0-9]+\\)")
	(setq hit t
	      securityCnt(n--pat 2)
	      security   (n--pat 3)
	      sellPrice "@@"
	      sellDate "@@"
	      buyDate     (n--pat 1)
	      buyPrice    (n--pat 4)
	      )
	)
       (t (error "nst-process-amtd-import-trade-data: "))
       )
      (if hit
	  (progn
	    (if (string-match "\\(Put\\|Call\\)" security)
		(setq overhead (+ overhead (* 1.25 (string-to-int securityCnt))))
	      )
	    (nst-log-xaction securityCnt security sellPrice sellDate buyDate buyPrice "amtd" overhead)
	    )
	)
      (forward-line 1)
      (end-of-line)
      )
    )
  )

(defun nst-process-harris-import-trade-data()
  (goto-char (point-min))
  (replace-regexp "COVERED" "BOUGHT")

  (n-prune-buf-v "SOLD\\|BOUGHT")
  (let(
       hit
       overhead
       )
    (goto-char (point-min))
    (while (not (eobp))
      (setq hit nil)
      (forward-line 0)
      (cond
       ((looking-at "\\([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]\\) +SOLD\\( SHORT\\)? +\\([0-9]+\\) +\\([A-Z0-9]+\\)\\( [A-Z][A-Z][A-Z] [0-9/ ]+\\)? +\\([\\.0-9]+\\) +\\$")
	(setq hit t
	      securityCnt (n--pat 3)
	      security   (concat (n--pat 4) (n--pat 5))
	      sellPrice   (n--pat 6)
	      sellDate   (n--pat 1)
	      buyDate    "@@"
	      buyPrice   "@@"
	      )
	)
       ((looking-at "\\([0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]\\) +BOUGHT +\\([0-9]+\\) +\\([A-Z0-9]+\\)\\( [A-Z][A-Z][A-Z] [0-9/ ]+\\)? +\\([\\.0-9]+\\) +\\$")
	(setq hit t
	      securityCnt (n--pat 2)
	      security   (concat (n--pat 3) (n--pat 4))
	      sellPrice "@@"
	      sellDate   "@@"
	      buyDate    (n--pat 1)
	      buyPrice   (n--pat 5)
	      )
	)
       (t
        (error "nst-process-harris-import-trade-data: "))
       )
      (if hit
	  (let(
	       overhead
	       )
	    (if (not (string-match " " security))
		(setq overhead 20)	;; not an option; flat commission of $20
	      (setq security (nstr-replace-regexp security
						  " *$"
						  (concat " "
							  (if (y-or-n-p (format "%s is an option: is it a Put? " security))
							      "Put"
							    "Call"
							    )
							  )
						  )
		    overhead (* 2.75 (string-to-number securityCnt))
		    )
	      )
	    (nst-log-xaction securityCnt security sellPrice sellDate buyDate buyPrice "harris" overhead)
	    )
	)
      (forward-line 1)
      (end-of-line)
      )
    )
  (goto-char (point-min))

  (replace-regexp (concat "\\([0-9][0-9]\\)/\\([0-9][0-9]\\)/" (n-year t) "\\b")
		  (concat "\\1-\\2-" (n-year nil))
		  )
  )

(defun nst-process-ib-import-trade-data()
  ;; this data comes from TWS->File->Export report, with "Extended report" checked
  (goto-char (point-min))
  (replace-regexp "CALL" "Call")
  (replace-regexp "PUT"  "Put")

  (nst-combine-transactions "ib")

  (let(
       hit
       overhead
       (futurePriceMultiplier 1)
       )
    (while (not (eobp))
      (setq hit nil)
      (forward-line 0)
      (cond
       ((looking-at "^\\([A-Z0-9]+\\);\\([A-Z]+\\);\\([A-Z0-9]*\\);\\([0-9\\.]*\\);\\([A-Za-z]*\\);;\\(BOT\\|SLD\\);\\([0-9]+\\);\\([0-9\\.]*\\);\\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\\);[0-9][0-9]\\([0-9][0-9]\\)\\([0-9][0-9]\\)\\([0-9][0-9]\\);\\([A-Z]+\\);\\([A-Z0-9]+\\);+$")
	(setq hit t
	      symbol   (n--pat 1)
	      securityType   (n--pat 2)
	      strikeDate   (n--pat 3)
	      strikePrice   (n--pat 4)
	      optionType   (n--pat 5)
	      action_BOT_or_SLD   (n--pat 6)
	      securityCnt (n--pat 7)
	      price   (n--pat 8)
	      time   (n--pat 9)
	      year   (n--pat 10)
	      month   (n--pat 11)
	      day   (n--pat 12)
	      exchange   (n--pat 13)
	      orderId   (n--pat 14)
	      date (concat month "-" day "-" year)
	      )
        (cond
         ((string= securityType "STK")
          (setq overhead (* 0.01 (string-to-int securityCnt))
                security symbol
                )
          )
         ((string= securityType "OPT")
	  (setq overhead (* 3.00 (string-to-int securityCnt))
		security (concat symbol " " strikeDate " " strikePrice " " optionType)
		)
	  )
         ((string= securityType "FUT")
	  (setq overhead (* 10.00 (string-to-int securityCnt))
                security symbol
                futurePriceMultiplier (nst-get-futurePriceMultiplier security)
                )
          )
         (t (error "nst-process-ib-import-trade-data: unknown securityType %s" securityType))
         )

        (cond
         ((string= action_BOT_or_SLD "SLD")
          (setq sellDate date
                buyDate "@@"
                buyPrice   "@@"
                sellPrice   price
                )
          )
         ((string= action_BOT_or_SLD "BOT")
          (setq sellDate "@@"
                buyDate date
                buyPrice  price
                sellPrice  "@@"
                )
          )
         (t
          (error "nst-process-ib-import-trade-data: unknown action %s" action_BOT_or_SLD)
          )
         )

        )
       (t
        (error "nst-process-ib-import-trade-data: unrecognized line")
	)
       )
      (nst-log-xaction securityCnt security sellPrice sellDate buyDate buyPrice "ib" overhead futurePriceMultiplier)
      (forward-line 1)
      (end-of-line)
      )
    )
  )

(defun nst-update-broker-cash-total(broker)
  (nst-set-float (concat broker "_cash") (+ nst-cumulative-change
 					    (nst-get-float (concat broker "_cash"))
					    )
		 )
  )
(defun nst-set(name val)
  (save-window-excursion
    (n-file-find "$dp/data/b.st")
    (goto-char (point-max))
    (if (not (n-r (concat "^" name " *=")))
	(insert name " = " val "\n")
      (n-s "=" t)
      (insert " " val)
      (delete-region (point) (progn
			       (end-of-line)
			       (point)
			       )
		     )
      )
    )
  )
(defun nst-set-float(name val)
  (nst-set name (narithmetic-pretty val))
  )
(defun nst-get-float(name)
  (string-to-number (nst-get name))
  )
(defun nst-get(name)
  (save-window-excursion
    (n-file-find "$dp/data/b.st")
    (goto-char (point-max))
    (if (n-r (concat "^" name " *= *\\(.*\\)"))
	(n--pat 1)
      ""
      )
    )
  )
(defun nst-calculate-various-values()
  (interactive)
  (n-file-find "$dp/data/b.st")

  (nst-set-float "realized_profit" (nst-calculate-realized_profit))
  (nst-set-float "total_portfolio_cost" (nst-calculate-total_portfolio_cost))

  ;;(nst-set-float "options_paper_profit"
  ;;(- (nst-get-float "options_current")
  ;;(nst-get-float "options_start")
  ;;)
  ;;)
  ;;(nst-set-float "total_paper_profit"
  ;;(+ (nst-get-float "options_paper_profit")
  ;;(nst-get-float "stock_paper_profit")
  ;;)
  ;;)
  (nst-set-float "total_profit"
		 (+ (nst-get-float "realized_profit")
		    (- (nst-get-float "total_portfolio_cost"))
		    (nst-get-float "amtd_portfolio_value")
		    (nst-get-float "harris_portfolio_value")
		    (nst-get-float "ib_portfolio_value")
		    )
		 )
  )

(defun nst-calculate-profit()
  (let(
       (sumSales	(progn
			  (goto-char (point-min))
			  (move-to-column 72)
			  (narithmetic-sum)
			  )
			)
       (sumBuys	 	(progn
			  (goto-char (point-min))
			  (move-to-column 88)
			  (narithmetic-sum)
			  )
	 		)
       )
    (- sumSales sumBuys)
    )
  )
(defun nst-calculate-realized_profit()
  (save-restriction
    (goto-char (point-min))
    (n-s "^$" t)
    (forward-line 1)
    (if (not (looking-at "100 QQQ"))
	(error "nst-calculate-realized_profit: where ami?"))
    (narrow-to-region (point) (progn
				(n-s "^$" t)
				(point)
				)
		      )
    (goto-char (point-min))
    (if (n-s "@@")
	(error "nst-calculate-realized_profit: should be narrowed to closed positionsonly -- why did I just find @@?"))
    (nst-calculate-profit)
    )
  )

(defun nst-calculate-total_portfolio_cost()
  (save-restriction
    (goto-char (point-min))
    (n-s "^$" t) ;; start of the modern era
    (forward-line 1)
    (n-s "^$" t) ;; start of open positions
    (forward-line 1)
    (if (not (looking-at ".*@@"))
	(error "nst-calculate-total_portfolio_cost: where ami?"))
    (narrow-to-region (point) (progn
				(n-s "^$" t) ;; start of summary data
				(point)
				)
		      )
    (- (nst-calculate-profit))
    )
  )

(defun nst-combine-transactions(broker)
  (require 'nsort)
  (nsort-buf)
  (call-process-region (point-min) (point-max) "perl" t t nil "-w" (n-host-to-canonical "$dp/bin/perl/combine_stock_transactions.pl") broker)
  (goto-char (point-min))
  )

(defun nst-ib-go-get-trade-data-into-kill()
  ;;(dired "c:/Documents and Settings/x/My Documents/")
  (dired "c:/")
  (goto-char (point-min))	;; needed in case the dired had already been created and we are not at bof
  (n-s "\\(Mon\\|Tue\\|Wed\\|Thu\\|Fri\\)\\.txt" t)
  (if (n-s "\\(Mon\\|Tue\\|Wed\\|Thu\\|Fri\\)\\.txt")
      (error "nst-ib-go-get-trade-data-into-kill: looks like there are 2 possible ib trade data files"))
  (dired-find-file)

  (n-host-shell-cmd-visible (format "cat '%s' >> $HOME/work/ib/trade_data; rm '%s'"
				    (buffer-file-name)
				    (buffer-file-name)
				    )
			    )
  (message "Exit recursive edit when you feel the data are good enough to be imported (hit key to continue)")
  (read-char)
  (recursive-edit)
  (nsimple-copy-region-as-kill (point-min) (point-max))
  )

;;Since interactive brokers exports trade data to an inconvenient
;;location,
;;this routine is set up to assist in capturing that information
;;automatically.
;;If this routine is in both with an argument, it will go find the
;;interactive brokers exports file, save its contents to my global record
;;of
;;interactive brokers trades under ~/work/ib/trade_data, and enter a
;;recursive edit of the file to allow combining partial fills for a more
;;orderly record of the trading data.
;;
(defun nst-import-trade-data(&optional arg)
  (interactive "P")
  (let(
       done
       )
    (cond
     (arg
      (let(
	   (cmd (progn
		  (message "e-edit ib report dir, p-rocess ONE file there")
		  (read-char)
		  )
		)
	   )
	(cond
	 ((eq ?e cmd)
	  (dired "c:/Documents and Settings/x/My Documents/")
	  (setq done t)
	  )
	 ((eq ?p cmd)
	  (nst-ib-go-get-trade-data-into-kill)
	  )
	 )
	)
      )
     )
    (if (not done)
	(progn
	  (setq nst-cumulative-change 0)
	  (nst-goto-tmp)
	  (delete-region (point-min) (point-max))








          (insert "VLNC;STK;;;;;SLD;43;3.80;16:12:57;20031219;ARCA;U49683;;;\nVLNC;STK;;;;;SLD;200;3.79;16:12:57;20031219;ARCA;U49683;;;\nVLNC;STK;;;;;SLD;257;3.78;16:12:57;20031219;ARCA;U49683;;;\nVLNC;STK;;;;;SLD;200;3.79;16:13:39;20031219;ARCA;U49683;;;\nVLNC;STK;;;;;SLD;300;3.78;16:13:39;20031219;ARCA;U49683;;;\n") (nelisp-bp "nst-import-trade-data" "just inserting the data directly (nst.el)" 684);;;;;;;;;;;;;;;;;
          ;;(yank)











          (goto-char (point-min))

          (let(
               (brokerAndDataType (nst-identify-broker-of-import-trade-data))
               broker
               type
               (narithmetic-register-is-a-dollar-value-and-we-should-show-trailing-zeroes-for-cents t)
               sym
               )
            (setq broker (car brokerAndDataType)
                  type (cdr brokerAndDataType)
                  sym (intern (concat "nst-process-" broker "-import-" type)))
            (funcall (symbol-function sym))
            
            (n-file-find "$dp/data/b.st")
            (goto-char (point-max))
            (delete-other-windows)
            
            ;;(nst-update-broker-cash-total broker)
	    ;;(nst-calculate-various-values)
            
	    (untabify (point-min) (point-max))
	    )
	  (nst-bury-tmp)
	  )
      )
    )
  )
(defun nst-get-amtd-portfolio-value()
  (let(
       (longOptionValue (progn
			  (goto-char (point-min))
			  (if (not (n-s "Long Option Value *\\$"))
			      0
			    (n-grab-number  "ignoreCommas")
			    )
			  )
			)
       (shortOptionValue (progn
			   (goto-char (point-min))
			   (if (not (n-s "Short Option Value *\\$"))
			       0
			     (n-grab-number  "ignoreCommas")
			     )
			   )
			 )
       (longStockValue (progn
			 (goto-char (point-min))
			 (if (not (n-s "Long Stock Value *\\$"))
			     0
			   (n-grab-number  "ignoreCommas")
			   )
			 )
		       )
       (shortStockValue (progn
			  (goto-char (point-min))
			  (if (not (n-s "Short Stock Value *\\$"))
			      0
			    (n-grab-number  "ignoreCommas")
			    )
			  )
			)
       amtdValue
       )
    (setq amtdValue (+ longOptionValue
			     shortOptionValue
			     longStockValue
			     shortStockValue
			     )
	  )
    amtdValue
    )
  )

(defun nst-process-ib-import-holdings-data()
  ;; to get this info: in TWS, click the "Accounts" button; then grab to the cutbuffer the "Market Value" line
  (if (not (looking-at "\\([A-Z]+\\)\t\\([-0-9\\.]+\\)\t\\([-0-9\\.]+\\)\t\\([-0-9\\.]+\\)\t\\([-0-9\\.]+\\)\t\\([-0-9\\.]+\\)"))
      (error "nst-process-ib-import-holdings-data: no comprende"))
  (let(
       (currency (n--pat 1))
       (cash (n--pat 2))
       (stockValue (n--pat 3))
       (optionsValue (n--pat 4))
       (futuresProfit (n--pat 5))
       (futuresOptionsValue (n--pat 6))
       ibValue
       (currency (n--pat 1))
       )
    (setq ibValue (+ (string-to-int stockValue)
		     (string-to-int optionsValue)
		     (string-to-int futuresProfit)
		     (string-to-int futuresOptionsValue)
		     )
	  )
    (nst-set-float "ib_cash" (string-to-number cash))
    (nst-set-float "ib_portfolio_value" ibValue)
    )
  )

(defun nst-process-amtd-import-holdings-data()
  (goto-char (point-min))
  (n-s "Cash Balance \\$" t)
  (nst-set-float "amtd_cash" (n-grab-number "ignoreCommas"))

  (nst-set-float "amtd_portfolio_value" (nst-get-amtd-portfolio-value))
  )

(defun nst-process-harris-import-holdings-data()
  (goto-char (point-min))
  (let(
       (longValue (progn
		    (goto-char (point-min))
		    (n-s "Long Market Value: \\$" t)
		    (n-grab-number "ignoreCommas")
		    )
		  )
       (shortValue (progn
		     (goto-char (point-min))
		     (n-s "Short Market Value: \\$" t)
		     (n-grab-number "ignoreCommas")
		     )
		   )
       )
    (nst-set-float "harris_cash"        (progn
					  (goto-char (point-min))
					  (n-s "Cash: \\$" t)
					  (n-grab-number "ignoreCommas")
					  )
		   )


    (nst-set-float "harris_portfolio_value" (- longValue shortValue))
    )
  )
