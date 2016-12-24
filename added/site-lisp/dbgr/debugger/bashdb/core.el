;;; Copyright (C) 2010 Rocky Bernstein <rocky@gnu.org>
(eval-when-compile (require 'cl))
  
(require 'load-relative)
(require-relative-list '("../../common/track" "../../common/core") "dbgr-")
(require-relative-list '("init") "dbgr-bashdb-")

;; FIXME: I think the following could be generalized and moved to 
;; dbgr-... probably via a macro.
(defvar bashdb-minibuffer-history nil
  "minibuffer history list for the command `bashdb'.")

(easy-mmode-defmap bashdb-minibuffer-local-map
  '(("\C-i" . comint-dynamic-complete-filename))
  "Keymap for minibuffer prompting of gud startup command."
  :inherit minibuffer-local-map)

;; FIXME: I think this code and the keymaps and history
;; variable chould be generalized, perhaps via a macro.
(defun bashdb-query-cmdline (&optional opt-debugger)
  (dbgr-query-cmdline 
   'bashdb-suggest-invocation
   bashdb-minibuffer-local-map
   'bashdb-minibuffer-history
   opt-debugger))

(defun bashdb-parse-cmd-args (orig-args)
  "Parse command line ARGS for the annotate level and name of script to debug.

ARGS should contain a tokenized list of the command line to run.

We return the a list containing
- the command processor (e.g. bashdb) and it's arguments if any - a list of strings
- the name of the debugger given (e.g. bashdb) and its arguments - a list of strings
- the script name and its arguments - list of strings
- whether the annotate or emacs option was given ('-A', '--annotate' or '--emacs) - a boolean

For example for the following input 
  (map 'list 'symbol-name
   '(zsh -W -C /tmp bashdb --emacs ./gcd.rb a b))

we might return:
   ((zsh -W -C) (bashdb --emacs) (./gcd.rb a b) 't)

NOTE: the above should have each item listed in quotes.
"

  ;; Parse the following kind of pattern:
  ;;  [zsh zsh-options] bashdb bashdb-options script-name script-options
  (let (
	(args orig-args)
	(pair)          ;; temp return from 
	;; zsh doesn't have any optional two-arg options
	(zsh-opt-two-args '())
	(zsh-two-args '("o" "c"))

	;; One dash is added automatically to the below, so
	;; h is really -h and -host is really --host.
	(bashdb-two-args '("A" "-annotate" "l" "-library"
			   "c" "-command" "-t" "-tty"
			   "x" "-eval-command"))
	(bashdb-opt-two-args '())
	(interp-regexp 
	 (if (member system-type (list 'windows-nt 'cygwin 'msdos))
	     "^zsh*\\(.exe\\)?$"
	   "^zsh*$"))

	;; Things returned
	(script-name nil)
	(debugger-name nil)
	(interpreter-args '())
	(debugger-args '())
	(script-args '())
	(annotate-p nil))

    (if (not (and args))
	;; Got nothing: return '(nil, nil)
	(list interpreter-args debugger-args script-args annotate-p)
      ;; else
      ;; Strip off optional "ruby" or "ruby182" etc.
      (when (string-match interp-regexp
			  (file-name-sans-extension
			   (file-name-nondirectory (car args))))
	(setq interpreter-args (list (pop args)))

	;; Strip off Ruby-specific options
	(while (and args
		    (string-match "^-" (car args)))
	  (setq pair (dbgr-parse-command-arg 
		      args zsh-two-args zsh-opt-two-args))
	  (nconc interpreter-args (car pair))
	  (setq args (cadr pair))))

      ;; Remove "bashdb" from "bashdb --bashdb-options script
      ;; --script-options"
      (setq debugger-name (file-name-sans-extension
			   (file-name-nondirectory (car args))))
      (unless (string-match "^bashdb$" debugger-name)
	(message 
	 "Expecting debugger name `%s' to be `bashdb'"
	 debugger-name))
      (setq debugger-args (list (pop args)))

      ;; Skip to the first non-option argument.
      (while (and args (not script-name))
	(let ((arg (car args)))
	  (cond
	   ;; Annotation or emacs option with level number.
	   ((or (member arg '("--annotate" "-A"))
		(equal arg "--emacs"))
	    (setq annotate-p t)
	    (nconc debugger-args (list (pop args))))
	   ;; Combined annotation and level option.
	   ((string-match "^--annotate=[0-9]" arg)
	    (nconc debugger-args (list (pop args)) )
	    (setq annotate-p t))
	   ;; Options with arguments.
	   ((string-match "^-" arg)
	    (setq pair (dbgr-parse-command-arg 
			args bashdb-two-args bashdb-opt-two-args))
	    (nconc debugger-args (car pair))
	    (setq args (cadr pair)))
	   ;; Anything else must be the script to debug.
	   (t (setq script-name arg)
	      (setq script-args args))
	   )))
      (list interpreter-args debugger-args script-args annotate-p))))

(defvar bashdb-command-name) ; # To silence Warning: reference to free variable
(defun bashdb-suggest-invocation (debugger-name)
  "Suggest a bashdb command invocation via `dbgr-suggest-invocaton'"
  (dbgr-suggest-invocation bashdb-command-name bashdb-minibuffer-history 
			   "Shell-script" "\\.sh$"))

(defun bashdb-goto-backtrace-line (pt)
  "Display the location mentioned by the zshd backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt-and-type pt "backtrace" dbgr-bashdb-pat-hash))

(defun bashdb-goto-control-frame-line (pt)
  "Display the location mentioned by a control-frame line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt-and-type pt "control-frame" dbgr-bashdb-pat-hash))

(defun bashdb-goto-dollarbang-backtrace-line (pt)
  "Display the location mentioned by a zshd backtrace line
described by PT."
  (interactive "d")
  (dbgr-goto-line-for-pt-and-type pt "dollar-bang" dbgr-bashdb-pat-hash))

(defun bashdb-reset ()
  "Bashdb cleanup - remove debugger's internal buffers (frame,
breakpoints, etc.)."
  (interactive)
  ;; (bashdb-breakpoint-remove-all-icons)
  (dolist (buffer (buffer-list))
    (when (string-match "\\*bashdb-[a-z]+\\*" (buffer-name buffer))
      (let ((w (get-buffer-window buffer)))
        (when w
          (delete-window w)))
      (kill-buffer buffer))))

;; (defun bashdb-reset-keymaps()
;;   "This unbinds the special debugger keys of the source buffers."
;;   (interactive)
;;   (setcdr (assq 'bashdb-debugger-support-minor-mode minor-mode-map-alist)
;; 	  bashdb-debugger-support-minor-mode-map-when-deactive))


(defun bashdb-customize ()
  "Use `customize' to edit the settings of the `bashdb' debugger."
  (interactive)
  (customize-group 'bashdb))

(provide-me "dbgr-bashdb-")
