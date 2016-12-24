(require 'test-unit)
(load-file "../dbgr/debugger/rdebug/rdebug.el")

(test-unit-clear-contexts)

(context "rdebug"
	 (tag rdebug)

	 (specify "rdebug-get-script-name"
	      (assert-equal '("foo" nil) 
			    (rdebug-get-script-name '("rdebug" "foo")))
	      (assert-equal '("foo" nil) 
			    (rdebug-get-script-name '("rdebug" "-m" "foo")))
	      (assert-equal '("foo" t)
			    (rdebug-get-script-name
			     '("rdebug" "--emacs" "3" "foo")))
	      (assert-equal '("foo" t) 
			    (rdebug-get-script-name
			     '("myrdebug" "--annotate=1" "foo")))
	      (assert-equal '("foo" t) 
			    (rdebug-get-script-name
			     '("ruby" "rdebug" "--annotate" "1" "foo")))
	      (assert-equal '("foo" nil) 
			    (rdebug-get-script-name
			     '("/usr/bin/ruby19" "rdebug" 
			       "--emacs-basic" "foo")))
	      (assert-equal '("foo" nil) 
			    (rdebug-get-script-name '("rdbg.rb" "foo")))
	      (assert-equal '("rdbg.rb" nil) 
			    (rdebug-get-script-name 
			     '("rdebug" "rdbg.rb" "foo")))
	      (assert-equal '("foo" t) 
			    (rdebug-get-script-name 
			     '("rdebug" "-A" "1" "foo")))
	      (assert-equal '("foo" nil)
			    (rdebug-get-script-name
			     '("rdebug" "--include" "me" "-n" "foo")))
	      (assert-equal '("foo" nil) 
			    (rdebug-get-script-name
			     '("rdebug" "--server" "-d" "--host"
			       "localhost" "foo" "-1")))
	      )
	 )

(test-unit "rdebug")

