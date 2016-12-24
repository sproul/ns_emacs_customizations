(provide 'n-mail)
(setq n-mail-record (nsimple-env-expand
                     (concat "$NELSON_HOME/work/m/"
                             "."
                             n-local-world-name
                             "."
                             (n-month-day 2)
                             ".record"
                             )
                     )
      )


(setq rmail-highlighted-headers nil)

(defun n-rmail-cmd( func advance &rest args)
  (save-window-excursion
    (set-buffer "RMAIL")
    (apply func args)
    )
  (if advance
      (rmail-summary-next-msg 1))
  )

(defun n-h-rmail-summary-delete-forward()
  (interactive)
  (n-rmail-summary)
  (rmail-summary-delete-forward)
  )

(defun n-rmail-scroll-down-other()
  (interactive)
  (other-window 1)
  (scroll-down)
  (other-window 1)
  )

(defun n-rmail-summary-save( &optional arg)
  (interactive "P")
  (n-rmail-cmd 'n-rmail-save nil arg)
  )
(defun n-rmail-summary-forward( &optional arg)
  (interactive "P")
  (n-rmail-cmd 'rmail-forward nil nil)
  (switch-to-buffer "*mail*")
  (insert (nmenu "to " "mailees"))
  (forward-line 1)
  (end-of-line)
  )

(defun n-rmail-summary-lpr()
  (interactive)
  (n-rmail-cmd 'n-rmail-lpr t)
  )

(defun n-rmail-lpr(&optional queue)
  (interactive)
  (n-lpr-region (point-min) (point-max) queue)
  )

(defun n-rmail-summary-reply2( replyAll )
  (interactive "P")
  (n-rmail-cmd 'rmail-reply nil (not replyAll))
  (switch-to-buffer "*mail*")
  (nbuf-post-for-kill 'switch-to-buffer "RMAIL-summary")
  )

(defun n-rmail-summary-reply-all()
  (interactive)
  (n-rmail-summary-reply2 t)
  )
(defun n-mail-record-ff()
  (interactive)
  (find-file n-mail-record)
  (goto-char (point-max))
  )

(defun n-rmail-summary-reply()
  (interactive)
  (n-rmail-summary-reply2 nil)
  )

(defun n-rmail-save( &optional arg)
  (interactive "P")
  (message "saving...")
  (n-rmail-saveBuf arg)
  (n-rmail-summary)
  )

(defun n-mail-from()
  (goto-char (point-min))
  (n-s "From:" t)
  (let(
       (name	(cond
                 ((or
                   (looking-at " \\([a-zA-Z]+\\)[()<>a-zA-Z@ 0-9]+$")
                   (looking-at "[^\n]*[(<\"]+\\([^<): @]+\\)[ @]")
                   )
                  (n--pat 1)
                  )
                 (t
                  (forward-char 1)
                  (n-grab-token2)
                  )
                 )
                )
       )
    (nstr-downcase name)
    )
  )
(defun n-rmail-saveBuf( &optional arg &optional mailDir)
  (if (not mailDir)
      (setq mailDir n-local-mail))
  (let(
       (data	(buffer-substring-no-properties (point-min) (point-max)))
       (from	(n-mail-from))
       (subject "in"
                ;;        	(cond
                ;;                 ((and arg (stringp arg))	arg)
                ;;                 (arg		                    (read-string "Enter file suffix: "))
                ;;                 ((progn
                ;;                    (goto-char (point-min))
                ;;                    (n-s "Subject: ")
                ;;                    )
                ;;                  (buffer-substring-no-properties (point) (progn
                ;;                                              (end-of-line)
                ;;                                              (point)
                ;;                                              )
                ;;                                    )
                ;;                  )
                ;;                 (t		                    (read-string "Subject: "))
                ;;                 )
                )
       )
    ;;    (setq subject (nstr-replace-regexp subject " " "_"))
    ;;    (setq subject (nstr-replace-regexp subject "/" "."))
    ;;    (setq subject (nstr-downcase subject))
    (message "%s.%s" from subject)
    (let(
         (fn (concat mailDir from "." subject))
         )
      (append-to-file (point-min) (point-max) fn)
      (rmail-delete-forward)
      (if arg
          (n-file-find fn))
      )
    )
  )

(defun n-rmail-summary()
  (interactive)
  (rmail-summary)
  )

(defun n-rmail( &optional arg)
  "rmail OR grep thru mail db"
  (interactive "P")
  (if arg
      (let(
           (topic	(read-string "topic: "))
           )
        (n-env-grep nil "grep -ni " topic " " n-local-mail "*")
        )
    (if (get-buffer "RMAIL")
        (switch-to-buffer "RMAIL")
      (condition-case() (rmail) (error nil))
      (let(
           (msg	 rmail-current-message)
           )
        (toggle-read-only)
        (n-rmail-prune 'n-rmail-bs-p)
        (n-rmail-prune 'n-rmail-queued-print)
        (rmail-summary)
        (goto-char (point-min))
        (forward-line (1- msg))
        (rmail-summary-goto-msg msg)
        )
      )
    )
  )
(defun n-mail-get-email-address(&optional multipleNameMode)
  (save-window-excursion
    (let(
	 (tmp (n-grab-token-in-file "$dp/emacs/lisp/data/n-data-menu-mailees.el"
				    nil
				    (cond
				     (multipleNameMode "\"");; set of names
				     (t "\" \t\n,");; single name
				     )
				    )
	      )
	 )
      (nstr-kill tmp)
      tmp
      )
    )
  )

(defun n-mail()
  (interactive)
  (let(
       (x	(nmenu "to " "mailees"))
       cmd
       )
    (if (string= x "prompt_for_args")
	(setq cmd (progn
		    (message "n-elson@adyn.com, r-ecord-goto, t-oken-from-data")
		    (read-char)
		    )
	      )
      )
    (cond
     ((eq cmd ?r)
      (n-mail-record-ff)
      )
     ((eq cmd ?n)
      (nstr-kill "nelson@adyn.com")
      )
     ((get-buffer "*mail*")
      (switch-to-buffer "*mail*")
      (if (eq cmd ?t)
	  (progn
	    (goto-char (point-min))
	    (n-s "To: " t)
	    (if (not (looking-at "$"))
		(progn
		  (end-of-line)
		  (insert ", ")
		  )
	      )
	    (insert (n-mail-get-email-address))
	    )
	)
      )
     (t
      (let(
	   (to       (cond
		      ((eq cmd ?t)
		       (n-mail-get-email-address)
		       )
		      (t x)
		      )
		     )
	   )
	(mail)
	(auto-save-mode -1)
	(if to
	    (insert to))
	)
      (forward-line 1)
      (end-of-line)
      )
     )
    )
  )

(defun n-rmail-kill()
  (interactive)
  (if (get-buffer "RMAIL")
      (progn
        (set-buffer "RMAIL")
        (rmail-expunge)
        (save-buffer)
        (nbuf-kill (current-buffer))
        )
    )
  (if (get-buffer "RMAIL-summary")
      (progn
        (set-buffer "RMAIL-summary")
        (nbuf-kill (current-buffer))
        )
    )
  (message "")
  )
(defun n-mail-save-send-and-exit( &optional arg)
  (interactive "P")
  (if (not arg)
      (setq arg t))
  (n-mail-send-and-exit arg)
  )
(defun n-mail-send-and-exit( &optional arg)
  (interactive "P")
  (if (and arg (listp arg))
      (insert "\n thanks,	-Nelson"))
  (if arg
      (progn
        (goto-char (point-max))
        (insert "\n")
        (insert (current-time-string) "\n")
        (save-window-excursion
          (let(
               (data (buffer-substring-no-properties (point-min) (point-max)))
               )
	    (n-mail-record-ff)
            (insert data)
            (save-buffer)
            (nbuf-kill-current)
            )
          )

        ;; get rid of timestamp
        (forward-line -1)
        (nsimple-delete-line)
        )
    )
  (mail-send-and-exit arg)

  (set-buffer "*mail*")	; force execution of posted functions
  (nbuf-kill-current)
  )
(defun n-mail-question()
  (interactive)
  (rmail-reply t)
  (insert "\n\nSince I'm unsure of the answer, I have forwarded this mail to an authority on the subject.\n\n\n\n")
  (n-mail-yank-original)
  (goto-char (point-min))
  (delete-char 2)
  (insert "\nCC")
  (goto-char (point-min))
  (insert "To: ")
  )
(defun n-mail-yank-original()
  (interactive)
  (mail-yank-original 8)
  )
(defun n-mail-i-am-done()
  (interactive)
  (rmail-delete-message)
  (rmail-reply nil)
  (insert "\n\n")
  (let(
       (string  (nmenu "" "canned-mail"))
       )
    (if string
        (insert string))
    )
  (insert "@@\n\n\n")
  (n-mail-yank-original)
  (goto-char (point-min))
  (n-complete-leap)
  (nbuf-post-for-kill 'n-rmail-equilibrium)
  )
(defun n-mail-summary-i-am-done()
  (interactive)
  (set-buffer "RMAIL")
  (n-mail-i-am-done)
  )
(defun n-rmail-misc( &optional arg)
  (interactive "P")
  (let(
       (cmd	(progn
                  (n-s " -9" t)
                  (n-get-line)
                  )
                )
       )
    (n-esc cmd "pokey")
    )
  )
(defun n-mail-clean()
  (interactive)
  (goto-char (point-min))
  (n-s "^--text follows this line--" t)
  (forward-line 1)
  (delete-region (point) (progn
                           (goto-char (point-max))
                           (point)
                           )
                 )
  )
(defun n-rmail-prune(pruner)
  (interactive)
  (rmail-expunge)
  (rmail-show-message 1)
  (while
      (prog1
          (/= rmail-current-message rmail-total-messages)
        (if (funcall pruner)
            (rmail-delete-message)
          )
        (rmail-next-undeleted-message 1)
        )
    )
  )
(defun n-rmail-dcl-bs(beg end)
  (interactive "r")
  (let(
       (val	(buffer-substring-no-properties beg end))
       )
    (n-file-push (concat "$dp/emacs/lisp/data/"
                         "n-data-rmail-bs-regexps.el")
                 )
    (goto-char (point-min))
    (forward-line 1)
    (insert "\"" val "\"\n")
    (nelisp-compile)
    (n-file-pop)
    )
  )

(defun n-rmail-bs-p()
  (goto-char (point-min))
  (n-sv n-data-rmail-bs-regexps)
  )
(defun n-rmail-queued-print()
  (goto-char (point-min))
  (if (n-sv n-data-rmail-print-regexps)
      (progn
        (n-rmail-lpr t)
        t
        )
    )
  )
(defun n-mail-buf( subject user &optional cc dontSend record)
  "send mail with SUBJECT to USER"
  (let(
       (contentBuf	(current-buffer))
       )
    (mail)
    (insert user)
    (forward-line 1)
    (end-of-line)
    (insert subject)
    (if cc
        (insert "\ncc: " cc))
    (goto-char (point-max))
    (insert-buffer contentBuf)
    (if (not dontSend)
        (if record
            (n-mail-send-and-exit)
          (mail-send-and-exit nil)
          )
      )
    )
  )

(defun n-rmail-summary-delete-forward( &optional arg)
  (interactive "p")
  (if (integerp arg)
      (while (> arg 0) (rmail-summary-delete-forward) (setq arg (1- arg)))
    (rmail-summary-delete-forward)
    )
  )
(defun n-rmail-equilibrium()
  (n-rmail)
  (delete-other-windows)
  (rmail-summary)
  )

(defun n-mail-grab-compress-header()
  ;; stop the following line splitting:
  ;;	Subject:
  ;;	        homing in
  ;;	   Date:
  ;;	        Wed, 09 Aug 2000 08:33:52 -0500
  ;;	   From:
  ;;	        Christi Merrill <cmerrill@virginia.edu>
  ;;	     To:
  ;;	        sixcount@adyn.com
  ;;	
  (goto-char (point-min))
  (if (looking-at ".*Subject:$")
      (while (and (looking-at ".*:$")
		  (not (eobp))
		  )
	(nsimple-join-lines)
	(forward-line 1)
	)
    )
  (nsimple-just-one-blank-line)
  )

(defun n-mail-grab-prune-viral-marketing()
  (goto-char (point-min))
  (cond
   ((n-s "Yahoo! Mail - Free email you can access from anywhere!")
    (delete-region (progn
		     (forward-line -2)
		     (point)
		     )
		   (progn
		     (forward-line 4)
		     (point)
		     )
		   )
    )
   ((n-s "_*\nGet Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com")
    (delete-region (progn
		     (forward-line -1)
		     (point)
		     )
		   (progn
		     (forward-line 5)
		     (point)
		     )
		   )
    )
   )
  
  (goto-char (point-min))
  (if (n-s "YOU'RE PAYING TOO MUCH FOR THE INTERNET!")
      (delete-region (progn
		       (forward-line 0)
		       (point)
		       )
		     (progn
		       (goto-char (point-max))
		       (point)
		       )
		     )
    )
  )

(defun n-mail-grab()
  (and (get-buffer "*mail*")
       (not (y-or-n-p "kill existing *mail* buffer?"))
       (error "n-mail-grab: ")
       )
  (if (get-buffer "*mail*")
      (kill-buffer "*mail*"))

  (let(
       (sender (progn
		 (goto-char (point-min))
		 (if (n-s "^From:.*<\\([^ \t\n]+\\)>")
		     (n--pat 1)
		   ""
		   )
		 )
	       )
       (subject (progn
		  (goto-char (point-min))
		  (if (n-s "^Subject: \\([^\n]+\\)\n")
		      (n--pat 1)
		    ""
		    )
		  )
		)
       (data (buffer-substring-no-properties (point-min) (point-max)))
       )



    (delete-region (point-min) (point-max))
    ;;(mail)
    ;;(insert sender)
    ;;(forward-line 1)
    ;;(end-of-line)
    ;;(insert "Re: " subject)
    ;;(goto-char (point-max))

    (narrow-to-region (point) (point))
    (insert data "\n")
    (goto-char (point-min))
    (replace-regexp " =$" "")
    (goto-char (point-min))

    (nsimple-marginalize-region 90 (point-min) (point-max))

    (n-mail-grab-prune-viral-marketing)

    (n-mail-grab-compress-header)

    (forward-word 1)
    (nsimple-back-to-indentation)
    (n-loc-push)

    (goto-char (point-max))
    (nsimple-delete-vertical-space)

    (goto-char (point-min))
    (replace-regexp "^" "|	")

    (n-loc-pop)
    (nsimple-copy-region-as-kill (point) (point-max))
    (widen)
    )
  )


(if n-win
    (progn
      (setq user-full-name (n-database-get "user-full-name" nil nil "Nelson Sproul")
            mail-host-address (n-database-get "user-full-name" nil nil "pop.rcn.com")
            user-mail-address (n-database-get "user-mail-address" nil nil "nelson@adyn.com")
            n-mail-host-userId (n-database-get "n-mail-host-userId" nil nil "xxx123")
            ;;n-mail-host-userPw (n
            smtpmail-smtp-server (n-database-get "smtpmail-smtp-server" nil nil "smtp.rcn.com")
            smtpmail-local-domain nil
            send-mail-function 'smtpmail-send-it
            )
      (if (and (string= user-full-name "Nelson Sproul")
               n-not-nelson
               )
          (progn
            (message "despite my name being Nelson Sproul, n-not-nelson == t -- hit a key")
            (read-char)
            )
        )
      (load-library "smtpmail")

      ;;(setenv "MAILHOST" (n-database-get "pop incoming mail server" t))

      (setq rmail-primary-inbox-list '("po:sproul")
            rmail-pop-password-required t
            )
      )
  )
(defun n-mail-goto-c-mail-txt(&optional noKill)
  (interactive)
  (n-file-find "$HOME/mail.txt")
  (let(
       (cmd (progn
	      (if (not noKill)
		  ?k
		(message "c-urrent reformat, k-ill reformat")
		(read-char)
		)
	      )
	    )
       )
    (cond
     ((eq cmd ?c)
      (n-mail-grab)
      )
     ((eq cmd ?k)
      (delete-region (point-min) (point-max))
      (yank)
      (n-mail-grab)
      )
     )
    )
  )
(defun n-mail-goto-c-mail-txt-and-gen-license()
  (interactive)
  (n-mail-goto-c-mail-txt)
  (let(
       (prod (progn
	       (goto-char (point-min))
	       (cond
		((n-s "[Ss]pinach") "spinach")
		((n-s "[Ww]eb ?[Kk]eyboard") "web_key")
		((n-s "\\bWK\\b") "web_key")
		((n-s "\\bwk\\b") "web_key")
		((n-s "[Mm]acro") "macro")
		)
	       )
	     )
       (id (cond
	    ((or
	      (n-s "[Cc]ustomer[ \t]+[Ii][Dd][ \t]+\\([0-9]+\\)")
	      (n-s "\\b[Ii][Dd][ \t]*[#=]?[ \t]*\\([0-9]+\\)")
	      (n-s "\\b[Ll]icense[ \t]*[#=]?[ \t]*\\([0-9]+\\)")
	      )
	     (n--pat 1)
	     )
	    (t
	     (read-string "Enter customer ID: ")
	     )
	    )
	   )
       exe
       key
       )
    (if (not prod)
	(setq prod (read-string "Enter product: ")))
    (require 'nshell)
    (setq key (nstr-call-process nil "" (nshell-get-explicit-shell-file-name) "gen_key" prod id))
    (setq exe (if (string= prod "macro")
		  "macro.exe"
		(concat "c:\\perl\\bin\\" prod)
		)
	  )

    (goto-char (point-min))
    (insert "hi,

To install your permanent license, do

	" exe " -register " key "

thanks,

-Nelson

")
    )
  (nsimple-copy-region-as-kill (point-min) (point-max))
  )
