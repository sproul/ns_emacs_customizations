;;  `remake' Main interface to remake via Emacs
(require 'load-relative)
(require-relative-list '("../../common/helper") "dbgr-")
(require-relative-list '("../../common/track") "dbgr-")
(require-relative-list '("core" "track-mode") "dbgr-remake-")
;; This is needed, or at least the docstring part of it is needed to
;; get the customization menu to work in Emacs 23.
(defgroup remake nil
  "The GNU Make debugger: remake"
  :group 'processes
  :group 'tools
  :version "23.1")

;; -------------------------------------------------------------------
;; User definable variables
;;

(defcustom remake-command-name
  ;;"remake --emacs 3"
  "remake"
  "File name for executing the GNU make debugger, remake, and command options.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'remake)

(declare-function remake-track-mode (bool))

;; -------------------------------------------------------------------
;; The end.
;;

;;;###autoload
;; (defun dbgr-remake (&optional opt-command-line no-reset)
;;   "Invoke the GNU Make debugger, remake and start the Emacs user interface.

;; String COMMAND-LINE specifies how to run remake.

;; Normally command buffers are reused when the same debugger is
;; reinvoked inside a command buffer with a similar command. If we
;; discover that the buffer has prior command-buffer information and
;; NO-RESET is nil, then that information which may point into other
;; buffers and source buffers which may contain marks and fringe or
;; marginal icons is reset."

  
;;   (interactive)
;;   (let* (
;; 	 (cmd-str (or opt-command-line (remake-query-cmdline "remake")))
;; 	 (cmd-args (split-string-and-unquote cmd-str))
;; 	 (parsed-args (remake-parse-cmd-args cmd-args))
;; 	 (script-args (cdr cmd-args))
;; 	 (script-name (car script-args))
;; 	 (cmd-buf))
  
;;     ;; Parse the command line and pick out the script name and whether
;;     ;; --annotate has been set.
  
;;     (condition-case nil
;; 	(setq cmd-buf 
;; 	      (apply 'dbgr-exec-shell "remake" script-name
;; 		     (car cmd-args) no-reset (cdr cmd-args)))
;;     (error nil))
;;     ;; FIXME: Is there probably is a way to remove the
;;     ;; below test and combine in condition-case? 
;;     (let ((process (get-buffer-process cmd-buf)))
;;       (if (and process (eq 'run (process-status process)))
;; 	  (progn
;; 	    (switch-to-buffer cmd-buf)
;; 	    (remake-track-mode 't)
;; 	    (dbgr-cmdbuf-info-cmd-args= dbgr-cmdbuf-info cmd-args)
;; 	    )
;; 	(message "Error running remake command"))
;;     )))

;; (defalias 'remake 'dbgr-remake)

(provide-me "dbgr-")

;;; remake.el ends here
