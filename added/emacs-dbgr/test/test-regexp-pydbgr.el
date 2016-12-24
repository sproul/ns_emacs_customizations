(require 'test-unit)
(load-file "../dbgr/debugger/pydbgr/init.el")

(test-unit-clear-contexts)


(setq bps    (gethash "brkpt-set" dbgr-pydbgr-pat-hash))
(setq loc    (gethash "loc"       dbgr-pydbgr-pat-hash))
(setq tb     (gethash "backtrace" dbgr-pydbgr-pat-hash))

(defun loc-match(text var) 
  (string-match (dbgr-loc-pat-regexp var) text)
)

;; FIXME: we get a void variable somewhere in here when running
;;        even though we define it in lexical-let. Dunno why.
;;        setq however will workaround this.
(setq text "  File \"/usr/lib/python2.6/code.py\", line 281, in raw_input")
(context "traceback location matching"
	 (tag regexp-pydbgr)
	 (specify "basic traceback location"
		  (assert-t (numberp (loc-match text tb))))
	 (specify "extract file name"
		  (assert-equal "/usr/lib/python2.6/code.py"
				(match-string (dbgr-loc-pat-file-group tb)
					      text)
				(format "Failing file group is %s" 
					(dbgr-loc-pat-file-group tb))))
	 (specify "extract line number"
		  (assert-equal "281"
				(match-string (dbgr-loc-pat-line-group tb)
					      text))
		  ))

(context "breakpoint location matching"
	 (tag regexp-pydbgr)
	 (lexical-let ((text "Breakpoint 1 set at line 13 of file /src/git/code/gcd.py"))
	   (specify "basic breakpoint location"
		    (assert-t (numberp (loc-match text bps))))
	   (specify "extract breakpoint file name"
	   	    (assert-equal "/src/git/code/gcd.py"
				  (match-string (dbgr-loc-pat-file-group bps)
	   				  text)))
	   (specify "extract breakpoint line number"
	   	    (assert-equal "13"
				  (match-string (dbgr-loc-pat-line-group bps)
						text)))
	   )
	 )

(context "prompt matching"
	 (tag regexp-pydbgr)
	 (lexical-let ((text "(c:\\working\\python\\helloworld.py:30): <module>"))
	   (specify "MS DOS position location"
		    (assert-t (numberp (loc-match text loc))))
	   (specify "extract file name"
		    (assert-equal "c:\\working\\python\\helloworld.py"
				(match-string (dbgr-loc-pat-file-group loc)
					      text)
				(format "Failing file group is %s" 
					(dbgr-loc-pat-file-group tb))))
	 (specify "extract line number"
		  (assert-equal "30"
				(match-string (dbgr-loc-pat-line-group loc)
					      text)))

	   )
	 (lexical-let ((text "(/usr/bin/ipython:24): <module>"))
	   (specify "position location"
		    (assert-t (numberp (loc-match text loc))))
	   (specify "extract file name"
		    (assert-equal "/usr/bin/ipython"
				(match-string (dbgr-loc-pat-file-group loc)
					      text)
				(format "Failing file group is %s" 
					(dbgr-loc-pat-file-group tb))))
	 (specify "extract line number"
		  (assert-equal "24"
				(match-string (dbgr-loc-pat-line-group loc)
					      text)))

	   )
	 )

(test-unit "regexp-pydbgr")

