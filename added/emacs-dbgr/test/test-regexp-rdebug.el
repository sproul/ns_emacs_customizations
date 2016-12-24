(require 'test-unit)
(load-file "../dbgr/debugger/rdebug/init.el")

(test-unit-clear-contexts)

(setq tb  (gethash "backtrace" dbgr-rdebug-pat-hash))
(setq bps (gethash "brkpt-set" dbgr-rdebug-pat-hash))
(setq rails-bt (gethash "rails-backtrace" dbgr-rdebug-pat-hash))

(defun loc-match(text var) 
  (string-match (dbgr-loc-pat-regexp var) text)
)

;; FIXME: we get a void variable somewhere in here when running
;;        even though we define it in lexical-let. Dunno why.
;;        setq however will workaround this.
(setq text "	from /usr/local/bin/irb:12:in `<main>'")
(context "traceback location matching"
	 (tag regexp-rdebug)
	 (lexical-let ((text "	from /usr/local/bin/irb:12:in `<main>'"))
	   (specify "basic traceback location"
		    (assert-t (numberp (loc-match text tb))))
	   (specify "extract traceback file name"
	   	    (assert-equal "/usr/local/bin/irb"
				  (match-string (dbgr-loc-pat-file-group tb)
	   				  text)))
	   (specify "extract traceback line number"
	   	    (assert-equal "12"
				  (match-string (dbgr-loc-pat-line-group tb)
						text)))
	   )

	 (lexical-let ((text "Breakpoint 1 file /usr/bin/irb, line 10\n"))
	   (specify "basic breakpoint location"
		    (assert-t (numberp (loc-match text bps))))
	   (specify "extract breakpoint file name"
	   	    (assert-equal "/usr/bin/irb"
				  (match-string (dbgr-loc-pat-file-group bps)
	   				  text)))
	   (specify "extract breakpoint line number"
	   	    (assert-equal "10"
				  (match-string (dbgr-loc-pat-line-group bps)
						text)))
	   )
	 )

(test-unit "regexp-rdebug")

